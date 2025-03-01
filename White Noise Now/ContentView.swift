import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var isNoiseOn = true
    @State private var player: AVAudioPlayer?
    
    var body: some View {
        
        ZStack {
            if isNoiseOn {
                StaticView()
                    .transition(.opacity.combined(with: .scale(scale: 1.2)).animation(.easeInOut(duration: 0.2)))
            } else {
                Color.black
                    //.overlay(Text("Tap").foregroundColor(.white).font(.largeTitle))
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .ignoresSafeArea()
        .onTapGesture {
            toggleNoise()
        }
        .onAppear {
            prepareNoise()
            player?.play()
        }
    }
    
    func toggleNoise() {
        withAnimation {
            isNoiseOn.toggle()
        }
        if isNoiseOn {
            player?.play()
        } else {
            player?.stop()
        }
    }
    
    func prepareNoise() {
        guard let url = Bundle.main.url(forResource: "whitenoise", withExtension: "wav") else { return }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
            
            print("noise prepared")
        } catch {
            
            print("Error loading audio: \(error)")
        }
    }
}

struct StaticView: View {
    var body: some View {
        Canvas { context, size in
            let numLines = Int(size.height / 2)
            for i in 0..<numLines {
                let y = CGFloat(i * 2)
                let randomGray = Double.random(in: 0...1)
                context.fill(Path(CGRect(x: 0, y: y, width: size.width, height: 2)), with: .color(Color(white: randomGray)))
            }
        }
        .animation(.linear(duration: 0.1).repeatForever(autoreverses: true), value: UUID())
    }
}

