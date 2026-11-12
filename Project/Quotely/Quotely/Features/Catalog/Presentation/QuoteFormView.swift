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
            return String(localized: "form.validation.text_empty")
        }
        if trimmedAuthor.isEmpty {
            return String(localized: "form.validation.author_empty")
        }
        if trimmedText.count > maxTextLength {
            return String(
                format: String(localized: "form.validation.text_length"),
                maxTextLength
            )
        }
        if trimmedAuthor.count > maxAuthorLength {
            return String(
                format: String(localized: "form.validation.author_length"),
                maxAuthorLength
            )
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("form.text") {
                    TextField("form.text_field", text: $text, axis: .vertical)
                }
                Section("form.author") {
                    TextField("form.author", text: $author)
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
            .navigationTitle("form.edit_title")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") { dismiss() }
                        .disabled(isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await save() }
                    } label: {
                        if isSaving {
                            ProgressView()
                                .accessibilityLabel("form.saving")
                        } else {
                            Text("form.save")
                        }
                    }
                    .disabled(isSaving || validationError != nil)
                }
            }
            .onAppear {
                text = quote.text
                author = quote.author
            }
            .alert("form.save_error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("common.ok", role: .cancel) { errorMessage = nil }
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
