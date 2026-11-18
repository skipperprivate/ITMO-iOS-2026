//
//  HistoryView.swift
//  Lab2
//
//  Created by n grebenkin on 01.10.2026.
//

import SwiftUI

struct HistoryView: View {
    @State private var viewModel: HistoryViewModel
    @State private var editingItem: GeneratedNumber?
    @State private var isEditingNote = false
    @State private var noteDraft = ""
    @State private var isConfirmingClear = false

    init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                Button { startEditing(item) } label: { HistoryRow(item: item) }
                    .tint(.primary)
            }
            .onDelete(perform: viewModel.delete(at:))
        }
        .overlay {
            if viewModel.items.isEmpty {
                ContentUnavailableView("История пуста", systemImage: "clock",
                                       description: Text("Сгенерируйте число на главном экране"))
            }
        }
        .navigationTitle("История")
        .toolbar {
            Button("Очистить", role: .destructive) { isConfirmingClear = true }
                .disabled(viewModel.items.isEmpty)
        }
        .confirmationDialog("Удалить всю историю?", isPresented: $isConfirmingClear, titleVisibility: .visible) {
            Button("Удалить всё", role: .destructive, action: viewModel.deleteAll)
        }
        .alert("Заметка", isPresented: $isEditingNote, presenting: editingItem) { item in
            TextField("Текст заметки", text: $noteDraft)
            Button("Сохранить") { viewModel.updateNote(item, note: noteDraft) }
            Button("Отмена", role: .cancel) {}
        } message: { item in
            Text("Число \(item.value)")
        }
        .onAppear(perform: viewModel.load)
    }

    private func startEditing(_ item: GeneratedNumber) {
        editingItem = item
        noteDraft = item.note
        isEditingNote = true
    }
}

private struct HistoryRow: View {
    let item: GeneratedNumber

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(String(item.value))
                .font(.title3.monospacedDigit())
            if !item.note.isEmpty {
                Text(item.note)
                    .font(.subheadline)
            }
            Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}
