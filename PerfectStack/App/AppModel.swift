import Foundation
import Observation

enum AppRoute {
    case home
    case gameplay(GameSessionContext)
    case results(RunSummary)
}

@Observable
@MainActor
final class AppModel {
    var route: AppRoute = .home
    var isShowingSettings = false
    var isShowingDailyChallenge = false
    var dailyChallenge: DailyChallenge

    let settings: SettingsStore
    let themeCatalog: ThemeCatalog
    let persistence: PersistenceClient
    let analytics: any AnalyticsClient
    let audioManager: AudioManager
    let hapticsManager: HapticsManager
    let monetizationClient: any MonetizationClient

    init(
        settings: SettingsStore = SettingsStore(),
        themeCatalog: ThemeCatalog = .launch,
        persistence: PersistenceClient = PersistenceClient(),
        analytics: any AnalyticsClient = LocalAnalyticsClient(),
        audioManager: AudioManager? = nil,
        hapticsManager: HapticsManager? = nil,
        monetizationClient: any MonetizationClient = DisabledMonetizationClient()
    ) {
        self.settings = settings
        self.themeCatalog = themeCatalog
        self.persistence = persistence
        self.analytics = analytics
        self.audioManager = audioManager ?? AudioManager()
        self.hapticsManager = hapticsManager ?? HapticsManager()
        self.monetizationClient = monetizationClient
        dailyChallenge = DailyChallenge.forToday(date: Date())

        settings.onSettingsChanged = { [weak self] key, value in
            self?.analytics.track(AnalyticsEvent(name: "settings_changed", payload: [
                "key": key,
                "value": value
            ]))
        }

        if !themeCatalog.isUnlocked(themeID: settings.selectedThemeID, unlockedThemeIDs: persistence.unlockedThemeIDs) {
            settings.selectedThemeID = themeCatalog.defaultTheme.id
        }

        analytics.track(AnalyticsEvent(name: "app_open", payload: ["theme_id": settings.selectedThemeID]))
        if persistence.consumeFirstOpenFlag() {
            analytics.track(AnalyticsEvent(name: "first_open"))
        }
    }

    var routeID: String {
        switch route {
        case .home:
            return "home"
        case .gameplay(let session):
            return "game-\(session.id.uuidString)"
        case .results(let summary):
            return "results-\(summary.id.uuidString)"
        }
    }

    var bestScore: Int { persistence.bestScore }

    var unlockedThemeIDs: Set<String> {
        persistence.unlockedThemeIDs.union([themeCatalog.defaultTheme.id])
    }

    var selectedTheme: Theme {
        themeCatalog.theme(id: settings.selectedThemeID)
    }

    var availableThemes: [Theme] {
        themeCatalog.themes
    }

    func isUnlocked(_ theme: Theme) -> Bool {
        theme.isDefault || unlockedThemeIDs.contains(theme.id)
    }

    func tapPlay() {
        analytics.track(AnalyticsEvent(name: "tap_play", payload: [
            "theme_id": selectedTheme.id
        ]))
        route = .gameplay(GameSessionContext(
            id: UUID(),
            themeID: selectedTheme.id,
            challenge: nil,
            launchedFromDailyChallenge: false
        ))
    }

    func openDailyChallenge() {
        dailyChallenge = DailyChallenge.forToday(date: Date())
        isShowingDailyChallenge = true
        analytics.track(AnalyticsEvent(name: "daily_challenge_entered", payload: [
            "challenge_id": dailyChallenge.id,
            "challenge_type": dailyChallenge.kind.rawValue
        ]))
    }

    func startDailyChallengeRun() {
        isShowingDailyChallenge = false
        route = .gameplay(GameSessionContext(
            id: UUID(),
            themeID: selectedTheme.id,
            challenge: dailyChallenge,
            launchedFromDailyChallenge: true
        ))
    }

    func selectTheme(_ theme: Theme) {
        guard isUnlocked(theme) else { return }
        settings.selectedThemeID = theme.id
        analytics.track(AnalyticsEvent(name: "theme_changed", payload: [
            "theme_id": theme.id
        ]))
    }

    func completeRun(_ summary: RunSummary) {
        let priorBest = persistence.bestScore
        let bestScore = max(priorBest, summary.score)
        let isNewBest = summary.score > priorBest
        persistence.bestScore = bestScore

        let newUnlocks = themeCatalog.newlyUnlockedThemes(
            bestScore: bestScore,
            existingUnlockedThemeIDs: persistence.unlockedThemeIDs
        )
        persistence.unlock(themeIDs: newUnlocks.map(\.id))

        if !isUnlocked(selectedTheme) {
            settings.selectedThemeID = themeCatalog.defaultTheme.id
        }

        let finalized = summary.finalized(
            bestScore: bestScore,
            isNewBest: isNewBest,
            unlockedThemeNames: newUnlocks.map(\.name)
        )

        if isNewBest {
            audioManager.play(.newBest, settings: settings)
            hapticsManager.play(.newBest, settings: settings)
        }

        route = .results(finalized)
    }

    func replayCurrentRun() {
        switch route {
        case .results(let summary):
            route = .gameplay(GameSessionContext(
                id: UUID(),
                themeID: summary.themeID,
                challenge: summary.challenge,
                launchedFromDailyChallenge: summary.challenge != nil
            ))
        case .gameplay(let session):
            route = .gameplay(GameSessionContext(
                id: UUID(),
                themeID: session.themeID,
                challenge: session.challenge,
                launchedFromDailyChallenge: session.launchedFromDailyChallenge
            ))
        case .home:
            tapPlay()
        }
    }

    func returnHome() {
        dailyChallenge = DailyChallenge.forToday(date: Date())
        route = .home
    }
}
