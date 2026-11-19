import PhotosUI
import Vision
import SwiftData
import SwiftUI

struct ScreenAnalysisPage: View {
    @Bindable var model: ScreenAnalysisModel
    @Bindable var viewModel: BatteryViewModel
    @Environment(\.scenePhase) private var scenePhase
    @FocusState private var editing: Field?
    private enum Field { case rule, question }
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Screen analysis", isOn: Binding(get: { model.enabled }, set: { value in
                        if value && viewModel.isLocked { viewModel.beginUnlock() } else { model.setEnabled(value) }
                    }))
                        .disabled(!model.canToggle)
                        .accessibilityIdentifier("screenAnalysisEnabled")
                    Label(model.status, systemImage: "record.circle")
                        .foregroundStyle(model.capturing ? Color.red : Color.secondary)
                    if model.enabled {
                        TimelineView(.periodic(from: .now, by: 2)) { context in
                            if let latest = model.latest {
                                Text("Last analyzed \(latest.date, style: .relative) ago")
                                    .font(.caption).foregroundStyle(.secondary)
                                if context.date.timeIntervalSince(latest.date) > max(10, model.options.interval * 3) {
                                    Text("No recent frame. Current screen state is unknown.")
                                        .font(.caption).foregroundStyle(.orange)
                                }
                            }
                        }
                    }
                } footer: {
                    Text("""
                        Turning on opens Apple's screen-sharing picker. Frames are processed on this device; no video or audio is saved.
                        You can stop here or through the system recording controls.
                        """)
                }
                ProtectedPage(viewModel: viewModel) {
                    if viewModel.config.credit.mode != .app || !sessions.isEmpty {
                        Section("Screen credit today") {
                            if model.enabled, viewModel.config.credit.mode != .app {
                                Text(model.creditStatus).font(.subheadline.weight(.medium))
                            }
                            LabeledContent("Matched", value: duration(matchedToday))
                            LabeledContent("Qualified", value: duration(model.account.qualifiedSeconds ?? 0))
                            DisclosureGroup {
                                Text("Qualified seconds ÷ 60 × the good-app rate at the time of the match.")
                                Text("Current rate: \(points(viewModel.config.goodRate)) per minute")
                                ForEach(sessions) { session in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Recording · \(session.firstMatch.formatted(date: .omitted, time: .standard))")
                                        Text("\(duration(session.matched)) matched · \(duration(session.qualified)) qualified · \(points(session.points)) earned")
                                            .font(.caption).foregroundStyle(.secondary)
                                        ForEach(session.qualifiedByRate.keys.sorted(), id: \.self) { rate in
                                            let seconds = session.qualifiedByRate[rate] ?? 0
                                            Text("\(seconds.formatted(.number.precision(.fractionLength(0...2))))s ÷ 60 × \(points(rate)) = \(points(seconds / 60 * rate))")
                                                .font(.caption).monospacedDigit()
                                        }
                                    }
                                }
                            } label: {
                                LabeledContent("Screen credit", value: points(model.account.earnedPoints ?? 0))
                            }
                            if viewModel.config.credit.mode == .combined {
                                Text("Screen Time confirms selected-app use in whole minutes during a continuous match. Shorter matches can stay uncredited.")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        }
                    }
                    Section("Earning rule") {
                        CreditModePicker(viewModel: viewModel, showExplanation: false)
                        Text(ruleDescription).font(.subheadline)
                        if viewModel.config.credit.mode != .app {
                            Toggle("Count unchanged screens", isOn: $model.options.creditsUnchangedScreens)
                            if !model.options.creditsUnchangedScreens { changeControl }
                            Stepper("Confirm over \(model.options.requiredMatches) samples", value: $model.options.requiredMatches, in: 1...10)
                        }
                    }
                    settings
                    if let error = model.errorMessage { Text(error).foregroundStyle(.red) }
                    Section {
                        NavigationLink("Live results") { ScreenResultsPage(model: model, viewModel: viewModel) }
                        if let history = model.history {
                            NavigationLink("Analysis history") {
                                ScreenHistoryPage(model: model, viewModel: viewModel).modelContainer(history.container)
                            }
                        }
                        LabeledContent("Frames analyzed", value: "\(model.frames)")
                        LabeledContent("Visual changes", value: "\(model.changes)")
                        LabeledContent("Unchanged through last sample", value: "\(model.stableSeconds)s")
                    } footer: {
                        Text("Qualifying time earns the good-app rate set in Settings.")
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { editing = nil }.accessibilityIdentifier("dismissAnalysisKeyboard")
                }
            }
            .navigationTitle("Screen analysis")
        }
        .task { model.refreshAIAvailability() }
        .task(id: scenePhase == .active) {
            guard scenePhase == .active else { return }
            // Screen Time can confirm an earlier match after capture has stopped.
            while !Task.isCancelled {
                model.refreshAccount()
                do { try await Task.sleep(for: .seconds(3)) } catch { return }
            }
        }
        .task(id: selectedPhoto) {
            if let photo = selectedPhoto {
                do {
                    guard let data = try await photo.loadTransferable(type: Data.self), !Task.isCancelled else { return }
                    await model.setReference(data: data)
                } catch { model.errorMessage = error.localizedDescription }
                if !Task.isCancelled { selectedPhoto = nil }
            }
        }
    }

    private var sessions: [RecordingSessionCredit] {
        model.account.sessions?.values.sorted { $0.firstMatch > $1.firstMatch } ?? []
    }

    private var matchedToday: Double {
        // Older versions stored qualified time only. Include those known matches.
        (model.account.qualifiedSeconds ?? 0) + sessions.reduce(0) { $0 + $1.matched - $1.qualified }
    }

    private func duration(_ seconds: Double) -> String {
        Duration.seconds(seconds).formatted(.units(allowed: [.hours, .minutes, .seconds], width: .abbreviated))
    }

    private func points(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...2))) + "%"
    }

    private var ruleDescription: String {
        let mode = viewModel.config.credit.mode
        if mode == .app { return "Time in selected good apps earns credit." }
        var conditions: [String] = []
        let pattern = model.options.textPattern.trimmingCharacters(in: .whitespacesAndNewlines)
        if model.options.recognizeText || model.options.readCodes, !pattern.isEmpty, model.options.patternError == nil {
            conditions.append(model.options.useRegex ? "text matches the pattern “\(pattern)”" : "text contains “\(pattern)”")
        }
        if model.options.compareImages, model.reference != nil { conditions.append("the reference picture appears") }
        if model.options.classifyImages, let selected = model.options.goodImageLabels, !selected.isEmpty {
            conditions.append("a selected image label reaches \(model.options.minimumLabelConfidence.formatted(.percent)) confidence")
        }
        guard !conditions.isEmpty else { return "Set up a text rule, choose a reference picture, or select good image labels." }
        let prefix = mode == .combined ? "While using a selected good app, earn when " : "Earn when "
        return prefix + conditions.joined(separator: " or ") + "."
    }

    @ViewBuilder private var changeControl: some View {
        LabeledContent("Minimum visual change", value: model.options.changeThreshold.formatted(.percent))
        Slider(value: $model.options.changeThreshold, in: 0.01...0.25, step: 0.01)
    }

    @ViewBuilder private var settings: some View {
        Section("Sampling") {
            Picker("Analyze every", selection: $model.options.interval) {
                Text("1 second").tag(1.0)
                Text("2 seconds").tag(2.0)
                Text("5 seconds").tag(5.0)
            }
            .disabled(model.enabled)
            if viewModel.config.credit.mode == .app || model.options.creditsUnchangedScreens {
                changeControl
            }
            Text("The visual change threshold also controls change events and automatic AI analysis.").font(.caption).foregroundStyle(.secondary)
        }
        Section("Recognition") {
            Toggle("Read text (OCR)", isOn: $model.options.recognizeText)
            Toggle("Read QR codes and barcodes", isOn: $model.options.readCodes)
            Toggle("Suggest image labels", isOn: $model.options.classifyImages)
            if model.options.classifyImages {
                NavigationLink {
                    ProtectedPage(viewModel: viewModel) { GoodImageLabelsPage(model: model) }
                } label: {
                    LabeledContent("Good image labels", value: "\(model.options.goodImageLabels?.count ?? 0) selected")
                }
                LabeledContent("Minimum confidence for credit", value: model.options.minimumLabelConfidence.formatted(.percent))
                Slider(value: $model.options.minimumLabelConfidence, in: ScreenAnalysisOptions.suggestionFloor...1, step: 0.01)
                    .accessibilityLabel("Minimum image label confidence for credit")
                    .accessibilityValue(model.options.minimumLabelConfidence.formatted(.percent))
            }
        }
        Section {
            TextField("Text or pattern to find", text: $model.options.textPattern)
                .accessibilityIdentifier("screenTextRule")
                .focused($editing, equals: .rule)
                .submitLabel(.done)
                .onSubmit { editing = nil }
                .textInputAutocapitalization(.never).autocorrectionDisabled()
            Toggle("Regular expression", isOn: $model.options.useRegex)
            if let error = model.options.patternError { Text(error).font(.caption).foregroundStyle(.red) }
        } header: { Text("Text rule") } footer: {
            Text("""
                Case-insensitive matching. A rule fires once after consecutive matching samples, then rearms when the match disappears.
                The rule checks visible text when OCR is on and decoded contents when QR and barcode detection is on.
                """)
        }
        Section {
            Toggle("Compare reference image", isOn: $model.options.compareImages)
            let referenceTitle = model.reference == nil ? "Choose reference image" : "Replace reference image"
            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                Label(referenceTitle, systemImage: "photo")
            }
            if let reference = model.reference {
                Image(decorative: reference, scale: 1).resizable().scaledToFit().frame(maxHeight: 120)
                Button("Remove reference", role: .destructive) { Task { await model.setReference(data: nil) } }
            }
            LabeledContent("Minimum picture similarity", value: model.options.matchThreshold.formatted(.percent.precision(.fractionLength(0))))
            Slider(value: $model.options.matchThreshold, in: 0.75...0.99, step: 0.01)
        } header: { Text("Picture in picture") } footer: {
            Text("""
                Choose a tightly cropped icon or picture. Multi-scale matching searches the full screen.
                The score measures pixel similarity, not certainty. Full-screen feature distance is also shown; lower means more similar.
                Your reference stays on this device until you replace or remove it.
                """)
        }
        Section {
            Text(model.aiAvailability).font(.subheadline).foregroundStyle(.secondary)
            Toggle("Analyze changed screens automatically", isOn: $model.options.automaticAI)
                .disabled(!model.canUseAI)
            Toggle("Include screenshot with text", isOn: $model.options.aiUsesImage)
                .disabled(!model.canUseAI)
            TextField("Question about the screen", text: $model.options.aiQuestion, axis: .vertical)
                .focused($editing, equals: .question)
                .lineLimit(2...5)
            Button("Analyze latest frame") { model.analyzeWithAI() }
                .disabled(!model.canUseAI || model.aiBusy || model.latest == nil || !model.enabled)
            if model.aiBusy { ProgressView("Analyzing on device…") }
        } header: { Text("Apple Intelligence") } footer: {
            Text("""
                Uses Apple's on-device model when available, with no third-party model installation.
                Automatic analysis runs at most once every 30 seconds on changed frames.
                Results are estimates; they do not prove attention or task completion.
                """)
        }
    }
}

