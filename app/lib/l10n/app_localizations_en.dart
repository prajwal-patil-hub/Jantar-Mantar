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

  @override
  String get navGroups => 'Groups';

  @override
  String get groupsTitle => 'Groups';

  @override
  String get groupsSignInNeeded =>
      'Groups need you to be online and signed in. Complete the backend setup, then reopen this tab.';

  @override
  String get noGroupsYet => 'No groups yet. Create one or join with a code.';

  @override
  String get createGroup => 'Create group';

  @override
  String get joinWithCode => 'Join with code';

  @override
  String get groupName => 'Group name';

  @override
  String get groupDescription => 'Description (optional)';

  @override
  String get groupVisibility => 'Visibility';

  @override
  String get visibilityHidden => 'Hidden';

  @override
  String get visibilityPublic => 'Public';

  @override
  String get create => 'Create';

  @override
  String get join => 'Join';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get pendingApproval =>
      'Request sent — an admin must approve you before you see group content.';

  @override
  String get membershipPending => 'Pending approval';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabMembers => 'Members';

  @override
  String get tabPins => 'Amenities';

  @override
  String get messageHint => 'Message (end-to-end encrypted)';

  @override
  String get e2eNotice =>
      'Messages are end-to-end encrypted — only group members can read them.';

  @override
  String get cantDecrypt => 'Can\'t decrypt this message.';

  @override
  String get send => 'Send';

  @override
  String get approveMember => 'Approve';

  @override
  String get admin => 'Admin';

  @override
  String get member => 'Member';

  @override
  String get removeMember => 'Remove';

  @override
  String removeMemberTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeMemberBody =>
      'They lose access to this group and a new encryption key is issued, so they cannot read anything sent from now on. Messages they already received stay on their device.';

  @override
  String get memberRemoved =>
      'Removed. New encryption key issued to the group.';

  @override
  String rekeyWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count members have no device key yet and will not receive the new key until they open the app.',
      one:
          '1 member has no device key yet and will not receive the new key until they open the app.',
    );
    return '$_temp0';
  }

  @override
  String get invite => 'Invite';

  @override
  String inviteCreated(String code) {
    return 'Invite code (24h, 10 uses): $code';
  }

  @override
  String get addAmenity => 'Add amenity';

  @override
  String get amenityLabel => 'Label';

  @override
  String get noAmenities => 'No group amenities yet.';

  @override
  String get noMessages => 'No messages yet. Say hello.';

  @override
  String get chatOffline => 'Offline — showing saved messages';

  @override
  String get broadcast => 'Broadcast';

  @override
  String broadcastTitle(String group) {
    return 'Broadcast to $group';
  }

  @override
  String get broadcastHint =>
      'Everyone in this group sees this at the top of the chat and in Alerts.';

  @override
  String get broadcastSend => 'Send broadcast';

  @override
  String get broadcastSeverity => 'Urgency';

  @override
  String get groupBroadcasts => 'From your groups';

  @override
  String get groupBroadcastNote => 'Group broadcast · members only';

  @override
  String get messageSending => 'Sending…';

  @override
  String groupActionFailed(String error) {
    return 'Action failed: $error';
  }

  @override
  String get eventLive => 'Live';

  @override
  String get eventToday => 'Today';

  @override
  String get eventUpcoming => 'Upcoming';

  @override
  String get eventVerified => 'Verified';

  @override
  String get eventDetails => 'Details';

  @override
  String eventDetailsSoon(String title) {
    return '$title — details arrive with the events build.';
  }

  @override
  String get eventMainTitle => 'Main gathering — Jantar Mantar';

  @override
  String get eventMainNote =>
      'Peak crowd expected until 6 PM. Water points at Gates 1 and 3.';

  @override
  String get eventMainLocation => 'Jantar Mantar Road';

  @override
  String get eventMedicalTitle => 'Medical volunteer briefing';

  @override
  String get eventMedicalNote =>
      'Shift handover and supply check for all first-aid volunteers.';

  @override
  String get eventMedicalLocation => 'First-aid tent (main)';

  @override
  String get eventMedicalTime => 'Starts 3:00 PM';

  @override
  String get eventLegalTitle => 'Legal aid desk hours';

  @override
  String get eventLegalNote =>
      'Volunteer lawyers available for detention-related queries.';

  @override
  String get eventLegalLocation => 'Gate 2 pavilion';

  @override
  String get eventLegalTime => 'Starts 4:30 PM';

  @override
  String get eventLangarTitle => 'Community langar';

  @override
  String get eventLangarNote =>
      'Food for ~500 people; volunteers needed from 10 AM.';

  @override
  String get eventLangarLocation => 'Parliament Street corner';

  @override
  String get eventLangarTime => 'Tomorrow, 12:00 PM';

  @override
  String get eventLiveNow => 'Live now';

  @override
  String get pickOnMap => 'Place on map';

  @override
  String get pickAmenityHint =>
      'Drag the map to place this amenity, then confirm.';

  @override
  String get confirmLocation => 'Confirm location';

  @override
  String get showGroupPins => 'Show group amenities';

  @override
  String get groupPinsLayer => 'Group amenities';

  @override
  String groupPinFrom(String group, String label) {
    return '$group · $label';
  }

  @override
  String get scanInvite => 'Scan invite QR';

  @override
  String get scanInviteHint =>
      'Point the camera at the invite QR. You will still need admin approval.';

  @override
  String get scanUnavailable =>
      'Camera scanning is not available in the browser. Ask for the code and enter it instead.';

  @override
  String scanFailed(String error) {
    return 'Camera unavailable ($error). Enter the code instead.';
  }

  @override
  String get enterCodeInstead => 'Enter code instead';

  @override
  String get scan => 'Scan';

  @override
  String get inviteScanHint =>
      'Have them scan this QR, or share the code below.';

  @override
  String get inviteExpiry =>
      'Expires in 24 hours · up to 10 uses · they still need admin approval';

  @override
  String get inviteCopied => 'Invite code copied';

  @override
  String get copyCode => 'Copy code';

  @override
  String get done => 'Done';

  @override
  String get demoMode => 'Demo mode';

  @override
  String get demoModeSubtitle =>
      'Explore every screen with sample data — no backend or login needed. Turn off to use the live backend.';
}
