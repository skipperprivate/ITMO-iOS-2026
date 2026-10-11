import Foundation
import Combine

class RandomNumberViewModel: ObservableObject {
    @Published var randomNumber: Int = 0
    
    func generateRandomNumber() {
        randomNumber = Int.random(in: 1...100)
    }
}
