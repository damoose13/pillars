# Pillars — Data Integrations: Masterlist & Build-Out Assessment

The goal: let Pillars **auto-collect signals** for each pillar from the apps/devices people
already use, instead of relying only on the manual daily check-in.

> **The one insight that shapes everything below:** on iOS, **Apple HealthKit is the hub.**
> Oura, Whoop, Strava, Fitbit, MyFitnessPal, AutoSleep, and dozens more **already write into
> Apple Health.** So integrating HealthKit *once* gives read access to data spanning five of
> the eight pillars — **on-device, no backend, no per-app OAuth.** Direct cloud-API
> integrations with those same services are mostly *redundant on iOS* and each one needs the
> backend we've deliberately deferred. **Build HealthKit first; treat cloud APIs as a later,
> optional, Android-and-history play.**

This also reframes a prior constraint: the original spec said "no HealthKit." Adding it is a
deliberate expansion — and a privacy-aligned one, because HealthKit data stays **on the
device** (local-first), which is exactly Pillars' model.

---

## How each pillar can be fed

Access method legend:
- **HK** — Apple HealthKit (on-device, no backend, ~most third-party trackers feed this)
- **iOS** — another on-device Apple framework (EventKit, WeatherKit, DeviceActivity, …)
- **OAuth+BE** — a cloud API needing OAuth **and a backend** (can't embed client secrets in the app)
- **Manual** — no reliable API; stays a check-in input

| Pillar | Best signals | Sources | Access | Backend? | iOS marginal value over HK |
|---|---|---|---|---|---|
| **Body** | steps, workouts, active energy, exercise min, VO₂max | Apple Watch, Strava, Garmin, Fitbit, Whoop, Peloton, Nike | **HK** | No | Low (all feed HK) |
| **Fuel** | dietary energy, macros, water | MyFitnessPal, Cronometer, Lose It!, WaterMinder, Lumen, CGM (Levels/Nutrisense) | **HK** (+ OAuth+BE for richer) | No for HK | Medium (some don't fully write macros to HK) |
| **Sleep** | duration, stages, consistency | Apple Watch, Oura, Whoop, Eight Sleep, Withings, AutoSleep, Sleep Cycle | **HK** | No | Low |
| **Recover** | HRV, resting HR, respiratory rate, readiness | Apple Watch, Oura (readiness), Whoop (recovery), Garmin (Body Battery) | **HK** (raw) / **OAuth+BE** (vendor scores) | No for HK | Medium (vendor "readiness/recovery" scores aren't in HK) |
| **Mind** | mindful minutes, **State of Mind** (mood, iOS 17+), focus/productivity | Apple Mindfulness, Headspace/Calm (→HK), RescueTime, Screen Time | **HK** + **iOS** (DeviceActivity) | No | Medium |
| **Connect** | social calendar time, planned gatherings | Calendar | **iOS** (EventKit) | No | — (HK has none) |
| **Space** | air quality, time-at-home, noise exposure | WeatherKit/AirNow, Core Location, HK (environmental audio) | **iOS** + **HK** | No | — |
| **Purpose** | reflection/journaling cadence, goals | Day One, goal apps | **Manual** (mostly) | — | — |

**Takeaway:** Body / Fuel / Sleep / Recover / Mind are richly auto-fillable. **Connect, Space,
Purpose stay mostly manual** — which is fine; they're the human, reflective pillars.

---

## Full masterlist of candidate services

Grouped by what it takes to integrate.

### A. Reachable through HealthKit (no backend) — **build once, get all of these**
Apple Watch · iPhone motion · **Oura** · **Whoop** · **Strava** · **Garmin** · **Fitbit** ·
**Withings** · **Eight Sleep** · **AutoSleep / Sleep Cycle / Pillow** · **MyFitnessPal /
Cronometer / Lose It!** · **WaterMinder** · **Headspace / Calm** (mindful minutes) ·
**Peloton / Nike Run Club** (workouts) · CGMs (**Levels / Nutrisense**) · most blood-pressure
/ scale / glucose hardware. *(Coverage varies by what each app chooses to write; sleep, steps,
workouts, HR/HRV, and active energy are near-universal.)*

### B. Other on-device Apple frameworks (no backend)
- **EventKit** (Calendar) → Connect: hours of social/relationship events.
- **WeatherKit** + **Core Location** → Space: air quality, daylight, time spent at home.
- **DeviceActivity / Screen Time** → Mind: focus vs. doom-scrolling (heavily privacy-gated).
- **HealthKit State of Mind** (iOS 17+) → Mind: the user's own mood logs.

### C. Cloud APIs — **need OAuth + a backend** (defer)
Direct vendor APIs, valuable mainly for **vendor-computed scores not in HealthKit** (Oura
Readiness, Whoop Recovery, Garmin Body Battery) and for **Android / web** later:
**Oura API · Whoop API · Strava API · Fitbit Web API · Garmin Connect (partner) · Withings ·
Eight Sleep · Polar · Suunto · RescueTime · Google Fit / Health Connect (Android) · Spotify**
(wind-down/focus proxy) **· Todoist / Notion** (mental load proxy).
Each requires: an OAuth client, a server to hold the client secret + refresh tokens + receive
webhooks, and (for several) partner-program approval.

### D. Weak / no public API (stay manual or skip)
Apple Messages/Phone frequency (private by design), most mood journals (Daylio), most
meditation streaks, "tidiness," and anything for **Purpose** (inherently subjective).

---

## Recommended build-out — phased

**Phase 1 — HealthKit (do this first). ~Medium effort, no backend.**
- Add the HealthKit capability + `NSHealthShareUsageDescription`.
- A `HealthKitProvider` requests **read-only** access to a minimal set: steps, active energy,
  exercise minutes, sleep, HRV, resting HR, mindful minutes, State of Mind, dietary energy, water.
- A `HealthSignals → pillar score` mapper blends auto-data with the manual check-in (e.g. a
  pillar shows "from Health" when data exists, else falls back to the slider).
- Onboarding: an optional "Connect Apple Health" step (skippable; everything still works manually).
- **Privacy story stays intact:** data is read on-device, mapped to a 1–5 score, and never
  uploaded — "Pillars reads only what you allow from Apple Health, on your device."
- *Caveat:* HealthKit needs a real signed build on a device (it's limited in the Simulator and
  in unsigned CI), so this is verified on your Mac, not the screenshot pipeline.

**Phase 2 — On-device Apple frameworks. ~Small–Medium each, no backend.**
EventKit (Connect), WeatherKit + Location (Space), optionally DeviceActivity (Mind). Each is a
self-contained, skippable signal.

**Phase 3 — Cloud APIs. Large; requires the backend + accounts first.**
Only worth it for vendor scores HealthKit lacks (Oura Readiness, Whoop Recovery) and for
**Android**. Build the account/sync backend (already sketched in `BACKEND.md`), then add OAuth
connectors one vendor at a time, starting with **Oura** and **Whoop** (highest-signal readiness).

---

## Scoring: how auto-data becomes a pillar state

Keep the 1–5 / five-state model. For a connected pillar, derive the score **relative to the
user's own recent baseline**, not absolute targets (avoids judgement, matches the calm tone):
- e.g. Sleep: last night vs. the person's 14-day median duration + consistency → 1–5.
- Recover: today's HRV / resting HR vs. baseline → 1–5.
- Always let the manual check-in **override** the auto-score (it's a felt sense, not just data).
- Show provenance quietly: a small "from Apple Health" tag on auto-filled pillars.

## Effort summary

| Phase | What | Backend | Rel. effort | iOS value |
|---|---|---|---|---|
| 1 | **HealthKit** (5 pillars) | No | ●●○○○ | ★★★★★ |
| 2 | EventKit / WeatherKit / DeviceActivity | No | ●●○○○ (each) | ★★☆ |
| 3 | Cloud APIs (Oura, Whoop, Strava…) | **Yes** | ●●●●● | ★★ (mostly redundant on iOS) |

**Bottom line:** HealthKit is ~80% of the value for ~20% of the work and **fits local-first
with no backend**. I'd build Phase 1 next; everything in Phase 3 should wait for the backend
and is mainly an Android/cross-platform story.
