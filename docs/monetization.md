# Monetization

## Launch Stance
Optimize for retention, polish, and ratings first. Do not ship forced ad interruptions or any off-platform digital checkout inside the iOS app.

## In-App Rules
- Future digital unlocks must go through StoreKit-backed abstractions
- Monetization remains feature-flagged and disabled by default in v1
- Candidate future products:
  - cosmetic theme pack
  - premium visual effects pack
  - ad-free package

## Stripe Boundary
Stripe is reserved for off-app planning or companion-web support artifacts, not for digital-goods checkout inside the iOS app. If a companion site is added later, Stripe product metadata should be maintained outside the iOS runtime.

## Review-Safe Path
- Keep all digital purchase UI out of v1
- Document product ids and paywall concepts only
- Add StoreKit product loading behind a disabled abstraction so the architecture is ready without violating App Store rules

