import SwiftUI

struct ProductsScreen: View {
    @StateObject private var viewModel: ProductsViewModel

    @State private var selectedProduct: Product?
    @State private var isFilterVisible = false

    init(viewModel: @autoclosure @escaping () -> ProductsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("База средств")
                    .font(.largeTitle)
                    .foregroundColor(.darkGreen)
                    .padding(.horizontal, 8)
                    .padding(.top, 24)

                Spacer().frame(height: 24)

                HStack(spacing: 8) {
                    SegmentedControl(
                        items: ["Все продукты", "Избранное"],
                        defaultSelectedIndex: viewModel.selectedTab == .allProducts ? 0 : 1,
                        onSelection: { index in
                            viewModel.selectTab(index == 0 ? .allProducts : .favoriteProducts)
                        }
                    )
                    .frame(maxWidth: .infinity)

                    Button {
                        withAnimation {
                            isFilterVisible.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 24))
                            .foregroundColor(.lightBeige)
                            .frame(width: 48, height: 48)
                            .background(Color.brightPink)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 8)

                if isFilterVisible {
                    FilterPanel(
                        porosityTag: viewModel.porosityTag,
                        coloringTag: viewModel.coloringTag,
                        thicknessTag: viewModel.thicknessTag,
                        onTagClick: { category, tag in
                            viewModel.toggleTag(category: category, tag: tag)
                        },
                        onReset: {
                            viewModel.clearAllFilters()
                            withAnimation { isFilterVisible = false }
                        },
                        onSave: {
                            withAnimation { isFilterVisible = false }
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                Spacer().frame(height: 16)

                content
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedProduct) { product in
            ReviewModalSheet(
                product: product,
                viewModel: viewModel,
                onDismiss: { selectedProduct = nil }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProductsLoading()
        } else if let error = viewModel.error {
            ErrorMessage(message: error)
        } else {
            let productsToShow: [Product] = {
                switch viewModel.selectedTab {
                case .allProducts:      return viewModel.filteredProducts
                case .favoriteProducts: return viewModel.favoriteProducts
                }
            }()

            ProductsList(
                productsToShow: productsToShow,
                onFavoriteClick: { id in
                    Task { await viewModel.toggleFavorite(productId: id) }
                },
                onProductClick: { product in
                    selectedProduct = product
                    Task { await viewModel.loadReviews(product.id) }
                },
                isProductFavorite: { id in
                    viewModel.favorites.contains { $0.productId == id }
                }
            )
        }
    }
}
