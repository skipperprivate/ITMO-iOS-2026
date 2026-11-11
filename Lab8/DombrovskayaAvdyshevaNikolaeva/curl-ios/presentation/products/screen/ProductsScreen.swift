import SwiftUI

struct ProductsScreen: View {
    @StateObject private var viewModel: ProductsViewModel

    @State private var selectedProduct: Product?
    @State private var isFilterVisible = false

    init(viewModel: @autoclosure @escaping () -> ProductsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                introCard
                controls
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
                content
            }
            .padding(24)
        }
        .background(Color(.curlySurface).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(Color(.curlyDarkGreen))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Image(systemName: "person.circle")
                    .foregroundColor(Color(.curlyDarkGreen))
            }
        }
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

    private var header: some View {
        Text("База средств")
            .font(.system(size: 28, weight: .regular, design: .serif))
            .foregroundColor(Color(.curlyDarkGreen))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 16)
    }

    private var introCard: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundColor(Color(.curlyGreen))
                .padding(12)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

            Text("Подберите средства под тип ваших волос или сохраните любимые в избранное")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(.curlyDarkGreen))
                .lineSpacing(4)
        }
        .padding(20)
        .background(Color(.curlySurface))
        .cornerRadius(24)
    }

    private var controls: some View {
        HStack(spacing: 12) {
            SegmentedControl(
                items: ["Все продукты", "Избранное"],
                defaultSelectedIndex: viewModel.selectedTab == .allProducts ? 0 : 1,
                onSelection: { index in
                    viewModel.selectTab(index == 0 ? .allProducts : .favoriteProducts)
                }
            )
            .frame(maxWidth: .infinity)

            Button {
                withAnimation { isFilterVisible.toggle() }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.system(size: 22))
                    .foregroundColor(Color(.curlyDarkGreen))
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProductsLoading()
                .padding(.top, 40)
        } else if let error = viewModel.error {
            ErrorMessage(message: error)
                .padding(.top, 40)
        } else {
            let productsToShow: [Product] = {
                switch viewModel.selectedTab {
                case .allProducts:      return viewModel.filteredProducts
                case .favoriteProducts: return viewModel.favoriteProducts
                }
            }()

            if productsToShow.isEmpty {
                Text("Пока нет средств по выбранным фильтрам")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(.curlyDarkGreen).opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(productsToShow) { product in
                        ProductCard(
                            product: product,
                            isFavorite: viewModel.favorites.contains { $0.productId == product.id },
                            onFavoriteClick: {
                                Task { await viewModel.toggleFavorite(productId: product.id) }
                            },
                            onProductClick: {
                                selectedProduct = product
                                Task { await viewModel.loadReviews(product.id) }
                            }
                        )
                    }
                }
            }
        }
    }
}
