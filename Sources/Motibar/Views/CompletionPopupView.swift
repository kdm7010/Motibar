import AppKit
import SwiftUI

struct CompletionPopupView: View {
    let title: String
    let imagePath: String
    let closeAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2.weight(.semibold))

            imageView
                .frame(width: 340, height: 220)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))

            Button("Close") {
                closeAction()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding(24)
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = NSImage(contentsOfFile: imagePath) {
            Image(nsImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            VStack(spacing: 10) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.green)
                Text("Timer complete")
                    .foregroundStyle(.secondary)
            }
        }
    }
}
