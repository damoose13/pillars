# Pillars

A private wellness **operating system** — not a habit tracker.

Pillars helps an individual (and, later, trusted *Circles*) check in across **eight
life pillars**, surface the one pillar holding them back today, and take **1–3 small
restoring actions**. Local-first. Private by design.

> Today's Foundation — your system is steady. One pillar is asking for attention.

---

## Status — v0.1 (Individual mode)

The first milestone is intentionally narrow and complete:

> A user completes an 8‑pillar daily check‑in and receives a **Today** dashboard with a
> system score, weakest & strongest pillar, all 8 pillar scores, exactly 3 recommended
> restoring actions, and a visual pillar map.

Circles, real backend (Supabase), HealthKit, and subscriptions (StoreKit 2) are
**deliberately deferred** to later versions. The `CircleGroup` / `SharedWin` SwiftData
models are included as foundation only — there is no Circle UI yet.

## The eight pillars

`Body · Fuel · Sleep · Recover · Mind · Connect · Space · Purpose`

`Purpose` is the mainstream default and can be renamed (Spirit, Faith, Dharma, Values,
Meaning, Direction) in **Settings**, which keeps the app broad while preserving more
personal/spiritual use cases.

## Tech

- SwiftUI + SwiftData, iOS 17+
- No external dependencies
- Clean, MVVM‑ish separation: domain logic lives in `Engines/`, never inside views
- A dark, premium design system in `Theme/` with reusable `Components/`

## Architecture / file map

```
Pillars/
  App/          App entry, root routing, observable app state
  Models/       PillarType, DailyCheckIn, PillarAction, CircleGroup, SharedWin, …
  Engines/      PillarScoringEngine, RecommendationEngine  (pure, testable logic)
  Theme/        Colors, typography, spacing, background, shared small components
  Components/   PillarGlassCard, PillarScoreOrb, TodayFoundationHeader,
                PillarMoveCard, PillarRadialMap, ScoreSelector, PillarScoreForm
  Views/
    Onboarding/ Welcome, PillarPhilosophy, BaselineAssessment
    Today/      TodayDashboard, DailyCheckIn, TodayMoves, PillarMap, PillarDetail
    Settings/   Settings
  Assets.xcassets
```

## Design language

Premium, calm, private, modern. Warm off‑black background, soft ivory text, a subtle
gold accent, muted pillar colors, glass cards with quiet borders, large editorial
(serif) display type, and a distinctive radial pillar map. No neon, no mascots, no
gamification, no medical claims.

## Open it

```bash
open Pillars.xcodeproj
```

Build & run on an iOS 17+ simulator or device. The project uses Xcode's file‑system
synchronized groups, so new files added under `Pillars/` are picked up automatically.

## Note on `Circle`

The data model the spec calls `Circle` is named **`CircleGroup`** in code to avoid
colliding with SwiftUI's `Circle` shape (used heavily in the orb and radial map).
