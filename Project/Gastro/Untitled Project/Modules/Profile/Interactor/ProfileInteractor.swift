import Combine
import Foundation

@MainActor
protocol ProfileInteractor {
    var currentUsername: String? { get }

    func signIn(name: String, password: String) throws

    func signOut()
}
