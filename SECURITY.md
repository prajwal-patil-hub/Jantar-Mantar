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
- [ ] Certificate pinning on API + tile hosts (dio + pinning; ship backup pin + remote pin-rotation plan)
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
- [ ] flutter_secure_storage for keys/tokens (Android Keystore / iOS Keychain) — never SharedPreferences
- [ ] Screenshot protection (FLAG_SECURE) on group/member screens
- [ ] Coarse location default; precise only per-action opt-in; never background-tracked
- [ ] Dependency audit each release (`dart pub outdated`, osv-scanner); lockfiles committed
- [ ] Root/jailbreak detection = warn-only (protesters may use custom ROMs; don't lock them out)
- [x] Local group-chat cache stores **ciphertext only** (Drift v3 `CachedGroupMessages`) — no plaintext ever touches the SQLite file; keys stay in the OS keystore (ADR-19)
- [x] Group key rotates on member removal; new epoch sealed only to remaining active members; offline-queued messages re-sealed before sending. Forward secrecy only — the removed device keeps what it already had, and the UI says so (ADR-20)
- [ ] Panic action: wipe local keys, hide memberships, sign out — `GroupMessageCache.wipe()` is ready to call from that path

## Release gates
- [ ] `flutter analyze` + tests green · [ ] RLS negative tests green · [ ] pinning verified against test MITM proxy
- [ ] MASVS-L1 checklist reviewed · [ ] third-party security review + digital-rights consult before public launch
