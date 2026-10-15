import SwiftUI

struct ContentView: View {

    @State private var randomNumber = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Text("Рандомное число:")

                Text("\(randomNumber)")
                    .font(.largeTitle)

                Button("Сгенерировать число") {
                    randomNumber = Int.random(in: 1...100)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                NavigationLink("Перейти на второй экран") {
                    SecondView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
