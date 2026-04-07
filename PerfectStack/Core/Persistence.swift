import Foundation

final class PersistenceClient {
    private enum Keys {
        static let bestScore = "perfectstack.bestScore"
        static let unlockedThemeIDs = "perfectstack.unlockedThemeIDs"
        static let firstOpen = "perfectstack.firstOpen"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Keys.unlockedThemeIDs) == nil {
            defaults.set([], forKey: Keys.unlockedThemeIDs)
        }
        if defaults.object(forKey: Keys.firstOpen) == nil {
            defaults.set(true, forKey: Keys.firstOpen)
        }
    }

    var bestScore: Int {
        get { defaults.integer(forKey: Keys.bestScore) }
        set { defaults.set(max(newValue, 0), forKey: Keys.bestScore) }
    }

    var unlockedThemeIDs: Set<String> {
        Set(defaults.stringArray(forKey: Keys.unlockedThemeIDs) ?? [])
    }

    func unlock(themeIDs: [String]) {
        guard !themeIDs.isEmpty else { return }
        var current = unlockedThemeIDs
        current.formUnion(themeIDs)
        defaults.set(Array(current).sorted(), forKey: Keys.unlockedThemeIDs)
    }

    func consumeFirstOpenFlag() -> Bool {
        let firstOpen = defaults.bool(forKey: Keys.firstOpen)
        if firstOpen {
            defaults.set(false, forKey: Keys.firstOpen)
        }
        return firstOpen
    }
}

