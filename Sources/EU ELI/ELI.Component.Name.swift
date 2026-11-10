extension ELI.Component {

    public enum Name: Sendable, Hashable, CaseIterable {

        case jurisdiction

        case agent

        case subagent

        case year

        case month

        case day

        case type

        case subtype

        case domain

        case naturalIdentifier

        case subdivision

        case pointInTime

        case version

        case language

        case format

        case publicationDate

        case sequence
    }
}

extension ELI.Component.Name {

    public var variable: String {
        switch self {
        case .jurisdiction: "jurisdiction"
        case .agent: "agent"
        case .subagent: "sub_agent"
        case .year: "year"
        case .month: "month"
        case .day: "day"
        case .type: "type"
        case .subtype: "sub_type"
        case .domain: "domain"
        case .naturalIdentifier: "natural_identifier"
        case .subdivision: "subdivision"
        case .pointInTime: "point_in_time"
        case .version: "version"
        case .language: "language"
        case .format: "format"
        case .publicationDate: "publication_date"
        case .sequence: "sequence"
        }
    }
}
