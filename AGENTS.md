# AGENTS

## Product Principles
- The tower is the hero. UI chrome stays quiet and secondary.
- Perfect Stack wins on feel, not feature count.
- First-session delight matters more than long-term systems in v1.
- Failures must still feel polished enough to invite an instant replay.

## Source-Of-Truth Ordering
1. `C:\Users\jimmy\Downloads\Perfect_Stack_Strategy_and_Design_Dossier.pdf`
2. Repo docs generated in this project
3. Implementation assumptions made to close gaps cleanly

## Coding Standards
- Prefer small Swift files with one primary responsibility.
- Keep game math pure in engine code and keep SpriteKit focused on rendering/animation.
- Use SwiftUI Observation APIs and explicit dependency injection over global state.
- Default to simple value types and testable helpers before introducing indirection.
- Avoid placeholder architecture that does not serve the MVP.

## Architecture Conventions
- `PerfectStack/App`: app shell and route coordination
- `PerfectStack/Core`: domain models and shared services
- `PerfectStack/Features/Home`: home and theme selection
- `PerfectStack/Features/Game`: engine, coordinator, and SpriteKit scene
- `PerfectStack/Features/Results`: end-of-run presentation and replay/share
- `PerfectStack/Features/Shared`: settings sheet, share card, and UIKit bridges
- `PerfectStackTests`: pure logic/unit coverage
- `PerfectStackUITests`: smoke coverage for the main loop

## Visual And Motion Rules
- Near-black base with one bright accent at a time
- Rounded forms, restrained glow, excellent spacing
- Quiet menus and a minimal HUD
- Use stronger motion/audio/haptics only for perfects, streaks, and new-best moments
- Reduced motion removes excess flourish but preserves clarity

## Validation Expectations
- Build locally on macOS with Xcode before any release candidate
- Keep game rules covered with unit tests
- Smoke test home -> play -> results -> replay
- Manually verify persistence, settings toggles, and share flow
- Capture final screenshots for Home, Gameplay, Combo, and Results

## Git Discipline
- Work on a feature branch with clear milestone commits
- Do not mix unrelated cleanup into gameplay commits
- Keep README and docs current as architecture changes
- Never rewrite user work without explicit direction

## Do Not Overbuild
- No accounts, currencies, battle passes, or progression trees
- No ad SDKs or payment flows in v1
- No flashy particle spam or noisy HUD chrome
- No complex physics simulation when scripted motion is cleaner

