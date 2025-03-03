import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var player = AVPlayerWrapper() // 🔥 Keeps AVPlayer in memory
    @State private var isNoiseOn = true // Start with video ON

    var body: some View {
        ZStack {
            VideoPlayer(player: player.instance)
                .opacity(isNoiseOn ? 1 : 0) // 🔥 Hide instead of removing from hierarchy
                .ignoresSafeArea()
                .onAppear {
                    player.play() // 🔥 Start video immediately upon launch
                }

            if !isNoiseOn {
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
            player.play() // 🔥 Instantly resume playback
        } else {
            player.pause() // 🔥 Pause instead of removing the player
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
