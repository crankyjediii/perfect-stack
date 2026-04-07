# Architecture

## App Structure
- `PerfectStackApp`: root entry point
- `AppModel`: route coordination, run lifecycle, unlock handling, and dependency ownership
- `SettingsStore`: persisted user controls
- `ThemeCatalog`: static theme definitions plus unlock logic
- `GameEngine`: pure game rules and challenge progress
- `GameCoordinator`: bridge between engine outputs and UI/scene state
- `GameScene`: SpriteKit rendering, movement, and timing effects
- `HomeView`, `GameView`, `ResultsView`, `SettingsSheet`: SwiftUI shell
- `AudioManager`, `HapticsManager`, `AnalyticsClient`, `MonetizationClient`, `PersistenceClient`: shared services

## Rule Split
- Pure logic never depends on SpriteKit
- Scene code never owns canonical score or progression data
- Results and sharing read a single `RunSummary`

## Persistence
- `UserDefaults` stores best score, theme selection, unlocks, and settings
- Analytics log writes to Application Support for local inspection

## Challenge Model
- Daily challenge is deterministic from the calendar date
- Endless mode remains the only gameplay mode
- Challenge progress is evaluated from run events and shown on home/results

