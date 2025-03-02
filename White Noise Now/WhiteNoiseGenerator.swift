import AVFoundation

class WhiteNoiseGenerator {
    private var engine = AVAudioEngine()
    private var player = AVAudioPlayerNode()
    private var isPlaying = false // Tracks state

    init() {
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 44100)!
        buffer.frameLength = buffer.frameCapacity

        let floats = buffer.floatChannelData![0]
        for i in 0..<Int(buffer.frameLength) {
            floats[i] = Float.random(in: -1...1) // Generate white noise
        }

        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try engine.start() // Always running
        } catch {
            print("Error starting engine: \(error)")
        }

        player.scheduleBuffer(buffer, at: nil, options: .loops)
    }

    func play() {
        if !isPlaying {
            player.play()
            isPlaying = true
        }
    }

    func stop() {
        if isPlaying {
            player.pause() // Mute instead of stopping engine
            isPlaying = false
        }
    }
}
