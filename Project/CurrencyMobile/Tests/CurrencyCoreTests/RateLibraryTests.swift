//
//  RateLibraryTests.swift
//  Поведение слоя данных: кэш, работа без сети, выходные,
//  параллельная загрузка, сборка URL.
//

import XCTest
@testable import CurrencyCore

final class RateLibraryTests: XCTestCase {

    //  MARK: - Сеть и кэш

    func testЗагрузкаИПересчётИзменения() async throws {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка)
        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())

        let день = try await библиотека.day(Образцы.день)

        XCTAssertEqual(день.rates.count, 3)
        XCTAssertFalse(день.fromCache)
        XCTAssertEqual(день.previous.count, 3)
    }

    func testВчерашнийДеньЗапрашивается() async throws {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка)
        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())

        _ = try await библиотека.day(Образцы.день)

        let спрашивали = await источник.спрашивали
        XCTAssertTrue(спрашивали.contains("18.11.2026"))
        XCTAssertTrue(спрашивали.contains("17.11.2026"))
    }

    func testПовторныйЗапросНеИдётВСеть() async throws {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка)
        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())

        _ = try await библиотека.day(Образцы.день)
        let послеПервого = await источник.вызововКурсов
        _ = try await библиотека.day(Образцы.день)
        let послеВторого = await источник.вызововКурсов

        //  Переключение вкладок не должно бить по сети.
        XCTAssertEqual(послеПервого, послеВторого)
    }

    func testОбновлениеВсёТакиИдётВСеть() async throws {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка)
        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())

        _ = try await библиотека.day(Образцы.день)
        let было = await источник.вызововКурсов
        _ = try await библиотека.refresh(Образцы.день)
        let стало = await источник.вызововКурсов

        XCTAssertGreaterThan(стало, было)
    }

    //  MARK: - Работа без сети

    func testБезСетиБерётсяСохранённое() async throws {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка)
        let хранилище = MemoryRateStore()
        let библиотека = RateLibrary(source: источник, store: хранилище)

        //  Удачная загрузка — данные осели в хранилище.
        _ = try await библиотека.day(Образцы.день)

        await источник.настроить(ошибка: NetError.offline("нет сети"))
        await библиотека.forget()

        let день = try await библиотека.day(Образцы.день)

        XCTAssertEqual(день.rates.count, 3)
        //  Пометка обязательна: по ней экран подписывает данные
        //  как сохранённые.
        XCTAssertTrue(день.fromCache)
    }

    func testБезСетиИБезСохранённогоЧестнаяОшибка() async {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка)
        await источник.настроить(ошибка: NetError.offline("нет сети"))
        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())

        do {
            _ = try await библиотека.day(Образцы.день)
            XCTFail("должна была вылететь ошибка")
        } catch {
            XCTAssertEqual(error as? NetError, .offline("нет сети"))
        }
    }

    //  MARK: - Выходные

    func testВВыходнойШагаемНазадЕщёРаз() async throws {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка)
        //  Любой запрос возвращает данные за пятницу 14.11.
        await источник.настроить(
            закреплённаяДата: DateBits.day(14, 11, 2026)!)
        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())

        //  Запрашиваем субботу.
        let день = try await библиотека.day(DateBits.day(15, 11, 2026)!)

        XCTAssertEqual(DateBits.forPerson(день.date), "14.11.2026")

        //  «Вчера» дало тот же день, значит нужен ещё шаг назад —
        //  от фактической даты ответа.
        let спрашивали = await источник.спрашивали
        XCTAssertTrue(спрашивали.contains("13.11.2026"),
                      "спрашивали: \(спрашивали)")
    }

    func testСохраняетсяПодНастоящейДатой() async throws {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка)
        await источник.настроить(
            закреплённаяДата: DateBits.day(14, 11, 2026)!)
        let хранилище = MemoryRateStore()
        let библиотека = RateLibrary(source: источник, store: хранилище)

        _ = try await библиотека.day(DateBits.day(15, 11, 2026)!)

        let вСубботу = await хранилище.rates(
            on: DateBits.day(15, 11, 2026)!)
        let вПятницу = await хранилище.rates(
            on: DateBits.day(14, 11, 2026)!)
        XCTAssertNil(вСубботу)
        XCTAssertEqual(вПятницу?.count, 3)
    }

    //  MARK: - Параллельность

    /// Проверяется не по времени (секундомер даёт случайные
    /// провалы на загруженной машине), а по максимальному числу
    /// одновременных обращений к источнику.
    func testГрафикиЗагружаютсяОдновременно() async throws {
        let источник = ПоддельныйИсточник(
            курсы: Образцы.тройка,
            точки: Образцы.история(["80", "81"]))
        await источник.настроить(задержка: 40_000_000)   // 40 мс

        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())

        let коды = ["R01235", "R01239", "R01060", "R01375", "R01010"]
        let итог = await библиотека.histories(ids: коды, days: 7)

        XCTAssertEqual(итог.count, 5)
        let максимум = await источник.максимумОдновременно
        XCTAssertGreaterThan(максимум, 1,
                             "запросы шли по очереди, а не разом")
        XCTAssertEqual(максимум, 5,
                       "ожидалось пять одновременных запросов")
    }

    func testОднаНеудачнаяВалютаНеРушитОстальные() async throws {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка)
        await источник.настроить(ошибка: NetError.offline("нет"))
        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())

        let итог = await библиотека.histories(ids: ["R01235"], days: 7)
        XCTAssertEqual(итог["R01235"], [])
    }

    //  MARK: - Хранилище

    func testХранилищеОтдаётСамоеСвежее() async {
        let хранилище = MemoryRateStore()
        await хранилище.save([Образцы.доллар(on: DateBits.day(1, 12, 2026)!)],
                             on: DateBits.day(1, 12, 2026)!)
        await хранилище.save([Образцы.доллар(on: Образцы.день)],
                             on: Образцы.день)

        let свежее = await хранилище.latest()
        //  Сравнение ключей как строк дало бы «18.11» > «01.12».
        XCTAssertEqual(DateBits.forPerson(свежее!.date), "01.12.2026")
    }

    func testОбрезкаСтарого() async {
        let хранилище = MemoryRateStore()
        for день in 1...5 {
            let d = DateBits.day(день, 11, 2026)!
            await хранилище.save([Образцы.доллар(on: d)], on: d)
        }
        await хранилище.trim(keepDays: 2)

        let пятое = await хранилище.rates(on: DateBits.day(5, 11, 2026)!)
        let первое = await хранилище.rates(on: DateBits.day(1, 11, 2026)!)
        XCTAssertNotNil(пятое)
        XCTAssertNil(первое)
    }

    func testОбрезкаНольНичегоНеТрогает() async {
        let хранилище = MemoryRateStore()
        await хранилище.save(Образцы.тройка, on: Образцы.день)
        await хранилище.trim(keepDays: 0)
        let всё = await хранилище.rates(on: Образцы.день)
        XCTAssertEqual(всё?.count, 3)
    }

    func testИзбранноеЖивётОтдельноОтКурсов() async {
        let хранилище = MemoryRateStore()
        await хранилище.set("USD", on: true)
        await хранилище.save(Образцы.тройка, on: Образцы.день)

        await хранилище.trim(keepDays: 1)

        //  Очистка кэша не должна затрагивать выбор пользователя.
        let избранное = await хранилище.all()
        XCTAssertEqual(избранное, ["USD"])
    }

    //  MARK: - Сборка запросов

    func testСсылкаНаДневныеКурсы() async throws {
        let доставка = ПоддельнаяДоставка(ответ: """
        <ValCurs Date="18.11.2026"><Valute ID="R01235">\
        <CharCode>USD</CharCode><Nominal>1</Nominal>\
        <Name>Доллар США</Name><Value>80,9734</Value>\
        </Valute></ValCurs>
        """)
        let источник = CBRSource(transport: доставка)

        _ = try await источник.rates(on: Образцы.день)

        let ссылки = await доставка.ссылки
        //  Дата через косую черту: с точками сервис отвечает
        //  пустым списком без признаков ошибки.
        XCTAssertEqual(ссылки.first,
                       "https://www.cbr.ru/scripts/XML_daily.asp"
                       + "?date_req=18/11/2026")
    }

    func testСсылкаНаИсторию() async throws {
        let доставка = ПоддельнаяДоставка(
            ответ: "<ValCurs ID=\"R01235\"></ValCurs>")
        let источник = CBRSource(transport: доставка)

        _ = try await источник.history(
            id: "R01235",
            from: DateBits.day(1, 11, 2026)!,
            to: Образцы.день)

        let ссылки = await доставка.ссылки
        XCTAssertEqual(ссылки.first,
                       "https://www.cbr.ru/scripts/XML_dynamic.asp"
                       + "?date_req1=01/11/2026&date_req2=18/11/2026"
                       + "&VAL_NM_RQ=R01235")
    }
}
