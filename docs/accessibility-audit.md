# Accessibility audit

_Last run: 2026-07-26. Colour checks are automated; screen-reader checks are not._

The app's standing rule (CLAUDE.md) is that **status is always colour + icon +
text, never colour alone**. That rule is what makes the known colour
compromises below acceptable rather than defects.

## Automated — `app/test/core/theme/color_accessibility_test.dart`

Runs in CI on every PR. Computes WCAG relative-luminance contrast against both
surfaces, and simulates deuteranopia / protanopia / tritanopia to check that
statuses stay separable. Measured values are **pinned**, so improving the
palette fails the test and forces a deliberate update rather than silent drift.

| Swatch | Light | Dark | Verdict |
|---|---|---|---|
| `good` #2E7D32 | 5.00:1 | 3.63:1 | passes |
| `out` #C62828 | 5.48:1 | 3.31:1 | passes |
| `unverified` #616161 | 6.04:1 | 3.00:1 | **fixed this audit** (was #9E9E9E, 2.61:1) |
| `info` #1976D2 | 4.49:1 | 4.04:1 | passes |
| `low` #F9A825 | 1.92:1 | 9.43:1 | accepted trade-off, see below |
| accent #FF6D1F | 2.75:1 | 6.60:1 | accepted, ADR-10 |

### Accepted trade-offs

**`low` is under the 3:1 bar on the light surface.** Every darker amber that
clears 3:1 collapses against the red `out` under all three CVD simulations —
#C07000 scores 0.036 separation versus 0.26 for today's amber. "Low" versus
"Out" (is there water left, or none) is the most consequential distinction on
the map, so separability wins over fill contrast. Covered by the icon + text
rule. Revisit only with a palette that satisfies both.

**`good` vs `out` collapse under protanopia** (0.167 separation). Fixing it
properly means making "good" a teal; the best in-family candidate scored 0.310
but reads as blue-green and would collide with the info blue. Left as-is and
carried by the ✓ / ✕ icons and localised labels. Holds up fine under
deuteranopia and tritanopia.

**The saffron accent is indistinguishable from `low` and `out` under CVD**
(0.07–0.20). This is exactly why ADR-10 forbids the accent from ever conveying
status. The test asserts the collapse, so the ban has teeth.

## Automated — structural

- Every `IconButton` in `lib/` carries a `tooltip` (verified by sweep;
  tooltips are what TalkBack announces for icon-only controls).
- Interactive controls use `minimumSize: Size(_, 48)` or Material defaults that
  meet the 48dp target.
- Status is rendered via `*_visuals.dart` (icon) + `core/l10n/l10n_labels.dart`
  (localised text) + `StatusColors` — the three-channel rule is structural, not
  per-screen discipline.

## Manual — NOT yet done

These need real hardware and a human; nothing here has been run.

- [ ] **TalkBack sweep (Android)** across at least two OEM skins (stock Pixel +
      one of Samsung/Xiaomi, whose screen readers diverge). Traverse: map →
      pin → detail sheet → submit flow (all 5 steps) → alerts → SOS → groups →
      chat → profile.
- [ ] **VoiceOver sweep (iOS)**.
- [ ] **SOS screen under a screen reader specifically** — hold-to-fire is a
      gesture a screen reader intercepts. This is the one screen where an
      inaccessible control could matter enormously; it may need an explicit
      accessible alternative action.
- [ ] **Large text / display scaling** at 200% on the map and submit flow.
- [ ] **Outdoor legibility** in direct sunlight (the high-contrast theme in
      DESIGN.md is still unbuilt).
- [ ] Physical-device CVD check with a simulator overlay, to sanity-check the
      numeric model above against how it actually looks.
