//  RateSource.swift
//  Получение курсов из сети.

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

//  MARK: - Транспорт

/// Загрузка данных по URL.
public protocol Transport: Sendable {
    func get(_ url: URL) async throws -> Data
}

public enum NetError: Error, Equatable {
    case badURL
    /// Код ответа сервера вне 2xx.
    case http(Int)
    case empty
    /// Нет соединения или истекло время ожидания.
    case offline(String)
}

public struct URLTransport: Transport {

    private let session: URLSession

    public init(timeout: TimeInterval = 20) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        //  Системный кэш не нужен: своё хранилище работает
        //  по собственным правилам.
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: config)
    }

    public func get(_ url: URL) async throws -> Data {
        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse,
               !(200..<300).contains(http.statusCode) {
                throw NetError.http(http.statusCode)
            }
            guard !data.isEmpty else { throw NetError.empty }
            return data
        } catch let e as NetError {
            throw e
        } catch {
            throw NetError.offline(error.localizedDescription)
        }
    }
}

//  MARK: - Источник курсов

public protocol RateSource: Sendable {

    func rates(on date: Date) async throws -> [Rate]

    /// `id` — внутренний код ЦБ (`R01235`): история доступна
    /// только по нему.
    func history(id: String, from: Date, to: Date) async throws
        -> [HistoryPoint]
}

/// XML-сервис ЦБ РФ.
public struct CBRSource: RateSource {

    public static let host = "https://www.cbr.ru/scripts"

    private let transport: Transport

    public init(transport: Transport = URLTransport()) {
        self.transport = transport
    }

    public func rates(on date: Date) async throws -> [Rate] {
        let s = "\(Self.host)/XML_daily.asp"
            + "?date_req=\(DateBits.forRequest(date))"
        guard let url = URL(string: s) else { throw NetError.badURL }
        return try CBRParser.rates(from: await transport.get(url))
    }

    public func history(id: String, from: Date, to: Date) async throws
        -> [HistoryPoint] {
        let s = "\(Self.host)/XML_dynamic.asp"
            + "?date_req1=\(DateBits.forRequest(from))"
            + "&date_req2=\(DateBits.forRequest(to))"
            + "&VAL_NM_RQ=\(id)"
        guard let url = URL(string: s) else { throw NetError.badURL }
        return try CBRParser.history(from: await transport.get(url))
    }
}
