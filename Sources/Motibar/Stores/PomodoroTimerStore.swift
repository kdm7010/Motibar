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
    @Published var imagePath: String
    @Published var audioPath: String

    private var ticker: AnyCancellable?
    private let defaults: UserDefaults
    private let mediaPlayer = MediaPlayer()
    private let popupPresenter = CompletionPopupPresenter()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let preferences = TimerPreferences(defaults: defaults)
        self.workMinutes = preferences.workMinutes
        self.breakMinutes = preferences.breakMinutes
        self.imagePath = preferences.imagePath
        self.audioPath = preferences.audioPath
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

    func chooseImage() {
        guard let url = FilePicker.pickFile(
            allowedContentTypes: [.png, .jpeg, .gif, .tiff, .bmp, .heic],
            title: "Choose completion image"
        ) else {
            return
        }
        imagePath = url.path
        defaults.set(imagePath, forKey: DefaultsKey.imagePath)
    }

    func chooseAudio() {
        guard let url = FilePicker.pickFile(
            allowedContentTypes: [.audio],
            title: "Choose alarm sound"
        ) else {
            return
        }
        audioPath = url.path
        defaults.set(audioPath, forKey: DefaultsKey.audioPath)
    }

    func clearImage() {
        imagePath = ""
        defaults.removeObject(forKey: DefaultsKey.imagePath)
    }

    func clearAudio() {
        audioPath = ""
        defaults.removeObject(forKey: DefaultsKey.audioPath)
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
        isRunning = false
        mediaPlayer.playSound(atPath: audioPath)
        popupPresenter.show(
            title: completedPhase.completionTitle,
            imagePath: imagePath
        )

        phase = completedPhase.next
        remainingSeconds = durationSeconds(for: phase)
        persistRuntimeState()
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
    static let imagePath = "imagePath"
    static let audioPath = "audioPath"
    static let phase = "phase"
    static let remainingSeconds = "remainingSeconds"
    static let isRunning = "isRunning"
}

private struct TimerPreferences {
    let workMinutes: Int
    let breakMinutes: Int
    let imagePath: String
    let audioPath: String

    init(defaults: UserDefaults) {
        let savedWork = defaults.integer(forKey: DefaultsKey.workMinutes)
        let savedBreak = defaults.integer(forKey: DefaultsKey.breakMinutes)
        self.workMinutes = savedWork > 0 ? savedWork : 25
        self.breakMinutes = savedBreak > 0 ? savedBreak : 5
        self.imagePath = defaults.string(forKey: DefaultsKey.imagePath) ?? ""
        self.audioPath = defaults.string(forKey: DefaultsKey.audioPath) ?? ""
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
