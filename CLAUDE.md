# CLAUDE.md — working guide for Pillars

**Read [`NORTH_STAR.md`](./NORTH_STAR.md) first.** It is the product north star; this file is the
short operating guide for working in the codebase.

## What Pillars is

A private wellness & restoration app built around eight pillars — Body, Fuel, Sleep, Recover,
Mind, Connect, Space, Purpose — centered on the **Pillar Web**. The intelligence layer is
**FitOS** (the engines under `Pillars/Engines/`). Training is *one restoration path inside*
Pillars, not a separate product. Hardware (Pillars Band / HUD) is the future Body/Recover
interface and cannot be built in this SwiftUI repo — only Device screens and integration seams.

## Durable invariants (do not violate without explicit sign-off)

- **Private & local-first.** Check-in data in SwiftData on-device; preferences in UserDefaults.
  Individual scores are never shown to a Circle by default — only voluntary, permissioned shares.
- **Secular by default.** No temple/prayer/seva language unless `spiritualRitualsEnabled` is on.
  Community framings only when `communityContentEnabled` is on. Both opt-in, off by default.
- **Restoration, not performance pressure.** No streaks/shame/red-green scoring by default.
  Language is "asking for support," never "bad/failed." Training is matched to current state.
- **Felt over Signal.** Wearable/HealthKit data informs but never overrides what the user reports.
- **Calm premium tone.** Deep charcoal, ivory text, muted amber-gold. Calm motion, minimal badges.

## Architecture map

- `Pillars/App/` — shell: `AppState` (tabs + prefs), `MainTabView`, `RootView`, `CaptureRoot`
  (UI-test routes for CI screenshots).
- `Pillars/Engines/` — FitOS: scoring, restoration, restoration-effectiveness/learning, weekly
  insight, Circle morale/pulse/recommendation, privacy rules, HealthKit, ritual library.
- `Pillars/Models/` — SwiftData models + value types (`PillarType`, `DailyCheckIn`, `PillarAction`,
  `PillarRecommendation`, `ContentPreferences`, …).
- `Pillars/Views/` — by area: `Today/`, `Restore/`, `Circle/`, `Insights/`, `Settings/`,
  `Onboarding/`, plus shared `Components/`.

## Working conventions

- **One step per commit; each must compile cleanly before the next.** No combining steps.
- CI (`.github/workflows/simulator.yml`) builds on an iOS simulator and publishes screenshots to
  the `ci-simulator-shots` branch. Add a `CaptureRoot` route + a `shoot` line for new screens.
- Match surrounding code: comment density, naming, spacing tokens (`PillarsSpacing`,
  `PillarsColors`, `PillarsTypography`).
- Develop on the assigned feature branch; never push elsewhere without permission.
