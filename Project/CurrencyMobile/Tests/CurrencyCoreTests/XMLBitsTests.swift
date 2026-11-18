//
//  XMLBitsTests.swift
//  Разбор XML, включая некорректный ввод: данные приходят
//  извне, и разборщик обязан держать удар.
//

import XCTest
@testable import CurrencyCore

final class XMLBitsTests: XCTestCase {

    func testПростойТег() throws {
        let node = try XMLBits.parse("<Value>80,9734</Value>")
        XCTAssertEqual(node.name, "Value")
        XCTAssertEqual(node.text, "80,9734")
        XCTAssertTrue(node.children.isEmpty)
    }

    func testЗначенияВТеге() throws {
        let node = try XMLBits.parse(
            "<Valute ID=\"R01235\" x='1'>а</Valute>")
        XCTAssertEqual(node.attributes["ID"], "R01235")
        //  Апострофы вместо кавычек допустимы по стандарту.
        XCTAssertEqual(node.attributes["x"], "1")
    }

    func testВложенность() throws {
        let node = try XMLBits.parse("""
        <ValCurs Date="18.11.2026">
          <Valute ID="R01010"><CharCode>AUD</CharCode></Valute>
          <Valute ID="R01235"><CharCode>USD</CharCode></Valute>
        </ValCurs>
        """)
        XCTAssertEqual(node.all("Valute").count, 2)
        XCTAssertEqual(node.all("Valute")[1].value("CharCode"), "USD")
    }

    func testЗаголовокИКомментарииНеМешают() throws {
        let node = try XMLBits.parse("""
        <?xml version="1.0" encoding="windows-1251"?>
        <!-- так отвечает ЦБ -->
        <ValCurs><A>1</A></ValCurs>
        """)
        XCTAssertEqual(node.name, "ValCurs")
        XCTAssertEqual(node.value("A"), "1")
    }

    func testОдиночныйТег() throws {
        let node = try XMLBits.parse("<ValCurs><Пусто/><A>1</A></ValCurs>")
        XCTAssertEqual(node.children.count, 2)
        XCTAssertEqual(node.children[0].name, "Пусто")
        XCTAssertEqual(node.children[0].text, "")
    }

    func testПробелыПоКраямСрезаются() throws {
        let node = try XMLBits.parse("<Name>\n   Доллар США  \n</Name>")
        XCTAssertEqual(node.text, "Доллар США")
    }

    func testПодстановки() throws {
        let node = try XMLBits.parse(
            "<N>Банк &amp; Co &lt;1&gt; &quot;А&quot; &#1055;</N>")
        XCTAssertEqual(node.text, "Банк & Co <1> \"А\" П")
    }

    func testПодстановкаШестнадцатеричная() throws {
        let node = try XMLBits.parse("<N>&#x41F;</N>")
        XCTAssertEqual(node.text, "П")
    }

    func testОдинокийАмперсандНеТеряется() throws {
        //  Вне стандарта, но терять часть текста хуже.
        let node = try XMLBits.parse("<N>Рога & копыта</N>")
        XCTAssertEqual(node.text, "Рога & копыта")
    }

    func testCDATA() throws {
        let node = try XMLBits.parse("<N><![CDATA[А & Б <тут>]]></N>")
        XCTAssertEqual(node.text, "А & Б <тут>")
    }

    func testПустаяСтрокаЭтоОшибка() {
        XCTAssertThrowsError(try XMLBits.parse("   ")) { e in
            XCTAssertEqual(e as? XMLError, .empty)
        }
    }

    func testОборванныйДокумент() {
        //  Прерванная загрузка.
        XCTAssertThrowsError(try XMLBits.parse("<ValCurs><A>1")) { e in
            XCTAssertEqual(e as? XMLError, .unexpectedEnd)
        }
    }

    func testЗакрылиНеТотТег() {
        XCTAssertThrowsError(try XMLBits.parse("<A>1</B>")) { e in
            XCTAssertEqual(e as? XMLError,
                           .mismatchedTag(expected: "A", found: "B"))
        }
    }

    func testНеXMLВообще() {
        //  Страница ошибки или заглушка прокси вместо данных
        //  должна приводить к ошибке, а не к пустому списку.
        XCTAssertThrowsError(try XMLBits.parse("502 Bad Gateway"))
    }

    func testТекстВперемешкуСТегами() throws {
        let node = try XMLBits.parse("<A>до<B/>после</A>")
        XCTAssertEqual(node.text, "допосле")
        XCTAssertEqual(node.children.count, 1)
    }
}
