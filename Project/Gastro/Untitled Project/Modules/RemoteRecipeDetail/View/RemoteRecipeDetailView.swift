import SwiftUI

@MainActor
struct RemoteRecipeDetailView<Presenter: RemoteRecipeDetailViewOutput>: View {
    @StateObject private var presenter: Presenter

    init(presenter: @autoclosure @escaping () -> Presenter) {
        _presenter = StateObject(wrappedValue: presenter())
    }

    var body: some View {
        Group {
            if presenter.state.isLoaded {
                List {
                    if let imageURL = presenter.state.imageURL {
                        Section {
                            GeometryReader { geometry in
                                AsyncImage(url: imageURL) { phase in
                                    switch phase {
                                        case .empty:
                                            ProgressView("Loading image…")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .onAppear {
                                                    #if DEBUG
                                                    print("[Recipe Image] Loading: \(imageURL.absoluteString)")
                                                    #endif
                                                }
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: geometry.size.width, height: 220)
                                                .clipped()
                                                .accessibilityLabel("Photo of \(presenter.state.title)")
                                                .onAppear {
                                                    #if DEBUG
                                                    print("[Recipe Image] Loaded: \(imageURL.absoluteString)")
                                                    #endif
                                                }
                                        case .failure(let error):
                                            Label("Image unavailable", systemImage: "photo")
                                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                                .foregroundStyle(.secondary)
                                                .onAppear {
                                                    #if DEBUG
                                                    print(
                                                        "[Recipe Image] Failed: \(imageURL.absoluteString) — \(error)"
                                                    )
                                                    #endif
                                                }
                                        @unknown default:
                                            EmptyView()
                                    }
                                }
                                .frame(width: geometry.size.width, height: 220)
                            }
                            .frame(height: 220)
                            .listRowInsets(EdgeInsets())
                        }
                    }
                    if let minutes = presenter.state.cookingTimeMinutes {
                        Section {
                            Label("Total time: \(minutes) min", systemImage: "clock")
                        }
                    }
                    Section("Ingredients") {
                        ForEach(Array(presenter.state.ingredients.enumerated()), id: \.offset) { _, ingredient in
                            Text(ingredient)
                        }
                    }
                    Section("Instructions") {
                        ForEach(Array(presenter.state.steps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1).")
                                    .foregroundStyle(Color("AccentColor"))
                                    .fontWeight(.bold)
                                Text(step)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            } else if let error = presenter.state.error {
                ContentUnavailableView {
                    Label("Could not load recipe", systemImage: "wifi.exclamationmark")
                } description: {
                    Text(error)
                } actions: {
                    Button("Retry") { Task { await presenter.load() } }
                    Button("Back to recipes", action: presenter.goBack)
                }
            } else {
                ProgressView("Loading recipe…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(red: 0.965, green: 0.973, blue: 0.965))
        .navigationTitle(presenter.state.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "globe")
                    .accessibilityLabel("Online recipe")
            }
        }
        .task { await presenter.load() }
    }
}
