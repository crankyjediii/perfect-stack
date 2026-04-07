import Foundation
import Observation

@Observable
final class SettingsStore {
    typealias ChangeHandler = (_ key: String, _ value: String) -> Void

    private enum Keys {
        static let soundEnabled = "perfectstack.settings.soundEnabled"
        static let hapticsEnabled = "perfectstack.settings.hapticsEnabled"
        static let reducedMotionEnabled = "perfectstack.settings.reducedMotionEnabled"
        static let selectedThemeID = "perfectstack.settings.selectedThemeID"
        static let tutorialCleared = "perfectstack.settings.tutorialCleared"
    }

    private let defaults: UserDefaults
    private var isHydrating = true
    var onSettingsChanged: ChangeHandler?

    var soundEnabled: Bool {
        didSet { persistBool(soundEnabled, key: Keys.soundEnabled) }
    }

    var hapticsEnabled: Bool {
        didSet { persistBool(hapticsEnabled, key: Keys.hapticsEnabled) }
    }

    var reducedMotionEnabled: Bool {
        didSet { persistBool(reducedMotionEnabled, key: Keys.reducedMotionEnabled) }
    }

    var selectedThemeID: String {
        didSet { persistString(selectedThemeID, key: Keys.selectedThemeID) }
    }

    var tutorialCleared: Bool {
        didSet { persistBool(tutorialCleared, key: Keys.tutorialCleared) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        soundEnabled = defaults.object(forKey: Keys.soundEnabled) as? Bool ?? true
        hapticsEnabled = defaults.object(forKey: Keys.hapticsEnabled) as? Bool ?? true
        reducedMotionEnabled = defaults.object(forKey: Keys.reducedMotionEnabled) as? Bool ?? false
        selectedThemeID = defaults.string(forKey: Keys.selectedThemeID) ?? "obsidian-sky"
        tutorialCleared = defaults.object(forKey: Keys.tutorialCleared) as? Bool ?? false
        isHydrating = false
    }

    private func persistBool(_ value: Bool, key: String) {
        defaults.set(value, forKey: key)
        guard !isHydrating else { return }
        onSettingsChanged?(key, value ? "true" : "false")
    }

    private func persistString(_ value: String, key: String) {
        defaults.set(value, forKey: key)
        guard !isHydrating else { return }
        onSettingsChanged?(key, value)
    }
}

