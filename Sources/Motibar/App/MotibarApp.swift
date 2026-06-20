import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct MotibarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var timerStore = PomodoroTimerStore()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(store: timerStore)
        } label: {
            Label(timerStore.menuTitle, systemImage: timerStore.phase.systemImage)
        }
        .menuBarExtraStyle(.window)

    }
}
