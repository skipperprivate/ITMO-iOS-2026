import SwiftUI

struct ContentView: View {
    @State private var viewModel = BatteryViewModel()
    @State private var screenAnalysis = ScreenAnalysisModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch viewModel.access {
            case .checking:
                ProgressView()
            case .granted:
                TabView {
                    Tab("Battery", systemImage: "battery.75percent") {
                        BatteryPage(viewModel: viewModel)
                    }
                    Tab("Settings", systemImage: "gearshape") {
                        AppsPage(viewModel: viewModel)
                    }
                    Tab("Integrations", systemImage: "puzzlepiece.extension") {
                        CodingPage(viewModel: viewModel)
                    }
                    Tab("Screen", systemImage: "viewfinder") {
                        ScreenAnalysisPage(model: screenAnalysis, viewModel: viewModel)
                    }
                    Tab("Lock", systemImage: "lock") {
                        SecurityPage(viewModel: viewModel)
                    }
                }
            case .denied:
                ContentUnavailableView {
                    Label("Screen Time access", systemImage: "hourglass")
                } description: {
                    Text(viewModel.errorMessage ?? "Allow access to track good and bad apps.")
                } actions: {
                    Button("Allow") { Task { await viewModel.authorize() } }
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .task {
            screenAnalysis.accountingDidChange = { [weak viewModel] in viewModel?.reloadReport() }
            await viewModel.authorize()
        }
        .onChange(of: viewModel.config, initial: true) { _, config in screenAnalysis.setAccountingPolicy(config) }
        .onChange(of: scenePhase) { old, new in
            if new == .active { screenAnalysis.refreshAccount() }
            if new == .background { viewModel.lock() }
            if old == .background, new != .background { viewModel.becameActive() }
        }
        .sheet(item: $viewModel.challenge) { challenge in
            ChallengeSheet(challenge: challenge, submit: viewModel.submit)
        }
    }
}

#Preview {
    ContentView()
}
