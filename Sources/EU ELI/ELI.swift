public struct ELI: Sendable, Hashable {

    public let template: ELI.Template

    public let components: ELI.Components

    public init(template: ELI.Template, components: ELI.Components) throws(ELI.Error) {
        let named = Set(template.names)
        for name in ELI.Component.Name.allCases where name != .subdivision {
            let present = components.has(name)
            if named.contains(name), !present {
                throw .missing(name)
            }
            if !named.contains(name), present {
                throw .unexpected(name)
            }
        }
        if !template.hasSubdivisions, !components.subdivisions.isEmpty {
            throw .unexpected(.subdivision)
        }
        self.template = template
        self.components = components
    }
}
