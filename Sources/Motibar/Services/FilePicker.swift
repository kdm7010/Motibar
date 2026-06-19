import AppKit
import UniformTypeIdentifiers

enum FilePicker {
    static func pickFile(allowedContentTypes: [UTType], title: String) -> URL? {
        let panel = NSOpenPanel()
        panel.title = title
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = allowedContentTypes
        return panel.runModal() == .OK ? panel.url : nil
    }
}
