public import ISO_8601

extension ELI {

    public struct Components: Sendable, Hashable {

        public let jurisdiction: ELI.Jurisdiction?

        public let agent: ELI.Component.Value?

        public let subagent: ELI.Component.Value?

        public let date: ISO_8601.CalendarDate.Reduced?

        public let type: ELI.Component.Value?

        public let subtype: ELI.Component.Value?

        public let domain: ELI.Component.Value?

        public let naturalIdentifier: ELI.Component.Value?

        public let subdivisions: [ELI.Component.Value]

        public let pointInTime: ISO_8601.CalendarDate?

        public let version: ELI.Component.Value?

        public let language: ELI.Language?

        public let format: ELI.Component.Value?

        public let publicationDate: ISO_8601.CalendarDate?

        public let sequence: ELI.Component.Value?

        public init(
            jurisdiction: ELI.Jurisdiction? = nil,
            agent: ELI.Component.Value? = nil,
            subagent: ELI.Component.Value? = nil,
            date: ISO_8601.CalendarDate.Reduced? = nil,
            type: ELI.Component.Value? = nil,
            subtype: ELI.Component.Value? = nil,
            domain: ELI.Component.Value? = nil,
            naturalIdentifier: ELI.Component.Value? = nil,
            subdivisions: [ELI.Component.Value] = [],
            pointInTime: ISO_8601.CalendarDate? = nil,
            version: ELI.Component.Value? = nil,
            language: ELI.Language? = nil,
            format: ELI.Component.Value? = nil,
            publicationDate: ISO_8601.CalendarDate? = nil,
            sequence: ELI.Component.Value? = nil
        ) throws(ELI.Error) {
            let values: [(ELI.Component.Name, ELI.Component.Value?)] = [
                (.agent, agent), (.subagent, subagent), (.type, type), (.subtype, subtype), (.domain, domain),
                (.version, version), (.format, format),
            ]
            for case (let name, let value?) in values where value.hasParentheses {
                throw .invalid(name, value.text)
            }
            for subdivision in subdivisions where subdivision.hasParentheses {
                throw .invalid(.subdivision, subdivision.text)
            }
            if let sequence, !sequence.text.utf8.allSatisfy(ELI.isDigit) || sequence.text.utf8.allSatisfy({ $0 == UInt8(ascii: "0") }) {
                throw .invalid(.sequence, sequence.text)
            }
            self.jurisdiction = jurisdiction
            self.agent = agent
            self.subagent = subagent
            self.date = date
            self.type = type
            self.subtype = subtype
            self.domain = domain
            self.naturalIdentifier = naturalIdentifier
            self.subdivisions = subdivisions
            self.pointInTime = pointInTime
            self.version = version
            self.language = language
            self.format = format
            self.publicationDate = publicationDate
            self.sequence = sequence
        }
    }
}

extension ELI.Components {

    public var year: Int? { date?.year }

    public var month: Int? { date?.month }

    public var day: Int? { date?.day }
}

extension ELI.Components {

    internal func has(_ name: ELI.Component.Name) -> Bool {
        text(name, dates: .basic) != nil || (name == .subdivision && !subdivisions.isEmpty)
    }

    internal func text(_ name: ELI.Component.Name, dates: ELI.Template.Dates) -> String? {
        switch name {
        case .jurisdiction: jurisdiction?.code
        case .agent: agent?.text
        case .subagent: subagent?.text
        case .year: date.map { ELI.digits($0.year, count: 4) }
        case .month: date?.month.map { ELI.digits($0, count: 2) }
        case .day: date?.day.map { ELI.digits($0, count: 2) }
        case .type: type?.text
        case .subtype: subtype?.text
        case .domain: domain?.text
        case .naturalIdentifier: naturalIdentifier?.text
        case .subdivision: nil
        case .pointInTime: pointInTime.map { dates == .extended ? $0.extended : $0.basic }
        case .version: version?.text
        case .language: language?.code
        case .format: format?.text
        case .publicationDate: publicationDate.map { dates == .extended ? $0.extended : $0.basic }
        case .sequence: sequence?.text
        }
    }
}
