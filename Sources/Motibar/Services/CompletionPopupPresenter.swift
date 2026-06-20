import AppKit
import SwiftUI

@MainActor
final class CompletionPopupPresenter: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private var onClose: (() -> Void)?

    func show(title: String, imagePath: String, onClose: @escaping () -> Void) {
        closeCurrentWindow()
        self.onClose = onClose

        let view = CompletionPopupView(title: title, imagePath: imagePath) { [weak self] in
            self?.window?.close()
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
        popup.delegate = self
        popup.isReleasedWhenClosed = false
        popup.center()
        popup.level = .floating

        window = popup
        popup.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    nonisolated func windowWillClose(_ notification: Notification) {
        Task { @MainActor in
            onClose?()
            onClose = nil
            window = nil
        }
    }

    private func closeCurrentWindow() {
        guard let window else {
            return
        }
        let closeHandler = onClose
        self.window = nil
        onClose = nil
        window.delegate = nil
        window.close()
        closeHandler?()
    }
}
