import SwiftUI

struct SettingsView: View {
    @ObservedObject var store: PomodoroTimerStore

    var body: some View {
        Form {
            Section("Timer") {
                Stepper("Work: \(store.workMinutes) minutes", value: Binding(
                    get: { store.workMinutes },
                    set: { store.updateWorkMinutes($0) }
                ), in: 1...180)

                Stepper("Break: \(store.breakMinutes) minutes", value: Binding(
                    get: { store.breakMinutes },
                    set: { store.updateBreakMinutes($0) }
                ), in: 1...180)
            }

            Section("Work completion") {
                FileSelectionRow(
                    title: "Image",
                    path: store.workImagePath,
                    chooseAction: store.chooseWorkImage,
                    clearAction: store.clearWorkImage
                )

                FileSelectionRow(
                    title: "Alarm sound",
                    path: store.workAudioPath,
                    chooseAction: store.chooseWorkAudio,
                    clearAction: store.clearWorkAudio
                )
            }

            Section("Break completion") {
                FileSelectionRow(
                    title: "Image",
                    path: store.breakImagePath,
                    chooseAction: store.chooseBreakImage,
                    clearAction: store.clearBreakImage
                )

                FileSelectionRow(
                    title: "Alarm sound",
                    path: store.breakAudioPath,
                    chooseAction: store.chooseBreakAudio,
                    clearAction: store.clearBreakAudio
                )
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 520)
    }
}

private struct FileSelectionRow: View {
    let title: String
    let path: String
    let chooseAction: () -> Void
    let clearAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
            Text(path.isEmpty ? "No file selected" : path)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                Button("Choose") {
                    chooseAction()
                }

                Button("Clear") {
                    clearAction()
                }
                .disabled(path.isEmpty)
            }
        }
    }
}
