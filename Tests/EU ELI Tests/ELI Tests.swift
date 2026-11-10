import EU_ELI
import ISO_3166
import ISO_639
import ISO_8601
import RFC_3986
import Testing

enum `ELI Tests` {}

extension `ELI Tests` {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

extension `ELI Tests`.Test.Unit {

    @Test
    func `an EU act in the Official Journal is built from its components and parsed back`() throws {
        let gdpr = try ELI(
            template: .eu(.officialJournal),
            components: ELI.Components(
                date: ISO_8601.CalendarDate.Reduced(year: 2016),
                type: ELI.Component.Value("reg"),
                naturalIdentifier: ELI.Component.Value("679")
            )
        )
        #expect(gdpr.uri.value == "http://data.europa.eu/eli/reg/2016/679/oj")
        let parsed = try ELI(eu: "http://data.europa.eu/eli/reg/2016/679/oj")
        #expect(parsed == gdpr)
        #expect(parsed.components.type?.text == "reg")
        #expect(parsed.components.year == 2016)
        #expect(parsed.components.naturalIdentifier?.text == "679")
    }

    @Test(arguments: [
        "http://data.europa.eu/eli/reg/2016/679/oj",
        "http://data.europa.eu/eli/reg/2016/679/oj/eng",
        "http://data.europa.eu/eli/dir/2000/31/oj/fra/pdf",
        "http://data.europa.eu/eli/dir/2000/31/art_1/par_2/oj",
        "http://data.europa.eu/eli/reg/2019/1241/art_2/oj",
        "http://data.europa.eu/eli/reg/2009/423/corrigendum/2009-05-26/oj",
        "http://data.europa.eu/eli/reg/2000/2814/corrigendum/2001-02-23/1/oj",
        "http://data.europa.eu/eli/reg/2010/185/2013-07-11",
        "http://data.europa.eu/eli/reg/2016/679/2016-05-04/eng/html",
        "http://data.europa.eu/eli/dec_impl/2016/2122/2016-12-09",
        "http://data.europa.eu/eli/dec/2014/445(1)/oj",
        "http://data.europa.eu/eli/treaty/tfeu_2016/art_246/oj",
        "http://data.europa.eu/eli/treaty/acc_2005/pro_1/art_15/sign",
        "http://data.europa.eu/eli/dec/2009/496",
        "http://data.europa.eu/eli/dec/2009/496/fra",
        "http://data.europa.eu/eli/C/2024/5444",
        "http://data.europa.eu/eli/C/2023/236/corrigendum/2023-11-06/oj",
        "http://data.europa.eu/eli/treaty/acc_2003/corrigendum/2004-04-28/4/oj",
        "http://data.europa.eu/eli/treaty/acc_2012/corrigendum/2016-06-07/oj",
        "http://data.europa.eu/eli/treaty/withd_2020/2020-06-13",
    ])
    func `the EU's own ELIs print as they were read`(text: String) throws {
        #expect(try ELI(eu: text).description == text)
    }

