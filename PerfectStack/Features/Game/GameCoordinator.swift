import Foundation
import Observation

@Observable
@MainActor
final class GameCoordinator {
    let session: GameSessionContext
    let theme: Theme
    let settings: SettingsStore
    let analytics: any AnalyticsClient
    let persistence: PersistenceClient
    let audioManager: AudioManager
    let hapticsManager: HapticsManager
    let scene: GameScene

    var score = 0
    var currentPerfectStreak = 0
    var challengeProgress: ChallengeProgress?
    var isPaused = false
    var isEndingRun = false

    private let engine: GameEngine
    private let onComplete: (RunSummary) -> Void
    private let onExit: () -> Void

    init(
        session: GameSessionContext,
        theme: Theme,
        settings: SettingsStore,
        analytics: any AnalyticsClient,
        persistence: PersistenceClient,
        audioManager: AudioManager,
        hapticsManager: HapticsManager,
        onComplete: @escaping (RunSummary) -> Void,
        onExit: @escaping () -> Void
    ) {
        self.session = session
        self.theme = theme
        self.settings = settings
        self.analytics = analytics
        self.persistence = persistence
        self.audioManager = audioManager
        self.hapticsManager = hapticsManager
        self.onComplete = onComplete
        self.onExit = onExit
        engine = GameEngine(challenge: session.challenge)
        scene = GameScene(theme: theme, reducedMotionEnabled: settings.reducedMotionEnabled)
        challengeProgress = engine.challengeProgress

        scene.bootstrap(initialWidth: engine.initialWidth)
        scene.spawnMovingBlock(width: engine.initialWidth, level: 1, speedMultiplier: engine.speedMultiplier)

        analytics.track(AnalyticsEvent(name: "run_start", payload: [
            "theme_id": theme.id,
            "daily_challenge": session.challenge == nil ? "false" : "true"
        ]))

        if !settings.tutorialCleared {
            analytics.track(AnalyticsEvent(name: "tutorial_shown"))
        }
    }

    var shouldShowTutorial: Bool {
        !settings.tutorialCleared
    }

    func handleTap() {
        guard !isPaused, !isEndingRun else { return }

        let droppedX = scene.currentMovingBlockCenterX
        analytics.track(AnalyticsEvent(name: "block_drop", payload: [
            "score_before_drop": "\(score)"
        ]))

        let outcome = engine.dropBlock(at: droppedX)
        score = outcome.score
        currentPerfectStreak = outcome.perfectStreak
        challengeProgress = outcome.challengeProgress

        if !settings.tutorialCleared, outcome.kind != .failed {
            settings.tutorialCleared = true
            analytics.track(AnalyticsEvent(name: "tutorial_cleared"))
        }

        switch outcome.kind {
        case .normal:
            analytics.track(AnalyticsEvent(name: "slice_miss", payload: [
                "trimmed_width": String(format: "%.2f", outcome.trimmedWidth)
            ]))
            audioManager.play(.normalLand, settings: settings)
            hapticsManager.play(.normalLand, settings: settings)
            scene.applyDrop(outcome) { [weak self] in
                self?.spawnNextBlock()
            }
        case .perfect:
            analytics.track(AnalyticsEvent(name: "perfect_land", payload: [
                "score": "\(outcome.score)",
                "streak": "\(outcome.perfectStreak)"
            ]))
            audioManager.play(.perfect(streak: outcome.perfectStreak), settings: settings)
            hapticsManager.play(.perfect, settings: settings)
            scene.applyDrop(outcome) { [weak self] in
                self?.spawnNextBlock()
            }
        case .failed:
            isEndingRun = true
            currentPerfectStreak = 0
            audioManager.play(.fail, settings: settings)
            hapticsManager.play(.fail, settings: settings)
            scene.animateFailure { [weak self] in
                self?.finishRun()
            }
        }
    }

    func togglePause() {
        guard !isEndingRun else { return }
        isPaused.toggle()
        scene.isPaused = isPaused
    }

    func leaveToHome() {
        onExit()
    }

    private func spawnNextBlock() {
        scene.spawnMovingBlock(
            width: engine.currentWidth,
            level: engine.score + 1,
            speedMultiplier: engine.speedMultiplier
        )
    }

    private func finishRun() {
        let summary = engine.makeSummary(themeID: theme.id)
        analytics.track(AnalyticsEvent(name: "run_end", payload: [
            "score": "\(summary.score)",
            "duration_seconds": String(format: "%.2f", summary.duration),
            "perfect_streak": "\(summary.perfectStreak)",
            "remaining_width": String(format: "%.2f", summary.remainingWidth)
        ]))
        onComplete(summary)
    }
}

