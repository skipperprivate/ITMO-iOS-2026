import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            SignInScreen(
                onSignIn: { path.append(Route.home) },
                onGoToSignUp: { path.append(Route.signUp) }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .signIn:
                    SignInScreen(
                        onSignIn: { path.append(Route.home) },
                        onGoToSignUp: { path.append(Route.signUp) }
                    )

                case .signUp:
                    SignUpScreen(
                        onSignUp: { path.append(Route.home) },
                        onGoToSignIn: { path.removeLast() }
                    )

                case .home:
                    HomeScreen(
                        onOpenComposition: { /* TODO */ },
                        onOpenGuide: { path.append(Route.guide) },
                        onOpenDictionary: { path.append(Route.dictionary) },
                        onOpenHairTyping: { /* TODO */ },
                        onOpenProducts: { path.append(Route.products) }
                    )

                case .guide:
                    GuideScreen()

                case .dictionary:
                    DictionaryScreen()

                case .products:
                    ProductsScreen(viewModel: ProductsViewModelFactory.make())
                }
            }
        }
    }
}
