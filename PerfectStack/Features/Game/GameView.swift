import SpriteKit
import SwiftUI

struct GameView: View {
    let session: GameSessionContext
    let theme: Theme
    let settings: SettingsStore
    let analytics: any AnalyticsClient
    let persistence: PersistenceClient
    let audioManager: AudioManager
    let hapticsManager: HapticsManager
    let onComplete: (RunSummary) -> Void
    let onExit: () -> Void

    @State private var coordinator: GameCoordinator

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
        _coordinator = State(initialValue: GameCoordinator(
            session: session,
            theme: theme,
            settings: settings,
            analytics: analytics,
            persistence: persistence,
            audioManager: audioManager,
            hapticsManager: hapticsManager,
            onComplete: onComplete,
            onExit: onExit
        ))
    }

    var body: some View {
        ZStack {
            AmbientBackground(theme: theme)

            SpriteView(scene: coordinator.scene, options: [.allowsTransparency], preferredFramesPerSecond: 120)
                .ignoresSafeArea()

            Button {
                coordinator.handleTap()
            } label: {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .ignoresSafeArea()
            .accessibilityIdentifier("game.tapSurface")
            .disabled(coordinator.isPaused || coordinator.isEndingRun)

            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Spacer()
                    VStack(spacing: 10) {
                        Text("\(coordinator.score)")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                            .accessibilityIdentifier("game.score")

                        if coordinator.currentPerfectStreak > 0 {
                            Text("Perfect x\(coordinator.currentPerfectStreak)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.accent)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(.white.opacity(0.055), in: Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(theme.accent.opacity(0.2), lineWidth: 1)
                                )
                                .accessibilityIdentifier("game.combo")
                        }
                    }
                    Spacer()
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        coordinator.togglePause()
                    } label: {
                        Image(systemName: coordinator.isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(theme.primaryText)
                            .frame(width: 34, height: 34)
                            .background(.white.opacity(0.05), in: Circle())
                            .overlay(Circle().stroke(theme.accent.opacity(0.18), lineWidth: 1))
                    }
                    .padding(.trailing, 24)
                    .accessibilityIdentifier("game.pause")
                }
                .padding(.top, 18)

                Spacer()

                if let progress = coordinator.challengeProgress, let challenge = session.challenge {
                    HStack(spacing: 10) {
                        Text(challenge.shortLabel)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                        ProgressView(value: progress.fractionComplete)
                            .tint(theme.accent)
                            .frame(width: 120)
                        Text(progress.detailText)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.secondaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.white.opacity(0.045), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(theme.accent.opacity(0.18), lineWidth: 1)
                    )
                    .padding(.bottom, 26)
                }
            }
            .padding(.horizontal, 12)
            .ignoresSafeArea(edges: .top)

            if coordinator.shouldShowTutorial {
                VStack {
                    Spacer()
                    Text("Tap to drop")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.primaryText)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(.white.opacity(0.06), in: Capsule())
                        .overlay(
                            Capsule()
                                .stroke(theme.accent.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.bottom, 92)
                        .accessibilityIdentifier("game.tutorial")
                }
                .allowsHitTesting(false)
            }

            if coordinator.isPaused {
                PauseOverlay(theme: theme, onResume: coordinator.togglePause, onHome: coordinator.leaveToHome)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct PauseOverlay: View {
    let theme: Theme
    let onResume: () -> Void
    let onHome: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            GlassCard(theme: theme) {
                Text("Paused")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.primaryText)

                Button("Resume") {
                    onResume()
                }
                .buttonStyle(PrimaryPillButton(theme: theme))

                Button("Return Home") {
                    onHome()
                }
                .buttonStyle(SecondaryCapsuleButton(theme: theme))
            }
            .padding(.horizontal, 34)
        }
    }
}
