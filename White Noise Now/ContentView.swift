import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var player = AVPlayerWrapper()
    @State private var isNoiseOn = true // Start with video ON

    var body: some View {
        ZStack {
            if isNoiseOn {
                VideoPlayer(player: player.instance)
                    .rotationEffect(.degrees(90)) // 🔥 Manually rotate video
                    .aspectRatio(contentMode: .fill) // 🔥 Ensures video fills screen
                    .frame(width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width) // 🔥 Swap width & height
                    .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2) // 🔥 Center it properly
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                    }
            } else {
                Color.black.ignoresSafeArea()
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onEnded { _ in
                toggleNoise()
            }
        )
    }

    func toggleNoise() {
        withAnimation {
            isNoiseOn.toggle()
        }
        if isNoiseOn {
            player.play()
        } else {
            player.pause()
        }
    }
}

// MARK: - AVPlayer Wrapper (Keeps Video Loaded in Memory)
class AVPlayerWrapper: ObservableObject {
    let instance: AVPlayer

    init() {
        let url = Bundle.main.url(forResource: "TV_Static_Noise_HD", withExtension: "mp4")!
        self.instance = AVPlayer(url: url)
        self.instance.actionAtItemEnd = .none

        // ✅ Configure Audio Session for playback in silent mode, Bluetooth, and wired headphones
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: instance.currentItem, queue: .main) { _ in
            self.loopVideo()
        }
    }

    func play() {
        instance.play()
    }

    func pause() {
        instance.pause()
    }

    private func loopVideo() {
        instance.seek(to: .zero)
        instance.play()
    }
}
