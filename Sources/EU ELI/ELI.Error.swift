extension ELI {

    public enum Error: Swift::Error, Sendable, Equatable {

        case missing(ELI.Component.Name)

        case unexpected(ELI.Component.Name)

        case invalid(ELI.Component.Name, String)

        case base(String)

        case segmentCount(Int)

        case literal(expected: String, found: String)

        case template(String)

        case notEU(String)
    }
}
