# Perfect Stack

Perfect Stack is an iOS-first minimalist stacking game prototype built from the product dossier in `C:\Users\jimmy\Downloads\Perfect_Stack_Strategy_and_Design_Dossier.pdf`. The goal is a premium, replay-first experience: quiet dark UI, tactile feedback, elegant motion, and a one-tap mechanic that feels unusually polished.

## Stack
- SwiftUI for shell, navigation, settings, results, and share UI
- SpriteKit for timing-critical gameplay rendering
- Core Haptics with UIKit fallback
- AVFoundation for low-latency procedural audio playback
- StoreKit 2 abstractions for future digital products
- Local persistence via `UserDefaults`
- Protocol-based analytics with a local logger implementation

## Project Layout
- `PerfectStack/`: app source
- `PerfectStackTests/`: pure logic tests
- `PerfectStackUITests/`: smoke tests
- `docs/`: product, design, architecture, analytics, launch, and monetization docs
- `.github/workflows/`: CI

## Build
This repository is authored from a Windows workspace, but the app itself requires macOS with Xcode 16+.

```bash
xcodebuild -project PerfectStack.xcodeproj \
  -scheme PerfectStack \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
  build
```

## Test
```bash
xcodebuild -project PerfectStack.xcodeproj \
  -scheme PerfectStack \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest' \
  test
```

## Screenshots
Capture on macOS after booting a simulator:

```bash
xcrun simctl io booted screenshot artifacts/screenshots/home.png
xcrun simctl io booted screenshot artifacts/screenshots/gameplay.png
xcrun simctl io booted screenshot artifacts/screenshots/gameplay-combo.png
xcrun simctl io booted screenshot artifacts/screenshots/results.png
```

## Notes
- Monetization is intentionally disabled in-app for v1. Future digital unlocks are modeled around StoreKit abstractions, not Stripe checkout inside iOS.
- A Figma handoff file is not guaranteed from this workspace because the current Figma access is view-only. The repo docs are the reliable handoff artifact.

See `docs/architecture.md` and `docs/design-system.md` for implementation details.

