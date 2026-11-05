import Foundation
import UIKit

enum RecipePhotoLoader {
    enum PhotoError: LocalizedError {
        case invalidURL
        case badResponse
        case tooLarge
        case notAnImage

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Введите полную ссылку на изображение, начиная с https:// или http://"
            case .badResponse:
                return "Не удалось скачать фото. Проверьте ссылку и попробуйте снова."
            case .tooLarge:
                return "Фото слишком большое. Выберите изображение размером до 10 МБ."
            case .notAnImage:
                return "По этой ссылке нет подходящего изображения. Нужна ссылка на само фото, а не на страницу сайта."
            }
        }
    }

    static func load(from address: String, session: URLSession = .shared) async throws -> Data {
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmedAddress),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              let host = url.host, !host.isEmpty else {
            throw PhotoError.invalidURL
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.setValue("image/*", forHTTPHeaderField: "Accept")
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw PhotoError.badResponse
        }
        guard data.count <= 10_000_000 else {
            throw PhotoError.tooLarge
        }
        // Сервер может вернуть HTML-страницу даже со статусом 200.
        guard UIImage(data: data) != nil else {
            throw PhotoError.notAnImage
        }
        return data
    }
}
