import SwiftUI

struct FavoriteNoteView: View {

    let eventTitle: String
    let onSave: (String) -> Void

    @Environment(\.dismiss)
    private var dismiss

    @State private var note: String

    init(
        eventTitle: String,
        initialNote: String,
        onSave: @escaping (String) -> Void
    ) {
        self.eventTitle = eventTitle
        self.onSave = onSave

        _note = State(
            initialValue: initialNote
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                VStack(
                    alignment: .leading,
                    spacing: 16
                ) {
                    Text(eventTitle)
                        .font(.headline)
                        .foregroundStyle(.white)

                    TextEditor(text: $note)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(.white)
                        .padding(12)
                        .frame(minHeight: 180)
                        .background(
                            Color.white.opacity(0.08)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 16
                            )
                        )

                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Заметка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    placement: .cancellationAction
                ) {
                    Button("Отмена") {
                        dismiss()
                    }
                }

                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Button("Сохранить") {
                        let trimmedNote =
                            note.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            )

                        onSave(trimmedNote)

                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
