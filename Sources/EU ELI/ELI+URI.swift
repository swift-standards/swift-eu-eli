import ISO_8601
public import RFC_3986
import RFC_6570

extension ELI {

    public var uri: RFC_3986.URI {
        var variables: [String: RFC_6570.Variable] = [:]
        for name in template.names {
            if let text = components.text(name, dates: template.dates) {
                variables[name.variable] = .string(text)
            }
        }
        if template.hasSubdivisions {
            variables[ELI.Component.Name.subdivision.variable] = .list(components.subdivisions.map(\.text))
        }
        return template.uriTemplate.expand(variables: variables)
    }
}

extension ELI: CustomStringConvertible {

    public var description: String { uri.value }
}

extension ELI {

    public init(_ uri: RFC_3986.URI, template: ELI.Template) throws(ELI.Error) {
        let baseSegments = template.base.path?.segments.filter { !$0.isEmpty } ?? []
        guard uri.scheme == template.base.scheme, uri.host == template.base.host, uri.port == template.base.port,
            uri.query == nil, uri.fragment == nil
        else {
            throw .base(uri.value)
        }
        let path = uri.path?.segments ?? []
        let segments = path.first?.isEmpty == true ? Array(path.dropFirst()) : path
        guard segments.starts(with: baseSegments) else {
            throw .base(uri.value)
        }
        let rest = Array(segments.dropFirst(baseSegments.count))
        let fixed = template.segments.count - (template.hasSubdivisions ? 1 : 0)
        guard template.hasSubdivisions ? rest.count >= fixed : rest.count == fixed else {
            throw .segmentCount(rest.count)
        }
        let subdivisionCount = rest.count - fixed
        var values: [ELI.Component.Name: String] = [:]
        var subdivisions: [String] = []
        var index = 0
        for segment in template.segments {
            switch segment {
            case .literal(let literal):
                guard rest[index] == literal else {
                    throw .literal(expected: literal, found: rest[index])
                }
                index += 1

            case .component(let name):
                values[name] = rest[index]
                index += 1

            case .subdivisions:
                subdivisions = Array(rest[index..<(index + subdivisionCount)])
                index += subdivisionCount
            }
        }
        let components = try ELI.Components.parse(values, subdivisions: subdivisions, dates: template.dates)
        try self.init(template: template, components: components)
    }
}

extension ELI.Components {

    internal static func parse(
        _ values: [ELI.Component.Name: String],
        subdivisions: [String],
        dates: ELI.Template.Dates
    ) throws(ELI.Error) -> ELI.Components {
        try ELI.Components(
            jurisdiction: try jurisdiction(values[.jurisdiction]),
            agent: try value(values[.agent], .agent),
            subagent: try value(values[.subagent], .subagent),
            date: try date(year: values[.year], month: values[.month], day: values[.day]),
            type: try value(values[.type], .type),
            subtype: try value(values[.subtype], .subtype),
            domain: try value(values[.domain], .domain),
            naturalIdentifier: try value(values[.naturalIdentifier], .naturalIdentifier),
            subdivisions: try subdivisions.map { (text: String) throws(ELI.Error) -> ELI.Component.Value in
                guard let value = try value(text, .subdivision) else { throw .invalid(.subdivision, text) }
                return value
            },
            pointInTime: try date(values[.pointInTime], .pointInTime, dates: dates),
            version: try value(values[.version], .version),
            language: try language(values[.language]),
            format: try value(values[.format], .format),
            publicationDate: try date(values[.publicationDate], .publicationDate, dates: dates),
            sequence: try value(values[.sequence], .sequence)
        )
    }

    private static func value(_ text: String?, _ name: ELI.Component.Name) throws(ELI.Error) -> ELI.Component.Value? {
        guard let text else { return nil }
        do throws(ELI.Component.Value.Error) {
            return try ELI.Component.Value(text)
        } catch {
            throw .invalid(name, text)
        }
    }

    private static func jurisdiction(_ text: String?) throws(ELI.Error) -> ELI.Jurisdiction? {
        guard let text else { return nil }
        return try ELI.Jurisdiction(text)
    }

    private static func date(year: String?, month: String?, day: String?) throws(ELI.Error) -> ISO_8601.CalendarDate.Reduced? {
        guard let year else { return nil }
        let yearNumber = try number(year, .year, digits: 4)
        let monthNumber = try month.map { (text: String) throws(ELI.Error) -> Int in try number(text, .month, digits: 2) }
        let dayNumber = try day.map { (text: String) throws(ELI.Error) -> Int in try number(text, .day, digits: 2) }
        do throws(ISO_8601.CalendarDate.Error) {
            return try ISO_8601.CalendarDate.Reduced(year: yearNumber, month: monthNumber, day: dayNumber)
        } catch {
            switch error {
            case .monthOutOfRange: throw .invalid(.month, month ?? "")
            case .dayOutOfRange: throw .invalid(.day, day ?? "")
            default: throw .invalid(.year, year)
            }
        }
    }

    private static func number(_ text: String, _ name: ELI.Component.Name, digits: Int) throws(ELI.Error) -> Int {
        guard text.utf8.count == digits, text.utf8.allSatisfy(ELI.isDigit), let value = Int(text) else {
            throw .invalid(name, text)
        }
        return value
    }

    private static func date(
        _ text: String?,
        _ name: ELI.Component.Name,
        dates: ELI.Template.Dates
    ) throws(ELI.Error) -> ISO_8601.CalendarDate? {
        guard let text else { return nil }
        let date =
            switch dates {
            case .basic: ISO_8601.CalendarDate(basic: text)
            case .extended: ISO_8601.CalendarDate(extended: text)
            }
        guard let date else {
            throw .invalid(name, text)
        }
        return date
    }

    private static func language(_ text: String?) throws(ELI.Error) -> ELI.Language? {
        guard let text else { return nil }
        return try ELI.Language(text)
    }
}
