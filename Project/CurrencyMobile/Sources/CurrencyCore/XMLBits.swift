
//  XMLBits.swift
//  Минимальный разбор XML в дерево.


import Foundation

/// Узел дерева: тег с атрибутами, детьми и текстом.
public struct XMLNode: Equatable, Sendable {

    public let name: String
    public let attributes: [String: String]
    public let children: [XMLNode]

    /// Текст внутри тега, обрезанный по краям.
    public let text: String

    public init(name: String,
                attributes: [String: String] = [:],
                children: [XMLNode] = [],
                text: String = "") {
        self.name = name
        self.attributes = attributes
        self.children = children
        self.text = text
    }

    /// Первый вложенный тег с таким именем.
    public func child(_ name: String) -> XMLNode? {
        children.first { $0.name == name }
    }

    /// Все вложенные теги с таким именем.
    public func all(_ name: String) -> [XMLNode] {
        children.filter { $0.name == name }
    }

    /// Текст вложенного тега.
    public func value(_ name: String) -> String? {
        child(name)?.text
    }
}

public enum XMLError: Error, Equatable {

    /// Ни одного тега — обычно вместо данных пришла страница ошибки.
    case empty

    /// Документ оборвался на середине.
    case unexpectedEnd

    case mismatchedTag(expected: String, found: String)

    /// Некорректный тег; число — позиция в исходном тексте.
    case brokenTag(at: Int)
}

public enum XMLBits {

    /// Разобрать документ и вернуть корневой тег.
    public static func parse(_ source: String) throws -> XMLNode {
        var reader = Reader(chars: Array(source))
        return try reader.document()
    }
}

//  MARK: - Разбор

private struct Reader {

    let chars: [Character]
    var i = 0

    var done: Bool { i >= chars.count }

    func peek(_ ahead: Int = 0) -> Character? {
        let k = i + ahead
        return k < chars.count ? chars[k] : nil
    }

    /// Стоим ли мы перед такой последовательностью.
    func looksLike(_ s: String) -> Bool {
        let want = Array(s)
        guard i + want.count <= chars.count else { return false }
        for (k, ch) in want.enumerated() where chars[i + k] != ch {
            return false
        }
        return true
    }

    mutating func skipSpace() {
        while let c = peek(), c.isWhitespace { i += 1 }
    }

    /// Промотать до указанной последовательности включительно.
    mutating func skip(past s: String) {
        while !done {
            if looksLike(s) {
                i += s.count
                return
            }
            i += 1
        }
    }

    /// Имя тега или атрибута. Двоеточие остаётся частью имени.
    mutating func readName() -> String {
        skipSpace()
        var out = ""
        while let c = peek(),
              c.isLetter || c.isNumber
                || c == "_" || c == ":" || c == "-" || c == "." {
            out.append(c)
            i += 1
        }
        return out
    }

    mutating func document() throws -> XMLNode {
        try skipProlog()
        guard !done else { throw XMLError.empty }
        guard peek() == "<" else { throw XMLError.empty }
        return try element()
    }

    /// Пролог, комментарии и DOCTYPE перед корневым тегом.
    mutating func skipProlog() throws {
        while true {
            skipSpace()
            if looksLike("<?") { skip(past: "?>"); continue }
            if looksLike("<!--") { skip(past: "-->"); continue }
            if looksLike("<!") { skip(past: ">"); continue }
            return
        }
    }

    /// Разобрать тег целиком. Вызывается на открывающей скобке.
    mutating func element() throws -> XMLNode {
        guard peek() == "<" else { throw XMLError.brokenTag(at: i) }
        i += 1

        let name = readName()
        guard !name.isEmpty else { throw XMLError.brokenTag(at: i) }

        var attributes: [String: String] = [:]
        while true {
            skipSpace()
            guard !done else { throw XMLError.unexpectedEnd }

            if peek() == "/", peek(1) == ">" {
                i += 2
                return XMLNode(name: name, attributes: attributes)
            }
            if peek() == ">" {
                i += 1
                break
            }

            let key = readName()
            guard !key.isEmpty else { throw XMLError.brokenTag(at: i) }
            skipSpace()
            guard peek() == "=" else {
                //  Атрибут без значения — вне стандарта, но падать
                //  из-за него не стоит.
                attributes[key] = ""
                continue
            }
            i += 1
            skipSpace()
            guard let quote = peek(), quote == "\"" || quote == "'" else {
                throw XMLError.brokenTag(at: i)
            }
            i += 1
            var raw = ""
            while let c = peek(), c != quote {
                raw.append(c)
                i += 1
            }
            guard !done else { throw XMLError.unexpectedEnd }
            i += 1
            attributes[key] = unescape(raw)
        }

        var kids: [XMLNode] = []
        var text = ""

        while true {
            guard !done else { throw XMLError.unexpectedEnd }

            if looksLike("</") {
                i += 2
                let close = readName()
                skipSpace()
                guard peek() == ">" else { throw XMLError.brokenTag(at: i) }
                i += 1
                guard close == name else {
                    throw XMLError.mismatchedTag(expected: name,
                                                 found: close)
                }
                let clean = text.trimmingCharacters(
                    in: .whitespacesAndNewlines)
                return XMLNode(name: name, attributes: attributes,
                               children: kids, text: clean)
            }

            if looksLike("<!--") { skip(past: "-->"); continue }

            if looksLike("<![CDATA[") {
                i += 9
                //  Внутри CDATA сущности не раскрываются, поэтому
                //  текст берётся как есть, минуя unescape.
                while !done, !looksLike("]]>") {
                    text.append(chars[i])
                    i += 1
                }
                guard !done else { throw XMLError.unexpectedEnd }
                i += 3
                continue
            }

            if peek() == "<" {
                kids.append(try element())
                continue
            }

            var raw = ""
            while let c = peek(), c != "<" {
                raw.append(c)
                i += 1
            }
            text += unescape(raw)
        }
    }
}

/// Раскрыть сущности: именованные, `&#1055;` и `&#x41F;`.
/// Нераспознанное остаётся как было.
private func unescape(_ s: String) -> String {
    guard s.contains("&") else { return s }

    let названия: [String: Character] = [
        "amp": "&", "lt": "<", "gt": ">",
        "quot": "\"", "apos": "'",
    ]

    var out = ""
    var rest = Substring(s)

    while let amp = rest.firstIndex(of: "&") {
        out += rest[rest.startIndex..<amp]
        let after = rest.index(after: amp)

        //  Нет «;» поблизости — это просто амперсанд в тексте.
        guard let semi = rest[after...].firstIndex(of: ";"),
              rest.distance(from: after, to: semi) <= 10 else {
            out.append("&")
            rest = rest[after...]
            continue
        }

        let body = String(rest[after..<semi])
        if let c = названия[body] {
            out.append(c)
        } else if body.hasPrefix("#x") || body.hasPrefix("#X") {
            if let n = UInt32(body.dropFirst(2), radix: 16),
               let scalar = UnicodeScalar(n) {
                out.append(Character(scalar))
            } else {
                out += "&\(body);"
            }
        } else if body.hasPrefix("#") {
            if let n = UInt32(body.dropFirst()),
               let scalar = UnicodeScalar(n) {
                out.append(Character(scalar))
            } else {
                out += "&\(body);"
            }
        } else {
            out += "&\(body);"
        }
        rest = rest[rest.index(after: semi)...]
    }
    out += rest
    return out
}
