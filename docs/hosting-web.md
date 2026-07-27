# Running CommonGround on a phone, for free

## What this gets you

`.github/workflows/deploy-web.yml` builds the Flutter web bundle and publishes
it to GitHub Pages on every push. Open the URL in Safari, **Share → Add to
Home Screen**, and you get a full-screen app with the CommonGround icon and no
browser chrome (`web/manifest.json` is already set to `display: standalone`).

URL: `https://prajwal-patil-hub.github.io/Jantar-Mantar/`

No Mac, no Apple Developer account, no cost — the repo is public, so Pages is
free.

### One-time setup (required)

**Repo → Settings → Pages → Build and deployment → Source: "GitHub Actions".**

This cannot be automated. The workflow's `GITHUB_TOKEN` is not permitted to
create a Pages site (`Resource not accessible by integration`), so the first
run fails with a 404 until the toggle is set. Once set, every push deploys
automatically and you never touch it again.

Demo Mode is ON by default, so every screen works immediately with sample data
and no backend or login.

## What it is NOT

The browser build is for **evaluating the app**, not for using it at a protest.
Three things that matter here are missing, and the app says so in Profile:

1. **No secure key storage.** `flutter_secure_storage` on web falls back to
   `localStorage` (encrypted, but the encryption key is also in localStorage —
   obfuscation, not a keystore). Worse, iOS Safari evicts localStorage after
   roughly **seven days of not opening the app**, which would destroy the
   X25519 device identity and every group key. Cached chat would become
   permanently undecryptable. The whole device-seizure threat model in
   SECURITY.md assumes an OS keystore.
2. **No offline map.** FMTC's tile cache does not initialise on web, so the map
   falls back to live network tiles. Offline-first — the premise of the project
   — does not apply.
3. **No camera.** QR invite scanning is disabled on web by design; joining
   falls back to pasting the code.

Certificate pinning is also inactive on web, but that one is correct: the
browser owns TLS and Dart cannot influence it.

## When you outgrow it

A native iOS build needs macOS — `flutter build ipa` runs nowhere else.

| Route | Cost | Notes |
|---|---|---|
| Xcode + free Apple ID | free | Real app on your own iPhone, all features. Signing expires every 7 days; reinstall weekly. |
| Apple Developer Program | $99/yr | TestFlight, 90-day builds, up to 10,000 testers. The only realistic route to volunteers' phones. |

Android has no such gate: `flutter build apk --release` produces an installable
APK from any machine, free, with none of the web limitations above. If the goal
is to put this in real hands cheaply, **Android first is the pragmatic path** —
which also matches ADR-1 ("Android-first", targeting low-end devices).

## Redeploying

Any push to `main` or a `claude/**` branch rebuilds and republishes. Watch it
under the repo's **Actions** tab. To take the site down, disable the workflow
or set Pages → Source to "None".
