@MainActor
protocol ProfileSessionStore {
    var currentUsername: String? { get }

    func signIn(name: String, password: String) throws

    func signOut()
}
