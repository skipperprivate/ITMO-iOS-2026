import SwiftUI

struct ReviewModalSheet: View {
    let product: Product
    @ObservedObject var viewModel: ProductsViewModel
    let onDismiss: () -> Void
    
    @State private var rating: Int = 0
    @State private var comment: String = ""
    @State private var editingReview: Review?
    @State private var userId: UUID?
    @State private var username: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                productHeaderCard
                
                reviewFormCard
                
                reviewsListCard
                
                Spacer().frame(height: 8)
                
                reviewsSection
            }
            .padding(16)
        }
        .background(Color.lightBeige)
        .task {
            userId = viewModel.getCurrentUserId()
            username = viewModel.getCurrentUsername()
            await viewModel.loadReviews(product.id)
        }
    }
    
    private var productHeaderCard: some View {
        HStack(spacing: 12) {
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
            .frame(width: 64, height: 64)
            .cornerRadius(12)
            .clipped()
            
            Text(product.name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.darkGreen)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private var reviewFormCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(editingReview != nil ? "Редактировать отзыв" : "Оставить отзыв")
                .font(.headline)
                .foregroundColor(.darkGreen)
            
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        rating = i
                    } label: {
                        Image(systemName: i <= rating ? "star.fill" : "star")
                            .font(.system(size: 24))
                            .foregroundColor(i <= rating ? .accentPink : .gray)
                            .frame(width: 40, height: 40)
                    }
                }
            }
            
            TextField("Ваш отзыв", text: $comment, axis: .vertical)
                .lineLimit(1...3)
                .textFieldStyle(.roundedBorder)
            
            if editingReview != nil {
                HStack(spacing: 8) {
                    Button {
                        editingReview = nil
                        rating = 0
                        comment = ""
                    } label: {
                        Text("Отменить")
                            .foregroundColor(.darkGreen)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.darkGreen, lineWidth: 1)
                            )
                    }
                    
                    Button {
                        if let review = editingReview {
                            Task {
                                await viewModel.deleteReview(product.id, review.id)
                                editingReview = nil
                                rating = 0
                                comment = ""
                            }
                        }
                    } label: {
                        Text("Удалить")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.accentPink)
                            .cornerRadius(8)
                    }
                }
            }
            
            Button {
                Task {
                    if let editing = editingReview {
                        await viewModel.updateReview(
                            productId: product.id,
                            reviewId: editing.id,
                            mark: rating,
                            reviewText: comment
                        )
                    } else {
                        await viewModel.submitReview(
                            productId: product.id,
                            mark: rating,
                            reviewText: comment
                        )
                    }
                    editingReview = nil
                    rating = 0
                    comment = ""
                }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(editingReview != nil ? "Обновить" : "Отправить")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.lightGreen)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(rating == 0 || comment.trimmingCharacters(in: .whitespaces).isEmpty || userId == nil)
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private var reviewsListCard: some View {
        HStack {
            Text("Все отзывы")
                .font(.headline)
                .foregroundColor(.darkGreen)
            
            Spacer()
            
            Image(systemName: "star.fill")
                .font(.system(size: 20))
                .foregroundColor(.darkGreen.opacity(0.6))
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    @ViewBuilder
    private var reviewsSection: some View {
        if viewModel.isLoading {
            ProgressView()
                .tint(.accentPink)
                .frame(maxWidth: .infinity)
                .padding()
            
        } else if viewModel.reviews.isEmpty {
            Text("Пока нет отзывов")
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            
        } else {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.reviews) { review in
                    let isCurrentUserReview = review.userId == userId
                    
                    ReviewItem(
                        review: review,
                        showMenu: isCurrentUserReview,
                        onEditClick: isCurrentUserReview ? { handleEdit(review) } : nil,
                        onDeleteClick: isCurrentUserReview ? { handleDelete(review) } : nil
                    )
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                }
            }
        }
    }
    
    private func handleEdit(_ review: Review) {
        editingReview = review
        rating = review.rating
        comment = review.comment
    }
    
    private func handleDelete(_ review: Review) {
        Task {
            await viewModel.deleteReview(product.id, review.id)
        }
    }
}
