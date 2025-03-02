import SwiftUI

struct ContentView: View {
    @State private var isNoiseOn = true // Start with noise ON
    @State private var noiseTrigger = UUID() // Forces refresh
    @State private var timer: Timer?
    private var noiseGenerator = WhiteNoiseGenerator() // Keeps noise running

    var body: some View {
        ZStack {
            if isNoiseOn {
                StaticView(noiseTrigger: $noiseTrigger)
            } else {
                Color.black
            }
        }
        .ignoresSafeArea()
        .onAppear {
            startNoiseAutomatically()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0).onEnded { _ in
                toggleNoise()
            }
        )
    }

    func startNoiseAutomatically() {
        DispatchQueue.main.async {
            forceImmediateRefresh() // 🔥 Static appears first
            startStaticUpdateTimer() // 🔥 Start animation first
            noiseGenerator.play() // 🔥 Then play sound
        }
    }

    func toggleNoise() {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setDisableActions(true) // 🔥 Bypasses SwiftUI animation delay

            if !isNoiseOn {
                forceImmediateRefresh() // 🔥 Static appears immediately
                startStaticUpdateTimer()
                noiseGenerator.play() // 🔥 Sound starts after static update
            } else {
                noiseGenerator.stop()
                timer?.invalidate()
                timer = nil
            }

            UIView.performWithoutAnimation {
                isNoiseOn.toggle()
                noiseTrigger = UUID() // 🔥 Forces immediate UI update
            }

            CATransaction.commit()
            CATransaction.flush() // 🔥 Forces UI to refresh *this frame*
        }
    }

    func forceImmediateRefresh() {
        noiseTrigger = UUID() // 🔥 Forces StaticView to refresh instantly
    }

    func startStaticUpdateTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            forceImmediateRefresh() // 🔥 Matches 60 FPS screen refresh rate
        }
    }
}
