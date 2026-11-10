public import RFC_3986

extension ELI {

    public enum EU {}
}

extension ELI.EU {

    public static let base = RFC_3986.URI(unchecked: "http://data.europa.eu/eli")
}

extension ELI.EU.Work {

    internal var segments: [ELI.Template.Segment] {
        switch self {
        case .act:
            [.component(.type), .component(.year), .component(.naturalIdentifier), .subdivisions]

        case .treaty:
            [.literal("treaty"), .component(.naturalIdentifier), .subdivisions]
        }
    }

    internal var versions: [ELI.EU.Version] {
        switch self {
        case .act: ELI.EU.Version.allCases.filter { $0 != .signature }
        case .treaty: ELI.EU.Version.allCases
        }
    }
}

extension ELI.EU.Version {

    internal var segments: [ELI.Template.Segment] {
        switch self {
        case .corrigendumSequence:
            [.literal("corrigendum"), .component(.publicationDate), .component(.sequence), .literal("oj")]

        case .corrigendum:
            [.literal("corrigendum"), .component(.publicationDate), .literal("oj")]

        case .officialJournal:
            [.literal("oj")]

        case .signature:
            [.literal("sign")]

        case .consolidated:
            [.component(.pointInTime)]

        case .abstract:
            []
        }
    }
}

extension ELI.EU.Expression {

    internal var segments: [ELI.Template.Segment] {
        switch self {
        case .work: []
        case .language: [.component(.language)]
        case .languageAndFormat: [.component(.language), .component(.format)]
        }
    }
}

extension ELI.Template {

    public static func eu(
        _ version: ELI.EU.Version,
        _ expression: ELI.EU.Expression = .work,
        of work: ELI.EU.Work = .act
    ) -> ELI.Template {
        ELI.Template(
            unchecked: ELI.EU.base,
            segments: work.segments + version.segments + expression.segments,
            dates: .extended
        )
    }
}

extension ELI.EU {

    public static let templates: [ELI.Template] = Work.allCases.flatMap { work in
        work.versions.flatMap { version in
            Expression.allCases.reversed().map { expression in ELI.Template.eu(version, expression, of: work) }
        }
    }
}

extension ELI {

    public init(eu uri: RFC_3986.URI) throws(ELI.Error) {
        guard let eli = ELI.EU.match(uri) else {
            throw .notEU(uri.value)
        }
        self = eli
    }

    public init(eu text: some StringProtocol) throws(ELI.Error) {
        let uri: RFC_3986.URI
        do throws(RFC_3986.Error) {
            uri = try RFC_3986.URI(text)
        } catch {
            throw .notEU(String(text))
        }
        try self.init(eu: uri)
    }
}

extension ELI.EU {

    internal static func match(_ uri: RFC_3986.URI) -> ELI? {
        for template in templates {
            do throws(ELI.Error) {
                let eli = try ELI(uri, template: template)
                if eli.components.type.map(isType) ?? true, eli.components.subdivisions.allSatisfy(isSubdivision) {
                    return eli
                }
            } catch {
                continue
            }
        }
        return nil
    }

    internal static func isSubdivision(_ value: ELI.Component.Value) -> Bool {
        let parts = value.text.split(separator: "_", maxSplits: 1, omittingEmptySubsequences: false)
        return parts.count == 2 && !parts[0].isEmpty && !parts[1].isEmpty
            && parts[0].utf8.allSatisfy { (UInt8(ascii: "a")...UInt8(ascii: "z")).contains($0) }
    }

    internal static func isType(_ value: ELI.Component.Value) -> Bool {
        value.text == "C"
            || value.text.utf8.allSatisfy { (UInt8(ascii: "a")...UInt8(ascii: "z")).contains($0) || $0 == UInt8(ascii: "_") }
    }
}
