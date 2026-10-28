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
    @ObservationIgnored private var job: Progress?
    @ObservationIgnored private var activeID: UUID?

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

    func start(minimumDuration: TimeInterval = 3) {
        guard !isRunning else { return }
        let id = UUID()
        activeID = id
        isRunning = true
        hasStarted = true
        result = nil
        fraction = 0
        testCount = 0
        status = "Обработка…"
        job = NewsStatisticsService.start(texts: texts, minimumDuration: minimumDuration) { [weak self] value in
            guard let self, self.activeID == id else { return }
            self.fraction = value
        } completion: { [weak self] value in
            guard let self, self.activeID == id else { return }
            self.result = value
            self.fraction = 1
            self.isRunning = false
            self.job = nil
            self.activeID = nil
            self.status = "Расчёт завершён"
        }
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
