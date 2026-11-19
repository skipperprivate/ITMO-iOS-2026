import Foundation

enum MockEventFactory {

    static var events: [Event] {
        featuredEvents + regularEvents
    }

    private static var featuredEvents: [Event] {
        [
            makeEvent(
                id: 1,
                title: "Большой концерт",
                category: .music,
                venue: "ВТБ Арена",
                city: "Москва",
                date: makeDate(2026, 11, 14, 20),
                price: "от 3 500 ₽",
                isFeatured: true
            ),
            makeEvent(
                id: 2,
                title: "Фестиваль новой музыки",
                category: .music,
                venue: "Севкабель Порт",
                city: "Санкт-Петербург",
                date: makeDate(2026, 11, 21, 18),
                price: "от 2 500 ₽",
                isFeatured: true
            ),
            makeEvent(
                id: 3,
                title: "Футбольный матч",
                category: .sport,
                venue: "Газпром Арена",
                city: "Санкт-Петербург",
                date: makeDate(2026, 11, 22, 19),
                price: "от 1 800 ₽",
                isFeatured: true
            ),
            makeEvent(
                id: 4,
                title: "Выставка современного искусства",
                category: .arts,
                venue: "Манеж",
                city: "Санкт-Петербург",
                date: makeDate(2026, 11, 28, 12),
                price: "от 700 ₽",
                isFeatured: true
            ),
            makeEvent(
                id: 5,
                title: "Премьера нового фильма",
                category: .film,
                venue: "Каро Октябрь",
                city: "Москва",
                date: makeDate(2026, 12, 2, 19),
                price: "от 600 ₽",
                isFeatured: true
            )
        ]
    }

    private static var regularEvents: [Event] {
        [
            makeEvent(
                id: 6,
                title: "Джазовый вечер",
                category: .music,
                venue: "Клуб Алексея Козлова",
                city: "Москва",
                date: makeDate(2026, 12, 10, 20, 30),
                price: "от 1 500 ₽"
            ),
            makeEvent(
                id: 7,
                title: "Хоккейный матч",
                category: .sport,
                venue: "ЦСКА Арена",
                city: "Москва",
                date: makeDate(2026, 12, 5, 18),
                price: "от 1 200 ₽"
            ),
            makeEvent(
                id: 8,
                title: "Театральная постановка",
                category: .arts,
                venue: "Театр Наций",
                city: "Москва",
                date: makeDate(2026, 11, 25, 19),
                price: "от 2 000 ₽"
            ),
            makeEvent(
                id: 9,
                title: "Фестиваль короткометражного кино",
                category: .film,
                venue: "Аврора",
                city: "Санкт-Петербург",
                date: makeDate(2026, 12, 8, 17),
                price: "от 500 ₽"
            ),
            makeEvent(
                id: 10,
                title: "Фестиваль еды",
                category: .miscellaneous,
                venue: "Хлебозавод №9",
                city: "Москва",
                date: makeDate(2026, 11, 29, 12),
                price: "Бесплатно"
            ),
            makeEvent(
                id: 11,
                title: "Научно-популярная лекция",
                category: .other,
                venue: "Дом культуры ГЭС-2",
                city: "Москва",
                date: makeDate(2026, 12, 12, 16),
                price: "Бесплатно"
            ),
            makeEvent(
                id: 12,
                title: "Ночь электронной музыки",
                category: .music,
                venue: "Севкабель Порт",
                city: "Санкт-Петербург",
                date: makeDate(2026, 12, 19, 22),
                price: "от 1 700 ₽"
            )
        ]
    }

    private static func makeEvent(
        id: Int,
        title: String,
        category: EventCategoryRu,
        venue: String,
        city: String,
        date: Date,
        price: String,
        isFeatured: Bool = false
    ) -> Event {
        Event(
            id: makeID(id),
            title: title,
            category: category,
            venue: venue,
            city: city,
            date: date,
            price: price,
            isFeatured: isFeatured
        )
    }

    private static func makeID(_ number: Int) -> UUID {
        let uuidString = String(
            format: "00000000-0000-0000-0000-%012d",
            number
        )

        guard let uuid = UUID(uuidString: uuidString) else {
            preconditionFailure("Invalid mock event UUID for ID \(number)")
        }
        return uuid
    }

    private static func makeDate(
        _ year: Int,
        _ month: Int,
        _ day: Int,
        _ hour: Int,
        _ minute: Int = 0
    ) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        guard let timeZone = TimeZone(identifier: "Europe/Moscow") else {
            preconditionFailure("Mock event timezone unavailable")
        }
        calendar.timeZone = timeZone

        let components = DateComponents(
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )

        guard let date = calendar.date(from: components) else {
            preconditionFailure("Invalid mock event date: \(components)")
        }
        return date
    }
}
