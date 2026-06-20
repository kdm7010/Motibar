import AppKit
import Combine
import Foundation

@MainActor
final class PomodoroTimerStore: ObservableObject {
    @Published var phase: PomodoroPhase
    @Published var remainingSeconds: Int
    @Published var isRunning: Bool
    @Published var workMinutes: Int
    @Published var breakMinutes: Int
    @Published var workImagePath: String
    @Published var workAudioPath: String
    @Published var breakImagePath: String
    @Published var breakAudioPath: String

    private var ticker: AnyCancellable?
    private let defaults: UserDefaults
    private let mediaPlayer = MediaPlayer()
    private let popupPresenter = CompletionPopupPresenter()
    private let settingsPresenter = SettingsWindowPresenter()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let preferences = TimerPreferences(defaults: defaults)
        self.workMinutes = preferences.workMinutes
        self.breakMinutes = preferences.breakMinutes
        self.workImagePath = preferences.workImagePath
        self.workAudioPath = preferences.workAudioPath
        self.breakImagePath = preferences.breakImagePath
        self.breakAudioPath = preferences.breakAudioPath
        let savedPhase = PomodoroPhase(rawValue: defaults.string(forKey: DefaultsKey.phase) ?? "") ?? .work
        self.phase = savedPhase
        self.isRunning = defaults.bool(forKey: DefaultsKey.isRunning)
        let savedRemaining = defaults.integer(forKey: DefaultsKey.remainingSeconds)
        self.remainingSeconds = savedRemaining > 0 ? savedRemaining : preferences.durationSeconds(for: savedPhase)

        startTicker()
    }

    var menuTitle: String {
        "\(phase.title) \(TimeFormatter.shortString(from: remainingSeconds))"
    }

    var progress: Double {
        let total = max(1, durationSeconds(for: phase))
        return 1.0 - (Double(remainingSeconds) / Double(total))
    }

    func toggleRunning() {
        isRunning.toggle()
        persistRuntimeState()
    }

    func resetCurrentPhase() {
        isRunning = false
        remainingSeconds = durationSeconds(for: phase)
        persistRuntimeState()
    }

    func skipPhase() {
        completeCurrentPhase()
    }

    func updateWorkMinutes(_ value: Int) {
        workMinutes = clampedMinutes(value)
        defaults.set(workMinutes, forKey: DefaultsKey.workMinutes)
        if phase == .work {
            remainingSeconds = durationSeconds(for: .work)
        }
        persistRuntimeState()
    }

    func updateBreakMinutes(_ value: Int) {
        breakMinutes = clampedMinutes(value)
        defaults.set(breakMinutes, forKey: DefaultsKey.breakMinutes)
        if phase == .breakTime {
            remainingSeconds = durationSeconds(for: .breakTime)
        }
        persistRuntimeState()
    }

    func chooseWorkImage() {
        chooseImage(for: .work)
    }

    func chooseBreakImage() {
        chooseImage(for: .breakTime)
    }

    func chooseWorkAudio() {
        chooseAudio(for: .work)
    }

    func chooseBreakAudio() {
        chooseAudio(for: .breakTime)
    }

    func clearWorkImage() {
        workImagePath = ""
        defaults.removeObject(forKey: DefaultsKey.workImagePath)
    }

    func clearBreakImage() {
        breakImagePath = ""
        defaults.removeObject(forKey: DefaultsKey.breakImagePath)
    }

    func clearWorkAudio() {
        workAudioPath = ""
        defaults.removeObject(forKey: DefaultsKey.workAudioPath)
    }

    func clearBreakAudio() {
        breakAudioPath = ""
        defaults.removeObject(forKey: DefaultsKey.breakAudioPath)
    }

    func showSettings() {
        settingsPresenter.show(store: self)
    }

    private func chooseImage(for phase: PomodoroPhase) {
        guard let url = FilePicker.pickFile(
            allowedContentTypes: [.png, .jpeg, .gif, .tiff, .bmp, .heic],
            title: "Choose \(phase.title.lowercased()) completion image"
        ) else {
            return
        }

        setImagePath(url.path, for: phase)
    }

    private func chooseAudio(for phase: PomodoroPhase) {
        guard let url = FilePicker.pickFile(
            allowedContentTypes: [.audio],
            title: "Choose \(phase.title.lowercased()) alarm sound"
        ) else {
            return
        }

        setAudioPath(url.path, for: phase)
    }

    private func startTicker() {
        ticker = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.tick()
                }
            }
    }

    private func tick() {
        guard isRunning else {
            return
        }

        if remainingSeconds > 1 {
            remainingSeconds -= 1
            persistRuntimeState()
        } else {
            completeCurrentPhase()
        }
    }

    private func completeCurrentPhase() {
        let completedPhase = phase
        let completionImagePath = imagePath(for: completedPhase)
        let completionAudioPath = audioPath(for: completedPhase)
        isRunning = false
        popupPresenter.show(
            title: completedPhase.completionTitle,
            imagePath: completionImagePath,
            onClose: { [weak self] in
                self?.mediaPlayer.stop()
            }
        )
        mediaPlayer.playSound(atPath: completionAudioPath)

        phase = completedPhase.next
        remainingSeconds = durationSeconds(for: phase)
        persistRuntimeState()
    }

    private func imagePath(for phase: PomodoroPhase) -> String {
        switch phase {
        case .work:
            return workImagePath
        case .breakTime:
            return breakImagePath
        }
    }

    private func audioPath(for phase: PomodoroPhase) -> String {
        switch phase {
        case .work:
            return workAudioPath
        case .breakTime:
            return breakAudioPath
        }
    }

    private func setImagePath(_ path: String, for phase: PomodoroPhase) {
        switch phase {
        case .work:
            workImagePath = path
            defaults.set(path, forKey: DefaultsKey.workImagePath)
        case .breakTime:
            breakImagePath = path
            defaults.set(path, forKey: DefaultsKey.breakImagePath)
        }
    }

    private func setAudioPath(_ path: String, for phase: PomodoroPhase) {
        switch phase {
        case .work:
            workAudioPath = path
            defaults.set(path, forKey: DefaultsKey.workAudioPath)
        case .breakTime:
            breakAudioPath = path
            defaults.set(path, forKey: DefaultsKey.breakAudioPath)
        }
    }

    private func durationSeconds(for phase: PomodoroPhase) -> Int {
        switch phase {
        case .work:
            return max(1, workMinutes) * 60
        case .breakTime:
            return max(1, breakMinutes) * 60
        }
    }

    private func clampedMinutes(_ value: Int) -> Int {
        min(max(value, 1), 180)
    }

    private func persistRuntimeState() {
        defaults.set(phase.rawValue, forKey: DefaultsKey.phase)
        defaults.set(remainingSeconds, forKey: DefaultsKey.remainingSeconds)
        defaults.set(isRunning, forKey: DefaultsKey.isRunning)
    }
}

