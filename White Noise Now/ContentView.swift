import SwiftUI

struct ContentView: View {
    @State private var isNoiseOn = true // Start with noise ON
    private var noiseGenerator = WhiteNoiseGenerator() // Keeps noise running

    var body: some View {
        ZStack {
            if isNoiseOn {
                StaticVideoPlayer() // 🔥 Displays the static video
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
        noiseGenerator.play() // 🔥 Start noise instantly
    }

    func toggleNoise() {
        DispatchQueue.main.async {
            isNoiseOn.toggle()
            if isNoiseOn {
                noiseGenerator.play()
            } else {
                noiseGenerator.stop()
            }
        }
    }
}
