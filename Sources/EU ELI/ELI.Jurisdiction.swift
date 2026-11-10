public import ISO_3166

extension ELI {

    public enum Jurisdiction: Sendable, Hashable {

        case country(ISO_3166.Alpha2, code: String)

        case organisation(String)
    }
}

extension ELI.Jurisdiction {

    public init(_ code: some StringProtocol) throws(ELI.Error) {
        let text = String(code)
        guard !text.isEmpty, text.utf8.allSatisfy(ELI.isLetter) else {
            throw .invalid(.jurisdiction, text)
        }
        guard text.utf8.count == 2 else {
            self = .organisation(text)
            return
        }
        do throws(ISO_3166.Alpha2.Error) {
            self = .country(try ISO_3166.Alpha2(text), code: text)
        } catch {
            self = .organisation(text)
        }
    }

    public var code: String {
        switch self {
        case .country(_, let code): code
        case .organisation(let code): code
        }
    }
}

extension ELI.Jurisdiction: CustomStringConvertible {

    public var description: String { code }
}