    @Test
    func `each EU ELI matches the EUR-Lex template it was written to`() throws {
        #expect(try ELI(eu: "http://data.europa.eu/eli/reg/2016/679/oj").template == .eu(.officialJournal))
        #expect(try ELI(eu: "http://data.europa.eu/eli/reg/2016/679/oj/eng").template == .eu(.officialJournal, .language))
        #expect(
            try ELI(eu: "http://data.europa.eu/eli/dir/2000/31/oj/fra/pdf").template
                == .eu(.officialJournal, .languageAndFormat)
        )
        #expect(
            try ELI(eu: "http://data.europa.eu/eli/reg/2009/423/corrigendum/2009-05-26/oj").template
                == .eu(.corrigendum)
        )
        #expect(
            try ELI(eu: "http://data.europa.eu/eli/reg/2000/2814/corrigendum/2001-02-23/1/oj").template
                == .eu(.corrigendumSequence)
        )
        #expect(try ELI(eu: "http://data.europa.eu/eli/reg/2010/185/2013-07-11").template == .eu(.consolidated))
        #expect(try ELI(eu: "http://data.europa.eu/eli/treaty/tfeu_2016/art_246/oj").template == .eu(.officialJournal, of: .treaty))
        #expect(
            try ELI(eu: "http://data.europa.eu/eli/treaty/acc_2005/pro_1/art_15/sign").template == .eu(.signature, of: .treaty)
        )
        #expect(
            try ELI(eu: "http://data.europa.eu/eli/treaty/acc_2003/corrigendum/2004-04-28/4/oj").template
                == .eu(.corrigendumSequence, of: .treaty)
        )
        #expect(try ELI(eu: "http://data.europa.eu/eli/treaty/withd_2020/2020-06-13").template == .eu(.consolidated, of: .treaty))
        #expect(try ELI(eu: "http://data.europa.eu/eli/dec/2009/496").template == .eu(.abstract))
        #expect(try ELI(eu: "http://data.europa.eu/eli/dec/2009/496/art_1").template == .eu(.abstract))
        #expect(try ELI(eu: "http://data.europa.eu/eli/dec/2009/496/fra").template == .eu(.abstract, .language))
    }

    @Test
    func `the components carry their typed values`() throws {
        let consolidated = try ELI(eu: "http://data.europa.eu/eli/reg/2016/679/2016-05-04/eng/html")
        #expect(consolidated.components.pointInTime == (try ISO_8601.CalendarDate(year: 2016, month: 5, day: 4)))
        #expect(consolidated.components.language?.iso639.alpha3 == .eng)
        #expect(consolidated.components.format?.text == "html")
        let corrigendum = try ELI(eu: "http://data.europa.eu/eli/reg/2000/2814/corrigendum/2001-02-23/1/oj")
        #expect(corrigendum.components.publicationDate == (try ISO_8601.CalendarDate(year: 2001, month: 2, day: 23)))
        #expect(corrigendum.components.sequence?.text == "1")
        let article = try ELI(eu: "http://data.europa.eu/eli/dir/2000/31/art_1/par_2/oj")
        #expect(article.components.subdivisions.map(\.text) == ["art_1", "par_2"])
        let treaty = try ELI(eu: "http://data.europa.eu/eli/treaty/tfeu_2016/art_246/oj")
        #expect(treaty.components.naturalIdentifier?.text == "tfeu_2016")
        #expect(treaty.components.type == nil)
    }

    @Test
    func `a template is the RFC 6570 template the conclusions describe`() {
        #expect(
            ELI.Template.eu(.officialJournal).description
                == "http://data.europa.eu/eli/{+type}/{+year}/{+natural_identifier}{/subdivision*}/oj"
        )
        #expect(
            ELI.Template.eu(.consolidated, .language).description
                == "http://data.europa.eu/eli/{+type}/{+year}/{+natural_identifier}{/subdivision*}/{+point_in_time}/{+language}"
        )
    }

    @Test
    func `a national template reads and prints its own components`() throws {
        let template = try ELI.Template(
            base: RFC_3986.URI("http://legilux.public.lu/eli"),
            segments: [
                .component(.agent), .component(.subagent), .component(.type), .component(.year), .component(.month),
                .component(.day), .component(.naturalIdentifier), .component(.version),
            ]
        )
        let law = try ELI(RFC_3986.URI("http://legilux.public.lu/eli/etat/leg/loi/2016/12/23/a1/jo"), template: template)
        #expect(law.components.type?.text == "loi")
        #expect(law.components.year == 2016)
        #expect(law.components.month == 12)
        #expect(law.components.day == 23)
        #expect(law.components.naturalIdentifier?.text == "a1")
        #expect(law.components.version?.text == "jo")
        #expect(law.description == "http://legilux.public.lu/eli/etat/leg/loi/2016/12/23/a1/jo")
    }

    @Test
    func `a jurisdiction is an ISO 3166 code or an organisation's name, and a point in time is YYYYMMDD by default`() throws {
        let template = try ELI.Template(
            base: RFC_3986.URI("https://example.org/eli"),
            segments: [.component(.jurisdiction), .component(.type), .component(.naturalIdentifier), .component(.pointInTime), .component(.language)]
        )
        let act = try ELI(RFC_3986.URI("https://example.org/eli/LU/loi/a1/20170101/en"), template: template)
        #expect(act.components.jurisdiction == .country(.lu, code: "LU"))
        #expect(act.components.pointInTime == (try ISO_8601.CalendarDate(year: 2017, month: 1, day: 1)))
        #expect(act.components.language?.iso639.alpha2 == .en)
        #expect(act.description == "https://example.org/eli/LU/loi/a1/20170101/en")
        #expect(try ELI.Jurisdiction("WTO") == .organisation("WTO"))
    }
}

extension `ELI Tests`.Test.`Edge Case` {

