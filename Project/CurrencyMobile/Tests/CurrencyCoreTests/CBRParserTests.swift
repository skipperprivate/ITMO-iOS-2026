//
//  CBRParserTests.swift
//  Разбор ответов ЦБ, кодировка, числа, даты.
//
//  Образцы XML — укороченные фрагменты реальных ответов сервиса
//  (18.11.2026). Сеть в тестах не используется.
//

import XCTest
@testable import CurrencyCore

final class CBRParserTests: XCTestCase {

    //  MARK: - Образцы

    /// Курсы на день. Драм включён намеренно: у него номинал 100.
    let дневной = """
    <?xml version="1.0" encoding="windows-1251"?>
    <ValCurs Date="18.11.2026" name="Foreign Currency Market">
      <Valute ID="R01060">
        <NumCode>051</NumCode>
        <CharCode>AMD</CharCode>
        <Nominal>100</Nominal>
        <Name>Армянских драмов</Name>
        <Value>21,0824</Value>
        <VunitRate>0,210824</VunitRate>
      </Valute>
      <Valute ID="R01235">
        <NumCode>840</NumCode>
        <CharCode>USD</CharCode>
        <Nominal>1</Nominal>
        <Name>Доллар США</Name>
        <Value>80,9734</Value>
        <VunitRate>80,9734</VunitRate>
      </Valute>
      <Valute ID="R01239">
        <NumCode>978</NumCode>
        <CharCode>EUR</CharCode>
        <Nominal>1</Nominal>
        <Name>Евро</Name>
        <Value>93,6195</Value>
        <VunitRate>93,6195</VunitRate>
      </Valute>
    </ValCurs>
    """

    let история = """
    <?xml version="1.0" encoding="windows-1251"?>
    <ValCurs ID="R01235" DateRange1="01.11.2026" DateRange2="18.11.2026"
             name="Foreign Currency Market Dynamic">
      <Record Date="05.11.2026" Id="R01235">
        <Nominal>1</Nominal><Value>81,1002</Value>
        <VunitRate>81,1002</VunitRate>
      </Record>
      <Record Date="03.11.2026" Id="R01235">
        <Nominal>1</Nominal><Value>80,9734</Value>
        <VunitRate>80,9734</VunitRate>
      </Record>
    </ValCurs>
    """

    //  MARK: - Курсы на день

    func testРазборДневногоСписка() throws {
        let список = try CBRParser.rates(fromXML: дневной)
        XCTAssertEqual(список.count, 3)
        //  Сортировка по буквенному коду, а не по порядку в ответе.
        XCTAssertEqual(список.map(\.code), ["AMD", "EUR", "USD"])
    }

    func testПоляДоллара() throws {
        let usd = try XCTUnwrap(
            CBRParser.rates(fromXML: дневной).first { $0.code == "USD" })
        XCTAssertEqual(usd.id, "R01235")
        XCTAssertEqual(usd.name, "Доллар США")
        XCTAssertEqual(usd.nominal, 1)
        XCTAssertEqual(usd.value, Decimal(string: "80.9734"))
        XCTAssertEqual(DateBits.forPerson(usd.date), "18.11.2026")
    }

    /// Без учёта номинала курс драма был бы завышен в сто раз.
    func testНоминалУчтён() throws {
        let amd = try XCTUnwrap(
            CBRParser.rates(fromXML: дневной).first { $0.code == "AMD" })
        XCTAssertEqual(amd.nominal, 100)
        XCTAssertEqual(amd.value, Decimal(string: "21.0824"))
        XCTAssertEqual(amd.perUnit, Decimal(string: "0.210824"))
    }

    func testБитаяВалютаНеРушитВесьСписок() throws {
        let испорченный = дневной.replacingOccurrences(
            of: "<Value>93,6195</Value>", with: "<Value>—</Value>")
        let список = try CBRParser.rates(fromXML: испорченный)
        XCTAssertEqual(список.map(\.code), ["AMD", "USD"])
    }

    func testНулевойНоминалПропускается() throws {
        //  Иначе при расчёте perUnit было бы деление на ноль.
        let испорченный = дневной.replacingOccurrences(
            of: "<Nominal>100</Nominal>", with: "<Nominal>0</Nominal>")
        let список = try CBRParser.rates(fromXML: испорченный)
        XCTAssertFalse(список.contains { $0.code == "AMD" })
    }

    func testЧужойКореньЭтоОшибка() {
        let чужое = "<html><body>Ошибка 500</body></html>"
        XCTAssertThrowsError(try CBRParser.rates(fromXML: чужое)) { e in
            XCTAssertEqual(e as? CBRParseError, .notValCurs("html"))
        }
    }

    func testБезДатыЭтоОшибка() {
        let безДаты = "<ValCurs><Valute ID=\"R01235\"/></ValCurs>"
        XCTAssertThrowsError(try CBRParser.rates(fromXML: безДаты)) { e in
            XCTAssertEqual(e as? CBRParseError, .noDate(""))
        }
    }

    func testПустойСписокЭтоОшибка() {
        let пусто = "<ValCurs Date=\"18.11.2026\"></ValCurs>"
        XCTAssertThrowsError(try CBRParser.rates(fromXML: пусто)) { e in
            XCTAssertEqual(e as? CBRParseError, .emptyList)
        }
    }

    //  MARK: - История

    func testРазборИстории() throws {
        let точки = try CBRParser.history(fromXML: история)
        XCTAssertEqual(точки.count, 2)
        //  В ответе записи шли 05, затем 03 — результат должен быть
        //  упорядочен по возрастанию.
        XCTAssertEqual(точки.map { DateBits.forPerson($0.date) },
                       ["03.11.2026", "05.11.2026"])
        XCTAssertEqual(точки[0].perUnit, Decimal(string: "80.9734"))
    }

