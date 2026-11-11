import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    
    
    @Published var selectedCuisine: String
    @Published var sortOption: String
    @Published var hasSeenOnboarding: Bool
    
    
    private let settings: AppSettings
    
    
    let sortOptions = [
        "Название",
        "Время приготовления",
        "Калорийность"
    ]
    
    
    init(settings: AppSettings? = nil) {
        let appSettings = settings ?? AppSettings.shared
        
        self.settings = appSettings
        self.selectedCuisine = appSettings.selectedCuisine
        self.sortOption = appSettings.sortOption
        self.hasSeenOnboarding = appSettings.hasSeenOnboarding
    }
    
    
    func saveCuisine(_ cuisine: String) {
        selectedCuisine = cuisine
        settings.selectedCuisine = cuisine
    }
    
    
    func saveSortOption(_ option: String) {
        sortOption = option
        settings.sortOption = option
    }
    

    func completeOnboarding() {
        hasSeenOnboarding = true
        settings.hasSeenOnboarding = true
    }
    
    
    func resetSettings() {
        settings.resetSettings()
        
        selectedCuisine = settings.selectedCuisine
        sortOption = settings.sortOption
        hasSeenOnboarding = settings.hasSeenOnboarding
    }
}
