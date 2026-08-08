import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether glass (BackdropFilter blur) is allowed on this device. Stays a
/// provider so a device-tier / frame-time probe can flip it without touching
/// call sites (DESIGN.md performance rule).
///
/// The `GlassSurface` widget that used to live here is gone (ADR-39). It
/// blurred **by default** and every caller got the expensive path unless it
/// opted out — which is backwards for a sub-2GB Android target, and directly
/// contradicts Blush Depth's rule that the opaque surface is the design and
/// blur is the enhancement. `GlassPanel` in `core/theme/depth.dart` replaces
/// it with the defaults the other way round.
///
/// Blur is now a per-site decision, and there is one rule behind the three
/// answers in the app: **never blur a surface that is itself the scroll
/// view.** `BackdropFilter` re-samples what is behind it every frame, so
/// inside a scrolling sheet it repaints on every pixel of travel. The docked
/// nav bar is fixed and painted once per frame regardless, so it is the one
/// place the cost is bounded — and it is the surface ADR-13 specified as
/// glass.
final glassEnabledProvider = Provider<bool>((ref) => true);
