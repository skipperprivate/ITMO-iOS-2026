import SwiftUI

struct AsyncRecipeImage: View {
    
    let url: String
    var height: CGFloat
    
    @State private var image: Image?
    @State private var isLoading = true
    @State private var hasError = false
    
    var body: some View {
        
        ZStack {
            
            if let image {
                
                image
                    .resizable()
                    .scaledToFill()
                
            } else if hasError {
                
                ZStack {
                    Color.gray.opacity(0.12)
                    
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
                
            } else {
                
                ZStack {
                    Color.gray.opacity(0.12)
                    
                    if isLoading {
                        ProgressView()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .task {
            await loadImage()
        }
    }
    
//    private func loadImage() async {
//        
//        guard let imageURL = URL(string: url) else {
//            hasError = true
//            isLoading = false
//            return
//        }
//        
//        do {
//            
//            let uiImage = try await RecipeImageLoader.shared.loadImage(
//                from: imageURL
//            )
//            
//            image = Image(uiImage: uiImage)
//            isLoading = false
//            
//        } catch {
//            
//            hasError = true
//            isLoading = false
//        }
//    }
    private func loadImage() async {
        guard image == nil, !hasError else { return }
        
        guard let imageURL = URL(string: url) else {
            hasError = true
            isLoading = false
            return
        }
        
        do {
            let uiImage = try await RecipeImageLoader.shared.loadImage(from: imageURL)
            image = Image(uiImage: uiImage)
            isLoading = false
        } catch {
            hasError = true
            isLoading = false
        }
    }
}
