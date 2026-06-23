# Backend plan (v0.3) — Supabase

> **Status: documented, not yet wired.** Pillars is local‑first and ships with **no
> external dependencies**. A live backend needs the `supabase-swift` SDK (a dependency) and
> a hosted project + network, none of which exist in this build. This document is the
> blueprint so v0.3 is a clean drop‑in rather than a rewrite. Nothing here weakens the
> on‑device privacy model — it extends it server‑side.

When you're ready to add it, the one guardrail change is explicit: **adding the Supabase
Swift package**. Everything below is designed around that single seam.

## Principles carried over from local‑first

1. **Private rows are private.** A user's `daily_checkins` never leave their account except
   as aggregate, non‑identifying outputs.
2. **Circle privacy is enforced server‑side**, mirroring `CirclePulseEngine`:
   2 → wins only · 3 → one blurred trend · 4+ → aggregate labels · never individual scores.
3. **The device stays the source of truth offline.** Sync is additive, not a dependency for
   the core loop to function.

## Schema

```
users
  id (uuid, pk)            email            display_name        created_at

daily_checkins             -- one private row per user per check-in
  id  user_id(fk)  date
  body_score fuel_score sleep_score recover_score
  mind_score connect_score space_score purpose_score
  notes_private            created_at

circles
  id  name  owner_id(fk users)  privacy_mode  created_at

circle_members
  id  circle_id(fk)  user_id(fk)  role  joined_at

shared_wins                -- voluntary, the only self-attributed circle content
  id  circle_id(fk)  user_id(fk)  pillar  title  note  created_at

circle_pulses              -- precomputed, privacy-safe outputs (no member data)
  id  circle_id(fk)  week_start  trend_summary  suggested_action  created_at
```

## Server‑side privacy enforcement (Postgres RLS + views)

- **`daily_checkins`**: RLS so `user_id = auth.uid()` for every select/insert/update. No
  other user — including a circle owner — can read a member's rows.
- **Aggregates** are produced only by `SECURITY DEFINER` functions / materialized views that:
  - require `count(distinct user_id) >= 3` before emitting any pillar aggregate (the 2‑person
    rule: no aggregate at all);
  - emit **labels** ("Quiet/Steady/Lifting"), never numeric averages, for 3‑person circles
    (single weakest pillar only) and 4+ circles (top‑N labels);
  - never return per‑member rows.
- **`shared_wins`**: readable by circle members; writable only by the author (`user_id = auth.uid()`).
- **`circle_pulses`**: read‑only to members; written by a scheduled job, not clients.

The client's `CirclePulseEngine` becomes a thin renderer of `circle_pulses` rows; the device
no longer needs other members' raw signals at all — a strict improvement over the v0.2 mock.

## Auth & invites

- Supabase Auth (email magic link or OAuth). `Account` maps to `users`.
- Invites: owner creates a row in `circle_members` keyed by invitee email, or a signed invite
  link with a short‑lived token; acceptance binds it to the invitee's `user_id`.
- No passwords stored by the app; tokens handled by the SDK.

## Sync strategy

- Keep SwiftData as the offline cache / source of truth.
- A `SyncService` protocol (added in v0.3) with two implementations: `LocalSyncService`
  (current, no‑op) and `SupabaseSyncService`. Push local `daily_checkins` on save; pull
  `circle_pulses` and `shared_wins` for the user's circles. Last‑writer‑wins on the private,
  single‑owner check‑in rows; circle outputs are server‑authoritative.

## The swap‑in seam (when you opt into the dependency)

1. Add the `supabase-swift` package.
2. Implement `AuthService` (sign in/up/out → `Account`) and `SupabaseSyncService`.
3. Inject them at the app root next to `EntitlementManager`; gate cloud features behind
   sign‑in. The Settings → **Sync** row already states the local‑only status and is the
   place this surfaces.
4. Move Circle reads from `CirclePulseEngine` (mock) to `circle_pulses` rows.

Until then, the app is fully functional offline and the Circle privacy rules are enforced in
the engine on‑device.
