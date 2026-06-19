import SwiftUI
import AppKit

struct MenuBarContentView: View {
    @ObservedObject var store: PomodoroTimerStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(store.phase.title)
                    .font(.headline)
                Text(TimeFormatter.longString(from: store.remainingSeconds))
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .monospacedDigit()

                ProgressView(value: store.progress)
            }

            HStack(spacing: 8) {
                Button(store.isRunning ? "Pause" : "Start") {
                    store.toggleRunning()
                }
                .keyboardShortcut(.space, modifiers: [])

                Button("Reset") {
                    store.resetCurrentPhase()
                }

                Button("Skip") {
                    store.skipPhase()
                }
            }

            Divider()

            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                GridRow {
                    Text("Work")
                    Stepper("\(store.workMinutes) min", value: Binding(
                        get: { store.workMinutes },
                        set: { store.updateWorkMinutes($0) }
                    ), in: 1...180)
                }

                GridRow {
                    Text("Break")
                    Stepper("\(store.breakMinutes) min", value: Binding(
                        get: { store.breakMinutes },
                        set: { store.updateBreakMinutes($0) }
                    ), in: 1...180)
                }
            }

            HStack(spacing: 8) {
                Button("Settings") {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(16)
        .frame(width: 280)
    }
}
