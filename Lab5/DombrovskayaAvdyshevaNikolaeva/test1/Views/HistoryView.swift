import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NumberEntry.date, order: .reverse)
    private var entries: [NumberEntry]
    
    @State private var editingEntry: NumberEntry?
    @State private var newValue: String = ""
    
    var body: some View {
        List {
            ForEach(entries) { entry in
                HStack {
                    Text("\(entry.value)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text(entry.date, style: .time)
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    editingEntry = entry
                    newValue = "\(entry.value)"
                }
            }
            .onDelete(perform: deleteEntries)
        }
        .navigationTitle("История (\(entries.count))")
        .toolbar {
            if !entries.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Очистить", role: .destructive) {
                        clearAll()
                    }
                }
            }
        }
        .alert("Редактировать значение", isPresented: .constant(editingEntry != nil)) {
            TextField("Число", text: $newValue)
                .keyboardType(.numberPad)
            Button("Сохранить") { saveEdit() }
            Button("Отмена", role: .cancel) { editingEntry = nil }
        }
    }
    
    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(entries[index])
        }
        try? modelContext.save()
    }
    
    private func saveEdit() {
        guard let entry = editingEntry,
              let value = Int(newValue) else {
            editingEntry = nil
            return
        }
        entry.value = value
        entry.date = Date()
        try? modelContext.save()
        editingEntry = nil
    }
    
    private func clearAll() {
        try? modelContext.delete(model: NumberEntry.self)
        try? modelContext.save()
    }
}
