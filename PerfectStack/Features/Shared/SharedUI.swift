import SwiftUI

struct AmbientBackground: View {
    let theme: Theme

    var body: some View {
        ZStack {
            theme.backgroundGradient
                .ignoresSafeArea()

            RadialGradient(
                colors: [theme.accent.opacity(0.24), .clear],
                center: .top,
                startRadius: 40,
                endRadius: 360
            )
            .blendMode(.screen)
            .offset(y: -120)
            .ignoresSafeArea()

            Circle()
                .fill(theme.accent.opacity(0.12))
                .frame(width: 260, height: 260)
                .blur(radius: 90)
                .offset(x: 130, y: 320)

            Circle()
                .fill(theme.accent.opacity(0.08))
                .frame(width: 220, height: 220)
                .blur(radius: 70)
                .offset(x: -160, y: -280)
        }
    }
}

struct GlassCard<Content: View>: View {
    let theme: Theme
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(theme.accent.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

struct PrimaryPillButton: ButtonStyle {
    let theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 19, weight: .bold, design: .rounded))
            .foregroundStyle(Color.black.opacity(0.88))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [theme.accent, theme.accent.opacity(0.78)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: theme.accent.opacity(configuration.isPressed ? 0.15 : 0.32), radius: configuration.isPressed ? 10 : 22, y: 10)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct SecondaryCapsuleButton: ButtonStyle {
    let theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .foregroundStyle(theme.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule(style: .continuous)
                    .fill(.white.opacity(configuration.isPressed ? 0.08 : 0.05))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(theme.accent.opacity(0.18), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}

struct StatBlock: View {
    let title: String
    let value: String
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.secondaryText)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(theme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.045))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(theme.accent.opacity(0.14), lineWidth: 1)
                )
        )
    }
}

struct ThemeChip: View {
    let theme: Theme
    let isSelected: Bool
    let isUnlocked: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Circle()
                    .fill(theme.accent)
                    .frame(width: 10, height: 10)
                Spacer()
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(theme.primaryText.opacity(0.7))
                }
            }

            Text(theme.name)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(theme.primaryText)
                .lineLimit(2)
        }
        .padding(14)
        .frame(width: 124, height: 92)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(isSelected ? theme.accent.opacity(0.16) : .white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(isSelected ? theme.accent.opacity(0.6) : theme.accent.opacity(0.14), lineWidth: 1)
                )
        )
        .opacity(isUnlocked ? 1 : 0.7)
    }
}

