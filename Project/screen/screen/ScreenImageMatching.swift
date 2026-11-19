import CoreGraphics
import Foundation

nonisolated struct GrayImage: Sendable {
    let width: Int
    let height: Int
    var pixels: [UInt8]

    init?(image: CGImage, width: Int, height: Int) {
        guard width > 0, height > 0 else { return nil }
        self.width = width
        self.height = height
        var pixels = [UInt8](repeating: 0, count: width * height)
        let drawn = pixels.withUnsafeMutableBytes { bytes -> Bool in
            guard let context = CGContext(data: bytes.baseAddress, width: width, height: height,
                                          bitsPerComponent: 8, bytesPerRow: width,
                                          space: CGColorSpaceCreateDeviceGray(), bitmapInfo: 0) else { return false }
            context.interpolationQuality = .medium
            context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
            return true
        }
        guard drawn else { return nil }
        self.pixels = pixels
    }

    func difference(from other: GrayImage) -> Double? {
        guard width == other.width, height == other.height else { return nil }
        let total = zip(pixels, other.pixels).reduce(0) { $0 + abs(Int($1.0) - Int($1.1)) }
        return Double(total) / Double(pixels.count * 255)
    }
}

nonisolated enum ScreenImageMatching {
    struct Match: Sendable {
        var score: Double
        /// Normalized bounds in the analyzed image.
        var bounds: CGRect
    }

    /// Bounded multi-scale search. Brightness similarity is deliberately not semantic similarity.
    static func locate(_ reference: CGImage, in image: CGImage) -> Match? {
        let width = min(240, image.width)
        let height = max(1, Int(Double(image.height) * Double(width) / Double(image.width)))
        guard let screen = GrayImage(image: image, width: width, height: height) else { return nil }
        let nativeWidth = Double(reference.width) * Double(width) / Double(image.width)
        let candidates = [nativeWidth * 0.75, nativeWidth, nativeWidth * 1.25,
                          Double(width) * 0.15, Double(width) * 0.3, Double(width) * 0.5, Double(width)]
        var best: Match?
        for templateWidth in Set(candidates.map { max(8, Int($0)) }).sorted() {
            let templateHeight = max(8, Int(Double(templateWidth) * Double(reference.height) / Double(reference.width)))
            guard templateWidth <= width, templateHeight <= height,
                  let template = GrayImage(image: reference, width: templateWidth, height: templateHeight) else { continue }
            // Coarse sampling keeps cost bounded even for large reference images.
            let sampleStep = max(1, min(templateWidth, templateHeight) / 16)
            var bestX = 0
            var bestY = 0
            var bestScore = -1.0
            func score(x: Int, y: Int) -> Double {
                var error = 0
                var count = 0
                for row in stride(from: 0, to: templateHeight, by: sampleStep) {
                    for col in stride(from: 0, to: templateWidth, by: sampleStep) {
                        error += abs(Int(screen.pixels[(y + row) * width + x + col]) - Int(template.pixels[row * templateWidth + col]))
                        count += 1
                    }
                }
                return 1 - Double(error) / Double(max(1, count) * 255)
            }
            for y in stride(from: 0, through: height - templateHeight, by: 4) {
                for x in stride(from: 0, through: width - templateWidth, by: 4) {
                    let candidate = score(x: x, y: y)
                    if candidate > bestScore { bestScore = candidate; bestX = x; bestY = y }
                }
            }
            let coarseX = bestX
            let coarseY = bestY
            for y in max(0, coarseY - 3)...min(height - templateHeight, coarseY + 3) {
                for x in max(0, coarseX - 3)...min(width - templateWidth, coarseX + 3) {
                    let candidate = score(x: x, y: y)
                    if candidate > bestScore { bestScore = candidate; bestX = x; bestY = y }
                }
            }
            if bestScore > (best?.score ?? -1) {
                best = Match(score: bestScore, bounds: CGRect(x: Double(bestX) / Double(width),
                             y: Double(bestY) / Double(height), width: Double(templateWidth) / Double(width),
                             height: Double(templateHeight) / Double(height)))
            }
        }
        return best
    }
}
