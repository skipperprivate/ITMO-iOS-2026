import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var isSidebarOpen: Bool = false
    @Published var isLoading: Bool = false
    @Published private(set) var userName: String = ""
    @Published private(set) var email: String = ""
    @Published private(set) var avatar: String = ""

    @Published private(set) var hairPorosity: String = ""
    @Published private(set) var hairThickness: String = ""
    @Published private(set) var hairColoring: String = ""

    @Published var isEditProfilePresented: Bool = false
    @Published var draftName: String = ""
    @Published var draftEmail: String = ""
    @Published var draftAvatar: String = ""

    private let profileService: UserDefaultsService
    private let router: HomeRouter
    private var cancellables = Set<AnyCancellable>()

    init(
        profileService: UserDefaultsService = .shared,
        router: HomeRouter
    ) {
        self.profileService = profileService
        self.router = router
        refreshFromProfile()
        bindProfile()
    }

    private func refreshFromProfile() {
        userName      = Self.displayName(from: profileService.name)
        email         = profileService.email
        avatar        = profileService.avatar
        hairPorosity  = profileService.hairPorosity
        hairThickness = profileService.hairThickness
        hairColoring  = profileService.hairColoring
    }

    private func bindProfile() {
        profileService.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self else { return }
                DispatchQueue.main.async { self.refreshFromProfile() }
            }
            .store(in: &cancellables)
    }

    func setHairPorosity(_ value: String)  { profileService.hairPorosity = value }
    func setHairThickness(_ value: String) { profileService.hairThickness = value }
    func setHairColoring(_ value: String)  { profileService.hairColoring = value }

    func onAppear() {
        isLoading = true
        defer { isLoading = false }
        refreshFromProfile()
    }

    private static func displayName(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Имя" : trimmed
    }

    func didTapEditProfile() {
        draftName = profileService.name
        draftEmail = profileService.email
        draftAvatar = profileService.avatar
        isEditProfilePresented = true
    }

    func didTapCancelEditProfile() {
        isEditProfilePresented = false
    }

    func didSelectDraftAvatar(_ avatar: String) {
        draftAvatar = avatar
    }

    func didTapSaveProfile() {
        let name = draftName.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = draftEmail.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !name.isEmpty,
              isValidEmail(email) else { return }

        profileService.name = name
        profileService.email = email
        profileService.avatar = draftAvatar

        isEditProfilePresented = false
    }

    var isDraftValid: Bool {
        !draftName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && isValidEmail(draftEmail.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func isValidEmail(_ email: String) -> Bool {
        // минимальная проверка; при желании замените на regex
        let parts = email.split(separator: "@")
        guard parts.count == 2,
              let domain = parts.last,
              domain.contains("."),
              !parts[0].isEmpty else { return false }
        return true
    }

    // MARK: - Sidebar
    func openSidebar() {
        withAnimation(.easeInOut(duration: 0.25)) { isSidebarOpen = true }
    }

    func closeSidebar() {
        withAnimation(.easeInOut(duration: 0.25)) { isSidebarOpen = false }
    }

    func toggleSidebar() {
        isSidebarOpen ? closeSidebar() : openSidebar()
    }

    func didTapSignOut() { /* логика выхода */ }

    func didTapComposition() { router.openComposition() }
    func didTapGuide()       { router.openGuide() }
    func didTapDictionary()  { router.openDictionary() }
    func didTapHairTyping()  { router.openHairTyping() }
    func didTapProducts()    { router.openProducts() }

    func didSelectSidebarComposition() { closeSidebar(); router.openComposition() }
    func didSelectSidebarGuide()       { closeSidebar(); router.openGuide() }
    func didSelectSidebarDictionary()  { closeSidebar(); router.openDictionary() }
    func didSelectSidebarHairTyping()  { closeSidebar(); router.openHairTyping() }
    func didSelectSidebarProducts()    { closeSidebar(); router.openProducts() }
}
