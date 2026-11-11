import Foundation
import UIKit

final class RecipeImageLoader {
    static let shared = RecipeImageLoader()
    private init() {}

    private let cache = NSCache<NSURL, UIImage>()

    func loadImage(from url: URL) async throws -> UIImage {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            return cachedImage
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        guard let image = UIImage(data: data, scale: 1.0) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        cache.setObject(image, forKey: url as NSURL)
        return image
    }
}
