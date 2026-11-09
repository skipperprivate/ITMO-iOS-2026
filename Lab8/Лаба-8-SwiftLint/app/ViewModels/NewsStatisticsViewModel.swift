import Foundation
import Observation

// Состояние принадлежит ленте, поэтому закрытие sheet не теряет результат
// и не прерывает выполняющийся расчёт. Все изменения UI изолированы MainActor.
@MainActor
@Observable
final class NewsStatisticsViewModel {
    private(set) var texts: [String] = []
    private(set) var fraction = 0.0
    private(set) var result: NewsStatisticsResult?
    private(set) var status = "Готово к расчёту"
    private(set) var isRunning = false
    private(set) var hasStarted = false
    private(set) var testCount = 0
    @ObservationIgnored private var job: Task<Void, Never>?
    @ObservationIgnored private var activeID: UUID?

    private let service: any NewsStatisticsCalculating

    init(service: any NewsStatisticsCalculating = NewsStatisticsService()) {
        self.service = service
    }

    deinit { job?.cancel() }

    func updateTexts(_ newTexts: [String]) {
        guard newTexts != texts else { return }
        let hadCalculation = hasStarted
        cancel()
        texts = newTexts
        result = nil
        fraction = 0
        testCount = 0
        status = hadCalculation ? "Лента изменилась. Рассчитайте статистику повторно." : "Готово к расчёту"
    }

    func start() {
        guard !isRunning else { return }
        let id = UUID()
        activeID = id
        isRunning = true
        hasStarted = true
        result = nil
        fraction = 0
        testCount = 0
        status = "Обработка…"
        let snapshot = texts
        let service = service
        job = Task { [weak self] in
            do {
                let value = try await service.calculate(texts: snapshot) { [weak self] fraction in
                    guard let self, self.activeID == id else { return }
                    self.fraction = fraction
                }
                try Task.checkCancellation()
                guard let self, self.activeID == id else { return }
                self.result = value
                self.fraction = 1
                self.finish(status: "Расчёт завершён")
            } catch {
                guard let self, self.activeID == id else { return }
                self.finish(status: error is CancellationError ? "Расчёт отменён" : error.localizedDescription)
            }
        }
    }

    private func finish(status: String) {
        isRunning = false
        job = nil
        activeID = nil
        self.status = status
    }

    func checkResponsiveness() {
        guard isRunning else { return }
        testCount += 1
    }

    func cancel() {
        guard isRunning else { return }
        job?.cancel()
        job = nil
        activeID = nil // Запоздавшие callbacks не меняют состояние нового запуска.
        isRunning = false
        status = "Расчёт отменён"
    }
}
