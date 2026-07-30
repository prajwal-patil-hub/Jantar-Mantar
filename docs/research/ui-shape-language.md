# Soft Geometry — extracting a shape language from a reference image

_2026-07-30 · ADR-32. Wireframes for all 21 screens are published as an
artifact; this is the method and the reusable prompt behind them._

## 1. What the references actually contain

Two reference sheets were supplied: a set of search-bar shape studies, and a
set of app screens in a warm palette. **No copy, imagery or branding from
either is used** — only the component geometry.

Stripped of colour and words, the first sheet is a study of one move: a
**pill-shaped field with a circular action attached to it**, and five ways of
joining the two. The join is the whole idea; none of them is a rectangle
abutting another rectangle.

| # | Shape | Geometry |
|---|---|---|
| 1 | **Lens split** | One container, two tones, divided by a convex arc |
| 2 | **Notched knob** | Separate disc, overlapping, ring of page-ground biting a notch out of the bar |
| 3 | **Dropped tab** | Half-disc hanging below the container's top edge |
| 4 | **Corner cap** | Three round corners, one square, anchoring to the surface below |
| 5 | **Bleeding disc** | Disc taller than the bar, spilling past both edges |

The second sheet adds the layout vocabulary: **one card per row** with a
leading circular thumbnail and trailing chevron; large soft panels (22–28 px)
instead of dividers; full-width pill CTAs; circular icon buttons in the
corners; a floating pill nav bar; and roughly double the vertical breathing
room of a stock Material layout.

## 2. The logic: take the geometry, keep the semantics

Image-to-UI goes wrong when it copies pixels. The reliable method separates
what a reference can legitimately teach from what it cannot know about your
product. Here that is not a matter of taste — this app is read outdoors,
under stress, sometimes by someone deciding whether to walk into floodwater.

| Layer | Adopt? | Why |
|---|---|---|
| Shape and radii | **Yes, wholesale** | Carries no meaning. Pure identity. |
| Spacing and rhythm | **Yes** | More room helps a stressed thumb. |
| Ground and surface colour | **Yes, re-measured** | Warm sand keeps every status swatch above 3:1 — verified, not assumed. |
| Action / CTA colour | **Yes** | Clay is a desaturated member of the existing saffron hue family. |
| **Status colour** | **No — never** | Good / Low / Out / Closed must stay separable under colour-blindness. A brown-on-tan monochrome collapses exactly the distinction the map exists for. |
| Copy | No | Belongs to a different product. |
| Imagery style | No | No equivalent here. |

## 3. The reusable prompt

```
EXTRACT — from the reference image, list ONLY:
  · container shapes and corner radii (note asymmetric radii explicitly)
  · how actions attach to containers (contained / overlapping / notched / detached)
  · elevation and separation method (shadow, tone step, or gap)
  · spacing rhythm and touch-target sizes
  · the grouping unit (divided list vs card-per-row)
  · palette roles: ground, raised surface, action, ink, muted ink
Ignore all copy, all imagery, all brand marks, and the product domain.

CLASSIFY — sort every extracted property into:
  IDENTITY  shape, radius, spacing, elevation, surface tone   → adopt freely
  SEMANTIC  anything encoding state, severity, or safety      → do NOT adopt
  CONTENT   words, photos, icons specific to that product     → discard

CHECK — before adopting any colour:
  · compute contrast of every semantic colour against the new grounds
  · reject the ground if a semantic colour drops below 3:1
  · confirm semantic colours stay separable under deuteranopia,
    protanopia and tritanopia
  · state the measured numbers; never assert "accessible" without them

APPLY — express IDENTITY as tokens, never as per-screen styling:
  radii scale · spacing scale · one surface ramp · one action tone
  Then rebuild each screen from the tokens, so the language is
  consistent by construction rather than by discipline.

CONSTRAIN — state up front what the reference must not override:
  existing semantic colours, minimum touch targets, the rule that
  state is icon + colour + text, and any tested accessibility floor.
```

## 4. What the CHECK step actually found

Running it rather than asserting it changed three decisions:

- **The light ground costs about a point of contrast.** Every status swatch
  still clears 3:1 on sand `#EFE3D4` (good 4.06, out 4.45, unverified 4.90,
  info 4.54). Adopted.
- **The warm dark ground is an improvement.** On `#160F0A` the weakest swatch
  rises from 3.00:1 to 3.06:1 versus the old `#141218`. Adopted.
- **The first clay failed.** `#A5713F` matched the reference best but put
  cream label text at **3.93:1**, under the 4.5 body bar. Darkened to
  `#8C5A29`. The hue is unchanged; the label is now readable.
- **The dark theme needed an inverted label.** Clay is *lighter* than the
  ground in dark mode, so cream-on-clay measured 2.83:1. Added `onClayDark`.

The last two were caught by tests written during this work, not by eye.

A bug surfaced along the way: `color_accessibility_test.dart` was measuring
against a hardcoded `#FFFBFE` / `#141218` that no screen ever painted. It now
reads `AppTokens` directly, and measures the **scaffold** rather than the
card, because the scaffold is the darker of the two on light and therefore
the worst case.

## 5. What changed in code

- **`AppTokens`** — surface ramp (sand / shell), clay action tone with both
  on-colours, warm ink and muted ink, and a radii scale (pill / 28 / 22 / 14).
- **`AppTheme`** — the radii scale is applied through component themes
  (card, chip, dialog, sheet, input, list tile, filled and outlined buttons),
  so it lands on every screen at once rather than per screen. Filled and
  outlined buttons are pinned to the 56 dp emergency target, not Material's
  default 40.
- **`soft_geometry.dart`** — `NotchedActionField` (shape 2) and
  `CappedSurface` (shape 4) as widgets, because a shape language enforced by
  discipline drifts and one enforced by a shared widget cannot.
- **`StatusColors` is untouched.** Exactly the values ADR-23 measured.

## 6. Known limits

- Shapes 1, 3 and 5 are specified and drawn in the wireframes but not yet
  built as Flutter widgets — 2 and 4 cover the app's current needs and
  shipping unused widgets is not free.
- The glass treatment (ADR-9) is unchanged and still applies to hero
  surfaces; Soft Geometry governs shape and tone underneath it.
- Screens that hand-roll a container rather than using `Card`/`Chip`/
  `FilledButton` still need a per-screen pass. The theme covers the majority.
