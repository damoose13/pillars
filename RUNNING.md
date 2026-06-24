# Running Pillars on your iPhone (or the Simulator)

Pillars is a native iOS app (SwiftUI + SwiftData) with **no backend and no external
dependencies** — everything runs on-device. You build it once from Xcode on a Mac and it
installs straight onto your phone. No account, no internet required to use it.

## What you need

- A **Mac** with **Xcode 16 or newer** (free from the Mac App Store)
- An **iPhone on iOS 17 or newer** and a USB cable (first install)
- A **free Apple ID** (a paid Apple Developer account is *not* required)

---

## 1. Get the code

Open **Terminal** on the Mac:

```bash
git clone https://github.com/damoose13/pillars.git
cd pillars
git checkout claude/hopeful-allen-md1li0
open Pillars.xcodeproj
```

Xcode will open the project.

## 2. Add your Apple ID (one-time)

Xcode → **Settings… → Accounts → +** → Apple ID → sign in.

## 3. Set signing (one-time)

Pillars has **two targets** that both need a team: the app and its widget.

1. Click the **Pillars** project in the left sidebar → select the **Pillars** target →
   **Signing & Capabilities** tab.
2. Check **Automatically manage signing** and set **Team** to your Apple ID (Personal Team).
3. If you see *"Failed to register bundle identifier"* (someone already uses `com.pillars.app`),
   change **Bundle Identifier** to something unique, e.g. `com.yourname.pillars`.
4. Select the **PillarsWidgetExtension** target and do the same — set the **Team**, and if you
   changed the app's bundle ID, set the widget's to `com.yourname.pillars.widget` (it must be
   the app's ID + `.widget`).

## 4. Run on your iPhone

1. Plug your iPhone into the Mac. On the phone, tap **Trust** if asked.
2. In Xcode's top bar, set the run destination (next to the **Pillars** scheme) to **your iPhone**.
3. Press **▶ Run** (⌘R).
4. **First launch is blocked by iOS** with an "Untrusted Developer" message. On the phone:
   **Settings → General → VPN & Device Management → Developer App →** tap your Apple ID →
   **Trust**. Then reopen **Pillars** from the home screen.

That's it — Pillars is on your phone.

### Add the widget
Long-press the home screen → **+** (top-left) → search **Pillars** → add the small or medium
widget. (It's a calm check-in nudge; tapping it opens the app.)

---

## Prefer no cable? Run in the Simulator

You don't even need a phone to try it:

1. In Xcode's top bar, set the destination to a simulator, e.g. **iPhone 16 Pro**.
2. Press **▶ Run** (⌘R). The iOS Simulator launches the app.

(The screenshots in the project's CI are generated this way, on a cloud Mac.)

---

## Good to know

- **Free Apple ID = 7-day builds.** The app stops opening after ~7 days; just press **Run**
  again in Xcode to refresh it. A paid Apple Developer account ($99/yr) extends this to a year
  and unlocks TestFlight (install over the air, no cable).
- **Everything is local.** Your check-ins, notes, and scores live only on your device. There's
  no sign-in and nothing is uploaded.
- **Purchases are simulated.** The paywall runs against a bundled StoreKit configuration
  (`Products.storekit`), so you can exercise the flow without being charged. To see it live in
  the Simulator, Xcode → **Edit Scheme → Run → Options → StoreKit Configuration → Products.storekit**.
- **Spiritual content is off by default.** Turn it on (and rename the Purpose pillar) in
  **Settings**.

## Troubleshooting

| Problem | Fix |
|---|---|
| "Failed to register bundle identifier" | Change the bundle IDs to something unique (step 3). |
| "Untrusted Developer" on launch | Trust the profile: Settings → General → VPN & Device Management (step 4). |
| "Signing requires a development team" | Select each target → Signing & Capabilities → set Team (step 3). |
| Widget doesn't show live scores | By design — v1 is a static check-in nudge. Live scores need an App Group + paid signing. |
| Build fails on an old Xcode | The project needs Xcode 16+ (file-format objectVersion 77). Update Xcode. |