    func testИсторияДелитсяНаНоминал() throws {
        let сотней = история.replacingOccurrences(
            of: "<Nominal>1</Nominal>", with: "<Nominal>100</Nominal>")
        let точки = try CBRParser.history(fromXML: сотней)
        XCTAssertEqual(точки[0].perUnit, Decimal(string: "0.809734"))
    }

    func testПустаяИсторияНеОшибка() throws {
        //  Период целиком из выходных — нормальный ответ.
        let пусто = "<ValCurs ID=\"R01235\"></ValCurs>"
        XCTAssertEqual(try CBRParser.history(fromXML: пусто).count, 0)
    }

    //  MARK: - Числа

    func testЗапятаяКакРазделитель() {
        XCTAssertEqual(CBRParser.number("80,9734"),
                       Decimal(string: "80.9734"))
    }

    func testТочкаТожеПонимается() {
        XCTAssertEqual(CBRParser.number("80.9734"),
                       Decimal(string: "80.9734"))
    }

    func testЦелоеЧисло() {
        XCTAssertEqual(CBRParser.number("100"), Decimal(100))
    }

    func testОтрицательное() {
        XCTAssertEqual(CBRParser.number("-0,5"),
                       Decimal(string: "-0.5"))
    }

    func testПробелыМеждуТысячами() {
        XCTAssertEqual(CBRParser.number("1 234,5"),
                       Decimal(string: "1234.5"))
    }

    func testМусорНеЧисло() {
        XCTAssertNil(CBRParser.number("—"))
        XCTAssertNil(CBRParser.number("80,97,34"))
        XCTAssertNil(CBRParser.number(""))
        XCTAssertNil(CBRParser.number("8a0"))
    }

    /// Обоснование выбора Decimal вместо Double.
    func testДесятичнаяТочность() {
        let a = try! XCTUnwrap(CBRParser.number("0,1"))
        let b = try! XCTUnwrap(CBRParser.number("0,2"))
        XCTAssertEqual(a + b, Decimal(string: "0.3"))
        XCTAssertNotEqual(0.1 + 0.2, 0.3)
    }

    //  MARK: - Кодировка

    func testWindows1251() {
        //  «Доллар» в windows-1251.
        let байты = Data([0xC4, 0xEE, 0xEB, 0xEB, 0xE0, 0xF0])
        XCTAssertEqual(CP1251.text(from: байты), "Доллар")
    }

    func testЛатиницаНеПортится() {
        let байты = Data("USD <Value>".utf8)
        XCTAssertEqual(CP1251.text(from: байты), "USD <Value>")
    }

    func testЁИНомер() {
        //  Символы из нестандартных позиций таблицы.
        XCTAssertEqual(CP1251.text(from: Data([0xB8, 0xA8, 0xB9])),
                       "ёЁ№")
    }

    func testВыборКодировкиПоЗаголовку() {
        let utf8 = Data("<?xml version=\"1.0\" encoding=\"UTF-8\"?><N>Ёж</N>"
            .utf8)
        XCTAssertTrue(CP1251.smartText(from: utf8).contains("Ёж"))
    }

    /// Полный путь: байты в windows-1251 → строка → разбор.
    func testЦелыйОтветВWindows1251() throws {
        var байты = [UInt8]()
        let латиница = """
        <?xml version="1.0" encoding="windows-1251"?>\
        <ValCurs Date="18.11.2026"><Valute ID="R01235">\
        <CharCode>USD</CharCode><Nominal>1</Nominal><Name>
        """
        байты += Array(латиница.utf8)
        байты += [0xC4, 0xEE, 0xEB, 0xEB, 0xE0, 0xF0, 0x20,
                  0xD1, 0xD8, 0xC0]
        байты += Array("</Name><Value>80,9734</Value></Valute></ValCurs>"
            .utf8)

        let список = try CBRParser.rates(from: Data(байты))
        XCTAssertEqual(список.count, 1)
        XCTAssertEqual(список[0].name, "Доллар США")
    }

    //  MARK: - Даты

    func testРазборДаты() throws {
        let d = try XCTUnwrap(DateBits.parse("18.11.2026"))
        XCTAssertEqual(DateBits.forPerson(d), "18.11.2026")
        XCTAssertEqual(DateBits.forRequest(d), "18/11/2026")
        XCTAssertEqual(DateBits.short(d), "18.11")
    }

    func testДатаЧерезКосуюЧерту() {
        XCTAssertEqual(DateBits.parse("01/02/2026"),
                       DateBits.day(1, 2, 2026))
    }

    func testНесуществующаяДата() {
        XCTAssertNil(DateBits.parse("тридцатое"))
        XCTAssertNil(DateBits.parse("18.11"))
    }

    func testСдвигЧерезГраницуМесяца() throws {
        let первое = try XCTUnwrap(DateBits.day(1, 3, 2026))
        //  2026-й не високосный.
        XCTAssertEqual(DateBits.forPerson(DateBits.shift(первое, days: -1)),
                       "28.02.2026")
    }

    func testОдинаковыйДень() throws {
        let a = try XCTUnwrap(DateBits.day(18, 11, 2026))
        XCTAssertTrue(DateBits.sameDay(a, a.addingTimeInterval(3600)))
        XCTAssertFalse(DateBits.sameDay(a, DateBits.shift(a, days: 1)))
    }
}
