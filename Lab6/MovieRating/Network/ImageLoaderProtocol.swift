import Foundation

protocol ImageLoaderProtocol:
    AnyObject {

    func loadImageData(
        from url: URL
    ) async throws -> Data
}
