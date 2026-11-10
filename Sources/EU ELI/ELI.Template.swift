public import RFC_3986
public import RFC_6570

extension ELI {

    public struct Template: Sendable, Hashable {

        public let base: RFC_3986.URI

        public let segments: [ELI.Template.Segment]

        public let dates: ELI.Template.Dates

        public let uriTemplate: RFC_6570.Template

        public init(
            base: RFC_3986.URI,
            segments: [ELI.Template.Segment],
            dates: ELI.Template.Dates = .basic
        ) throws(ELI.Error) {
            guard base.scheme != nil, base.host != nil, base.query == nil, base.fragment == nil,
                !base.value.hasSuffix("/")
            else {
                throw .base(base.value)
            }
            var names: Set<ELI.Component.Name> = []
            for segment in segments {
                switch segment {
                case .literal(let literal):
                    guard ELI.isToken(literal, parentheses: false) else {
                        throw .template(literal)
                    }

                case .component(let name):
                    guard name != .subdivision, names.insert(name).inserted else {
                        throw .template(name.variable)
                    }

                case .subdivisions:
                    guard names.insert(.subdivision).inserted else {
                        throw .template(ELI.Component.Name.subdivision.variable)
                    }
                }
            }
            for (name, requirement) in [(ELI.Component.Name.month, ELI.Component.Name.year), (.day, .month)]
            where names.contains(name) && !names.contains(requirement) {
                throw .missing(requirement)
            }
            var text = base.value
            for segment in segments {
                switch segment {
                case .literal(let literal):
                    text += "/" + literal

                case .component(let name):
                    text += "/{+" + name.variable + "}"

                case .subdivisions:
                    text += "{/" + ELI.Component.Name.subdivision.variable + "*}"
                }
            }
            do throws(RFC_6570.Error) {
                self.uriTemplate = try RFC_6570.Template(text)
            } catch {
                throw .template(text)
            }
            self.base = base
            self.segments = segments
            self.dates = dates
        }
    }
}

extension ELI.Template {

    internal init(unchecked base: RFC_3986.URI, segments: [ELI.Template.Segment], dates: ELI.Template.Dates) {
        do throws(ELI.Error) {
            self = try ELI.Template(base: base, segments: segments, dates: dates)
        } catch {
            preconditionFailure("the EU's templates are well-formed")
        }
    }
}

extension ELI.Template {

    internal var names: [ELI.Component.Name] {
        segments.compactMap {
            if case .component(let name) = $0 { name } else { nil }
        }
    }

    internal var hasSubdivisions: Bool {
        segments.contains(.subdivisions)
    }
}

extension ELI.Template: CustomStringConvertible {

    public var description: String { uriTemplate.value }
}
