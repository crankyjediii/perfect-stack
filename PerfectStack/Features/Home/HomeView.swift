import SwiftUI

struct HomeView: View {
    @Environment(AppModel.self) private var appModel

    var body: some View {
        @Bindable var appModel = appModel
        let theme = appModel.selectedTheme

        ZStack {
            AmbientBackground(theme: theme)

            VStack(spacing: 24) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Perfect Stack")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                        Text("Precision. Restraint. One more run.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.secondaryText)
                    }

                    Spacer()

                    Button {
                        appModel.isShowingSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(theme.primaryText)
                            .frame(width: 44, height: 44)
                            .background(.white.opacity(0.05), in: Circle())
                            .overlay(Circle().stroke(theme.accent.opacity(0.16), lineWidth: 1))
                    }
                    .accessibilityIdentifier("home.settings")
                }

                HeroTowerPreview(theme: theme)
                    .frame(height: 260)

                HStack(spacing: 14) {
                    StatBlock(title: "Best", value: "\(appModel.bestScore)", theme: theme)
                    StatBlock(title: "Daily", value: appModel.dailyChallenge.shortLabel, theme: theme)
                }

                Button("Play") {
                    appModel.tapPlay()
                }
                .buttonStyle(PrimaryPillButton(theme: theme))
                .accessibilityIdentifier("home.play")

                GlassCard(theme: theme) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Daily Challenge")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                            Text(appModel.dailyChallenge.title)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundStyle(theme.primaryText)
                            Text(appModel.dailyChallenge.subtitle)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.secondaryText)
                        }

                        Spacer()

                        Button("Enter") {
                            appModel.openDailyChallenge()
                        }
                        .buttonStyle(SecondaryCapsuleButton(theme: theme))
                        .accessibilityIdentifier("home.dailyChallenge")
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Themes")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.primaryText)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(appModel.availableThemes) { item in
                                Button {
                                    appModel.selectTheme(item)
                                } label: {
                                    ThemeChip(
                                        theme: item,
                                        isSelected: item.id == appModel.selectedTheme.id,
                                        isUnlocked: appModel.isUnlocked(item)
                                    )
                                }
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("theme.\(item.id)")
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 22)
            .padding(.bottom, 30)
        }
        .sheet(isPresented: $appModel.isShowingSettings) {
            SettingsSheet(settings: appModel.settings, theme: theme)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $appModel.isShowingDailyChallenge) {
            DailyChallengeSheet(
                theme: theme,
                challenge: appModel.dailyChallenge,
                onStart: appModel.startDailyChallengeRun
            )
            .presentationDetents([.height(320)])
        }
    }
}

private struct DailyChallengeSheet: View {
    let theme: Theme
    let challenge: DailyChallenge
    let onStart: () -> Void

    var body: some View {
        ZStack {
            AmbientBackground(theme: theme)

            VStack(alignment: .leading, spacing: 18) {
                Text("Today")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(theme.secondaryText)
                Text(challenge.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(theme.primaryText)
                Text(challenge.subtitle)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(theme.secondaryText)

                Button("Start Run") {
                    onStart()
                }
                .buttonStyle(PrimaryPillButton(theme: theme))
            }
            .padding(24)
        }
    }
}

private struct HeroTowerPreview: View {
    let theme: Theme
    @State private var shimmerOffset: CGFloat = -120

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.white.opacity(0.035))
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(theme.accent.opacity(0.16), lineWidth: 1)
                )

            VStack(spacing: 10) {
                Spacer(minLength: 0)

                ForEach(0..<6, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(theme.towerFill)
                        .frame(width: CGFloat(170 - (index * 16)), height: 26)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(theme.towerEdge.opacity(0.6), lineWidth: 1)
                        )
                        .shadow(color: theme.accent.opacity(0.16), radius: 10, y: 4)
                }

                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [theme.accent.opacity(0.92), theme.accent.opacity(0.55)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 132, height: 28)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(.white.opacity(0.24), lineWidth: 1)
                    )
                    .offset(x: shimmerOffset, y: -8)
                    .blur(radius: 0.2)
            }
            .padding(.vertical, 28)

            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.clear, theme.accent.opacity(0.28), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 130, height: 240)
                .rotationEffect(.degrees(20))
                .offset(x: shimmerOffset * 0.25)
                .blendMode(.screen)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.6).repeatForever(autoreverses: true)) {
                shimmerOffset = 120
            }
        }
    }
}

