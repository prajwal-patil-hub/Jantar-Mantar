import 'package:flutter/material.dart';

/// Design tokens from DESIGN.md. Change only via an ADR.
abstract final class AppTokens {
  /// Bold accent (locked choice: Saffron). Never used to convey facility
  /// status — status is always [StatusColors] + icon + text, so the accent's
  /// warmth cannot be confused with the amber "Low" state.
  static const Color accent = Color(0xFFFF6D1F);

  // ------------------------------------------------- elevation ramp (ADR-39)
  // "Blush Depth". Five surfaces, sampled off the reference boards.
  //
  // The critical measurement: every ADJACENT pair is ~1.06:1. Tone carries
  // none of the layering — light carries all of it. That is why a single soft
  // shadow reads as a sticker here and why [depth] composes four separate
  // effects instead of one. Do not try to "fix" the flat ramp by darkening a
  // layer; the flatness is the reference, and the shadows are the answer.
  //
  //   e0 ground · e1 base plate · e2 panel · e3 card · e4 floating
  static const Color e0Light = Color(0xFFE8DED6);
  static const Color e1Light = Color(0xFFEDE4DC);
  static const Color e2Light = Color(0xFFF4ECE5);
  static const Color e3Light = Color(0xFFFAF4EF);
  static const Color e4Light = Color(0xFFFFFBF8);

  // The dark ramp is COMPRESSED, and that is forced, not a taste call.
  //
  // Status colours paint on the top surface, and the darkest of them (`out`
  // #C62828) only clears 3:1 while that surface stays at or below luminance
  // 0.0123 — which is #241A13, the old Soft Geometry card, right at its
  // existing 3.03 pin. A five-layer dark ramp as tall as the light one puts
  // `out` at 2.35 and every other status under 3:1 too.
  //
  // So in dark mode the ramp gives way, not the status. Steps here are
  // ~1.03-1.04 rather than ~1.06, which means shadow carries even more of
  // the depth than it does on light. Raising any of these lightens the
  // surface markers paint on and breaks the contrast suite.
  static const Color e0Dark = Color(0xFF0D0907);
  static const Color e1Dark = Color(0xFF130D0A);
  static const Color e2Dark = Color(0xFF1A120D);
  static const Color e3Dark = Color(0xFF1F1610);
  static const Color e4Dark = Color(0xFF241A13);

  /// Scaffold + card aliases, kept so existing screens and the contrast suite
  /// keep compiling. The card is e3, not e2: e2 is the panel a card sits on.
  static const Color scaffoldLight = e0Light;
  static const Color surfaceLight = e3Light;
  static const Color scaffoldDark = e0Dark;
  static const Color surfaceDark = e4Dark;

  static const Color ink = Color(0xFF3A2E2A);
  static const Color inkMuted = Color(0xFF6B5750);
  static const Color inkDark = Color(0xFFF6EAE2);
  static const Color inkMutedDark = Color(0xFFBFA79C);

  /// Peach is a **FILL ONLY** tone — rings, bars, blob grounds, knob bodies.
  /// It measures 1.41:1 against the deepest ground, so text on it, or it as
  /// text, is not a close call. The reference boards use it for big numerals;
  /// that is the one thing from them that cannot ship.
  static const Color peach = Color(0xFFF0AE98);
  static const Color peach2 = Color(0xFFF7D2C4);
  static const Color peach3 = Color(0xFFFBE7DE);
  static const Color peachDark = Color(0xFFC98872);
  static const Color peach2Dark = Color(0xFF7A5344);
  static const Color peach3Dark = Color(0xFF573A2F);

  /// The text-bearing member of the same hue family. 4.69:1 against the
  /// WORST of the five light surfaces — chosen by measuring all five, not
  /// just the card, because a value that only clears the lightest layer
  /// fails exactly where the app puts its deepest ground.
  static const Color clay = Color(0xFF9C4830);
  static const Color clayDark = Color(0xFFE8A98F);
  static const Color onClay = Color(0xFFFFF7F3);
  static const Color onClayDark = Color(0xFF20140F);

  // ----------------------------------------------------------- depth parts
  // Four ingredients per raised surface. Dropping any one is what made the
  // first pass at this look flat:
  //   lip     a 1px top highlight — the edge catching light
  //   shade   an inset bottom darkening — the body of the object
  //   cast    the wide soft shadow — how far above the ground it sits
  //   contact the tight dark shadow — that it is resting on something
  static const Color lipLight = Color(0xB8FFFFFF);
  static const Color lipDark = Color(0x1AFFFFFF);
  static const Color shadeLight = Color(0x428C5640);
  static const Color shadeDark = Color(0x73000000);
  static const Color castLight = Color(0x33543729);
  static const Color castDark = Color(0x9E000000);

  // Glass surfaces (hero surfaces only — sheets, cards, nav, dialogs).
  static const double glassBlurSigma = 20;
  static const Color glassTintLight = Color(0xA6FFFFFF); // white @ 65%
  static const Color glassTintDark = Color(0x66000000); // black @ 40%
  static const Color glassBorder = Color(0x4DFFFFFF); // white @ 30%

