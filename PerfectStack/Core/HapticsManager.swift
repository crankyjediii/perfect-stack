import CoreHaptics
import Foundation
import UIKit

enum HapticCue {
    case normalLand
    case perfect
    case fail
    case newBest
}

@MainActor
final class HapticsManager {
    private var engine: CHHapticEngine?
    private let rigidGenerator = UIImpactFeedbackGenerator(style: .rigid)
    private let softGenerator = UIImpactFeedbackGenerator(style: .soft)
    private let notificationGenerator = UINotificationFeedbackGenerator()

    init() {
        prepareEngine()
        rigidGenerator.prepare()
        softGenerator.prepare()
        notificationGenerator.prepare()
    }

    func play(_ cue: HapticCue, settings: SettingsStore) {
        guard settings.hapticsEnabled else { return }

        if CHHapticEngine.capabilitiesForHardware().supportsHaptics, let engine {
            try? engine.start()
            if let player = try? engine.makePlayer(with: pattern(for: cue)) {
                try? player.start(atTime: 0)
                return
            }
        }

        switch cue {
        case .normalLand:
            softGenerator.impactOccurred(intensity: 0.65)
        case .perfect:
            rigidGenerator.impactOccurred(intensity: 0.95)
        case .fail:
            notificationGenerator.notificationOccurred(.warning)
        case .newBest:
            notificationGenerator.notificationOccurred(.success)
        }
    }

    private func prepareEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        engine = try? CHHapticEngine()
        try? engine?.start()
    }

    private func pattern(for cue: HapticCue) -> CHHapticPattern {
        let events: [CHHapticEvent]
        switch cue {
        case .normalLand:
            events = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.45),
                        .init(parameterID: .hapticSharpness, value: 0.38)
                    ],
                    relativeTime: 0
                )
            ]
        case .perfect:
            events = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.8),
                        .init(parameterID: .hapticSharpness, value: 0.7)
                    ],
                    relativeTime: 0
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.55),
                        .init(parameterID: .hapticSharpness, value: 0.5)
                    ],
                    relativeTime: 0.08
                )
            ]
        case .fail:
            events = [
                CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.24),
                        .init(parameterID: .hapticSharpness, value: 0.2)
                    ],
                    relativeTime: 0,
                    duration: 0.12
                )
            ]
        case .newBest:
            events = [
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.7),
                        .init(parameterID: .hapticSharpness, value: 0.45)
                    ],
                    relativeTime: 0
                ),
                CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: 0.5),
                        .init(parameterID: .hapticSharpness, value: 0.65)
                    ],
                    relativeTime: 0.14
                )
            ]
        }

        return (try? CHHapticPattern(events: events, parameters: []))
            ?? (try! CHHapticPattern(events: [], parameters: []))
    }
}
