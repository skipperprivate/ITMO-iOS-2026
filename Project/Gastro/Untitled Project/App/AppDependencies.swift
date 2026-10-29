import Combine
import Foundation
import SwiftData

@MainActor
final class AppDependencies: ObservableObject {
    let recipeRepository: any RecipeRepository
    let networkExamplesService: any NetworkExamplesService
    let recipeService: any RecipeService
    let profileSessionStore: any ProfileSessionStore

    init(modelContext: ModelContext) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dummyjson.com"
        guard let baseURL = components.url else {
            preconditionFailure("Invalid API base URL configuration")
        }
        let session: URLSession
        let defaults: UserDefaults
        #if DEBUG
        if UITestingConfiguration.isEnabled {
            session = UITestingConfiguration.makeSession()
            defaults = UITestingConfiguration.makeProfileDefaults()
        } else {
            session = .shared
            defaults = .standard
        }
        #else
        session = .shared
        defaults = .standard
        #endif
        let networkClient = NetworkClientImpl(baseURL: baseURL, session: session)
        recipeRepository = SwiftDataRecipeRepository(context: modelContext)
        networkExamplesService = NetworkExamplesServiceImpl(networkClient: networkClient)
        recipeService = RecipeServiceImpl(networkClient: networkClient)
        profileSessionStore = UserDefaultsProfileSessionStore(defaults: defaults)
    }
}
