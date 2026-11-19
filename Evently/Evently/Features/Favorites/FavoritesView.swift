import SwiftUI

struct FavoritesView: View {

    @State private var viewModel: FavoritesViewModel
    @State private var selectedFavorite: FavoriteEvent?

    init(viewModel: FavoritesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if viewModel.favorites.isEmpty {
                emptyView
            } else {
                favoritesList
            }
        }
        .task {
            viewModel.load()
        }
        .navigationTitle("Избранное")
        .sheet(item: $selectedFavorite) { favorite in
            FavoriteNoteView(
                eventTitle: favorite.title,
                initialNote: favorite.note
            ) { note in
                viewModel.updateNote(
                    eventId: favorite.eventId,
                    note: note
                )
            }
        }
        .preferredColorScheme(.dark)
    }

    private var favoritesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.favorites) { event in
                    FavoriteEventCard(
                        event: event,
                        onEditNote: {
                            selectedFavorite = event
                        },
                        onDelete: {
                            viewModel.delete(eventId: event.eventId)
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Нет избранных событий")
                .font(.headline)
                .foregroundStyle(.white)

            Text(
                "Добавьте мероприятие в избранное, чтобы оно появилось здесь"
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
        }
    }
}
