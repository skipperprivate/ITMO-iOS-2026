import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        NavigationStack(path: $path) {
            SignInScreen(
                viewModel: SignInViewModelFactory.make(),
                onSignIn: { path.append(Route.home) },
                onGoToSignUp: { path.append(Route.signUp) }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .signIn:
                    SignInScreen(
                        viewModel: SignInViewModelFactory.make(),
                        onSignIn: { path.append(Route.home) },
                        onGoToSignUp: { path.append(Route.signUp) }
                )

                case .signUp:
                    SignUpScreen(
                        viewModel: SignUpViewModelFactory.make(),
                        onSignUp: { path.append(Route.home) },
                        onGoToSignIn: { path.removeLast() }
                    )

                case .home:
                    HomeScreen(
                        router: HomeScreenRouterAdapter(
                            onComposition: { path.append(Route.composition) },
                            onGuide: { path.append(Route.guide) },
                            onDictionary: { path.append(Route.dictionary) },
                            onHairTyping: { path.append(Route.hairTyping) },
                            onProducts: { path.append(Route.products) }
                        ),
                        onLogout: { path.append(Route.signIn) }
                    )

                case .composition:
                    GuideScreen()

                case .guide:
                    GuideScreen()

                case .dictionary:
                    DictionaryScreen()

                case .hairTyping:
                    HairTypingScreen(
                        onOpenPhotoAnalysis: { path.append(Route.hairAnalysis) },
                        onOpenPorosityText: { path.append(Route.porosityText) },
                        onOpenThicknessText: { path.append(Route.thicknessText) },
                        onOpenColoredText: { path.append(Route.coloredText) }
                    )

                case .products:
                    ProductsScreen(viewModel: ProductsViewModelFactory.make())

                case .hairAnalysis:
                    HairAnalysisScreen(
                        onSaveComplete: { path.removeLast(2) }
                    )

                case .porosityText:
                    PorosityTypingScreen()

                case .thicknessText:
                    ThicknessTextTypingScreen(
                        onBackToHome: { path.removeLast(2) }
                    )

                case .coloredText:
                    IsColoredTypingScreen()
                }
            }
        }
        .onAppear(perform: setInitialRouteIfNeeded)
    }
    
    private func setInitialRouteIfNeeded() {
            if authManager.hasValidSession {
                path.append(Route.home)
            }
        }
}
