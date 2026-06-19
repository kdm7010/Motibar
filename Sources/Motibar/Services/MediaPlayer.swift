import AppKit
import AVFoundation
import Foundation

@MainActor
final class MediaPlayer {
    private var player: AVAudioPlayer?

    func playSound(atPath path: String) {
        guard !path.isEmpty else {
            NSSound.beep()
            return
        }

        let url = URL(fileURLWithPath: path)
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            player = audioPlayer
        } catch {
            NSSound.beep()
        }
    }
}
