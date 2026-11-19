import SwiftUI

struct RecipeImageView: View {
    let data: Data?

    @State private var image: UIImage?
    @State private var hasFailed = false

    var body: some View {
        Group {
            if let image {
                GeometryReader { geometry in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                }
            } else if data != nil && !hasFailed {
                ProgressView()
                    .tint(AppColors.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Image(systemName: "camera")
                    .font(.system(size: 28, weight: .regular))
                    .frame(width: 36, height: 32)
                    .foregroundStyle(AppColors.warm)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: data) {
            image = nil
            hasFailed = false
            guard let data else { return }

            let loadedImage = await Self.prepare(data)
            guard !Task.isCancelled else { return }
            image = loadedImage
            hasFailed = loadedImage == nil
        }
    }

    @concurrent
    static func prepare(_ data: Data) async -> UIImage? {
        guard !Task.isCancelled, let sourceImage = UIImage(data: data) else {
            return nil
        }
        return await sourceImage.byPreparingForDisplay()
    }
}
