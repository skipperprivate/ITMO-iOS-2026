//
//  QuoteFormView.swift
//  Quotely
//
//  Created by Egor Kuzminykh on 01.10.2026.
//

import SwiftUI

struct QuoteFormView: View {
    let quote: Quote
    let onSave: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var author = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Текст") {
                    TextField("Текст цитаты", text: $text, axis: .vertical)
                }
                Section("Автор") {
                    TextField("Автор", text: $author)
                }
            }
            .navigationTitle("Изменить цитату")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        onSave(text, author)
                        dismiss()
                    }
                    .disabled(text.isEmpty)
                }
            }
            .onAppear {
                text = quote.text
                author = quote.author
            }
        }
    }
}
