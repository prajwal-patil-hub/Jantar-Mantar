# DECISIONS.md — Architecture Decision Records

Format: `ADR-N · date · decision · why · alternatives rejected`

- **ADR-1 · 2026-07-24 · Flutter/Dart, Android-first.** Cross-platform from one codebase; target users on low-end Androids. _Rejected:_ native ×2 (cost), React Native (user preference for Dart).
- **ADR-2 · 2026-07-24 · Verify-before-display, two-axis (publish status ⊥ verified flag).** Ushahidi-proven; prevents misinformation without hiding pipeline. _Rejected:_ open publish (pollution risk).
- **ADR-3 · 2026-07-24 · Layered model: canonical public map + groups annotate.** Prevents fragmented facility copies; enables federated moderation. _Rejected:_ group-scoped-only (no shared truth).
- **ADR-4 · 2026-07-24 · Anonymous-by-default auth via device keypair.** OTP fails during SMS jamming; privacy. Phone = optional trust booster. _Rejected:_ mandatory OTP.
- **ADR-5 · 2026-07-24 · Groups deferred to Phase 3 (Stage 1).** MVP must prove public layer + moderation spine first. _Rejected:_ groups-in-MVP (empty infiltration-prone shells).
- **ADR-6 · 2026-07-24 · Add-by-user-ID preferred over phone number.** Contact discovery leaks who uses a protest app. _Rejected as default:_ phone adding (kept as opt-in, hidden numbers).
- **ADR-7 · 2026-07-24 · flutter_map + OSM + FMTC over Google Maps.** Offline tile caching, no billing/quota, no Google dependency. _Rejected:_ google_maps_flutter (weak offline), Mapbox (cost).
- **ADR-8 · PROPOSED · Supabase over Firebase.** Postgres RLS deny-by-default fits group scoping; self-host escape hatch for privacy/residency. Awaiting confirmation (task E1.1).
- **ADR-9 · 2026-07-24 · Glassmorphism UI (hero surfaces only) + neutral/one-accent palette + rich animations.** User's style choice; performance guarded by device-tier fallback (no blur on weak devices), reduced-motion/battery mode, and a no-glass high-contrast outdoor theme. _Rejected:_ app-wide glass (GPU cost on <2GB-RAM Androids).
