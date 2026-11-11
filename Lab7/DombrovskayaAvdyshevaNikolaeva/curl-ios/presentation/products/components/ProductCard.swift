import SwiftUI

struct ProductCard: View {
    let product: Product
    let isFavorite: Bool
    let onFavoriteClick: () -> Void
    var onProductClick: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Color.lightPink
                    AsyncImage(url: product.imageUrl) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                        default:
                            Image("curly_wave")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                .frame(width: 80, height: 80)
                .cornerRadius(12)
                .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text(product.name)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.darkGreen)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button(action: onFavoriteClick) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .accentPink : .gray)
                        }
                        .frame(width: 24, height: 24)
                    }

                    Text(product.description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(3)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            FlowLayout(spacing: 6) {
                ForEach(product.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .foregroundColor(.accentPink)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentPink.opacity(0.2))
                        .cornerRadius(8)
                        .frame(height: 24)
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .contentShape(Rectangle())
        .onTapGesture(perform: onProductClick)
    }
}