  /// Opaque fallback for weak devices / battery saver / outdoor mode:
  /// same layout, no blur.
  static const Color glassFallbackLight = Color(0xD9FFFFFF); // white @ 85%
  static const Color glassFallbackDark = Color(0xD9111214);

  // ---------------------------------------------------------------- depth
  // Soft Geometry is tone-on-tone, and tone-on-tone measures badly: a shell
  // card on the sand scaffold is **1.15:1**, dark is 1.11:1. Well under the
  // 3:1 WCAG 1.4.11 wants for a UI component boundary. Depth here is not
  // decoration — it is the only thing making a card perceptible as a card.
  //
  // Two mechanisms, because one is not enough:
  //  · a warm-tinted shadow (a grey shadow on a warm ground reads muddy);
  //  · a hairline, which is what carries it when shadows are unavailable —
  //    outdoor/high-contrast mode, and bright direct sunlight where a soft
  //    shadow is simply not visible.
  static const Color shadowTint = Color(0x1F3B2A1E); // cocoa @ 12%
  static const Color shadowTintDark = Color(0x66000000);

  /// Hairline that reaches 3:1 against BOTH the card and the scaffold, so the
  /// boundary is perceptible without a shadow. Deliberately not the muted-ink
  /// tone: that reads as a divider, this reads as an edge.
  /// Re-measured for the Blush Depth ramp: must clear 3:1 against ALL FIVE
  /// surfaces, not just two. The old pair cleared 3.10 / 2.93 — the dark one
  /// was already failing before the palette moved.
  static const Color hairline = Color(0xFF836751); // worst 3.94 of e0..e4
  static const Color hairlineDark = Color(0xFF9A8272); // worst 4.72 of e0..e4

  /// Compound elevation. Four ingredients, never one shadow — see the note
  /// on the ramp above for why a single soft shadow reads as a sticker here.
  ///
  /// [level] 1..4 maps to the reference's rungs: 1 resting card, 2 panel,
  /// 3 floating card, 4 overhanging element.
  static List<BoxShadow> depth(int level, {required bool dark}) {
    final cast = dark ? castDark : castLight;
    final spread = switch (level) {
      1 => (contact: 2.0, far: 5.0, dy: 2.0),
      2 => (contact: 3.0, far: 18.0, dy: 8.0),
      3 => (contact: 5.0, far: 32.0, dy: 16.0),
      _ => (contact: 9.0, far: 56.0, dy: 28.0),
    };
    return [
      // Contact: tight and dark, right under the edge. Without it the object
      // floats in a vacuum instead of resting on something.
      BoxShadow(
        color: cast,
        blurRadius: spread.contact,
        offset: Offset(0, level.toDouble()),
      ),
      // Cast: wide and soft. Carries how far above the ground it sits.
      BoxShadow(
        color: cast,
        blurRadius: spread.far,
        spreadRadius: -spread.far / 3,
        offset: Offset(0, spread.dy),
      ),
    ];
  }

  /// The top-edge highlight, applied as a 1px border rather than an inset
  /// shadow because Flutter has no inset BoxShadow. Subtle on its own and the
  /// single biggest contributor to "solid object" over "coloured rectangle".
  static Border lipBorder({required bool dark}) =>
      Border(top: BorderSide(color: dark ? lipDark : lipLight, width: 1));

  /// Kept as thin wrappers so existing call sites keep working while screens
  /// migrate to [depth].
  static List<BoxShadow> lift(Color tint) => [
    BoxShadow(color: tint, blurRadius: 14, offset: const Offset(0, 4)),
  ];

  static List<BoxShadow> float(Color tint) => [
    BoxShadow(color: tint, blurRadius: 24, offset: const Offset(0, 10)),
  ];

  /// Keyboard / switch-control focus ring (ADR-34). WCAG 2.4.7 requires a
  /// visible focus indicator, and the app had none — `FocusNode` appeared
  /// zero times. Saffron rather than clay: the ring must not be mistakable
  /// for a filled action, and it is never used to convey status.
  static const Color focusRing = accent;
  static const double focusRingWidth = 3;

  // Radii scale (ADR-32). One scale, applied through the theme, so the shape
  // language holds by construction instead of by per-screen discipline.
  static const double radiusChip = 12;
  static const double radiusCard = 20;
  static const double radiusPanel = 28;
  static const double radiusPlate = 36;
  static const double radiusPill = 999;

  /// Chat bubbles are the one surface the card radius does not fit — at 22 a
  /// short message reads as a lozenge. Named here rather than left as a bare
  /// `12` in the chat screen, because an unnamed number is how the scale
  /// leaks: alert cards had drifted to 12 too, and nothing said they were
  /// meant to differ from every other card in the app.
  static const double radiusBubble = 16;

  /// The bubble's speaker-side corner, squared off into a tail.
  static const double radiusBubbleTail = 5;

  // Touch targets (emergency UX: generous under stress).
  static const double minTouchTarget = 48;
  static const double primaryTouchTarget = 56;
  static const double sosTouchTarget = 60;
}
