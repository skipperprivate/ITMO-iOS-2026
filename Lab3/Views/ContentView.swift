import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Рандомное число:")

                Text("\(viewModel.randomNumber)")
                    .font(.largeTitle)

                Button("Сгенерировать число") {
                    viewModel.generateNumber()
                }

                NavigationLink("Перейти на второй экран") {
                    SecondView()
                }
            }
            .navigationTitle("Первый экран")
        }
    }
}

