import SwiftUI
import AVKit

struct StaticVideoPlayer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: Bundle.main.url(forResource: "StaticVisual", withExtension: "mp4")!)
        player.isMuted = true
        player.actionAtItemEnd = .none
        controller.player = player
        controller.showsPlaybackControls = false

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) { _ in
            player.seek(to: .zero) // 🔄 Loop the video forever
            player.play()
        }

        player.play()
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
