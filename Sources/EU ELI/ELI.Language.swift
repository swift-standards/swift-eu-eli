public import ISO_639

extension ELI {

    public struct Language: Sendable, Hashable {

        public let code: String

        public let iso639: ISO_639.LanguageCode

        public init(_ code: some StringProtocol) throws(ELI.Error) {
            let text = String(code)
            guard text.utf8.allSatisfy({ (UInt8(ascii: "a")...UInt8(ascii: "z")).contains($0) }) else {
                throw .invalid(.language, text)
            }
            do throws(ISO_639.Error) {
                self.iso639 = try ISO_639.LanguageCode(text)
            } catch {
                throw .invalid(.language, text)
            }
            self.code = text
        }
    }
}

extension ELI.Language: CustomStringConvertible {

    public var description: String { code }
}
