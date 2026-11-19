import Foundation

protocol UpdateFavoriteNoteUseCase: Sendable {
    func execute(id: UUID, note: String?) async throws
}

struct DefaultUpdateFavoriteNoteUseCase: UpdateFavoriteNoteUseCase {
    let repository: FavoritesRepository

    func execute(id: UUID, note: String?) async throws {
        let normalized = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = (normalized?.isEmpty ?? true) ? nil : normalized
        try await repository.updateNote(id: id, note: value)
    }
}
