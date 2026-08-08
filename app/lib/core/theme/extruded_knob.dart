import 'package:flutter/material.dart';

import 'tokens.dart';

/// The reference's signature control (ADR-39): a circular button pressed out
/// of the surface rather than painted onto it.
///
/// Three parts, and it needs all three:
///  · a **lip** — light at the top edge, where the extrusion catches light
///  · a **shade** — dark at the bottom inside, the body of the object
///  · a **cast** — beneath it, so it sits above the surface
///
/// Pressed **swaps the lip and the shade** so the control sinks. It does not
/// dim: dimming reads as "disabled", sinking reads as "you are pushing it",
/// and on a control someone hits while moving that difference matters.
///
/// A gradient would have been simpler and is wrong — it inverts incorrectly
/// in dark mode, where the light source has to stay above.
class ExtrudedKnob extends StatefulWidget {
  const ExtrudedKnob({
    required this.child,
    this.onTap,
    this.selected = false,
    this.size = KnobSize.medium,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Selected fills with the action tone; unselected uses the peach body.
  final bool selected;
  final KnobSize size;
  final String? semanticLabel;

  @override
  State<ExtrudedKnob> createState() => _ExtrudedKnobState();
}

enum KnobSize {
  /// 48 — the accessibility floor, not smaller.
  small(48),
  medium(64),
  large(104);

  const KnobSize(this.px);
  final double px;
}

class _ExtrudedKnobState extends State<ExtrudedKnob> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    final lip = dark ? AppTokens.lipDark : AppTokens.lipLight;
    final shade = dark ? AppTokens.shadeDark : AppTokens.shadeLight;
    final cast = dark ? AppTokens.castDark : AppTokens.castLight;

    final body = widget.selected
        ? (dark ? AppTokens.clayDark : AppTokens.clay)
        : (dark ? AppTokens.peachDark : AppTokens.peach);
    final onBody = widget.selected
        ? (dark ? AppTokens.onClayDark : AppTokens.onClay)
        : (dark ? AppTokens.inkDark : AppTokens.ink);

    // Flutter has no inset shadow, so the extrusion is built from two
    // stacked gradient rings plus a real cast shadow underneath.
    final gradient = _pressed
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [shade, body, lip],
            stops: const [0, .55, 1],
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lip, body, shade],
            stops: const [0, .45, 1],
          );

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      selected: widget.selected,
      child: GestureDetector(
        onTapDown: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = true),
        onTapUp: widget.onTap == null
            ? null
            : (_) => setState(() => _pressed = false),
        onTapCancel: widget.onTap == null
            ? null
            : () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          width: widget.size.px,
          height: widget.size.px,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: body,
            gradient: gradient,
            boxShadow: _pressed
                ? [BoxShadow(color: cast, blurRadius: 2, offset: const Offset(0, 1))]
                : AppTokens.depth(2, dark: dark),
          ),
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: onBody, size: widget.size.px * .38),
              child: DefaultTextStyle(
                style: theme.textTheme.labelLarge!.copyWith(
                  color: onBody,
                  fontWeight: FontWeight.w600,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
