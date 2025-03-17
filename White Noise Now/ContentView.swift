import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    @StateObject private var playerWrapper = AVQueuePlayerWrapper() // ✅ Renamed to "playerWrapper" to avoid confusion with "instance"
    @State private var isNoiseOn = true // Start with noise ON

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isNoiseOn {
                    VideoPlayer(player: playerWrapper.instance) // ✅ Access the AVQueuePlayer inside wrapper
                        .rotationEffect(.degrees(90)) // Rotate video 90 degrees
                        .frame(width: geometry.size.height, height: geometry.size.width) // Swap width/height
                        .scaleEffect(max(geometry.size.width / geometry.size.height, geometry.size.height / geometry.size.width)) // Scale to fill screen
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center video
                        .ignoresSafeArea()
                        .onAppear {
                            playerWrapper.play() // ✅ Correctly calling play() on wrapper
                        }
                } else {
                    Color.black.ignoresSafeArea() // Black screen when off
                }

                // Transparent overlay to handle taps
                Color.clear
                    .contentShape(Rectangle()) // Full screen tap area
                    .onTapGesture {
                        toggleNoise()
                    }
            }
        }
    }

    // Toggling playback and state
    func toggleNoise() {
        withAnimation {
            isNoiseOn.toggle()
        }
        if isNoiseOn {
            playerWrapper.play() // ✅ Call on wrapper
        } else {
            playerWrapper.pause() // ✅ Call on wrapper
        }
    }
}

// Wrapper for AVQueuePlayer and smooth looping
@MainActor // Optional but good for safety when interacting with player & UI
class AVQueuePlayerWrapper: ObservableObject {
    let instance: AVQueuePlayer
    private let looper: AVPlayerLooper

    init() {
        let url = Bundle.main.url(forResource: "TV_Static_Noise_HD", withExtension: "mp4")!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        // Setup AVQueuePlayer and looper for seamless looping
        self.instance = AVQueuePlayer()
        self.looper = AVPlayerLooper(player: instance, templateItem: playerItem)

        // Setup audio session for silent mode, Bluetooth, AirPlay
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }

    // Control playback
    func play() {
        instance.play()
    }

    func pause() {
        instance.pause()
    }
}
