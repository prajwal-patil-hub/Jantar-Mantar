import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The three states every async screen has and almost none of them had
/// (ADR-33). Before this, empty was a bare centred sentence, loading was a
/// spinner on a blank screen, and error printed the raw exception.
///
/// They live together because they are one decision: what the screen says
/// when it has nothing to show. Getting that wrong in a field app means
/// someone standing in the rain cannot tell whether the water point list is
/// empty, still loading, or broken.

/// Nothing to show, and that is fine. Icon + headline + one line of what to
/// do about it — never a lone sentence floating in the middle of a screen.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    required this.icon,
    required this.title,
    this.body,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A disc, not a bare glyph — same vocabulary as every leading
            // thumbnail in the app (ADR-32).
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (body != null) ...[
              const SizedBox(height: 6),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

/// Loading, as the shape of the thing that is coming.
///
/// A centred spinner on a blank screen is indistinguishable from a broken
/// screen, and on a bad connection that ambiguity lasts a long time. A
/// skeleton keeps the layout, so the wait reads as "arriving" rather than
/// "nothing here".
///
/// The pulse respects `prefers-reduced-motion` via [MediaQuery.disableAnimations],
/// which also covers battery saver on Android.
class LoadingStateView extends StatelessWidget {
  const LoadingStateView({this.rows = 4, this.semanticLabel, super.key});

  final int rows;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      liveRegion: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: rows,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, index) => _SkeletonRow(index: index),
      ),
    );
  }
}

class _SkeletonRow extends StatefulWidget {
  const _SkeletonRow({required this.index});
  final int index;

  @override
  State<_SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<_SkeletonRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  /// Held so it can be cancelled. A bare `Future.delayed` here leaked a
  /// pending timer past dispose — harmless-looking, but it kept a disposed
  /// State alive and made every widget test that mounted a loading screen
  /// fail at teardown.
  Timer? _stagger;

  @override
  void initState() {
    super.initState();
    // Staggered so the rows do not pulse as one block, which reads as a
    // flashing screen rather than as loading.
    _stagger = Timer(Duration(milliseconds: 120 * widget.index), () {
      if (mounted) _pulse.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _stagger?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final still = MediaQuery.disableAnimationsOf(context);

    Widget block(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: scheme.onSurfaceVariant,
        borderRadius: BorderRadius.circular(AppTokens.radiusChip),
      ),
    );

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Opacity(
        opacity: still ? 0.16 : 0.10 + 0.10 * _pulse.value,
        child: child,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    block(double.infinity, 11),
                    const SizedBox(height: 7),
                    block(120, 9),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Something failed.
///
/// **The raw exception never reaches the headline.** Screens used to render
/// `'$e'` straight from a Postgres or socket error, which tells a volunteer
/// in a field nothing and leaks backend shape to anyone looking over their
/// shoulder. [message] is the human sentence; [details] is folded away for
/// whoever is actually debugging.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    required this.message,
    this.details,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: scheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 28,
                color: scheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel ?? 'Try again'),
              ),
            ],
            if (details != null && details!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                tilePadding: EdgeInsets.zero,
                title: Text(
                  'Technical details',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: [
                  SelectableText(
                    details!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
