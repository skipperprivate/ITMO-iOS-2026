import SwiftUI
import SwiftData

struct ContentView: View {
    private let viewModel = MenuViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.system(size: 54))
                    .foregroundStyle(.blue)

                Text("Mini Twitter")
                    .font(.largeTitle.bold())

                Text("Выберите ленту, чтобы посмотреть твиты")
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    ForEach(viewModel.menuItems) { item in
                        NavigationLink {
                            TweetsView(title: item.title)
                        } label: {
                            Label(item.title, systemImage: item.iconName)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue, in: RoundedRectangle(cornerRadius: 14))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.top, 24)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Главная")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .modelContainer(for: Tweet.self, inMemory: true)
            .environmentObject(TweetRepositoryProvider(metadataSuite: "Lab3.ContentPreview", api: MockTweetsAPI()))
    }
}
