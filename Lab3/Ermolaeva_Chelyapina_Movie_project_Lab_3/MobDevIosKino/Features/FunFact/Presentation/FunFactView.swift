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
                .fill(Color.purple.opacity(0.15))
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

        case .loaded(let fact):
            Text(fact.text)
                .font(.system(size: 18, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

        case .error(let message):
            VStack(spacing: 16) {
                Text(message)
                    .multilineTextAlignment(.center)

                Button("Повторить") {
                    Task {  //  создание асинхронной задачи
                        await viewModel.retry()
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }
}
