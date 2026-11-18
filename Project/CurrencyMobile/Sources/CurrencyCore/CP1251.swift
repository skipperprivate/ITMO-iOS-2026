import Foundation

public enum CP1251 {

    /// Байты 0x80…0xFF. Нижняя половина совпадает с ASCII.
    private static let high: [Character] = [
        "Ђ", "Ѓ", "‚", "ѓ", "„", "…", "†", "‡",   // 80–87
        "€", "‰", "Љ", "‹", "Њ", "Ќ", "Ћ", "Џ",   // 88–8F
        "ђ", "‘", "’", "“", "”", "•", "–", "—",   // 90–97
        "\u{0098}", "™", "љ", "›", "њ", "ќ", "ћ", "џ",   // 98–9F
        "\u{00A0}", "Ў", "ў", "Ј", "¤", "Ґ", "¦", "§",   // A0–A7
        "Ё", "©", "Є", "«", "¬", "\u{00AD}", "®", "Ї",   // A8–AF
        "°", "±", "І", "і", "ґ", "µ", "¶", "·",   // B0–B7
        "ё", "№", "є", "»", "ј", "Ѕ", "ѕ", "ї",   // B8–BF
        "А", "Б", "В", "Г", "Д", "Е", "Ж", "З",   // C0–C7
        "И", "Й", "К", "Л", "М", "Н", "О", "П",   // C8–CF
        "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч",   // D0–D7
        "Ш", "Щ", "Ъ", "Ы", "Ь", "Э", "Ю", "Я",   // D8–DF
        "а", "б", "в", "г", "д", "е", "ж", "з",   // E0–E7
        "и", "й", "к", "л", "м", "н", "о", "п",   // E8–EF
        "р", "с", "т", "у", "ф", "х", "ц", "ч",   // F0–F7
        "ш", "щ", "ъ", "ы", "ь", "э", "ю", "я",   // F8–FF
    ]

    /// Декодировать байты как windows-1251.
    ///
    /// Не бросает и не возвращает nil: в этой кодировке любому
    /// байту соответствует символ.
    public static func text(from data: Data) -> String {
        var out = String()
        out.reserveCapacity(data.count)
        for byte in data {
            if byte < 0x80 {
                out.append(Character(UnicodeScalar(byte)))
            } else {
                out.append(high[Int(byte) - 0x80])
            }
        }
        return out
    }

    /// Декодировать, определив кодировку по заголовку XML.
    /// Запасной путь на случай, если ЦБ перейдёт на UTF-8.
    public static func smartText(from data: Data) -> String {
        //  Заголовок всегда в ASCII, его можно прочитать
        //  до того, как кодировка известна.
        let head = String(decoding: data.prefix(120), as: UTF8.self)
            .lowercased()
        if head.contains("utf-8"), let utf = String(data: data,
                                                    encoding: .utf8) {
            return utf
        }
        return text(from: data)
    }
}
