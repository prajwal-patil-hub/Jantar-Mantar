# SECURITY.md — Threat Model & Hardening Checklist
_Last updated: 2026-07-24 · Framework: OWASP MASVS-L1 baseline, selected L2/R controls_

> Honest note: no app has "zero vulnerabilities." The goal is security-by-design, a small
> attack surface, defense in depth, and independent review before real-world use.

## Threat model (who/what we defend against)
| Threat | Vector | Primary controls |
|---|---|---|
| Traffic interception / MITM | Hostile Wi-Fi, rogue proxies at site | TLS 1.2+ only, certificate pinning, HSTS |
| API abuse / tampered clients | Modified APK calling our API | Server-side authz (RLS), request signing with device key, rate limits — never trust the client |
| Endpoint discovery ≠ access | Anyone can find URLs | Assume all URLs public; every endpoint authenticated + authorized server-side; no security-by-obscurity |
| Data pollution / misinformation | Fake submissions | Verification pipeline, per-device rate limits, trust scores, audit log, revert tooling |
| Invite-link leaks | Screenshots, indexing | Expiry + max-uses + revocation + approval queue; `noindex` + robots.txt on all link pages |
| Device seizure | Detained user/admin | Minimal local sensitive data, flutter_secure_storage (Keystore/Keychain), panic-wipe, short TTL pins, no location history |
| Server compromise / subpoena | Legal or technical | Data minimization (can't leak what we don't store), coarse location only, minimal membership metadata, encrypted at rest |
| Secrets extraction from binary | Decompiled APK | **No secrets in the app.** Anon key is public-by-design; all privilege lives in RLS + edge functions; obfuscation (`--obfuscate --split-debug-info`) as speed bump only |

## Networking rules (hard requirements)
- [x] HTTPS everywhere; reject cleartext (`android:usesCleartextTraffic="false"` set 2026-07-24; iOS ATS default-on, no exceptions added — re-verify at release)
- [~] Certificate pinning: mechanism implemented and fails closed, but **inactive until a pin bundle is committed** — see "Certificate pinning" below for why a guessed pin is worse than none, and how to generate the real one
- [ ] No tokens/keys/IDs in URLs or query strings (headers/body only) — URLs land in logs
- [ ] Short-lived JWTs; refresh rotation; revoke on logout/panic
- [ ] Rate limiting + abuse detection at the edge (per-device, per-IP)
- [ ] CORS locked to our web origin; web fallback pages `noindex`

## Backend rules
- [x] Supabase RLS **deny-by-default** on every table (`supabase/migrations/20260724000001_init.sql`); negative tests written (`supabase/tests/rls_negative_test.sql`) — RUN THEM via `supabase test db` before launch, and wire into CI
- [x] Roles in JWT `app_metadata` (server-set, granted via SQL only — see `supabase/README.md`), never client-writable metadata
- [ ] All writes validated server-side (types, bounds, geo-fence sanity); parameterized queries only
- [ ] Signed invite tokens (Ed25519): payload = group, expiry, uses, nonce; verifiable offline; server re-checks on sync
- [ ] Append-only AuditLog; admin actions all logged
- [ ] Photos: strip EXIF/GPS server-side AND client-side before upload

## App rules
- [x] flutter_secure_storage for keys/tokens (Android Keystore / iOS Keychain) — never SharedPreferences (`core/crypto/key_store.dart`; SharedPreferences holds only locale + demo-mode flags)
- [ ] Screenshot protection (FLAG_SECURE) on group/member screens
- [ ] Coarse location default; precise only per-action opt-in; never background-tracked
- [ ] Dependency audit each release (`dart pub outdated`, osv-scanner); lockfiles committed
- [ ] Root/jailbreak detection = warn-only (protesters may use custom ROMs; don't lock them out)
- [x] Local group-chat cache stores **ciphertext only** (Drift v3 `CachedGroupMessages`) — no plaintext ever touches the SQLite file; keys stay in the OS keystore (ADR-19)
- [x] Group key rotates on member removal; new epoch sealed only to remaining active members; offline-queued messages re-sealed before sending. Forward secrecy only — the removed device keeps what it already had, and the UI says so (ADR-20)
- [x] Panic action: `PanicWipe` (`core/security/panic_wipe.dart`) — deletes every keystore secret first (so an interrupted wipe still fails safe), then every local table, then signs out locally. Surfaced in Profile behind a confirm dialog that states what it cannot reach: the server and other members' devices.


## Certificate pinning

Pinning is implemented and **off until a pin bundle is committed**
(`app/lib/core/security/certificate_pinning.dart`). Mechanism: a
`SecurityContext(withTrustedRoots: false)` loaded only with the roots in
`app/assets/certs/api_roots.pem`, so any chain outside that bundle fails the
handshake. There is deliberately no `badCertificateCallback` — that is how
pinning gets accidentally disabled. **Roots** are pinned, not leaves: leaf
certs rotate every few weeks and would brick released builds.

Threat addressed: a CA the *device* trusts but we do not — a state- or
employer-installed root, or an interception proxy. Plain TLS accepts those
silently.

To enable:
1. Run `./tool/fetch_api_roots.sh <api-host>` **from a trusted network.**
   Behind a VPN, captive portal, CI sandbox or intercepting proxy you will
   capture *that proxy's* CA and pin it, which is worse than not pinning.
2. Verify the printed SHA-256 against the CA's own published fingerprint.
3. Commit a **backup root** alongside the current one so a CA rotation is not
   an emergency release.
4. Add `assets/certs/` to the `flutter: assets:` list in `app/pubspec.yaml`.
5. Verify against a MITM proxy (release gate below) — confirm requests *fail*.

Debug builds and web are exempt: local Supabase stacks must stay reachable,
and on web the browser owns TLS.

## Release gates
- [ ] `flutter analyze` + tests green · [ ] RLS negative tests green · [ ] pinning verified against test MITM proxy
- [ ] MASVS-L1 checklist reviewed · [ ] third-party security review + digital-rights consult before public launch
