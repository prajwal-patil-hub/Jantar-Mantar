/// Which build am I actually looking at?
///
/// The hosted web app updates by re-deploying to the same URL, so a phone
/// showing a stale page and a phone showing the newest one look identical.
/// Without a stamp the only way to tell was to hunt for a change you happen
/// to remember making — which fails exactly when you most need certainty,
/// right after a fix.
///
/// Injected by CI:
///
///   flutter build web --dart-define=BUILD_COMMIT=$(git rev-parse --short HEAD) \
///                     --dart-define=BUILD_TIME=$(date -u +%Y-%m-%dT%H:%MZ)
///
/// Local builds get 'dev', which is the honest answer for them: an
/// unstamped build is not a released one and should not claim a commit.
abstract final class BuildInfo {
  static const commit = String.fromEnvironment(
    'BUILD_COMMIT',
    defaultValue: 'dev',
  );

  static const builtAt = String.fromEnvironment('BUILD_TIME');

  /// True when this build came off CI rather than someone's laptop.
  static bool get isReleaseBuild => commit != 'dev';

  /// One short line for the Profile screen. Deliberately plain text and not
  /// a link: it is something to read out or compare against the commit in
  /// GitHub, not something to tap.
  static String get label =>
      builtAt.isEmpty ? 'Build $commit' : 'Build $commit · $builtAt';
}
