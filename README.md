# Pillars

A private wellness **operating system** — not a habit tracker.

Pillars helps an individual (and, later, trusted *Circles*) check in across **eight
life pillars**, surface the one pillar holding them back today, and take **1–3 small
restoring actions**. Local-first. Private by design.

> Today's Foundation — your system is steady. One pillar is asking for attention.

---

## Status

**v0.1 — Individual mode (complete).** A user completes an 8‑pillar daily check‑in and
receives a **Today** cockpit with a system score, weakest & strongest pillar, all 8 pillar
scores, exactly 3 recommended restoring actions, and a visual pillar map — plus a **Weekly
Review** and **History**.

**v0.2 — Circle layer (mock).** Create a Circle, invite simulated trusted people, and see a
privacy‑safe **Circle Pulse**, shared resets, and voluntary shared wins. Privacy is gated by
size and enforced in the engine — never in the view:

| Circle size | What the Circle ever sees |
|---|---|
| 2 people | voluntary shared wins + suggestions only (no aggregates) |
| 3 people | one vague, blurred trend (e.g. "Connect is quiet") |
| 4+ people | aggregate pillar trend *labels* — never numbers, never per‑member |
| any size | a win you choose to share |

Individual pillar scores are **never** exposed in Circle mode. There is no auth/backend yet —
members are fabricated on‑device purely to exercise the privacy logic.

**v0.4 — Monetization (StoreKit 2, mock mode).** Real StoreKit 2 patterns with an offline
**mock** fallback, so the whole flow is testable with no real product IDs. `EntitlementManager`
gates a few features and `PaywallView` presents two plans:

- **Pillars Plus** — full history, Weekly Review, advanced insights.
- **Circle Pass** — Circle Pulse, shared resets, multiple Circles.

The daily loop stays free. A **developer mock‑store** toggle in Settings flips entitlements so
every gated state and the paywall are easy to preview. Product IDs are defined
(`pillars.plus.monthly` / `.yearly`, `pillars.circle.monthly` / `.yearly`) but **not** wired to
App Store Connect yet.

**v0.3 — Backend (Supabase): documented, not wired.** A live backend needs an external SDK,
which conflicts with the no‑dependency guardrail, so it's specified in
[`BACKEND.md`](BACKEND.md) (schema, server‑side privacy enforcement, auth/invite, sync, and the
swap‑in seam) and surfaced honestly as "Local only" in Settings → Sync.

HealthKit remains **deliberately deferred**.

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
