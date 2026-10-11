import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
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
                
                Text("Всего генераций: \(viewModel.generationCount)")
                    .font(.caption)
                    .foregroundColor(.gray)
            
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
                    HistoryView()
                } label: {
                    Text("История")
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
        .onAppear {
            viewModel.configure(with: modelContext)
        }
    }
}
