/// The two container/action joins extracted from the reference sheets
/// (ADR-32, `docs/research/ui-shape-language.md`).
///
/// Both exist as widgets rather than as per-screen styling for one reason:
/// a shape language enforced by discipline drifts, a shape language enforced
/// by a shared widget cannot. Everything else in the system — radii, surface
/// ramp, action tone — rides on the theme, so it lands everywhere at once.
///
/// Neither of these carries meaning. Status is [StatusColors] + icon + text,
/// always, and nothing here is allowed to encode it.
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// A stadium field with a circular action **overlapping its trailing end**,
/// separated by a ring of the surrounding ground so the bar reads as bitten
/// into rather than merely covered.
///
/// The ring colour has to be whatever is actually behind the widget — pass
/// [groundColor] when the parent is not the scaffold background, or the
/// "bite" fills with the wrong tone and the effect inverts into a halo.
class NotchedActionField extends StatelessWidget {
  const NotchedActionField({
    required this.child,
    required this.action,
    this.onAction,
    this.height = 52,
    this.actionDiameter = 52,
    this.overlap = 16,
    this.ringWidth = 6,
    this.groundColor,
    this.fieldColor,
    this.actionColor,
    this.actionTooltip,
    super.key,
  });

  /// The field content — a TextField, a label, whatever the screen needs.
  final Widget child;

  /// Icon for the circular action.
  final Widget action;
  final VoidCallback? onAction;
  final String? actionTooltip;

  final double height;
  final double actionDiameter;

  /// How far the disc sits over the bar. Larger reads as more attached.
  final double overlap;

  /// Thickness of the ground-coloured ring that cuts the notch.
  final double ringWidth;

  final Color? groundColor;
  final Color? fieldColor;
  final Color? actionColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ground = groundColor ?? Theme.of(context).scaffoldBackgroundColor;
    final field = fieldColor ?? scheme.surface;
    final onAct = actionColor ?? scheme.primary;

    return SizedBox(
      // The disc can be taller than the bar, so the row is sized to whichever
      // is larger — otherwise the overflow is silently clipped.
      height: height > actionDiameter ? height : actionDiameter,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: height,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: field,
                borderRadius: BorderRadius.circular(AppTokens.radiusPill),
              ),
              child: child,
            ),
          ),
          Transform.translate(
            offset: Offset(-overlap, 0),
            child: Container(
              width: actionDiameter,
              height: actionDiameter,
              decoration: BoxDecoration(
                color: onAct,
                shape: BoxShape.circle,
                // The ring IS the notch: ground colour painted over the bar.
                border: Border.all(color: ground, width: ringWidth),
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: IconButton(
                  tooltip: actionTooltip,
                  onPressed: onAction,
                  padding: EdgeInsets.zero,
                  color: AppTokens.onClay,
                  icon: action,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A container with three round corners and one square, so a corner-anchored
/// element (a badge, a leading disc) reads as belonging to the surface rather
/// than floating on it.
///
/// [square] names the corner that stays sharp.
class CappedSurface extends StatelessWidget {
  const CappedSurface({
    required this.child,
    this.square = Alignment.topLeft,
    this.radius = AppTokens.radiusPanel,
    this.color,
    this.padding = const EdgeInsets.all(14),
    super.key,
  });

  final Widget child;
  final Alignment square;
  final double radius;
  final Color? color;
  final EdgeInsetsGeometry padding;

  BorderRadius get _shape {
    final r = Radius.circular(radius);
    const flat = Radius.zero;
    return BorderRadius.only(
      topLeft: square == Alignment.topLeft ? flat : r,
      topRight: square == Alignment.topRight ? flat : r,
      bottomLeft: square == Alignment.bottomLeft ? flat : r,
      bottomRight: square == Alignment.bottomRight ? flat : r,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: _shape,
      ),
      child: child,
    );
  }
}
