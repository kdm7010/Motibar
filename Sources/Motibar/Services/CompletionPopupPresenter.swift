import AppKit
import SwiftUI

@MainActor
final class CompletionPopupPresenter {
    private var window: NSWindow?

    func show(title: String, imagePath: String) {
        let view = CompletionPopupView(title: title, imagePath: imagePath) { [weak self] in
            self?.window?.close()
            self?.window = nil
        }

        let hostingView = NSHostingView(rootView: view)
        let popup = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 360),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        popup.title = title
        popup.contentView = hostingView
        popup.isReleasedWhenClosed = false
        popup.center()
        popup.level = .floating

        window = popup
        popup.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
