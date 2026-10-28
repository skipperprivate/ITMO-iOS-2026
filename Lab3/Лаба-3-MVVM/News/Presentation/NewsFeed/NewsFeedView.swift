import SwiftUI
 
struct NewsFeedView: View {
 
    @ObservedObject var viewModel: NewsFeedViewModel
 
    var body: some View {
 
        NavigationStack {
 
            Group {
 
                if viewModel.isLoading && viewModel.articles.isEmpty {
 
                    loadingView
 
                } else if let errorMessage = viewModel.errorMessage,
                          viewModel.articles.isEmpty {
 
                    errorView(message: errorMessage)
 
                } else {
 
                    newsList
                }
            }
            .navigationTitle("Новости")
            .task {
 
                if viewModel.articles.isEmpty {
                    await viewModel.loadNews()
                }
            }
        }
    }
 
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Загружаем новости...")
                .foregroundStyle(.secondary)
        }
    }
 
    private func errorView(message: String) -> some View {
 
        VStack(spacing: 16) {
 
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
 
            Text("Не удалось загрузить новости")
                .font(.headline)
 
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
 
            Button("Попробовать снова") {
 
                Task {
                    await viewModel.loadNews()
                }
            }
        }
        .padding()
    }
 
    private var newsList: some View {
 
        List(viewModel.articles) { article in
 
            VStack(
                alignment: .leading,
                spacing: 8
            ) {
 
                Text(article.title)
                    .font(.headline)
 
                Text(article.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            .padding(.vertical, 4)
        }
        .refreshable {
            await viewModel.loadNews()
        }
    }
}
 
