//
//  ScreenModelsTests.swift
//  Поведение моделей всех пяти экранов.
//
//  Методы помечены @MainActor, потому что модели изолированы
//  в главном акторе.
//

import XCTest
@testable import CurrencyCore

final class ScreenModelsTests: XCTestCase {

    //  MARK: - Стенд

    private func стенд(
        курсы: [Rate] = Образцы.тройка,
        избранное: Set<String> = [],
        ошибка: Error? = nil
    ) async -> (RateLibrary, MemoryRateStore, ПоддельныйИсточник) {
        let источник = ПоддельныйИсточник(
            курсы: курсы,
            точки: Образцы.история(["80", "81", "82"]))
        if let ошибка { await источник.настроить(ошибка: ошибка) }
        let хранилище = MemoryRateStore(избранное: избранное)
        return (RateLibrary(source: источник, store: хранилище),
                хранилище, источник)
    }

    //  MARK: - Курсы

    @MainActor
    func testКурсыЗагружаются() async {
        let (библиотека, хранилище, _) = await стенд()
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)

        await модель.load()

        XCTAssertEqual(модель.phase, .ready)
        XCTAssertEqual(модель.visible.count, 3)
        XCTAssertTrue(модель.subtitle.contains("Курсы ЦБ РФ"))
    }

    @MainActor
    func testПоискПоКоду() async {
        let (библиотека, хранилище, _) = await стенд()
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)
        await модель.load()

        //  Регистр не должен иметь значения.
        модель.search = "usd"
        XCTAssertEqual(модель.visible.map(\.code), ["USD"])
    }

    @MainActor
    func testПоискПоНазванию() async {
        let (библиотека, хранилище, _) = await стенд()
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)
        await модель.load()

        модель.search = "доллар"
        XCTAssertEqual(модель.visible.map(\.code), ["USD"])
    }

    @MainActor
    func testПоискНичегоНеНашёл() async {
        let (библиотека, хранилище, _) = await стенд()
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)
        await модель.load()

        модель.search = "тугрик"
        XCTAssertTrue(модель.visible.isEmpty)
        //  Пустой результат поиска — не ошибка загрузки.
        XCTAssertEqual(модель.phase, .ready)
    }

    @MainActor
    func testИзбранныеНаверху() async {
        let (библиотека, хранилище, _) = await стенд(избранное: ["USD"])
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)
        await модель.load()

        //  По алфавиту доллар был бы третьим.
        XCTAssertEqual(модель.visible.map(\.code), ["USD", "AMD", "EUR"])
    }

    @MainActor
    func testОтметитьИСнять() async {
        let (библиотека, хранилище, _) = await стенд()
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)
        await модель.load()

        await модель.toggleFavourite("EUR")
        XCTAssertTrue(модель.isFavourite("EUR"))
        //  Отметка должна дойти до хранилища, а не остаться
        //  только в состоянии экрана.
        let вХранилище = await хранилище.all()
        XCTAssertEqual(вХранилище, ["EUR"])

        await модель.toggleFavourite("EUR")
        XCTAssertFalse(модель.isFavourite("EUR"))
    }

    @MainActor
    func testТолькоИзбранное() async {
        let (библиотека, хранилище, _) = await стенд(избранное: ["EUR"])
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)
        await модель.load()

        модель.onlyFavourites = true
        XCTAssertEqual(модель.visible.map(\.code), ["EUR"])
    }

    @MainActor
    func testПриОшибкеПонятноеСообщение() async {
        let (библиотека, хранилище, _) = await стенд(
            ошибка: NetError.offline("нет сети"))
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)

        await модель.load()

        XCTAssertEqual(модель.phase,
                       .failed("Нет связи с Центробанком."
                               + " Проверьте интернет."))
    }

    @MainActor
    func testПодписьПроСохранённыеДанные() async {
        let (библиотека, хранилище, источник) = await стенд()
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)
        await модель.load()

        //  Сеть пропала, кэш процесса сброшен — данные пойдут
        //  из хранилища.
        await источник.настроить(ошибка: NetError.offline("нет"))
        await библиотека.forget()
        await модель.refresh()

        XCTAssertTrue(модель.subtitle.contains("Сохранённые"),
                      "подпись: \(модель.subtitle)")
    }

    @MainActor
    func testСтрелкаРостаСчитается() async {
        let (библиотека, хранилище, _) = await стенд()
        let модель = RatesModel(library: библиотека,
                                favourites: хранилище)
        await модель.load()

        //  Заглушка отдаёт одинаковые цены на оба дня.
        let usd = модель.visible.first { $0.code == "USD" }!
        XCTAssertNil(модель.grew(usd))
        //  Ноль показывается без знака.
        XCTAssertEqual(модель.changeText(for: usd), "0,00 %")
    }

    //  MARK: - Конвертер

    @MainActor
    func testКонвертерСчитает() async {
        let (библиотека, _, _) = await стенд(
            курсы: [Образцы.доллар("80,00")])
        let модель = ConverterModel(library: библиотека)
        await модель.load()

        модель.amountText = "3"
        модель.fromCode = "USD"
        модель.toCode = "RUB"

        XCTAssertEqual(модель.resultText, "240,00")
    }

    @MainActor
    func testРубльЕстьВСписке() async {
        let (библиотека, _, _) = await стенд()
        let модель = ConverterModel(library: библиотека)
        await модель.load()

        //  ЦБ рубль не присылает, он добавляется вручную.
        XCTAssertEqual(модель.currencies.first?.code, "RUB")
    }

    @MainActor
    func testНезаконченныйВводНеОшибка() async {
        let (библиотека, _, _) = await стенд()
        let модель = ConverterModel(library: библиотека)
        await модель.load()

        //  «12,» — дробная часть ещё не набрана; результат
        //  должен совпадать с результатом для «12».
        модель.amountText = "12,"
        let сЗапятой = модель.resultText
        модель.amountText = "12"
        let безЗапятой = модель.resultText

        XCTAssertFalse(модель.inputLooksWrong)
        XCTAssertFalse(сЗапятой.isEmpty)
        XCTAssertEqual(сЗапятой, безЗапятой)
    }

    @MainActor
    func testИспорченныйВводПомечается() async {
        let (библиотека, _, _) = await стенд()
        let модель = ConverterModel(library: библиотека)
        await модель.load()

        модель.amountText = "1,2,3"
        XCTAssertTrue(модель.inputLooksWrong)
    }

    @MainActor
    func testПустоеПолеНеОшибка() async {
        let (библиотека, _, _) = await стенд()
        let модель = ConverterModel(library: библиотека)
        await модель.load()

        модель.amountText = ""
        XCTAssertFalse(модель.inputLooksWrong)
        XCTAssertEqual(модель.resultText, "")
    }

    @MainActor
    func testПереворотНеТеряетСумму() async {
        let (библиотека, _, _) = await стенд()
        let модель = ConverterModel(library: библиотека)
        await модель.load()

        модель.amountText = "123"
        модель.fromCode = "USD"
        модель.toCode = "RUB"
        модель.swap()

        XCTAssertEqual(модель.fromCode, "RUB")
        XCTAssertEqual(модель.toCode, "USD")
        XCTAssertEqual(модель.amountText, "123")
    }

    @MainActor
    func testПоясняющаяСтрока() async {
        let (библиотека, _, _) = await стенд(
            курсы: [Образцы.доллар("80,00")])
        let модель = ConverterModel(library: библиотека)
        await модель.load()
        модель.fromCode = "USD"
        модель.toCode = "RUB"

        XCTAssertEqual(модель.explanation, "1 USD = 80,00 RUB")
    }

    @MainActor
    func testПропавшаяВалютаЗаменяется() async {
        let (библиотека, _, _) = await стенд(
            курсы: [Образцы.доллар()])
        let модель = ConverterModel(library: библиотека)
        await модель.load()

        //  Валюта осталась в настройках с прошлого запуска,
        //  а ЦБ её больше не публикует.
        модель.fromCode = "XXX"
        модель.fixMissing()
        XCTAssertNotEqual(модель.fromCode, "XXX")
    }

    //  MARK: - История

    @MainActor
    func testИсторияЗагружается() async {
        let (библиотека, _, _) = await стенд()
        let модель = HistoryModel(rate: Образцы.доллар(),
                                  library: библиотека)

        await модель.load()

        XCTAssertEqual(модель.phase, .ready)
        XCTAssertEqual(модель.points.count, 3)
        XCTAssertEqual(модель.minimumText, "80,00 ₽")
        XCTAssertEqual(модель.maximumText, "82,00 ₽")
    }

    @MainActor
    func testИзменениеЗаПериод() async {
        let (библиотека, _, _) = await стенд()
        let модель = HistoryModel(rate: Образцы.доллар(),
                                  library: библиотека)
        await модель.load()

        //  80 → 82 это +2,5 %.
        XCTAssertEqual(модель.changeText, "+2,50 %")
        XCTAssertEqual(модель.grew, true)
    }

    @MainActor
    func testТочкиГрафикаВДолях() async {
        let (библиотека, _, _) = await стенд()
        let модель = HistoryModel(rate: Образцы.доллар(),
                                  library: библиотека)
        await модель.load()

        let точки = модель.points01
        XCTAssertEqual(точки.count, 3)
        XCTAssertEqual(точки.first!.x, 0, accuracy: 0.0001)
        XCTAssertEqual(точки.last!.x, 1, accuracy: 0.0001)
        XCTAssertEqual(точки.first!.y, 0, accuracy: 0.0001)
        XCTAssertEqual(точки.last!.y, 1, accuracy: 0.0001)
        //  81 ровно посередине между 80 и 82.
        XCTAssertEqual(точки[1].y, 0.5, accuracy: 0.0001)
    }

    @MainActor
    func testРовныйКурсНеДелитсяНаНоль() async {
        let источник = ПоддельныйИсточник(
            курсы: Образцы.тройка,
            точки: Образцы.история(["80", "80", "80"]))
        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())
        let модель = HistoryModel(rate: Образцы.доллар(),
                                  library: библиотека)
        await модель.load()

        //  Нулевой размах: без защиты получились бы NaN.
        let точки = модель.points01
        XCTAssertEqual(точки.count, 3)
        for т in точки {
            XCTAssertEqual(т.y, 0.5, accuracy: 0.0001)
            XCTAssertFalse(т.y.isNaN)
        }
    }

    @MainActor
    func testПустаяИсторияЭтоОбъяснимо() async {
        let источник = ПоддельныйИсточник(курсы: Образцы.тройка,
                                          точки: [])
        let библиотека = RateLibrary(source: источник,
                                     store: MemoryRateStore())
        let модель = HistoryModel(rate: Образцы.доллар(),
                                  library: библиотека)
        await модель.load()

        XCTAssertEqual(модель.phase,
                       .failed("За этот период Центробанк данных"
                               + " не даёт."))
    }

    @MainActor
    func testСменаПериодаПерезагружает() async {
        let (библиотека, _, источник) = await стенд()
        let модель = HistoryModel(rate: Образцы.доллар(),
                                  library: библиотека)
        await модель.load()
        let было = await источник.вызововИстории

        await модель.choose(.year)

        XCTAssertEqual(модель.period, .year)
        let стало = await источник.вызововИстории
        XCTAssertGreaterThan(стало, было)
    }

    //  MARK: - Избранное

    @MainActor
    func testИзбранноеПустоеОбъявляетсяЯвно() async {
        let (библиотека, хранилище, _) = await стенд()
        let модель = FavouritesModel(library: библиотека,
                                     favourites: хранилище)
        await модель.load()

        XCTAssertTrue(модель.isEmpty)
        XCTAssertEqual(модель.phase, .ready)
    }

    @MainActor
    func testИзбранноеСГрафиками() async {
        let (библиотека, хранилище, _) = await стенд(
            избранное: ["USD", "EUR"])
        let модель = FavouritesModel(library: библиотека,
                                     favourites: хранилище)
        await модель.load()

        XCTAssertEqual(модель.rates.map(\.code), ["EUR", "USD"])
        //  Графики разложены по буквенным кодам, а не внутренним.
        XCTAssertEqual(модель.sparks["USD"]?.count, 3)
        XCTAssertEqual(модель.spark01(for: "USD").count, 3)
        XCTAssertEqual(модель.grewThisWeek("USD"), true)
    }

    @MainActor
    func testУбратьИзИзбранного() async {
        let (библиотека, хранилище, _) = await стенд(
            избранное: ["USD", "EUR"])
        let модель = FavouritesModel(library: библиотека,
                                     favourites: хранилище)
        await модель.load()

        await модель.remove("USD")

        XCTAssertEqual(модель.rates.map(\.code), ["EUR"])
        let вХранилище = await хранилище.all()
        XCTAssertEqual(вХранилище, ["EUR"])
    }

    //  MARK: - О программе

    @MainActor
    func testНастройкиПоказываютДатуИЧисло() async {
        let (библиотека, хранилище, _) = await стенд()
        _ = try? await библиотека.today()
        let модель = SettingsModel(store: хранилище,
                                   library: библиотека)
        await модель.load()

        XCTAssertEqual(модель.savedCount, 3)
        XCTAssertTrue(модель.summary.contains("3 валюты"),
                      "вышло: \(модель.summary)")
    }

    @MainActor
    func testОкончанияСлова() async {
        let (библиотека, хранилище, _) = await стенд()
        let модель = SettingsModel(store: хранилище,
                                   library: библиотека)

        for (число, слово) in [(1, "валюта"), (2, "валюты"),
                              (5, "валют"), (11, "валют"),
                              (21, "валюта"), (14, "валют")] {
            XCTAssertEqual(модель.валют(число), слово,
                           "для числа \(число)")
        }
    }

    @MainActor
    func testОчисткаНеТрогаетИзбранное() async {
        let (библиотека, хранилище, _) = await стенд(избранное: ["USD"])
        _ = try? await библиотека.today()
        let модель = SettingsModel(store: хранилище,
                                   library: библиотека)
        await модель.load()

        await модель.clearCache()

        let избранное = await хранилище.all()
        XCTAssertEqual(избранное, ["USD"],
                       "очистка кэша затронула избранное")
        XCTAssertFalse(модель.note.isEmpty)
    }
}