    @Test
    func `components must match the template exactly`() {
        #expect(throws: ELI.Error.missing(.naturalIdentifier)) {
            try ELI(
                template: .eu(.officialJournal),
                components: ELI.Components(date: ISO_8601.CalendarDate.Reduced(year: 2016), type: ELI.Component.Value("reg"))
            )
        }
        #expect(throws: ELI.Error.unexpected(.language)) {
            try ELI(
                template: .eu(.officialJournal),
                components: ELI.Components(
                    date: ISO_8601.CalendarDate.Reduced(year: 2016),
                    type: ELI.Component.Value("reg"),
                    naturalIdentifier: ELI.Component.Value("679"),
                    language: ELI.Language("eng")
                )
            )
        }
    }

    @Test
    func `a component value is unreserved characters, with parentheses only in the natural identifier`() throws {
        #expect(throws: ELI.Component.Value.Error.invalid("re/g")) { try ELI.Component.Value("re/g") }
        #expect(throws: ELI.Component.Value.Error.invalid("")) { try ELI.Component.Value("") }
        #expect(throws: ELI.Component.Value.Error.invalid("6 79")) { try ELI.Component.Value("6 79") }
        #expect(throws: ELI.Error.invalid(.type, "re(g)")) { try ELI.Components(type: ELI.Component.Value("re(g)")) }
        #expect(throws: ELI.Error.invalid(.subdivision, "art(1)")) {
            try ELI.Components(subdivisions: [ELI.Component.Value("art(1)")])
        }
        #expect(throws: ELI.Error.invalid(.sequence, "0")) { try ELI.Components(sequence: ELI.Component.Value("0")) }
        #expect(try ELI.Components(naturalIdentifier: ELI.Component.Value("445(1)")).naturalIdentifier?.text == "445(1)")
    }

    @Test
    func `year, month and day are one date, which the calendar must have`() throws {
        let template = try ELI.Template(
            base: RFC_3986.URI("http://legilux.public.lu/eli"),
            segments: [.component(.type), .component(.year), .component(.month), .component(.day), .component(.naturalIdentifier)]
        )
        #expect(throws: ELI.Error.invalid(.month, "13")) {
            try ELI(RFC_3986.URI("http://legilux.public.lu/eli/loi/2016/13/23/a1"), template: template)
        }
        #expect(throws: ELI.Error.invalid(.day, "30")) {
            try ELI(RFC_3986.URI("http://legilux.public.lu/eli/loi/2016/02/30/a1"), template: template)
        }
        #expect(throws: ELI.Error.invalid(.day, "7")) {
            try ELI(RFC_3986.URI("http://legilux.public.lu/eli/loi/2016/10/7/a1"), template: template)
        }
        #expect(throws: ELI.Error.missing(.month)) {
            try ELI.Template(base: RFC_3986.URI("http://legilux.public.lu/eli"), segments: [.component(.year), .component(.day)])
        }
        #expect(throws: ELI.Error.unexpected(.month)) {
            try ELI(
                template: .eu(.abstract),
                components: ELI.Components(
                    date: ISO_8601.CalendarDate.Reduced(year: 2016, month: 5),
                    type: ELI.Component.Value("reg"),
                    naturalIdentifier: ELI.Component.Value("679")
                )
            )
        }
    }

    @Test
    func `a URI that fits none of the EU's templates is refused`() {
        #expect(throws: ELI.Error.notEU("http://data.europa.eu/eli/reg/16/679/oj")) {
            try ELI(eu: "http://data.europa.eu/eli/reg/16/679/oj")
        }
        #expect(throws: ELI.Error.notEU("http://data.europa.eu/eli/reg/2016/679/2016-02-30")) {
            try ELI(eu: "http://data.europa.eu/eli/reg/2016/679/2016-02-30")
        }
        #expect(throws: ELI.Error.notEU("https://eur-lex.europa.eu/eli/reg/2016/679/oj")) {
            try ELI(eu: "https://eur-lex.europa.eu/eli/reg/2016/679/oj")
        }
        #expect(throws: ELI.Error.notEU("http://data.europa.eu/eli/reg")) { try ELI(eu: "http://data.europa.eu/eli/reg") }
        #expect(throws: ELI.Error.notEU("http://data.europa.eu/eli/reg/2016/679/article6/oj")) {
            try ELI(eu: "http://data.europa.eu/eli/reg/2016/679/article6/oj")
        }
        #expect(throws: ELI.Error.notEU("http://data.europa.eu/eli/REG/2016/679/oj")) {
            try ELI(eu: "http://data.europa.eu/eli/REG/2016/679/oj")
        }
    }

    @Test
    func `parsing against a template refuses another base, a wrong literal and a wrong count`() throws {
        let template = ELI.Template.eu(.officialJournal)
        #expect(throws: ELI.Error.base("http://example.org/eli/reg/2016/679/oj")) {
            try ELI(RFC_3986.URI("http://example.org/eli/reg/2016/679/oj"), template: template)
        }
        #expect(throws: ELI.Error.literal(expected: "oj", found: "eng")) {
            try ELI(RFC_3986.URI("http://data.europa.eu/eli/reg/2016/679/eng"), template: template)
        }
        #expect(throws: ELI.Error.segmentCount(3)) {
            try ELI(RFC_3986.URI("http://data.europa.eu/eli/reg/2016/oj"), template: template)
        }
        #expect(throws: ELI.Error.invalid(.language, "xyz")) {
            try ELI(RFC_3986.URI("http://data.europa.eu/eli/reg/2016/679/oj/xyz"), template: .eu(.officialJournal, .language))
        }
    }

    @Test
    func `a template base is an absolute URI without a trailing slash, and names each component once`() throws {
        #expect(throws: ELI.Error.base("http://example.org/eli/")) {
            try ELI.Template(base: RFC_3986.URI("http://example.org/eli/"), segments: [])
        }
        #expect(throws: ELI.Error.template("year")) {
            try ELI.Template(base: RFC_3986.URI("http://example.org/eli"), segments: [.component(.year), .component(.year)])
        }
    }
}
