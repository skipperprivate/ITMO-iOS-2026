//
//  QuoteFormView.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 01.10.2026.
//

import SwiftUI

struct QuoteFormView: View {
    let quote: Quote
    let onSave: (String, String) async throws -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var author = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let maxTextLength = 500
    private let maxAuthorLength = 100

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedAuthor: String {
        author.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var validationError: String? {
        if trimmedText.isEmpty {
            return "Введите текст цитаты."
        }
        if trimmedAuthor.isEmpty {
            return "Укажите автора."
        }
        if trimmedText.count > maxTextLength {
            return "Текст цитаты не должен быть длиннее \(maxTextLength) символов."
        }
        if trimmedAuthor.count > maxAuthorLength {
            return "Имя автора не должно быть длиннее \(maxAuthorLength) символов."
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Текст") {
                    TextField("Текст цитаты", text: $text, axis: .vertical)
                }
                Section("Автор") {
                    TextField("Автор", text: $author)
                }
                if let validationError, !isSaving {
                    Section {
                        Text(validationError)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .disabled(isSaving)
            .navigationTitle("Изменить цитату")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .accessibilityLabel("Сохранение цитаты")
                        } else {
                            Text("Сохранить")
                        }
                    }
                    .disabled(isSaving || validationError != nil)
                }
            }
            .onAppear {
                text = quote.text
                author = quote.author
            }
            .alert("Не удалось сохранить цитату", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("ОК", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
        .interactiveDismissDisabled(isSaving)
    }

    private func save() async {
        guard !isSaving else { return }
        if let validationError {
            errorMessage = validationError
            return
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await onSave(trimmedText, trimmedAuthor)
            dismiss()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
