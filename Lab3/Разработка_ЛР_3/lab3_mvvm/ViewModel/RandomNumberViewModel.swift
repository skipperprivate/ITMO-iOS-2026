import Combine

final class RandomNumberViewModel: ObservableObject {
    @Published private(set) var number: Int

    private var model: RandomNumberModel

    init(model: RandomNumberModel = RandomNumberModel()) {
        self.model = model
        number = model.value
    }

    func generateRandomNumber() {
        model.generate()
        number = model.value
    }
}
