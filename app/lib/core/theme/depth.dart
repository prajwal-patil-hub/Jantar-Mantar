import 'dart:ui';

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Blush Depth surfaces (ADR-39).
///
/// The reference boards separate their layers by light, not by tone — every
/// adjacent surface pair measures ~1.06:1 on light and ~1.04:1 on dark. So a
/// raised surface here is never "a colour plus a shadow"; it is a compound of
/// contact shadow, cast shadow and a top lip, and dropping any one of them is
/// what makes the whole thing read flat.
///
/// Nothing outside this file should write a `BoxShadow`.

/// Where a surface sits in the stack. The names are the reference's own
/// structure: a card sits on a panel, which sits on a plate, on the ground.
enum Elevation {
  /// The page itself. No shadow — it is what everything else casts onto.
  ground,

  /// A large backing slab holding a group of panels.
  plate,

  /// A section container. Cards sit on this.
  panel,

  /// The everyday raised surface: list rows, stat cards, sheets.
  card,

  /// Something clearly above its container — a FAB, a floating search bar, or
  /// an element deliberately overhanging an edge.
  floating,
}

extension ElevationTone on Elevation {
  Color color(Brightness b) => switch ((this, b)) {
    (Elevation.ground, Brightness.light) => AppTokens.e0Light,
    (Elevation.plate, Brightness.light) => AppTokens.e1Light,
    (Elevation.panel, Brightness.light) => AppTokens.e2Light,
    (Elevation.card, Brightness.light) => AppTokens.e3Light,
    (Elevation.floating, Brightness.light) => AppTokens.e4Light,
    (Elevation.ground, Brightness.dark) => AppTokens.e0Dark,
    (Elevation.plate, Brightness.dark) => AppTokens.e1Dark,
    (Elevation.panel, Brightness.dark) => AppTokens.e2Dark,
    (Elevation.card, Brightness.dark) => AppTokens.e3Dark,
    (Elevation.floating, Brightness.dark) => AppTokens.e4Dark,
  };

  /// 0 for the ground, 1..4 for the rungs above it.
  int get rung => index;
}

/// A surface at a given [Elevation], with the compound shadow that makes the
/// layering visible.
class DepthSurface extends StatelessWidget {
  const DepthSurface({
    required this.child,
    this.elevation = Elevation.card,
    this.radius,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    super.key,
  });

  final Widget child;
  final Elevation elevation;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Overrides the ramp tone. Use sparingly — the ramp is the system.
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final r = radius ?? _defaultRadius;
    final shape = BorderRadius.circular(r);

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? elevation.color(Theme.of(context).brightness),
        borderRadius: shape,
        // Flutter has no inset BoxShadow, so the top lip is a border edge.
        // It is a real contributor, not a nicety — see the ADR.
        border: elevation == Elevation.ground
            ? null
            : AppTokens.lipBorder(dark: dark),
        boxShadow: elevation == Elevation.ground
            ? null
            : AppTokens.depth(elevation.rung, dark: dark),
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );

    final tappable = onTap == null
        ? surface
        : Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: shape,
              onTap: onTap,
              child: surface,
            ),
          );

    return margin == null ? tappable : Padding(padding: margin!, child: tappable);
  }

  double get _defaultRadius => switch (elevation) {
    Elevation.ground => 0,
    Elevation.plate => AppTokens.radiusPlate,
    Elevation.panel => AppTokens.radiusPanel,
    Elevation.card => AppTokens.radiusCard,
    Elevation.floating => AppTokens.radiusCard,
  };
}

/// A frosted panel — and, when blur is off, an opaque one that occupies the
/// same space and reads at the same elevation.
///
/// `BackdropFilter` is the most expensive widget you can put inside a scroll
/// view, and the performance target here is a sub-2GB Android. So the opaque
/// path is the default that everything is designed against, and the blur is
/// the enhancement: [blur] must be opted into, and it is dropped anyway when
/// the platform asks for reduced transparency or disabled animations.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    this.blur = false,
    this.elevation = Elevation.card,
    this.radius,
    this.padding,
    super.key,
  });

  final Widget child;

  /// Opt in. Off by default because the fallback is the design, not a
  /// degradation of it.
  final bool blur;
  final Elevation elevation;
  final double? radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    final wantsPlain =
        !blur ||
        (media?.disableAnimations ?? false) ||
        (media?.highContrast ?? false);

    if (wantsPlain) {
      return DepthSurface(
        elevation: elevation,
        radius: radius,
        padding: padding,
        child: child,
      );
    }

    final dark = Theme.of(context).brightness == Brightness.dark;
    final r = radius ?? AppTokens.radiusCard;
    final base = elevation.color(Theme.of(context).brightness);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        boxShadow: AppTokens.depth(elevation.rung, dark: dark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: DecoratedBox(
            decoration: BoxDecoration(
              // Never fully transparent: text sits on this, and a blur alone
              // does not guarantee any contrast floor against arbitrary
              // content behind it.
              color: base.withValues(alpha: dark ? 0.82 : 0.74),
              border: AppTokens.lipBorder(dark: dark),
            ),
            child: padding == null
                ? child
                : Padding(padding: padding!, child: child),
          ),
        ),
      ),
    );
  }
}
