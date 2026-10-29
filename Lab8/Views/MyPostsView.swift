import SwiftUI

struct MyPostsView: View {
    @EnvironmentObject private var viewModel: MyPostsViewModel

    var body: some View {
        NavigationStack {
            List {
                if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundStyle(.red)
                }

                if viewModel.posts.isEmpty {
                    Text("Постов пока нет")
                        .foregroundStyle(.secondary)
                }

                ForEach(viewModel.posts) { post in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(post.title)
                            .font(.headline)
                        Text(post.text)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Мои посты")
            .toolbar {
                NavigationLink("Создать пост") {
                    CreatePostView(myPosts: viewModel)
                }
            }
        }
    }
}