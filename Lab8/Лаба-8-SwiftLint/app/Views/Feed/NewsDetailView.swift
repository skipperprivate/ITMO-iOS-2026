import SwiftUI

struct NewsDetailView: View {
    @Environment(SettingsViewModel.self) private var settings
    let item: Item
    let repository: NewsRepository
    @State private var editingItem: Item?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text(item.category.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.tint)
                Text(item.title)
                    .accessibilityIdentifier("article-title")
                    .font(.largeTitle.weight(.bold))
                Text(item.source)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                if settings.showDates {
                    Text(item.dateLabel).font(.caption).foregroundStyle(.secondary)
                    Text(item.timestamp, format: .dateTime.day().month().year().hour().minute())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let value = item.sourceURL, let url = URL(string: value),
                   let scheme = url.scheme?.lowercased(), ["https", "http"].contains(scheme) {
                    Link("Открыть оригинал", destination: url)
                }
                if let serverID = item.serverPostID {
                    Text("Учебный сервер принял запись: ID \(serverID). Копия хранится на устройстве.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Divider()
                Text(item.text)
                    .accessibilityIdentifier("article-body")
                    .font(.body)
                    .textSelection(.enabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Публикация")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if item.remoteID == nil {
                    Button("Редактировать", systemImage: "square.and.pencil") {
                        editingItem = item
                    }
                }
            }
        }
        .sheet(item: $editingItem) { article in
            NewsEditorView(item: article, repository: repository)
        }
    }
}
