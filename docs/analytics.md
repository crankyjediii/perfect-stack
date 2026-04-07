# Analytics

## Provider Strategy
Use a protocol-first analytics layer with a local logger implementation so event wiring is real from day one without requiring provider credentials.

## Events
- `app_open`
- `first_open`
- `tap_play`
- `tutorial_shown`
- `tutorial_cleared`
- `run_start`
- `block_drop`
- `perfect_land`
- `slice_miss`
- `run_end`
- `share_tap`
- `daily_challenge_entered`
- `theme_changed`
- `settings_changed`

## Event Payload Principles
- Include only useful context: score, streak, duration, remaining width, challenge type, and theme id
- Keep payloads small and serializable
- Ensure `run_end` is the single authoritative summary event for a run

## Default Sink
`LocalAnalyticsClient` writes JSON lines and mirrors a readable summary to `OSLog`.

