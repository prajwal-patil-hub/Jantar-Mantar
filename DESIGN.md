# DESIGN.md — Visual Direction & Design System
_Last updated: 2026-07-24 · Status: direction locked, details open_

## Locked direction (user's choices)
- **Style:** minimal + **glassmorphism** (frosted-blur surfaces)
- **Palette:** neutral base + **one bold accent**
- **Motion:** **rich, fluid animations**

## Glassmorphism — performance rule (critical)
`BackdropFilter` blur is GPU-expensive; low-end Androids are our target.
- Glass ONLY on hero surfaces: bottom sheets, facility cards, nav bar, dialogs. Never on scrolling list items or map overlays.
- Implement a **capability check** (device tier / frame-time probe): weak devices get the fallback — semi-transparent solid (`Colors.white.withOpacity(0.85)`-style) + subtle border + shadow. Same layout, no blur.
- Respect reduced-motion / battery-saver: drop to fallback + subtle animations automatically.
- Text on glass must still hit 4.5:1 contrast (add scrim behind text if needed).

## Motion rules
- Rich animations for: sheet transitions, pin selection, capacity number changes, submit success, SOS countdown.
- Instant (no animation) for: safety-critical info appearing (alerts), offline banner.
- Battery-first mode / reduced-motion setting disables decorative motion.
- Candidate tools (decide in E1): `flutter_animate` (default), Rive (SOS/onboarding hero moments), built-in Hero + animated M3 components. Impeller renderer = default on modern Flutter; verify blur perf on test device.

## Theme tokens (proposal — pick accent below)
- Neutrals: near-white surface `#FAFAF8`, ink `#1A1A1A`, glass tint white @ 60–70% + blur 16–24, border white @ 30%.
- Dark theme: surface `#111214`, glass tint black @ 40%.
- **Status colors are semantic and never themed away:** Good `#2E7D32` ✓ · Low `#F9A825` ! · Out `#C62828` ✕ · Unverified grey ? (always icon + label too).
- Typography: Noto Sans + Noto Sans Devanagari; body 16sp; extra line-height for Devanagari.
- High-contrast Outdoor mode: kills glass entirely, max contrast.

## Answered choices (2026-07-24)
1. **Accent color: Saffron `#FF6D1F`** (ADR-10). Mitigation for amber proximity: accent never conveys status; status colors live in a `StatusColors` ThemeExtension independent of the seed scheme.
2. **Dark mode: system-follow** (ADR-10), with manual Light/Dark/High-contrast-Outdoor override in settings.

3. **App name: CommonGround** (ADR-12) — applied to Android label, iOS bundle names, web manifest/title.
4. **Nav bar: glass docked M3 bar** (ADR-13) — standard `NavigationBar` wrapped in `GlassSurface` (`app/lib/core/widgets/glass_surface.dart`), opaque fallback on weak devices/high-contrast.
5. **Map tiles: standard OSM for MVP** (ADR-13) — FMTC offline cache; tile-provider + muted-style decision deferred to pre-deployment (OSM public server policy forbids heavy production traffic).

## Open choices
- **App icon** direction (default Flutter placeholder still in place — replace in Phase 2; ADR-13 defers it).
- Glass capability probe: `glassEnabledProvider` is a static `true` today; Phase 2 adds the device-tier/frame-time check.

## References
Full screen-by-screen spec + wireframes: `docs/research/ui-ux-spec.md`
