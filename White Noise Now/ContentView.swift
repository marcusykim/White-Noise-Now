import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    @StateObject private var playerWrapper = AVQueuePlayerWrapper() // ✅ Perfect looping wrapper
    @State private var isNoiseOn = true // Start with noise ON

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isNoiseOn {
                    VideoPlayer(player: playerWrapper.instance) // ✅ Plays smooth looping video
                        .rotationEffect(.degrees(90)) // Rotate 90 degrees
                        .frame(width: geometry.size.height, height: geometry.size.width) // Fill screen
                        .scaleEffect(max(geometry.size.width / geometry.size.height, geometry.size.height / geometry.size.width))
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .ignoresSafeArea()
                        .onAppear {
                            playerWrapper.play() // ✅ Start playback
                        }
                } else {
                    Color.black.ignoresSafeArea()
                }

                // ✅ Transparent overlay for tapping
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        toggleNoise()
                    }
            }
        }
    }

    func toggleNoise() {
        withAnimation {
            isNoiseOn.toggle()
        }
        if isNoiseOn {
            playerWrapper.play() // ✅ Restart loop when toggled on
        } else {
            playerWrapper.pause() // ✅ Stop when toggled off
        }
    }
}

// ✅ Correct AVQueuePlayer Implementation for Smooth Infinite Looping
@MainActor
class AVQueuePlayerWrapper: ObservableObject {
    let instance: AVQueuePlayer
    private var looper: AVPlayerLooper?

    init() {
        let url = Bundle.main.url(forResource: "TV_Static_Noise_HD", withExtension: "mp4")!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        // ✅ Correct setup for perfect infinite looping
        self.instance = AVQueuePlayer()
        self.looper = AVPlayerLooper(player: instance, templateItem: playerItem)

        // ✅ Ensure sound plays in silent mode, Bluetooth, AirPlay
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    func play() {
        instance.seek(to: .zero)
        instance.play()
    }

    func pause() {
        instance.pause()
    }
}
