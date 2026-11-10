extension ELI.Template {

    public enum Segment: Sendable, Hashable {

        case literal(String)

        case component(ELI.Component.Name)

        case subdivisions
    }
}
