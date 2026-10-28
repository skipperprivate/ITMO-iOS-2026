import Foundation

enum NewsStatisticsService {
    // nonisolated разрешает вызов вне MainActor при настройках исходного проекта.
    @discardableResult
    nonisolated static func start(
        texts: [String],
        minimumDuration: TimeInterval = 3,
        onProgress: @escaping @MainActor @Sendable (Double) -> Void,
        completion: @escaping @MainActor @Sendable (NewsStatisticsResult) -> Void
    ) -> Progress {
        let cancellation = Progress(totalUnitCount: Int64(texts.count))
        // GCD выделяет поток из системного пула. Главный поток не ждёт подсчёта.
        DispatchQueue.global(qos: .userInitiated).async {
            let started = ProcessInfo.processInfo.systemUptime
            let result = calculate(texts: texts, cancellation: cancellation) { fraction in
                DispatchQueue.main.async {
                    guard !cancellation.isCancelled else { return }
                    onProgress(fraction * 0.05)
                }
            }
            guard let result, !cancellation.isCancelled else { return }
            // Учебная задержка: расчёт занимает минимум 3 секунды.
            // Ожидание только в фоновом потоке, отмена проверяется каждые 50 мс.
            while ProcessInfo.processInfo.systemUptime - started < minimumDuration {
                guard !cancellation.isCancelled else { return }
                Thread.sleep(forTimeInterval: 0.05)
                let elapsed = ProcessInfo.processInfo.systemUptime - started
                let fraction = min(0.99, 0.05 + 0.94 * elapsed / minimumDuration)
                DispatchQueue.main.async {
                    guard !cancellation.isCancelled else { return }
                    onProgress(fraction)
                }
            }
            // Состояние интерфейса меняется только в главной очереди.
            DispatchQueue.main.async {
                guard !cancellation.isCancelled else { return }
                completion(result)
            }
        }
        return cancellation
    }

    nonisolated static func calculate(
        texts: [String],
        cancellation: Progress,
        onProgress: (Double) -> Void
    ) -> NewsStatisticsResult? {
        var words = 0
        var characters = 0
        // Не более примерно ста обновлений прогресса за один расчёт.
        let progressStep = max(1, texts.count / 100)
        for (index, text) in texts.enumerated() {
            guard !cancellation.isCancelled else { return nil }
            var insideWord = false
            for character in text {
                // Проверяем отмену и внутри длинной публикации.
                if characters.isMultiple(of: 1024), cancellation.isCancelled { return nil }
                characters += 1
                if character.isWhitespace {
                    insideWord = false
                } else if !insideWord {
                    words += 1
                    insideWord = true
                }
            }
            if (index + 1).isMultiple(of: progressStep) || index + 1 == texts.count {
                onProgress(Double(index + 1) / Double(texts.count))
            }
        }
        guard !cancellation.isCancelled else { return nil }
        return (texts.count, words, characters, !Thread.isMainThread)
    }
}
// посмотреть про enum