private enum DefaultsKey {
    static let workMinutes = "workMinutes"
    static let breakMinutes = "breakMinutes"
    static let workImagePath = "workImagePath"
    static let workAudioPath = "workAudioPath"
    static let breakImagePath = "breakImagePath"
    static let breakAudioPath = "breakAudioPath"
    static let legacyImagePath = "imagePath"
    static let legacyAudioPath = "audioPath"
    static let phase = "phase"
    static let remainingSeconds = "remainingSeconds"
    static let isRunning = "isRunning"
}

private struct TimerPreferences {
    let workMinutes: Int
    let breakMinutes: Int
    let workImagePath: String
    let workAudioPath: String
    let breakImagePath: String
    let breakAudioPath: String

    init(defaults: UserDefaults) {
        let savedWork = defaults.integer(forKey: DefaultsKey.workMinutes)
        let savedBreak = defaults.integer(forKey: DefaultsKey.breakMinutes)
        let legacyImagePath = defaults.string(forKey: DefaultsKey.legacyImagePath) ?? ""
        let legacyAudioPath = defaults.string(forKey: DefaultsKey.legacyAudioPath) ?? ""
        self.workMinutes = savedWork > 0 ? savedWork : 25
        self.breakMinutes = savedBreak > 0 ? savedBreak : 5
        self.workImagePath = defaults.string(forKey: DefaultsKey.workImagePath) ?? legacyImagePath
        self.workAudioPath = defaults.string(forKey: DefaultsKey.workAudioPath) ?? legacyAudioPath
        self.breakImagePath = defaults.string(forKey: DefaultsKey.breakImagePath) ?? legacyImagePath
        self.breakAudioPath = defaults.string(forKey: DefaultsKey.breakAudioPath) ?? legacyAudioPath
    }

    func durationSeconds(for phase: PomodoroPhase) -> Int {
        switch phase {
        case .work:
            return workMinutes * 60
        case .breakTime:
            return breakMinutes * 60
        }
    }
}
