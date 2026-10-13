import SwiftUI
import SwiftData

struct MainView: View {
    @StateObject private var viewModel: MainViewModel

    init(storageService: StorageService) {
        _viewModel = StateObject(wrappedValue: MainViewModel(storageService: storageService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(viewModel.numberText)
                    .font(.largeTitle)
                    .bold()

                Stepper("Максимум: \(viewModel.maxValue)",
                        value: $viewModel.maxValue,
                        in: 1...1000)
                    .padding(.horizontal)

                Button("Случайное число") {
                    viewModel.generateRandomNumber()
                }
                .buttonStyle(.borderedProminent)

                Button("История (\(viewModel.records.count))") {
                    viewModel.openSecondScreen()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Генератор")
            .navigationDestination(isPresented: $viewModel.isSecondScreenShown) {
                SecondView(viewModel: viewModel)
            }
        }
    }
}


