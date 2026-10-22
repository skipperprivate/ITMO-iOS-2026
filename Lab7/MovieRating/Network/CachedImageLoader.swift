import Foundation

final class CachedImageLoader:
    ImageLoaderProtocol {

    enum ImageLoaderError:
        Error {

        case invalidStatusCode(Int)
    }

    private let httpClient:
        HTTPClientProtocol

    private let cache =
        NSCache<NSURL, NSData>()

    init(
        httpClient:
            HTTPClientProtocol
    ) {
        self.httpClient =
            httpClient
    }

    func loadImageData(
        from url: URL
    ) async throws -> Data {

        let key =
            url as NSURL

        if let cachedData =
            cache.object(
                forKey: key
            ) {

            return cachedData
                as Data
        }

        let request =
            URLRequest(
                url: url
            )

        let (data, response) =
            try await httpClient.data(
                for: request
            )

        guard
            (200...299).contains(
                response.statusCode
            )
        else {
            throw ImageLoaderError
                .invalidStatusCode(
                    response.statusCode
                )
        }

        cache.setObject(
            data as NSData,
            forKey: key
        )

        return data
    }
}