private struct GoodImageLabelsPage: View {
    @Bindable var model: ScreenAnalysisModel
    @State private var query = ""
    @State private var catalog: [String] = []
    @State private var suggestions: [String] = []
    @State private var loadError: String?

    var body: some View {
        List {
            Section {
                Text("In a screen-credit mode, a sample matches when any selected label appears among its suggestions. Unselected labels are neutral.")
            }
            labels("Selected", (model.options.goodImageLabels ?? []).sorted())
            labels("Latest suggestions", suggestions.filter { !(model.options.goodImageLabels ?? []).contains($0) })
            labels("Available labels", catalog.filter {
                !(model.options.goodImageLabels ?? []).contains($0) && !suggestions.contains($0)
            })
            if let loadError { Text(loadError).foregroundStyle(.secondary) }
        }
        .navigationTitle("Good image labels")
        .searchable(text: $query, prompt: "Search image labels")
        .task {
            suggestions = model.latest?.suggestedLabels.map(\.identifier) ?? []
            do { catalog = try VNClassifyImageRequest().supportedIdentifiers().sorted() }
            catch { loadError = error.localizedDescription }
        }
    }

    @ViewBuilder private func labels(_ title: String, _ identifiers: [String]) -> some View {
        let visible = identifiers.filter { query.isEmpty || $0.localizedCaseInsensitiveContains(query) }
        if !visible.isEmpty {
            Section(title) {
                ForEach(visible, id: \.self) { identifier in
                    Toggle(identifier, isOn: Binding(get: {
                        model.options.goodImageLabels?.contains(identifier) == true
                    }, set: { enabled in
                        var selected = model.options.goodImageLabels ?? []
                        if enabled { selected.insert(identifier) } else { selected.remove(identifier) }
                        model.options.goodImageLabels = selected
                    }))
                }
            }
        }
    }
}

