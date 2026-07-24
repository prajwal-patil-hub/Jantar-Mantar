import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/tokens.dart';

/// Whether glass (BackdropFilter blur) is allowed on this device. Stays a
/// provider so the Phase 2 device-tier/frame-time probe can flip it without
/// touching call sites (DESIGN.md performance rule).
final glassEnabledProvider = Provider<bool>((ref) => true);

/// Frosted hero surface with the mandatory cheap fallback: weak devices,
/// high-contrast mode, and (later) battery saver get a semi-opaque solid
/// with identical layout — no blur, same geometry.
class GlassSurface extends ConsumerWidget {
  const GlassSurface({
    required this.child,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final highContrast = MediaQuery.of(context).highContrast;
    final useGlass = ref.watch(glassEnabledProvider) && !highContrast;

    // Material.transparency keeps ink splashes visible for interactive
    // children (ListTile etc.) without covering the glass decoration.
    final surfaceChild = Material(
      type: MaterialType.transparency,
      child: child,
    );

    if (!useGlass) {
      return Container(
        decoration: BoxDecoration(
          color: dark
              ? AppTokens.glassFallbackDark
              : AppTokens.glassFallbackLight,
          borderRadius: borderRadius,
          border: Border.all(color: AppTokens.glassBorder),
        ),
        child: surfaceChild,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppTokens.glassBlurSigma,
          sigmaY: AppTokens.glassBlurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: dark ? AppTokens.glassTintDark : AppTokens.glassTintLight,
            borderRadius: borderRadius,
            border: Border.all(color: AppTokens.glassBorder),
          ),
          child: surfaceChild,
        ),
      ),
    );
  }
}
