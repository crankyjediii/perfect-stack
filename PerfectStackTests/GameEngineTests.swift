import XCTest
@testable import PerfectStack

final class GameEngineTests: XCTestCase {
    func testPerfectDropIncreasesScoreAndStreak() {
        let engine = GameEngine()

        let outcome = engine.dropBlock(at: 0)

        XCTAssertEqual(outcome.kind, .perfect)
        XCTAssertEqual(outcome.score, 1)
        XCTAssertEqual(outcome.perfectStreak, 1)
        XCTAssertEqual(engine.currentWidth, min(engine.initialWidth, engine.initialWidth + engine.widthRestoreOnPerfect))
    }

    func testNormalDropSlicesWidthAndResetsPerfectStreak() {
        let engine = GameEngine()
        _ = engine.dropBlock(at: 0)

        let outcome = engine.dropBlock(at: 18)

        XCTAssertEqual(outcome.kind, .normal)
        XCTAssertEqual(outcome.score, 2)
        XCTAssertEqual(outcome.perfectStreak, 0)
        XCTAssertLessThan(outcome.newWidth, outcome.previousWidth)
    }

    func testFailedDropEndsWhenNoOverlapRemains() {
        let engine = GameEngine()
        let outcome = engine.dropBlock(at: engine.initialWidth + 4)

        XCTAssertEqual(outcome.kind, .failed)
        XCTAssertEqual(engine.score, 0)
        XCTAssertEqual(engine.totalDrops, 1)
    }

    func testChallengeProgressTracksDailyChallenge() {
        let challenge = DailyChallenge(
            id: "2026-04-07",
            date: Date(timeIntervalSince1970: 0),
            kind: .perfects,
            target: 2
        )
        let engine = GameEngine(challenge: challenge)

        _ = engine.dropBlock(at: 0)
        let second = engine.dropBlock(at: 0)

        XCTAssertEqual(second.challengeProgress?.current, 2)
        XCTAssertTrue(second.challengeProgress?.isComplete == true)
    }

    func testThemeUnlockThresholds() {
        let catalog = ThemeCatalog.launch
        let unlocksAtTwenty = catalog.newlyUnlockedThemes(bestScore: 20, existingUnlockedThemeIDs: [])
        let unlocksAtSixty = catalog.newlyUnlockedThemes(bestScore: 60, existingUnlockedThemeIDs: [])

        XCTAssertEqual(unlocksAtTwenty.map(\.id), [])
        XCTAssertTrue(unlocksAtSixty.map(\.id).contains("iris-pulse"))
        XCTAssertTrue(unlocksAtSixty.map(\.id).contains("verdant-glow"))
    }

    func testPersistenceStoresBestScoreAndUnlocks() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let persistence = PersistenceClient(defaults: defaults)

        persistence.bestScore = 42
        persistence.unlock(themeIDs: ["iris-pulse"])

        XCTAssertEqual(persistence.bestScore, 42)
        XCTAssertTrue(persistence.unlockedThemeIDs.contains("iris-pulse"))
    }
}

