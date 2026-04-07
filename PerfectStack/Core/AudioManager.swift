import AVFoundation
import Foundation

enum AudioCue {
    case normalLand
    case perfect(streak: Int)
    case sliceMiss
    case fail
    case newBest

    var cacheKey: String {
        switch self {
        case .normalLand:
            return "normal"
        case .perfect(let streak):
            return "perfect-\(min(streak, 6))"
        case .sliceMiss:
            return "slice"
        case .fail:
            return "fail"
        case .newBest:
            return "newbest"
        }
    }
}

@MainActor
final class AudioManager {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 1)!
    private var buffers: [String: AVAudioPCMBuffer] = [:]

    init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        buildBuffers()
        startEngineIfNeeded()
    }

    func play(_ cue: AudioCue, settings: SettingsStore) {
        guard settings.soundEnabled else { return }
        startEngineIfNeeded()

        if !player.isPlaying {
            player.play()
        }

        let key = cue.cacheKey
        if let buffer = buffers[key] {
            player.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
        }
    }

    private func startEngineIfNeeded() {
        guard !engine.isRunning else { return }
        try? engine.start()
    }

    private func buildBuffers() {
        buffers["normal"] = makeBuffer(frequencies: [460], duration: 0.09, amplitude: 0.34, decay: 7)
        buffers["slice"] = makeBuffer(frequencies: [220, 180], duration: 0.13, amplitude: 0.22, decay: 9, noiseMix: 0.08)
        buffers["fail"] = makeBuffer(frequencies: [180, 120], duration: 0.2, amplitude: 0.28, decay: 6)
        buffers["newbest"] = makeBuffer(frequencies: [280, 420, 560], duration: 0.28, amplitude: 0.32, decay: 4)

        for streak in 1...6 {
            let base = 640 + Double(streak * 26)
            buffers["perfect-\(streak)"] = makeBuffer(
                frequencies: [base, base * 1.5],
                duration: 0.12,
                amplitude: 0.4,
                decay: 5
            )
        }
    }

    private func makeBuffer(
        frequencies: [Double],
        duration: Double,
        amplitude: Double,
        decay: Double,
        noiseMix: Double = 0
    ) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let frameCount = AVAudioFrameCount(duration * sampleRate)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount

        let twoPi = Double.pi * 2
        guard let channelData = buffer.floatChannelData?[0] else { return nil }

        for frame in 0..<Int(frameCount) {
            let progress = Double(frame) / sampleRate
            let envelope = exp(-progress * decay)
            var sample = 0.0

            for frequency in frequencies {
                sample += sin(twoPi * frequency * progress)
            }

            if !frequencies.isEmpty {
                sample /= Double(frequencies.count)
            }

            if noiseMix > 0 {
                sample = (sample * (1 - noiseMix)) + (Double.random(in: -1...1) * noiseMix)
            }

            channelData[frame] = Float(sample * amplitude * envelope)
        }

        return buffer
    }
}

