import SwiftUI
import UIKit

struct ResultsView: View {
    let summary: RunSummary
    let theme: Theme
    let analytics: any AnalyticsClient
    let onReplay: () -> Void
    let onHome: () -> Void

    @State private var shareImage: UIImage?
    @State private var isShowingShareSheet = false

    var body: some View {
        ZStack {
            AmbientBackground(theme: theme)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    VStack(spacing: 10) {
                        Text(summary.isNewBest ? "New Best" : "Run Complete")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(summary.isNewBest ? theme.accent : theme.secondaryText)
                        Text("\(summary.score)")
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                            .accessibilityIdentifier("results.score")
                        Text(summary.isNewBest ? "That one mattered." : "Clean run. Try again immediately.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.secondaryText)
                    }
                    .padding(.top, 30)

                    HStack(spacing: 14) {
                        StatBlock(title: "Best", value: "\(summary.bestScore)", theme: theme)
                        StatBlock(title: "Perfect Streak", value: "\(summary.perfectStreak)", theme: theme)
                    }

                    if let progress = summary.challengeProgress, let challenge = summary.challenge {
                        GlassCard(theme: theme) {
                            Text("Daily Challenge")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                            Text(challenge.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                            ProgressView(value: progress.fractionComplete)
                                .tint(theme.accent)
                            Text(progress.isComplete ? "Completed" : progress.detailText)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(progress.isComplete ? theme.accent : theme.secondaryText)
                        }
                    }

                    if !summary.unlockedThemeNames.isEmpty {
                        GlassCard(theme: theme) {
                            Text("Unlocked")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                            Text(summary.unlockedThemeNames.joined(separator: " • "))
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.accent)
                        }
                    }

                    Button("Replay") {
                        onReplay()
                    }
                    .buttonStyle(PrimaryPillButton(theme: theme))
                    .accessibilityIdentifier("results.replay")

                    Button("Share") {
                        analytics.track(AnalyticsEvent(name: "share_tap", payload: [
                            "score": "\(summary.score)",
                            "theme_id": theme.id
                        ]))
                        shareImage = renderShareCard(summary: summary, theme: theme)
                        isShowingShareSheet = shareImage != nil
                    }
                    .buttonStyle(SecondaryCapsuleButton(theme: theme))
                    .accessibilityIdentifier("results.share")

                    Button("Back to Home") {
                        onHome()
                    }
                    .buttonStyle(.plain)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.secondaryText)
                    .padding(.top, 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let shareImage {
                ActivityView(items: [shareImage])
            }
        }
    }
}

