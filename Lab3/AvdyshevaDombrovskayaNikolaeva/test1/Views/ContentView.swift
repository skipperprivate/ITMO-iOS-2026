import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = RandomNumberViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Случайное число:")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("\(viewModel.randomNumber)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                    .frame(minWidth: 120, minHeight: 80)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                
                Button {
                    viewModel.generateRandomNumber()
                } label: {
                    Text("Сгенерировать число")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                NavigationLink {
                    SecondView()
                } label: {
                    Text("Перейти на второй экран")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SecondView: View {
    var body: some View {
        VStack {
            Text("Второй экран")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow.opacity(0.2))
        .navigationTitle("Экран 2")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
