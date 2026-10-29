@MainActor
final class ProfileInteractorImpl: ProfileInteractor {
    private let sessionStore: any ProfileSessionStore

    init(sessionStore: any ProfileSessionStore) {
        self.sessionStore = sessionStore
    }
    var currentUsername: String? { sessionStore.currentUsername }

    func signIn(name: String, password: String) throws {
        try sessionStore.signIn(name: name, password: password)
    }

    func signOut() {
        sessionStore.signOut()
    }
}
