import SwiftUI

struct FunFactView: View {
    
    // View владеет ViewModel и сохраняет её при обновлениях интерфейса
    @StateObject private var viewModel: FunFactViewModel
    
    init(
        viewModel: @autoclosure @escaping () -> FunFactViewModel // escaping связано с временем жизни замыкания
    ) {
        _viewModel = StateObject(wrappedValue: viewModel()) // Обёртка StateObject<FunFactViewModel>
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.background)
                .ignoresSafeArea()
            
            Circle()
                .fill(
                    Color(red: 0.72, green: 0.48, blue: 0.57)
                        .opacity(0.15)
                )
                .frame(width: 300, height: 300)
                .blur(radius: 60)
            
            content
        }
        
        // Запуск асинхронной загрузки при появлении View
        .task {
            await viewModel.load()
        }
    }
    
    // Интерфейс зависит от текущего состояния ViewModel
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
            
        case .loaded(let fact, let isCached):
            VStack(spacing: 16) {
                Text(fact.text)
                    .font(.system(size: 20, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                if isCached {
                    Label("Сохранённый факт", systemImage: "internaldrive")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        case .error(let message):
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.orange)
                
                Text(message)
                    .multilineTextAlignment(.center)
                
                Button("Повторить") {
                    Task {
                        await viewModel.retry()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
        case .empty(let message):
            VStack(spacing: 16) {
                Image(systemName: "text.book.closed")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 8) {
                    Text("Факты не найдены")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
