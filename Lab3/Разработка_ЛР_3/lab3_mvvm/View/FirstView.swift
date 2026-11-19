import SwiftUI

struct FirstView: View {
    @StateObject private var viewModel = RandomNumberViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("Случайное число")
                .font(.title2)

            Text("\(viewModel.number)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
                .accessibilityIdentifier("randomNumberLabel")

            Button("Сгенерировать число") {
                viewModel.generateRandomNumber()
            }
            .buttonStyle(.borderedProminent)

            NavigationLink("Перейти на второй экран") {
                SecondView()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Первый экран")
    }
}

struct FirstView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FirstView()
        }
    }
}
