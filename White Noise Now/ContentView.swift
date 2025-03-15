import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    @StateObject private var player = AVPlayerWrapper()
    @State private var isNoiseOn = true // Start with video ON

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isNoiseOn {
                    VideoPlayer(player: player.instance)
                        .rotationEffect(.degrees(90)) // ✅ Rotate video 90 degrees
                        .frame(width: geometry.size.height, height: geometry.size.width) // ✅ Swap width & height
                        .scaleEffect(max(geometry.size.width / geometry.size.height, geometry.size.height / geometry.size.width)) // ✅ Scale to fill screen, maintain center
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // ✅ Center video
                        .ignoresSafeArea()
                        .onAppear {
                            player.play()
                        }
                } else {
                    Color.black.ignoresSafeArea()
                }

                // ✅ Transparent overlay for global tap handling
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
            player.play()
        } else {
            player.pause()
        }
    }
}

// ✅ AVPlayerWrapper: Keeps video loaded and handles audio everywhere
class AVPlayerWrapper: ObservableObject {
    let instance: AVPlayer

    init() {
        let url = Bundle.main.url(forResource: "TV_Static_Noise_HD", withExtension: "mp4")!
        self.instance = AVPlayer(url: url)
        self.instance.actionAtItemEnd = .none

        // ✅ Ensure sound plays in silent mode, Bluetooth, AirPlay
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }

        // ✅ Loop video infinitely
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
