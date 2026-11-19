import Foundation
import Combine
import SwiftUI

@MainActor
final class FavoritesViewModel: ObservableObject {
    @Published private(set) var state: FavoritesViewState = .loading

    private let getUseCase: GetFavoritesUseCase
    private let removeUseCase: RemoveFavoriteUseCase
    private let updateNoteUseCase: UpdateFavoriteNoteUseCase
    private let reorderUseCase: ReorderFavoritesUseCase

    init(
        getUseCase: GetFavoritesUseCase,
        removeUseCase: RemoveFavoriteUseCase,
        updateNoteUseCase: UpdateFavoriteNoteUseCase,
        reorderUseCase: ReorderFavoritesUseCase
    ) {
        self.getUseCase = getUseCase
        self.removeUseCase = removeUseCase
        self.updateNoteUseCase = updateNoteUseCase
        self.reorderUseCase = reorderUseCase
    }

    func load() async {
        do {
            let items = try await getUseCase.execute()
            state = items.isEmpty ? .empty : .loaded(items)
        } catch {
            state = .error(message: (error as? LocalizedError)?.errorDescription ?? "Что-то пошло не так.")
        }
    }

    func delete(id: UUID) async {
        do {
            try await removeUseCase.execute(id: id)
            await load()
        } catch {
            state = .error(message: (error as? LocalizedError)?.errorDescription ?? "Что-то пошло не так.")
        }
    }

    func deleteAll() async {
        do {
            try await removeUseCase.executeAll()
            await load()
        } catch {
            state = .error(message: (error as? LocalizedError)?.errorDescription ?? "Что-то пошло не так.")
        }
    }

    func updateNote(id: UUID, note: String?) async {
        do {
            try await updateNoteUseCase.execute(id: id, note: note)
            await load()
        } catch {
            state = .error(message: (error as? LocalizedError)?.errorDescription ?? "Что-то пошло не так.")
        }
    }

    func move(from source: IndexSet, to destination: Int) async {
        guard case .loaded(var items) = state else { return }
        items.move(fromOffsets: source, toOffset: destination)
        state = .loaded(items)
        do {
            try await reorderUseCase.execute(ids: items.map(\.id))
        } catch {
            state = .error(message: (error as? LocalizedError)?.errorDescription ?? "Что-то пошло не так.")
        }
    }
}
