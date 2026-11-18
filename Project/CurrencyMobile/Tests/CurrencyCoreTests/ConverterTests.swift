//
//  ConverterTests.swift
//  Пересчёт валют и форматирование чисел.
//
//  Ожидаемые значения посчитаны вручную: сверять результат
//  с тем же выражением, что и в коде, бессмысленно.
//

import XCTest
@testable import CurrencyCore

final class ConverterTests: XCTestCase {

    //  MARK: - Пересчёт

    func testВалютаВРубли() throws {
        let usd = Образцы.доллар("80,00")
        let rub = Rate.ruble(on: Образцы.день)
        //  3 × 80 = 240
        XCTAssertEqual(Converter.convert(3, from: usd, to: rub),
                       Decimal(240))
    }

    func testРублиВВалюту() throws {
        let usd = Образцы.доллар("80,00")
        let rub = Rate.ruble(on: Образцы.день)
        //  240 / 80 = 3
        XCTAssertEqual(Converter.convert(240, from: rub, to: usd),
                       Decimal(3))
    }

    func testКроссКурс() throws {
        //  Доллар 80, евро 100 → 100 USD = 80 EUR.
        let usd = Образцы.доллар("80,00")
        let eur = Образцы.евро("100,00")
        XCTAssertEqual(Converter.convert(100, from: usd, to: eur),
                       Decimal(80))
    }

    func testНоминалУчитываетсяВПересчёте() throws {
        //  100 драмов стоят 20 ₽ → за 100 ₽ дают 500 драмов.
        let amd = Образцы.драм("20,00")
        let rub = Rate.ruble(on: Образцы.день)
        XCTAssertEqual(Converter.convert(100, from: rub, to: amd),
                       Decimal(500))
    }

    func testСамаВСебя() throws {
        let usd = Образцы.доллар()
        XCTAssertEqual(Converter.convert(7, from: usd, to: usd),
                       Decimal(7))
    }

    func testНулевойКурсНеРушитПриложение() throws {
        let битая = Rate(id: "X", code: "XXX", name: "Ноль",
                         nominal: 1, value: 0, date: Образцы.день)
        XCTAssertNil(Converter.convert(1, from: Образцы.доллар(),
                                       to: битая))
    }

    //  MARK: - Изменение

    func testИзменениеВверх() {
        XCTAssertEqual(Converter.change(now: 84, before: 80), Decimal(5))
    }

    func testИзменениеВниз() {
        XCTAssertEqual(Converter.change(now: 76, before: 80), Decimal(-5))
    }

    func testИзменениеОтНуляНевозможно() {
        XCTAssertNil(Converter.change(now: 80, before: 0))
    }

    //  MARK: - Округление

    func testОкруглениеВверх() {
        XCTAssertEqual(Converter.round(Decimal(string: "80.976")!,
                                       digits: 2),
                       Decimal(string: "80.98"))
    }

    func testОкруглениеВниз() {
        XCTAssertEqual(Converter.round(Decimal(string: "80.974")!,
                                       digits: 2),
                       Decimal(string: "80.97"))
    }

    //  MARK: - Форматирование

    func testПростойПоказ() {
        XCTAssertEqual(Converter.text(Decimal(string: "80.9734")!),
                       "80,97")
    }

    func testЗапятаяАНеТочка() {
        //  Разделитель не должен зависеть от языка устройства.
        XCTAssertTrue(Converter.text(Decimal(string: "1.5")!)
            .contains(","))
    }

    func testНедостающиеНулиДописываются() {
        XCTAssertEqual(Converter.text(Decimal(string: "80.5")!), "80,50")
        XCTAssertEqual(Converter.text(Decimal(8)), "8,00")
    }

    func testРазделениеТысяч() {
        //  Пробел неразрывный, чтобы число не разрывалось переносом.
        XCTAssertEqual(Converter.text(Decimal(1234567), digits: 0),
                       "1\u{00A0}234\u{00A0}567")
    }

    func testЧетырёхзначноеНеРазбивается() {
        XCTAssertEqual(Converter.text(Decimal(1234), digits: 0), "1234")
    }

    func testБезРазделенияЕслиПросили() {
        XCTAssertEqual(Converter.text(Decimal(12345), digits: 0,
                                      groups: false),
                       "12345")
    }

    func testМинусЭтоМинусАНеДефис() {
        XCTAssertEqual(Converter.text(Decimal(string: "-1.5")!),
                       "−1,50")
    }

    func testЧетыреЗнакаУДешёвойВалюты() {
        //  С двумя знаками курс дешёвой валюты округлился бы до нуля.
        XCTAssertEqual(Converter.rateText(Образцы.драм("21,0824")),
                       "0,2108 ₽")
    }

    func testДваЗнакаУДорогойВалюты() {
        XCTAssertEqual(Converter.rateText(Образцы.доллар("80,9734")),
                       "80,97 ₽")
    }

    func testПоказИзменения() {
        XCTAssertEqual(Converter.changeText(Decimal(string: "0.42")!),
                       "+0,42 %")
        XCTAssertEqual(Converter.changeText(Decimal(string: "-1.5")!),
                       "−1,50 %")
    }
}
