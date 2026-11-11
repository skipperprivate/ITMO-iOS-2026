//
//  RecipeImageLoader.swift
//  RecipeBook
//
//  Created by Viktor Medyankin on 07.10.2026.
//

import Foundation
import UIKit

actor RecipeImageLoader {
    
    static let shared = RecipeImageLoader()
    
    private var cache: [URL: UIImage] = [:]
    
    private init() {}
    
    
    func loadImage(from url: URL) async throws -> UIImage {
        if let cachedImage = cache[url] {
            return cachedImage
        }
        
        let (data, response) = try await URLSession.shared.data(
            from: url
        )
        
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }
        
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        cache[url] = image
        
        return image
    }
}
