import DeviceActivity
import Foundation

final class UsageMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard activity == .usage, UsageStore.isNewDay else { return }
        let usage = DailyUsage()
        UsageStore.save(usage)
        AppBlocker.update()
        RequestLog.add("Monitoring interval started")
    }

    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        if activity == .recordingMatch {
            let parts = event.rawValue.split(separator: ".")
            guard parts.count == 2, let window = UUID(uuidString: String(parts[0])),
                  let minutes = Int(parts[1]), minutes > 0 else { return }
            var changed = false
            _ = try? RecordingAccounting.update { account in
                let before = account.total
                account.report(minutes: minutes, for: window, at: .now)
                changed = before != account.total
            }
            if changed { AppBlocker.update() }
            return
        }
        guard activity == .usage, let hit = event.usage else { return }

        var usage = UsageStore.load()
        let counted = usage.record(hit.kind, minutes: hit.minutes)
        UsageStore.save(usage)
        guard counted else { return }

        let config = ConfigStore.load()
        let wasBlocking = AppBlocker.isBlocking
        let isBlocking = AppBlocker.update()
        if isBlocking != wasBlocking {
            RequestLog.add(isBlocking ? "Battery empty: bad apps blocked" : "Battery above 0%: bad apps unblocked")
        }

        let label = "\(hit.kind.rawValue) \(usage[keyPath: hit.kind.minutes]) min"
        if let url = BatteryConfig.endpoint(from: config[keyPath: hit.kind.url]) {
            send(url, label: label)
        } else {
            RequestLog.add("\(label) counted")
        }
    }

    private func send(_ url: URL, label: String) {
        let done = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url) { data, response, error in
            let result = if let error {
                error.localizedDescription
            } else {
                "HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0) " + String(decoding: (data ?? Data()).prefix(80), as: UTF8.self)
            }
            RequestLog.add("\(label) → \(result)")
            done.signal()
        }.resume()
        _ = done.wait(timeout: .now() + 10)
    }
}
