import CoreGraphics
import Foundation

final class GameEngine {
    let initialWidth: CGFloat = 188
    let widthRestoreOnPerfect: CGFloat = 10
    let challenge: DailyChallenge?
    let startedAt = Date()

    private(set) var currentWidth: CGFloat
    private(set) var currentCenterX: CGFloat = 0
    private(set) var score = 0
    private(set) var currentPerfectStreak = 0
    private(set) var highestPerfectStreak = 0
    private(set) var totalPerfects = 0
    private(set) var totalDrops = 0

    init(challenge: DailyChallenge? = nil) {
        currentWidth = initialWidth
        self.challenge = challenge
    }

    var speedMultiplier: Double {
        min(1 + (Double(score) * 0.055), 2.25)
    }

    var challengeProgress: ChallengeProgress? {
        challenge?.progress(score: score, perfects: totalPerfects, bestStreak: highestPerfectStreak)
    }

    func dropBlock(at droppedCenterX: CGFloat) -> GameDropOutcome {
        let previousCenterX = currentCenterX
        let previousWidth = currentWidth
        let offset = droppedCenterX - previousCenterX
        let overlap = previousWidth - abs(offset)
        let direction: CGFloat = offset >= 0 ? 1 : -1

        totalDrops += 1

        guard overlap > 0 else {
            currentPerfectStreak = 0
            return GameDropOutcome(
                kind: .failed,
                droppedCenterX: droppedCenterX,
                previousCenterX: previousCenterX,
                previousWidth: previousWidth,
                newCenterX: previousCenterX,
                newWidth: previousWidth,
                trimmedWidth: previousWidth,
                overhangDirection: direction,
                score: score,
                perfectStreak: currentPerfectStreak,
                totalPerfects: totalPerfects,
                speedMultiplier: speedMultiplier,
                challengeProgress: challengeProgress
            )
        }

        score += 1
        let tolerance = perfectTolerance(for: previousWidth)

        if abs(offset) <= tolerance {
            currentPerfectStreak += 1
            highestPerfectStreak = max(highestPerfectStreak, currentPerfectStreak)
            totalPerfects += 1
            currentCenterX = previousCenterX
            currentWidth = min(initialWidth, previousWidth + widthRestoreOnPerfect)

            return GameDropOutcome(
                kind: .perfect,
                droppedCenterX: droppedCenterX,
                previousCenterX: previousCenterX,
                previousWidth: previousWidth,
                newCenterX: currentCenterX,
                newWidth: currentWidth,
                trimmedWidth: max(previousWidth - overlap, 0),
                overhangDirection: direction,
                score: score,
                perfectStreak: currentPerfectStreak,
                totalPerfects: totalPerfects,
                speedMultiplier: speedMultiplier,
                challengeProgress: challengeProgress
            )
        }

        currentPerfectStreak = 0
        currentWidth = overlap
        currentCenterX = previousCenterX + (direction * ((previousWidth - currentWidth) / 2))

        return GameDropOutcome(
            kind: .normal,
            droppedCenterX: droppedCenterX,
            previousCenterX: previousCenterX,
            previousWidth: previousWidth,
            newCenterX: currentCenterX,
            newWidth: currentWidth,
            trimmedWidth: previousWidth - currentWidth,
            overhangDirection: direction,
            score: score,
            perfectStreak: currentPerfectStreak,
            totalPerfects: totalPerfects,
            speedMultiplier: speedMultiplier,
            challengeProgress: challengeProgress
        )
    }

    func makeSummary(themeID: String) -> RunSummary {
        RunSummary(
            score: score,
            bestScore: score,
            isNewBest: false,
            perfectStreak: highestPerfectStreak,
            totalPerfects: totalPerfects,
            totalDrops: totalDrops,
            duration: Date().timeIntervalSince(startedAt),
            remainingWidth: currentWidth,
            challenge: challenge,
            challengeProgress: challengeProgress,
            themeID: themeID
        )
    }

    private func perfectTolerance(for width: CGFloat) -> CGFloat {
        min(max(width * 0.08, 4), 18)
    }
}

