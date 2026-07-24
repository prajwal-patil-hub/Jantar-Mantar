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

## Open choices (answer before E3 map build)
1. **Accent color** (one bold): options — Saffron `#FF6D1F` · Indigo `#3D5AFE` · Teal `#00BFA5` · Magenta `#D500F9`. (Accent must not clash with status green/amber/red — saffron conflicts slightly with amber; indigo/teal are safest.)
2. **Dark mode default?** system-follow vs light-default.
3. **App name + icon** direction.
4. **Nav bar treatment:** glass floating pill vs standard docked M3 bar.
5. **Map tile style:** standard OSM vs muted/greyscale custom style (muted suits glass UI, needs style server or pre-rendered tiles).

## References
Full screen-by-screen spec + wireframes: `docs/research/ui-ux-spec.md`
