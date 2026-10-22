import SwiftUI

struct ContentView: View {
    @State private var number = 0

    var body: some View {
        NavigationStack { // контейнер для перехода между экранами
            VStack (spacing: 15) // вертикальное расположение элементов
            {
                Image(systemName: "dice.fill").font(.system(size: 48)).foregroundStyle(Color(red: 0.76, green: 0.58, blue: 0.62))

                Text("Random number:").font(.title2)

                Text("\(number)").font(.system(size: 37, weight: .bold, design: .rounded))

                VStack(spacing: 20){ // кнопки
                    Button("Generate random number") {
                        number = Int.random(in: 1...100)
                    }.buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(Color(red: 0.82, green: 0.45, blue: 0.6))

                    NavigationLink("Next Screen") {
                        SecondView()
                    }.buttonStyle(.bordered)
                        .buttonBorderShape(.capsule)
                }
                .padding(70) // от контейнера с кнопками
            }
        }
    }
}

#Preview {
    ContentView()
}
