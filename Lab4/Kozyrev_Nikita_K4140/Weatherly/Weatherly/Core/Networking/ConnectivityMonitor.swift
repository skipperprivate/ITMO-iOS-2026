//
//  ConnectivityMonitor.swift
//  Weatherly
//
//  Created by Nikita Kozyrev on 29.09.2026.
//

import Foundation
import Network

// Lets screens that failed offline reload by themselves once the connection is back.
@Observable
@MainActor
final class ConnectivityMonitor {
    // Optimistic until the first path update, so launch never flashes an offline state.
    private(set) var isConnected = true

    @ObservationIgnored private let monitor = NWPathMonitor()

    init() {
        monitor.pathUpdateHandler = Self.makeHandler { [weak self] isConnected in
            guard let self, self.isConnected != isConnected else { return }
            self.isConnected = isConnected
        }
        monitor.start(queue: DispatchQueue(label: "Weatherly.ConnectivityMonitor", qos: .utility))
    }

    deinit {
        monitor.cancel()
    }

    // Built outside the main actor: NWPathMonitor calls it on its own queue, so it must not
    // inherit main-actor isolation, and hops back to the main actor with the result.
    private nonisolated static func makeHandler(
        _ update: @escaping @MainActor (Bool) -> Void
    ) -> @Sendable (NWPath) -> Void {
        { path in
            let isConnected = path.status == .satisfied
            Task { @MainActor in update(isConnected) }
        }
    }
}
