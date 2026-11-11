import SwiftUI

struct ProductCard: View {
    let product: Product
    let isFavorite: Bool
    let onFavoriteClick: () -> Void
    var onProductClick: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Color(.curlySurface)
                    AsyncImage(url: product.imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        default:
                            Image("curly_wave").resizable().scaledToFit()
                        }
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(16)
                .clipped()

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top) {
                        Text(product.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(.curlyDarkGreen))
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: onFavoriteClick) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? Color( .curlyAccentPink) : Color(.curlyDarkGreen).opacity(0.4))
                                .frame(width: 24, height: 24)
                        }
                    }

                    Text(product.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color(.curlyDarkGreen).opacity(0.7))
                        .lineSpacing(3)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if !product.tags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(product.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(.curlyGreen))
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color(.curlyGreen).opacity(0.12))
                            .cornerRadius(10)
                            .frame(height: 24)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture(perform: onProductClick)
    }
}
