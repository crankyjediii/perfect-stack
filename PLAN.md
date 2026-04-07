# Perfect Stack Plan

## Objective
Ship a premium-feeling iOS MVP for Perfect Stack: a one-tap stacking game with a native SwiftUI shell, SpriteKit gameplay, strong tactile and audio feedback, persistent progression, lightweight daily challenges, and clean launch documentation.

## Source Of Truth
1. `C:\Users\jimmy\Downloads\Perfect_Stack_Strategy_and_Design_Dossier.pdf`
2. Repo docs in `docs/`
3. Implementation assumptions made to complete the MVP cleanly

## Delivery Phases
- Phase 1: Repo scaffold, product docs, app architecture, and project wiring
- Phase 2: Home shell, settings, themes, navigation, and results shell
- Phase 3: Playable SpriteKit core with scoring, slicing, failure, and persistence
- Phase 4: Premium polish pass with perfect snap, glow, slow-motion, haptics, and audio
- Phase 5: Share cards, daily challenge, analytics, StoreKit-ready abstractions, and CI
- Phase 6: Final cleanup, screenshots workflow, and release notes

## Acceptance Bar
- Home, gameplay, and results are implemented in a single coherent flow
- Perfect hits are mechanically and sensorially stronger than normal hits
- Best score, settings, unlocks, and selected theme persist
- Daily challenge path is functional and visible from home
- Analytics calls are real through a local-swappable abstraction
- Monetization is StoreKit-ready and disabled by default
- Repo docs explain setup, architecture, QA, design direction, and launch readiness

## Known Environment Constraint
This workspace is on Windows without Xcode or simulator tooling. The codebase is implemented here, but build, simulator validation, and screenshots require a macOS/Xcode machine.

