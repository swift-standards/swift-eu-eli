extension ELI.Component {

    public struct Value: Sendable, Hashable {

        public let text: String

        public init(_ text: some StringProtocol) throws(ELI.Component.Value.Error) {
            let string = String(text)
            guard ELI.isToken(string, parentheses: true) else {
                throw .invalid(string)
            }
            self.text = string
        }
    }
}

extension ELI.Component.Value {

    internal var hasParentheses: Bool {
        text.utf8.contains { $0 == UInt8(ascii: "(") || $0 == UInt8(ascii: ")") }
    }
}

extension ELI.Component.Value: CustomStringConvertible {

    public var description: String { text }
}
