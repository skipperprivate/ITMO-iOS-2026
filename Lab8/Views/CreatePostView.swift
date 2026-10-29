import SwiftUI

@MainActor
struct CreatePostView: View {
    @StateObject private var viewModel: CreatePostViewModel

    init(myPosts: MyPostsViewModel) {
        _viewModel = StateObject(
            wrappedValue: CreatePostViewModel(myPosts: myPosts)
        )
    }

    var body: some View {
        Form {
            Section("Новый пост") {
                TextField(
                    "Заголовок",
                    text: $viewModel.title
                )

                TextField(
                    "Текст",
                    text: $viewModel.text,
                    axis: .vertical
                )
            }
            .disabled(viewModel.isLoading)

            if let message = viewModel.errorMessage {
                Text(message)
                    .foregroundStyle(.red)
            }

            if let message = viewModel.successMessage {
                Text(message)
                    .foregroundStyle(.green)
            }

            if viewModel.isLoading {
                ProgressView("Отправка...")
            }

            Button("Создать") {
                Task {
                    await viewModel.sendPost()
                }
            }
            .disabled(viewModel.isLoading)
        }
        .navigationTitle("Создать пост")
    }
}
