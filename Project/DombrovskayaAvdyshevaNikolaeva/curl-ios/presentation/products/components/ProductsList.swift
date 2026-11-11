import SwiftUI

struct ProductsList: View {
    let productsToShow: [Product]
    let onFavoriteClick: (UUID) -> Void
    let onProductClick: (Product) -> Void
    let isProductFavorite: (UUID) -> Bool

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(productsToShow) { product in
                    ProductCard(
                        product: product,
                        isFavorite: isProductFavorite(product.id),
                        onFavoriteClick: { onFavoriteClick(product.id) },
                        onProductClick: { onProductClick(product) }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(16)
        }
    }
}
