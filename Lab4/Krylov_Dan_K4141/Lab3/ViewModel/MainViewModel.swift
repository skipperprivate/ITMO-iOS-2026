import Foundation
import Combine

@MainActor
final class MainViewModel: ObservableObject {
    @Published var numberText: String = "Нажмите кнопку"
    @Published var isSecondScreenShown: Bool = false
    @Published var records: [NumberRecord] = []

    @Published var maxValue: Int {
        didSet { settingsService.saveMaxValue(maxValue) }
    }

    private let storageService: StorageService
    private let settingsService: SettingsService

    init(storageService: StorageService,
         settingsService: SettingsService = SettingsService()) {
        self.storageService = storageService
        self.settingsService = settingsService
        self.maxValue = settingsService.loadMaxValue()

        loadRecords()
        if let last = records.first {
            numberText = String(last.value)
        }
    }

    func generateRandomNumber() {
        let value = RandomNumberModel(range: 0...maxValue).generate()
        numberText = String(value)
        storageService.add(value: value)
        loadRecords()
    }

    func loadRecords() {
        records = storageService.fetchAll()
    }

    func updateRecord(_ record: NumberRecord) {
        let newValue = RandomNumberModel(range: 0...maxValue).generate()
        storageService.update(record, newValue: newValue)
        loadRecords()
    }

    func deleteRecord(_ record: NumberRecord) {
        storageService.delete(record)
        loadRecords()
    }

    func openSecondScreen() {
        isSecondScreenShown = true
    }
}
