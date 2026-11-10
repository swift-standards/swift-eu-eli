extension ELI {

    internal static func isLetter(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "A")...UInt8(ascii: "Z")).contains(byte) || (UInt8(ascii: "a")...UInt8(ascii: "z")).contains(byte)
    }

    internal static func isDigit(_ byte: UInt8) -> Bool {
        (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(byte)
    }

    internal static func isUnreserved(_ byte: UInt8) -> Bool {
        isLetter(byte) || isDigit(byte) || byte == UInt8(ascii: "-") || byte == UInt8(ascii: ".")
            || byte == UInt8(ascii: "_") || byte == UInt8(ascii: "~")
    }

    internal static func isToken(_ text: some StringProtocol, parentheses: Bool) -> Bool {
        !text.isEmpty
            && text.utf8.allSatisfy {
                isUnreserved($0) || (parentheses && ($0 == UInt8(ascii: "(") || $0 == UInt8(ascii: ")")))
            }
    }

    internal static func digits(_ value: Int, count: Int) -> String {
        let text = String(value)
        return String(repeating: "0", count: max(0, count - text.count)) + text
    }
}
