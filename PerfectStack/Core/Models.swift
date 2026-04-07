import Foundation
import SwiftUI

struct Theme: Identifiable, Hashable {
    let id: String
    let name: String
    let accentLabel: String
    let unlockScore: Int?
    let backgroundTop: Color
    let backgroundBottom: Color
    let accent: Color
    let accentSoft: Color
    let towerFill: Color
    let towerEdge: Color
    let primaryText: Color
    let secondaryText: Color

    var isDefault: Bool { unlockScore == nil }
    var backgroundGradient: LinearGradient {
        LinearGradient(colors: [backgroundTop, backgroundBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct ThemeCatalog {
    let themes: [Theme]

    static let launch = ThemeCatalog(themes: [
        Theme(
            id: "obsidian-sky",
            name: "Obsidian Sky",
            accentLabel: "Sky",
            unlockScore: nil,
            backgroundTop: Color(hex: 0x121826),
            backgroundBottom: Color(hex: 0x040507),
            accent: Color(hex: 0x6FD3FF),
            accentSoft: Color(hex: 0x2E6C8C),
            towerFill: Color(hex: 0xD8F3FF, opacity: 0.96),
            towerEdge: Color(hex: 0x8EE4FF),
            primaryText: Color.white,
            secondaryText: Color.white.opacity(0.66)
        ),
        Theme(
            id: "iris-pulse",
            name: "Iris Pulse",
            accentLabel: "Iris",
            unlockScore: 25,
            backgroundTop: Color(hex: 0x170F1F),
            backgroundBottom: Color(hex: 0x050306),
            accent: Color(hex: 0xB684FF),
            accentSoft: Color(hex: 0x5D3B8A),
            towerFill: Color(hex: 0xF2E7FF, opacity: 0.95),
            towerEdge: Color(hex: 0xD5B8FF),
            primaryText: Color.white,
            secondaryText: Color.white.opacity(0.66)
        ),
        Theme(
            id: "verdant-glow",
            name: "Verdant Glow",
            accentLabel: "Mint",
            unlockScore: 60,
            backgroundTop: Color(hex: 0x0B1613),
            backgroundBottom: Color(hex: 0x030405),
            accent: Color(hex: 0x63F0C0),
            accentSoft: Color(hex: 0x1E755A),
            towerFill: Color(hex: 0xE3FFF5, opacity: 0.95),
            towerEdge: Color(hex: 0xA2FFD9),
            primaryText: Color.white,
            secondaryText: Color.white.opacity(0.66)
        )
    ])

    var defaultTheme: Theme {
        themes.first(where: \.isDefault) ?? themes[0]
    }

    func theme(id: String) -> Theme {
        themes.first(where: { $0.id == id }) ?? defaultTheme
    }

    func isUnlocked(themeID: String, unlockedThemeIDs: Set<String>) -> Bool {
        theme(id: themeID).isDefault || unlockedThemeIDs.contains(themeID)
    }

    func newlyUnlockedThemes(bestScore: Int, existingUnlockedThemeIDs: Set<String>) -> [Theme] {
        themes.filter { theme in
            guard let unlockScore = theme.unlockScore else { return false }
            return bestScore >= unlockScore && !existingUnlockedThemeIDs.contains(theme.id)
        }
    }
}

enum DailyChallengeKind: String, CaseIterable, Codable, Hashable {
    case score
    case perfects
    case streak
}

struct DailyChallenge: Identifiable, Equatable, Hashable {
    let id: String
    let date: Date
    let kind: DailyChallengeKind
    let target: Int

    var title: String {
        switch kind {
        case .score:
            return "Reach \(target)"
        case .perfects:
            return "Hit \(target) perfects"
        case .streak:
            return "Build a \(target)x streak"
        }
    }

    var subtitle: String {
        switch kind {
        case .score:
            return "Stay clean and keep stacking."
        case .perfects:
            return "Chase the bright line."
        case .streak:
            return "No panic taps. Stay precise."
        }
    }

    var shortLabel: String {
        switch kind {
        case .score:
            return "Score"
        case .perfects:
            return "Perfects"
        case .streak:
            return "Streak"
        }
    }

    func progress(score: Int, perfects: Int, bestStreak: Int) -> ChallengeProgress {
        let current: Int
        switch kind {
        case .score:
            current = score
        case .perfects:
            current = perfects
        case .streak:
            current = bestStreak
        }

        return ChallengeProgress(kind: kind, current: current, target: target)
    }

    static func forToday(date: Date, calendar: Calendar = .current) -> DailyChallenge {
        let startOfDay = calendar.startOfDay(for: date)
        let ordinal = calendar.ordinality(of: .day, in: .year, for: startOfDay) ?? 1
        let index = ordinal % DailyChallengeKind.allCases.count
        let kind = DailyChallengeKind.allCases[index]

        let target: Int
        switch kind {
        case .score:
            target = [18, 24, 30, 36][ordinal % 4]
        case .perfects:
            target = [4, 5, 6, 7][ordinal % 4]
        case .streak:
            target = [3, 4, 5, 6][ordinal % 4]
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return DailyChallenge(id: formatter.string(from: startOfDay), date: startOfDay, kind: kind, target: target)
    }
}

struct ChallengeProgress: Equatable, Hashable {
    let kind: DailyChallengeKind
    let current: Int
    let target: Int

    var isComplete: Bool {
        current >= target
    }

    var fractionComplete: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1)
    }

    var detailText: String {
        "\(min(current, target))/\(target)"
    }
}

struct GameSessionContext: Identifiable, Equatable {
    let id: UUID
    let themeID: String
    let challenge: DailyChallenge?
    let launchedFromDailyChallenge: Bool
}

struct RunSummary: Identifiable, Equatable {
    let id: UUID
    let score: Int
    let bestScore: Int
    let isNewBest: Bool
    let perfectStreak: Int
    let totalPerfects: Int
    let totalDrops: Int
    let duration: TimeInterval
    let remainingWidth: Double
    let challenge: DailyChallenge?
    let challengeProgress: ChallengeProgress?
    let themeID: String
    let unlockedThemeNames: [String]

    init(
        id: UUID = UUID(),
        score: Int,
        bestScore: Int,
        isNewBest: Bool,
        perfectStreak: Int,
        totalPerfects: Int,
        totalDrops: Int,
        duration: TimeInterval,
        remainingWidth: Double,
        challenge: DailyChallenge?,
        challengeProgress: ChallengeProgress?,
        themeID: String,
        unlockedThemeNames: [String] = []
    ) {
        self.id = id
        self.score = score
        self.bestScore = bestScore
        self.isNewBest = isNewBest
        self.perfectStreak = perfectStreak
        self.totalPerfects = totalPerfects
        self.totalDrops = totalDrops
        self.duration = duration
        self.remainingWidth = remainingWidth
        self.challenge = challenge
        self.challengeProgress = challengeProgress
        self.themeID = themeID
        self.unlockedThemeNames = unlockedThemeNames
    }

    func finalized(bestScore: Int, isNewBest: Bool, unlockedThemeNames: [String]) -> RunSummary {
        RunSummary(
            id: id,
            score: score,
            bestScore: bestScore,
            isNewBest: isNewBest,
            perfectStreak: perfectStreak,
            totalPerfects: totalPerfects,
            totalDrops: totalDrops,
            duration: duration,
            remainingWidth: remainingWidth,
            challenge: challenge,
            challengeProgress: challengeProgress,
            themeID: themeID,
            unlockedThemeNames: unlockedThemeNames
        )
    }
}

enum StoreProductKind: String, Hashable {
    case themePack = "theme_pack"
    case fxPack = "fx_pack"
    case adFree = "ad_free"
}

struct StoreProduct: Identifiable, Hashable {
    let id: String
    let kind: StoreProductKind
    let displayName: String
    let description: String
    let isEnabled: Bool
}

enum DropKind: Equatable {
    case normal
    case perfect
    case failed
}

struct GameDropOutcome: Equatable {
    let kind: DropKind
    let droppedCenterX: CGFloat
    let previousCenterX: CGFloat
    let previousWidth: CGFloat
    let newCenterX: CGFloat
    let newWidth: CGFloat
    let trimmedWidth: CGFloat
    let overhangDirection: CGFloat
    let score: Int
    let perfectStreak: Int
    let totalPerfects: Int
    let speedMultiplier: Double
    let challengeProgress: ChallengeProgress?
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

