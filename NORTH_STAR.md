# Pillars — North Star

> The master description. Keep this as the north star for all product and engineering
> decisions. When a change conflicts with this document, the document wins until it is
> deliberately revised.

## One-paragraph master statement

Pillars is a private wellness and restoration platform built around eight dimensions of
life: **Body, Fuel, Sleep, Recover, Mind, Connect, Space, Purpose**. At the center is the
**Pillar Web**, a living visual map of the user's day. The app helps people check in, see
what is asking for support, and choose one small restoration. Underneath Pillars is
**FitOS**, a private intelligence engine that learns from check-ins, rituals, wearable
signals, training, recovery, and feedback. For the Body and Recover pillars, Pillars extends
into a **camera-less HUD and sensing band** that guide workouts, auto-log reps, track
recovery, and update the Pillar Web without phone logging or recording anyone. For
**Circles**, Pillars lets trusted groups understand morale and support each other without
exposing private individual data. The long-term vision is *private wellness with shared
support*: a quiet operating system for knowing what feels off, restoring rhythm, and staying
connected without oversharing.

## Product architecture (one brand, layered)

- **Pillars** — the consumer app. Owns the language (the eight pillars), the visual (the
  Pillar Web), and the emotional promise: *"Know what is asking for support, then take one
  small restorative action."*
- **FitOS** — the private intelligence layer *underneath* Pillars. Not a separate app name.
  Turns signals into guidance. "Pillars is powered by FitOS."
- **Pillars Band + Pillars HUD** — the first hardware extension, focused on **Body / Recover**
  (secondary: Fuel, Sleep, Mind). The hardware is *Pillars entering the physical world* — it
  senses the user, never records the world. Camera-less, mic-less, minimal, peripheral.

Avoid presenting this as six products (wellness app + workout tracker + nutrition + glasses +
recovery wearable + community). It is **one** product: *Pillars helps you understand what feels
off and restore it. Sometimes the restoration is a text, a walk, a room reset, or a reflection.
Sometimes it is a guided workout, recovery adjustment, or nutrition action — powered by private
wearable data.*

## The philosophical bridge (training ≠ performance pressure)

Training is **one form of restoration when matched to the person's current state**. The app
should not always push harder — it helps choose the right action from the Pillar Web. Some days
that is a heavy lift; some days mobility, rest, an honest text, a room reset, water, or sleep.

## The main loop

Non-hardware: `Check in → see Pillar Web → choose restoration → complete → reflect → learn → (optionally share)`

Blended: `Check in → see Pillar Web → FitOS interprets signals → choose restoration OR training action → app/hardware guides it → reflect if it helped → Pillars learns → optionally share a win or start a Circle reset`

A workout is **an action that changes the Web**, not the whole product. After a workout the Web
updates (e.g. Body +9, Mind +3, Recover −5, Fuel asking) and Pillars suggests the next
restoration (e.g. protein + water).

## Felt + Signal (two-score system)

Never let wearable data override lived experience.

- **Felt score** — what the user reports ("How does your body feel?").
- **Signal score** — what data suggests (sleep, HR, workout load, missed sets…).

Combine gently: *"You feel ready, but recovery signals are low — consider keeping the workout but
reducing volume."* In the Web: inner shape = felt check-in; outer glow/halo = passive signal
confidence. Weak points pulse gently. **No red failure states, no score shame.** Language is
"asking for support," never "bad / failed / low performance."

## App structure — five tabs

1. **Today** — Pillar Web summary, the one pillar asking for support, one recommended
   restoration, today's training if relevant, a Circle nudge if relevant.
2. **Web** — the full Pillar Web: today / weekly / history / pattern; tap each pillar for detail.
   The signature surface.
3. **Restore** — library of actions, rituals, resets grouped by pillar. **Training lives here**
   under Body (Start programmed workout, walk, mobility, light session, rest day…).
4. **Circle** — group Pillar Web, shared resets, voluntary wins, gentle check-ins, permission
   controls. No scoreboard, no ranking, no "who is failing."
5. **Profile / Devices** — Pillars Band, Pillars HUD, integrations, privacy & sharing settings,
   subscription, data export/delete.

Training runs as a **Body Mode / Train Mode** entered from Today → Start Workout or Restore →
Body → Training. After the workout the user returns to the Pillar Web.

## FitOS — five engines

1. **Pillar Scoring Engine** — check-ins + passive data + completed restorations + feedback +
   trends → the eight scores. *(in repo: `PillarScoringEngine`)*
2. **Restoration Engine** — one small action from weak pillar, history, time of day, energy,
   available time, what worked before. *(in repo: `RestorationEngine` + `RestorationEffectiveness`)*
3. **Training Engine** — plans, reps/sets, progression, rest timers, deload, recovery-based
   adjustments. *(not yet built — MVP 3)*
4. **Circle Privacy Engine** — what may be shown given group size, permissions, sensitive
   pillars, voluntary wins. *(in repo: `PrivacyRulesEngine` + Circle engines)*
5. **Learning Engine** — learns which actions actually restore this user from "Did this restore
   anything?" *(in repo: `RestorationEffectiveness`, `WeeklyInsightEngine`)*

## Privacy model (the backbone)

- **App promise:** "Your inner life is yours. Circles show support signals, not private details."
- **Hardware promise:** "Your device senses you. It does not record the world."
- Local-first storage (SwiftData), preferences in UserDefaults. Individual scores never shown to
  Circle members by default; only voluntary, permissioned shares are visible.

## Subscription

- **Free** — daily check-in, Pillar Web, basic restorations & history, one Circle, manual logging.
- **Pillars Pro** — personalized restoration learning, weekly review, deeper insights, Training
  Engine, recovery-based adjustments, wearable integrations, advanced Circle privacy,
  coach/family modes, Fuel intelligence.
- **Hardware bundle** — Band + HUD, includes 3–12 months of Pro.

## MVP build order (do not build all at once)

1. **Pillars Core** — 8-pillar check-in, Web, one restoration, "Did this restore anything?",
   history. *(substantially DONE)*
2. **Circle** — create Circle, group Web, privacy-safe trend, shared reset, voluntary win.
   *(substantially DONE)*
3. **Body Mode** — workout plan, manual set logging, Body/Fuel/Recover updates after a workout,
   training restoration suggestions. *Bridges Pillars into fitness without hardware.* **← next**
4. **Band prototype** — rep counting, HR, set detection, haptics, corrections. *(hardware)*
5. **HUD prototype** — peripheral workout display, rest timer, next exercise, no camera/mic.
   *(hardware)*

Never skip Pillars Core. Hardware (MVP 4–5) cannot be built inside this SwiftUI app repo —
only Device screens and integration seams.

## Naming

App = **Pillars** · Engine = **FitOS** · Visual = **Pillar Web** · Wearable = **Pillars Band** ·
Glasses = **Pillars HUD** · Group layer = **Pillars Circle** · Subscription = **Pillars Pro** ·
Workout mode = **Body Mode / Train Mode**. Avoid proliferating brand names.

## Tone

Quiet, reflective, premium, private, warm, human. Not clinical, not gamified, not bro-fitness,
not spiritual unless opted in. Say "restore rhythm / see what is asking for support / train with
awareness / move without friction / support without oversharing / return to yourself." Avoid
"optimize everything / maximize performance / dominate your day / never miss / score your life."

Visual identity: deep charcoal / soft black, warm ivory text, muted amber-gold highlights, soft
web visualization, calm motion, minimal badges, no streak pressure by default, no harsh red/green.
