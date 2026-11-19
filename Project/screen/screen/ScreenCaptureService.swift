import CoreMedia
import Foundation
import ScreenCaptureKit

/// Sample buffers are retained only until the single in-flight analysis completes.
nonisolated struct ScreenFrame: @unchecked Sendable {
    let sample: CMSampleBuffer
    let observedAt = Date.now
    let continuity: UUID
    let orientation: Int32
}

nonisolated final class ScreenFrameOutput: NSObject, SCStreamOutput, @unchecked Sendable {
    private let lock = NSLock()
    private var busy = false
    private var latest: CMSampleBuffer?
    private var orientation: Int32 = 1
    private var continuity = UUID()
    private var lastFrame = Date.distantPast
    private let interval: Double
    private let consume: @Sendable (ScreenFrame?, String?) async -> Void

    init(interval: Double, consume: @escaping @Sendable (ScreenFrame?, String?) async -> Void) {
        self.interval = interval
        self.consume = consume
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .screen else { return }
        let attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: false) as? [[SCStreamFrameInfo: Any]]
        let status = (attachments?.first?[.status] as? Int).flatMap(SCFrameStatus.init(rawValue:))
        lock.lock()
        let now = Date.now
        if status == nil || status == .complete || status == .started {
            latest = sampleBuffer.isValid && sampleBuffer.imageBuffer != nil ? sampleBuffer : nil
            orientation = (attachments?.first?[.videoOrientation] as? NSNumber)?.int32Value ?? 1
        } else if status != .idle {
            latest = nil
        }
        if latest == nil { continuity = UUID() }
        guard !busy, now.timeIntervalSince(lastFrame) >= interval else { lock.unlock(); return }
        busy = true
        lastFrame = now
        let frame = latest.map { ScreenFrame(sample: $0, continuity: continuity, orientation: orientation) }
        lock.unlock()
        Task {
            await consume(frame, frame != nil ? nil : "Screen content is unavailable or capture is suspended.")
            releaseFrame()
        }
    }

    private func releaseFrame() {
        lock.lock()
        busy = false
        lock.unlock()
    }
}

@MainActor
final class ScreenCaptureService: NSObject, SCContentSharingPickerObserver, SCStreamDelegate {
    var onFrame: (@Sendable (ScreenFrame?, String?) async -> Void)?
    var onStatus: ((Bool, String) -> Void)?
    private var stream: SCStream?
    private var output: ScreenFrameOutput?
    private var requested = false
    private var generation = UUID()
    private var interval = 2.0

    private func deactivatePicker() {
        let picker = SCContentSharingPicker.shared
        picker.remove(self)
        picker.isActive = false
    }

    func start(interval: Double) {
        guard !requested, stream == nil else { return }
        let picker = SCContentSharingPicker.shared
        guard picker.isAvailable else { onStatus?(false, "Screen recording is unavailable on this device."); return }
        self.interval = interval
        requested = true
        generation = UUID()
        var configuration = SCContentSharingPickerConfiguration()
        configuration.showsMicrophoneControl = false
        configuration.showsCameraControl = false
        picker.defaultConfiguration = configuration
        picker.add(self)
        picker.isActive = true
        onStatus?(false, "Choose the screen in the system picker.")
        picker.present()
    }

    func stop() async {
        requested = false
        generation = UUID()
        let stopping = stream
        stream = nil
        output = nil
        deactivatePicker()
        if let stopping { try? await stopping.stopCapture() }
        onStatus?(false, "Inactive")
    }

    private func deliver(_ frame: ScreenFrame?, warning: String?, generation token: UUID) async {
        guard requested, generation == token else { return }
        await onFrame?(frame, warning)
    }

    private func selected(_ filter: SCContentFilter) async {
        guard requested, stream == nil else { return }
        let token = generation
        let configuration = SCStreamConfiguration()
        let size = filter.contentRect.size
        let scale = min(Double(filter.pointPixelScale), 1600 / max(size.width, size.height, 1))
        configuration.width = max(2, Int(size.width * scale))
        configuration.height = max(2, Int(size.height * scale))
        // iOS controls capture cadence and buffering; the output sink throttles analysis.
        configuration.capturesAudio = false
        let capture = SCStream(filter: filter, configuration: configuration, delegate: self)
        let sink = ScreenFrameOutput(interval: interval) { [weak self] frame, warning in
            await self?.deliver(frame, warning: warning, generation: token)
        }
        do {
            try capture.addStreamOutput(sink, type: .screen, sampleHandlerQueue: DispatchQueue(label: "screen.analysis.capture", qos: .utility))
            stream = capture
            output = sink
            try await capture.startCapture()
            guard generation == token, requested else { try? await capture.stopCapture(); return }
            onStatus?(true, "Analyzing screen")
        } catch {
            guard generation == token else { return }
            stream = nil
            output = nil
            requested = false
            deactivatePicker()
            onStatus?(false, "Capture failed: \(error.localizedDescription)")
        }
    }

    nonisolated func contentSharingPicker(_ picker: SCContentSharingPicker, didUpdateWith filter: SCContentFilter, for stream: SCStream?) {
        Task { @MainActor in await selected(filter) }
    }
    nonisolated func contentSharingPicker(_ picker: SCContentSharingPicker, didCancelFor stream: SCStream?) {
        Task { @MainActor in
            guard requested, self.stream == nil else { return }
            requested = false
            deactivatePicker()
            onStatus?(false, "Screen selection cancelled.")
        }
    }
    nonisolated func contentSharingPickerStartDidFailWithError(_ error: Error) {
        Task { @MainActor in
            guard requested, self.stream == nil else { return }
            requested = false
            deactivatePicker()
            onStatus?(false, "Picker failed: \(error.localizedDescription)")
        }
    }
    nonisolated func stream(_ stream: SCStream, didStopWithError error: Error) {
        Task { @MainActor in
            guard self.stream === stream else { return }
            self.stream = nil
            output = nil
            requested = false
            generation = UUID()
            deactivatePicker()
            onStatus?(false, "Capture stopped: \(error.localizedDescription)")
        }
    }
}
