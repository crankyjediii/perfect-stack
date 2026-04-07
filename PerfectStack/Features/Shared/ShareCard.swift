import SwiftUI
import UIKit

struct ShareCardView: View {
    let summary: RunSummary
    let theme: Theme

    var body: some View {
        ZStack {
            theme.backgroundGradient

            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Perfect Stack")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(theme.primaryText)
                        Text(summary.isNewBest ? "New Best" : "Run Complete")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(theme.secondaryText)
                    }
                    Spacer()
                    Circle()
                        .fill(theme.accent)
                        .frame(width: 14, height: 14)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 14) {
                    Text("\(summary.score)")
                        .font(.system(size: 74, weight: .black, design: .rounded))
                        .foregroundStyle(theme.primaryText)

                    HStack(spacing: 12) {
                        ShareStat(title: "Best", value: "\(summary.bestScore)", theme: theme)
                        ShareStat(title: "Perfect Streak", value: "\(summary.perfectStreak)", theme: theme)
                    }
                }

                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(index < min(summary.perfectStreak, 6) ? theme.accent : theme.towerFill.opacity(0.16))
                            .frame(width: 28, height: CGFloat(52 + (index * 14)))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(theme.accent.opacity(0.16), lineWidth: 1)
                            )
                    }
                    Spacer()
                }
            }
            .padding(28)
        }
        .frame(width: 1080, height: 1920)
    }
}

private struct ShareStat: View {
    let title: String
    let value: String
    let theme: Theme

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(theme.secondaryText)
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(theme.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

@MainActor
func renderShareCard(summary: RunSummary, theme: Theme) -> UIImage? {
    let renderer = ImageRenderer(content: ShareCardView(summary: summary, theme: theme))
    renderer.scale = 1
    return renderer.uiImage
}

struct ActivityView: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

