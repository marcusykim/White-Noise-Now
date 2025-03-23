import SwiftUI
import AVKit
import AVFoundation

struct ContentView: View {
    @StateObject private var playerWrapper = AVQueuePlayerWrapper()
    @State private var isNoiseOn = true
    @State private var fadeOverlayOpacity: Double = 0.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isNoiseOn {
                    VideoPlayer(player: playerWrapper.instance)
                        .rotationEffect(.degrees(90))
                        .frame(width: geometry.size.height, height: geometry.size.width)
                        .scaleEffect(max(geometry.size.width / geometry.size.height, geometry.size.height / geometry.size.width))
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .ignoresSafeArea()
                        .onAppear {
                            playerWrapper.startLoopMonitoring {
                                triggerFade()
                            }
                            playerWrapper.play()
                        }
                } else {
                    Color.black.ignoresSafeArea()
                }

                // Fade overlay
                Color.black
                    .opacity(fadeOverlayOpacity)
                    .ignoresSafeArea()

                // Tap layer
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
            fadeOverlayOpacity = 1.0
            playerWrapper.play()
            withAnimation(.easeInOut(duration: 1.0)) {
                fadeOverlayOpacity = 0.0
            }
        } else {
            withAnimation(.easeInOut(duration: 1.0)) {
                fadeOverlayOpacity = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                playerWrapper.pause()
            }
        }
    }

    func triggerFade() {
        // Fade out, then back in around the loop point
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.25)) {
                fadeOverlayOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    fadeOverlayOpacity = 0.0
                }
            }
        }
    }
}

// MARK: - Player Wrapper

@MainActor
class AVQueuePlayerWrapper: ObservableObject {
    let instance: AVQueuePlayer
    private var looper: AVPlayerLooper?
    private var loopMonitorTimer: Timer?
    private var loopCallback: (() -> Void)?

    private var loopDuration: Double = 0

    init() {
        let url = Bundle.main.url(forResource: "TV_Static_Noise_HD", withExtension: "mp4")!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)

        self.instance = AVQueuePlayer()
        self.looper = AVPlayerLooper(player: instance, templateItem: playerItem)

        loopDuration = CMTimeGetSeconds(asset.duration)

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetooth, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }

    func play() {
        instance.play()
    }

    func pause() {
        instance.pause()
        loopMonitorTimer?.invalidate()
    }

    func startLoopMonitoring(onLoop: @escaping () -> Void) {
        loopCallback = onLoop
        loopMonitorTimer?.invalidate()
        loopMonitorTimer = Timer.scheduledTimer(withTimeInterval: loopDuration - 0.4, repeats: true) { _ in
            onLoop()
        }
    }
}
