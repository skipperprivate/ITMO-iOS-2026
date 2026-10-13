import SwiftUI
import SwiftData

struct SecondView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        List(viewModel.records) { record in
            HStack {
                Text("\(record.value)")
                    .font(.title3)

                Spacer()

                Button("Обновить") {
                    viewModel.updateRecord(record)
                }
                .buttonStyle(.bordered)

                Button("Удалить") {
                    viewModel.deleteRecord(record)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .navigationTitle("История")
    }
}
