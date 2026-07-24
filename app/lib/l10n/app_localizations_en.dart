// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CommonGround';

  @override
  String get navMap => 'Map';

  @override
  String get navEvents => 'Events';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get filterAll => 'All';

  @override
  String get typeWater => 'Water';

  @override
  String get typeFood => 'Food';

  @override
  String get typeShelter => 'Shelter';

  @override
  String get typeMedical => 'Medical';

  @override
  String get typeToilet => 'Toilets';

  @override
  String get typeSafeArea => 'Safe area';

  @override
  String get typeDanger => 'Danger';

  @override
  String get statusGood => 'Good';

  @override
  String get statusLow => 'Low';

  @override
  String get statusOut => 'Out';

  @override
  String get statusClosed => 'Closed';

  @override
  String get report => 'Report';

  @override
  String get recenter => 'Back to Jantar Mantar';

  @override
  String get sos => 'SOS';

  @override
  String get nearby => 'Nearby';

  @override
  String get beFirstToReport =>
      'No facilities here yet — be the first to report one.';

  @override
  String get notYetVerified => 'Not yet verified';

  @override
  String verifiedAgo(String time) {
    return 'Verified $time';
  }

  @override
  String verifiedAgoRecheck(String time) {
    return 'Verified $time — needs re-check';
  }

  @override
  String get justNow => 'just now';

  @override
  String minAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String daysAgo(int count) {
    return '$count d ago';
  }

  @override
  String get mayBeOutdated => 'This info may be outdated.';

  @override
  String get updateThis => 'Update this';

  @override
  String get reportClosed => 'Report closed';

  @override
  String get directions => 'Directions';

  @override
  String get share => 'Share';

  @override
  String capacityFor(int count) {
    return 'for ~$count';
  }

  @override
  String get expiredRecheck => 'expired — needs re-check';

  @override
  String get reportFacilityTitle => 'Report a facility';

  @override
  String get updateFacilityTitle => 'Update facility';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get submitForVerification => 'Submit for verification';

  @override
  String get savedWillSend =>
      'Saved — will be sent for verification when connection returns.';

  @override
  String get stepCategoryQuestion => 'What are you reporting?';

  @override
  String get stepLocationQuestion => 'Where is it?';

  @override
  String get stepLocationHint => 'Drag the map until the pin sits on the spot.';

  @override
  String get updatingExisting => 'Updating an existing facility';

  @override
  String get locationStaysMapped => 'Location stays as mapped';

  @override
  String duplicateHint(String type, int meters) {
    return 'Similar $type $meters m away — update it instead?';
  }

  @override
  String updateNamed(String name) {
    return 'Update $name';
  }

  @override
  String get stepCapacityQuestion => 'Roughly how many people can it serve?';

  @override
  String get skipIfNotApplicable => 'Skip this if it doesn\'t apply.';

  @override
  String get skip => 'Skip';

  @override
  String get stepStatusQuestion => 'How is it right now?';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get noteHint => 'e.g. queue is long, tanker refills at 5 PM';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get photoComingSoon =>
      'Coming soon — photos are stripped of location data before upload.';

  @override
  String get review => 'Review';

  @override
  String get reviewNewNotice =>
      'New facilities appear publicly only after verification. You\'ll see it as \"Pending (yours)\" meanwhile.';

  @override
  String get reviewUpdateNotice =>
      'This update goes to the verification queue before it changes the public map.';

  @override
  String get alertInfo => 'Info';

  @override
  String get alertWarning => 'Warning';

  @override
  String get alertCritical => 'Critical';

  @override
  String get verifiedByAdmin => 'Verified by admin';

  @override
  String get areaAlert => 'Area alert';

  @override
  String get noActiveAlerts =>
      'No active alerts.\nCritical alerts appear here and on the map instantly.';

  @override
  String get cachedMayBeOutdated =>
      'Shown from local cache — may be outdated while offline.';

  @override
  String get sosHoldInstruction =>
      'Hold the button for 2–3 seconds to send an SOS to volunteers. Calling directly is always available below.';

  @override
  String get sosQueuedInstruction =>
      'SOS queued — it sends the moment any connection returns. Calling directly is fastest.';

  @override
  String get sosHoldToSend => 'SOS\nHold to send';

  @override
  String get sosQueued => 'SOS queued';

  @override
  String get imSafeReset => 'I\'m safe — reset';

  @override
  String callPolice(String number) {
    return 'Call emergency (police) — $number';
  }

  @override
  String callAmbulance(String number) {
    return 'Call ambulance — $number';
  }

  @override
  String callLegalAid(String number) {
    return 'Legal aid helpline — $number';
  }

  @override
  String get nearestMedical => 'Nearest medical on map';

  @override
  String get shareLocationLater =>
      'Sharing location with a trusted contact arrives in a later build — always explicit, per use.';

  @override
  String couldNotDial(String number) {
    return 'Could not open dialer — dial $number';
  }

  @override
  String get profile => 'Profile';

  @override
  String get pendingUploads => 'Pending uploads';

  @override
  String get nothingWaiting => 'Nothing waiting to send.';

  @override
  String pendingCount(int count) {
    return '$count submission(s) will be sent for verification when connection returns.';
  }

  @override
  String get language => 'Language';

  @override
  String get settingsComingLater =>
      'Appearance and privacy settings come with later builds.';

  @override
  String get volunteerAdmin => 'Volunteer / admin';

  @override
  String get signedInAsAdmin =>
      'Signed in as admin — open the verification queue';

  @override
  String get verifiersSignIn =>
      'Verifiers sign in here; everyone else stays anonymous';

  @override
  String get adminSignInTitle => 'Volunteer / admin sign in';

  @override
  String get adminSignInBlurb =>
      'Only facility verifiers need an account. Everyone else stays anonymous.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get signingIn => 'Signing in…';

  @override
  String get noAdminRole =>
      'Signed in, but this account has no admin role. Ask the project owner to grant it.';

  @override
  String get verificationQueue => 'Verification queue';

  @override
  String get queueClear => 'Queue is clear — nothing pending.';

  @override
  String get approve => 'Approve';

  @override
  String get reject => 'Reject';

  @override
  String get rejectWhy => 'Reject — why?';

  @override
  String get reasonDuplicate => 'Duplicate';

  @override
  String get reasonCantVerify => 'Can\'t verify';

  @override
  String get reasonStale => 'Stale';

  @override
  String get reasonInaccurate => 'Inaccurate';

  @override
  String get reasonSpam => 'Spam';

  @override
  String get cancel => 'Cancel';

  @override
  String get refresh => 'Refresh';

  @override
  String reportClosedQuestion(String name) {
    return 'Report $name as closed?';
  }

  @override
  String get reportClosedBody =>
      'This goes to the verification queue — the map changes once an admin confirms it.';

  @override
  String get reportedQueued => 'Reported — queued for verification.';

  @override
  String featureArrivesLater(String feature) {
    return '$feature arrives in a later build.';
  }

  @override
  String reviewStatus(String status) {
    return 'Status: $status';
  }

  @override
  String reviewCapacityPeople(int count) {
    return 'Capacity: ~$count people';
  }

  @override
  String get reviewCapacityNone => 'Capacity: not specified';

  @override
  String reviewUpdating(String name) {
    return 'Updating: $name';
  }

  @override
  String get reviewNewFacility => 'New facility';

  @override
  String reviewLocation(String lat, String lng) {
    return 'Location: $lat, $lng';
  }

  @override
  String get backendUnreachable => 'Backend not reachable on this build.';

  @override
  String get serverTryAgain => 'Could not reach the server — try again.';

  @override
  String queueCardNew(String type) {
    return '$type — new facility';
  }

  @override
  String queueCardUpdate(String type) {
    return '$type — update';
  }

  @override
  String queueLoadFailed(String error) {
    return 'Could not load the queue: $error';
  }

  @override
  String approveFailed(String error) {
    return 'Approve failed: $error';
  }

  @override
  String rejectFailed(String error) {
    return 'Reject failed: $error';
  }
}
