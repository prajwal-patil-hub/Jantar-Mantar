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
///
/// **The extrusion is confined to the rim, and that is a contrast fix.** The
/// first version ran the gradient edge to edge, which washed the lip and the
/// shade straight across the middle of the face — exactly where the glyph
/// sits. Measured over the glyph band that put the light action knob at
/// **3.66:1** and the dark quiet knob at **2.36:1**, both under the 4.5
/// floor, on the app's primary map controls. With the ramp flat across the
/// centre (see [_faceStops]) the glyph sits on the body tone alone and the
/// worst case is 5.87. It also reads better: an extruded object catches light
/// at its edge, not across its face.
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

/// Gradient stops that keep the lip and the shade at the rim and leave the
/// face flat. The glyph occupies roughly the middle 38%, so the flat band has
/// to be wider than that — see the contrast note on [ExtrudedKnob].
const _faceStops = <double>[0, .28, .72, 1];

enum KnobSize {
  /// 48 — the accessibility floor, not smaller.
  small(48),
  medium(64),
  large(104);

  const KnobSize(this.px);
  final double px;
}

/// The labelled sibling of [ExtrudedKnob]: same three-part extrusion, same
/// press-to-sink, but a stadium carrying an icon and a word.
///
/// Round knobs are for controls whose icon is unambiguous. An action with
/// consequences — "Report" opens a five-step flow that ends in a public
/// submission — gets a word, because an icon-only primary action on a map is
/// a guess.
class ExtrudedPill extends StatefulWidget {
  const ExtrudedPill({
    required this.label,
    this.icon,
    this.onTap,
    this.tone = PillTone.action,
    super.key,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final PillTone tone;

  @override
  State<ExtrudedPill> createState() => _ExtrudedPillState();
}

enum PillTone {
  /// Clay. The primary action on the screen.
  action,

  /// Peach body. A secondary action that still needs a word.
  quiet,
}

class _ExtrudedPillState extends State<ExtrudedPill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    final lip = dark ? AppTokens.lipDark : AppTokens.lipLight;
    final shade = dark ? AppTokens.shadeDark : AppTokens.shadeLight;
    final cast = dark ? AppTokens.castDark : AppTokens.castLight;

    final body = switch (widget.tone) {
      PillTone.action => dark ? AppTokens.clayDark : AppTokens.clay,
      PillTone.quiet => dark ? AppTokens.peachDark : AppTokens.peach,
    };
    // See the on-colour note on [ExtrudedKnob]: both dark bodies are lighter
    // than the dark ground, so both take the dark on-colour.
    final onBody = dark
        ? AppTokens.onClayDark
        : switch (widget.tone) {
            PillTone.action => AppTokens.onClay,
            PillTone.quiet => AppTokens.ink,
          };

    // Same inversion as the knob, and the same rim-confined ramp: pressed
    // swaps lip and shade so the light source stays above, and the face stays
    // flat so the label is not sitting on a highlight.
    final gradient = _pressed
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [shade, body, body, lip],
            stops: _faceStops,
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lip, body, body, shade],
            stops: _faceStops,
          );

    return Semantics(
      button: widget.onTap != null,
      label: widget.label,
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
          // The emergency touch target, not Material's 40 — this is operated
          // one-handed under stress.
          constraints: const BoxConstraints(
            minHeight: AppTokens.primaryTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusPill),
            color: body,
            gradient: gradient,
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: cast,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : AppTokens.depth(3, dark: dark),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: onBody, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: onBody,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
    // Both dark bodies are LIGHTER than the dark ground — peachDark measures
    // luminance 0.31 — so both take the dark on-colour. This is the same trap
    // clay already carries a separate onClayDark for; the quiet knob first
    // used inkDark, the light-on-dark text tone, and measured 2.45:1.
    final onBody = dark
        ? AppTokens.onClayDark
        : (widget.selected ? AppTokens.onClay : AppTokens.ink);

    // Flutter has no inset shadow, so the extrusion is built from two
    // stacked gradient rings plus a real cast shadow underneath.
    final gradient = _pressed
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [shade, body, body, lip],
            stops: _faceStops,
          )
        : LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [lip, body, body, shade],
            stops: _faceStops,
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
                ? [
                    BoxShadow(
                      color: cast,
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
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