private struct ScreenResultsPage: View {
    @Bindable var model: ScreenAnalysisModel
    let viewModel: BatteryViewModel

    var body: some View {
        ProtectedPage(viewModel: viewModel) {
            List {
                if let result = model.latest {
                    Section("Latest screen") {
                        Image(decorative: result.image, scale: 1).resizable().scaledToFit().frame(maxHeight: 320)
                        Text(result.date.formatted(date: .omitted, time: .standard)).font(.caption)
                        if let change = result.change {
                            LabeledContent("Pixel change", value: change.formatted(.percent.precision(.fractionLength(1))))
                        }
                        LabeledContent("Text changed", value: result.textChanged ? "Yes" : "No")
                        LabeledContent("Text rule", value: result.textMatched ? "Matches" : "No match")
                    }
                    Section("Recognized text") {
                        Text(result.text.isEmpty ? "No text recognized" : result.text).textSelection(.enabled)
                        if !result.language.isEmpty { LabeledContent("Language", value: result.language) }
                    }
                    values("Detected links", result.links)
                    values("QR / barcode contents", result.codes)
                    values("Image labels", result.labels)
                    let selected = result.suggestedLabels.filter { model.options.goodImageLabels?.contains($0.identifier) == true }
                    if !selected.isEmpty, model.options.classifyImages {
                        Section("Good label confidence") {
                            ForEach(selected, id: \.identifier) { label in
                                let qualifies = label.confidence >= Float(model.options.minimumLabelConfidence)
                                VStack(alignment: .leading) {
                                    Label(label.identifier, systemImage: qualifies ? "checkmark.circle" : "minus.circle")
                                    Text("\(label.confidence.formatted(.percent.precision(.fractionLength(0...2)))) confidence · \(model.options.minimumLabelConfidence.formatted(.percent)) required")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    if let score = result.templateScore {
                        Section("Reference comparison") {
                            LabeledContent("Best template score", value: score.formatted(.percent.precision(.fractionLength(1))))
                            if let bounds = result.templateBounds {
                                Text("""
                                Location on screen: x \(Int(bounds.minX * 100))%, y \(Int(bounds.minY * 100))%,
                                width \(Int(bounds.width * 100))%, height \(Int(bounds.height * 100))%
                                """)
                                    .font(.caption)
                            }
                            if let distance = result.similarityDistance {
                                LabeledContent("Full-screen feature distance", value: distance.formatted(.number.precision(.fractionLength(3))))
                            }
                        }
                    }
                    values("Recognition issues", result.warnings)
                } else {
                    Text("Start screen analysis to see observations here.").foregroundStyle(.secondary)
                }
                if !model.aiResult.isEmpty {
                    Section("Local AI response") { Text(model.aiResult).textSelection(.enabled) }
                }
                Section {
                    Button("Clear live results", role: .destructive, action: model.clearLiveData)
                } footer: { Text("Clearing live results keeps your saved analysis history.") }
            }
        }
        .navigationTitle("Live results")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder private func values(_ title: String, _ values: [String]) -> some View {
        if !values.isEmpty {
            Section(title) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, value in Text(value).textSelection(.enabled) }
            }
        }
    }
}

private struct ScreenHistoryPage: View {
    let model: ScreenAnalysisModel
    let viewModel: BatteryViewModel

    @State private var limit = 100
    @State private var selected: HistoryEntry?

    var body: some View {
        ProtectedPage(viewModel: viewModel) {
            HistoryList(model: model, limit: limit, select: { selected = $0 }) { limit += 100 }
        }
        .navigationDestination(item: $selected) { entry in
            ProtectedPage(viewModel: viewModel) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(entry.date.formatted(date: .long, time: .standard))
                            .font(.subheadline).foregroundStyle(.secondary)
                        Text(entry.detail).textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            .navigationTitle(viewModel.isLocked ? "History entry" : entry.title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationTitle("Analysis history")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct HistoryList: View {
    let model: ScreenAnalysisModel
    let limit: Int
    let select: (HistoryEntry) -> Void
    let loadMore: () -> Void
    @Query private var entries: [HistoryEntry]

    init(model: ScreenAnalysisModel, limit: Int, select: @escaping (HistoryEntry) -> Void, loadMore: @escaping () -> Void) {
        self.model = model
        self.limit = limit
        self.select = select
        self.loadMore = loadMore
        var descriptor = FetchDescriptor<HistoryEntry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        descriptor.fetchLimit = limit + 1
        _entries = Query(descriptor)
    }

    var body: some View {
        List {
            Section {
                Button("Clear history", role: .destructive, action: model.clearHistory)
                    .disabled(entries.isEmpty)
            } footer: {
                Text("Frame results and AI responses stay on this device until you clear history. Images are excluded.")
            }
            ForEach(entries.prefix(limit)) { entry in
                Button { select(entry) } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title).font(.headline)
                            Text(entry.date.formatted(date: .abbreviated, time: .standard))
                                .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption.bold()).foregroundStyle(.tertiary).accessibilityHidden(true)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            if entries.count > limit { Button("Show older entries", action: loadMore) }
        }
    }
}
