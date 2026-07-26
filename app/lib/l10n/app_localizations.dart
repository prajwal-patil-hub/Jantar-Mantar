import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CommonGround'**
  String get appName;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @typeWater.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get typeWater;

  /// No description provided for @typeFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get typeFood;

  /// No description provided for @typeShelter.
  ///
  /// In en, this message translates to:
  /// **'Shelter'**
  String get typeShelter;

  /// No description provided for @typeMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get typeMedical;

  /// No description provided for @typeToilet.
  ///
  /// In en, this message translates to:
  /// **'Toilets'**
  String get typeToilet;

  /// No description provided for @typeSafeArea.
  ///
  /// In en, this message translates to:
  /// **'Safe area'**
  String get typeSafeArea;

  /// No description provided for @typeDanger.
  ///
  /// In en, this message translates to:
  /// **'Danger'**
  String get typeDanger;

  /// No description provided for @statusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get statusGood;

  /// No description provided for @statusLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get statusLow;

  /// No description provided for @statusOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get statusOut;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @recenter.
  ///
  /// In en, this message translates to:
  /// **'Back to Jantar Mantar'**
  String get recenter;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @beFirstToReport.
  ///
  /// In en, this message translates to:
  /// **'No facilities here yet — be the first to report one.'**
  String get beFirstToReport;

  /// No description provided for @notYetVerified.
  ///
  /// In en, this message translates to:
  /// **'Not yet verified'**
  String get notYetVerified;

  /// No description provided for @verifiedAgo.
  ///
  /// In en, this message translates to:
  /// **'Verified {time}'**
  String verifiedAgo(String time);

  /// No description provided for @verifiedAgoRecheck.
  ///
  /// In en, this message translates to:
  /// **'Verified {time} — needs re-check'**
  String verifiedAgoRecheck(String time);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String daysAgo(int count);

  /// No description provided for @mayBeOutdated.
  ///
  /// In en, this message translates to:
  /// **'This info may be outdated.'**
  String get mayBeOutdated;

  /// No description provided for @updateThis.
  ///
  /// In en, this message translates to:
  /// **'Update this'**
  String get updateThis;

  /// No description provided for @reportClosed.
  ///
  /// In en, this message translates to:
  /// **'Report closed'**
  String get reportClosed;

  /// No description provided for @directions.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @capacityFor.
  ///
  /// In en, this message translates to:
  /// **'for ~{count}'**
  String capacityFor(int count);

  /// No description provided for @expiredRecheck.
  ///
  /// In en, this message translates to:
  /// **'expired — needs re-check'**
  String get expiredRecheck;

  /// No description provided for @reportFacilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a facility'**
  String get reportFacilityTitle;

  /// No description provided for @updateFacilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Update facility'**
  String get updateFacilityTitle;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @submitForVerification.
  ///
  /// In en, this message translates to:
  /// **'Submit for verification'**
  String get submitForVerification;

  /// No description provided for @savedWillSend.
  ///
  /// In en, this message translates to:
  /// **'Saved — will be sent for verification when connection returns.'**
  String get savedWillSend;

  /// No description provided for @stepCategoryQuestion.
  ///
  /// In en, this message translates to:
  /// **'What are you reporting?'**
  String get stepCategoryQuestion;

  /// No description provided for @stepLocationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Where is it?'**
  String get stepLocationQuestion;

  /// No description provided for @stepLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the map until the pin sits on the spot.'**
  String get stepLocationHint;

  /// No description provided for @updatingExisting.
  ///
  /// In en, this message translates to:
  /// **'Updating an existing facility'**
  String get updatingExisting;

  /// No description provided for @locationStaysMapped.
  ///
  /// In en, this message translates to:
  /// **'Location stays as mapped'**
  String get locationStaysMapped;

  /// No description provided for @duplicateHint.
  ///
  /// In en, this message translates to:
  /// **'Similar {type} {meters} m away — update it instead?'**
  String duplicateHint(String type, int meters);

  /// No description provided for @updateNamed.
  ///
  /// In en, this message translates to:
  /// **'Update {name}'**
  String updateNamed(String name);

  /// No description provided for @stepCapacityQuestion.
  ///
  /// In en, this message translates to:
  /// **'Roughly how many people can it serve?'**
  String get stepCapacityQuestion;

  /// No description provided for @skipIfNotApplicable.
  ///
  /// In en, this message translates to:
  /// **'Skip this if it doesn\'t apply.'**
  String get skipIfNotApplicable;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @stepStatusQuestion.
  ///
  /// In en, this message translates to:
  /// **'How is it right now?'**
  String get stepStatusQuestion;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. queue is long, tanker refills at 5 PM'**
  String get noteHint;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addPhoto;

  /// No description provided for @photoComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon — photos are stripped of location data before upload.'**
  String get photoComingSoon;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get review;

  /// No description provided for @reviewNewNotice.
  ///
  /// In en, this message translates to:
  /// **'New facilities appear publicly only after verification. You\'ll see it as \"Pending (yours)\" meanwhile.'**
  String get reviewNewNotice;

  /// No description provided for @reviewUpdateNotice.
  ///
  /// In en, this message translates to:
  /// **'This update goes to the verification queue before it changes the public map.'**
  String get reviewUpdateNotice;

  /// No description provided for @alertInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get alertInfo;

  /// No description provided for @alertWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get alertWarning;

  /// No description provided for @alertCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get alertCritical;

  /// No description provided for @verifiedByAdmin.
  ///
  /// In en, this message translates to:
  /// **'Verified by admin'**
  String get verifiedByAdmin;

  /// No description provided for @areaAlert.
  ///
  /// In en, this message translates to:
  /// **'Area alert'**
  String get areaAlert;

  /// No description provided for @noActiveAlerts.
  ///
  /// In en, this message translates to:
  /// **'No active alerts.\nCritical alerts appear here and on the map instantly.'**
  String get noActiveAlerts;

  /// No description provided for @cachedMayBeOutdated.
  ///
  /// In en, this message translates to:
  /// **'Shown from local cache — may be outdated while offline.'**
  String get cachedMayBeOutdated;

  /// No description provided for @sosHoldInstruction.
  ///
  /// In en, this message translates to:
  /// **'Hold the button for 2–3 seconds to send an SOS to volunteers. Calling directly is always available below.'**
  String get sosHoldInstruction;

  /// No description provided for @sosQueuedInstruction.
  ///
  /// In en, this message translates to:
  /// **'SOS queued — it sends the moment any connection returns. Calling directly is fastest.'**
  String get sosQueuedInstruction;

  /// No description provided for @sosHoldToSend.
  ///
  /// In en, this message translates to:
  /// **'SOS\nHold to send'**
  String get sosHoldToSend;

  /// No description provided for @sosQueued.
  ///
  /// In en, this message translates to:
  /// **'SOS queued'**
  String get sosQueued;

  /// No description provided for @imSafeReset.
  ///
  /// In en, this message translates to:
  /// **'I\'m safe — reset'**
  String get imSafeReset;

  /// No description provided for @callPolice.
  ///
  /// In en, this message translates to:
  /// **'Call emergency (police) — {number}'**
  String callPolice(String number);

  /// No description provided for @callAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Call ambulance — {number}'**
  String callAmbulance(String number);

  /// No description provided for @callLegalAid.
  ///
  /// In en, this message translates to:
  /// **'Legal aid helpline — {number}'**
  String callLegalAid(String number);

  /// No description provided for @nearestMedical.
  ///
  /// In en, this message translates to:
  /// **'Nearest medical on map'**
  String get nearestMedical;

  /// No description provided for @shareLocationLater.
  ///
  /// In en, this message translates to:
  /// **'Sharing location with a trusted contact arrives in a later build — always explicit, per use.'**
  String get shareLocationLater;

  /// No description provided for @couldNotDial.
  ///
  /// In en, this message translates to:
  /// **'Could not open dialer — dial {number}'**
  String couldNotDial(String number);

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @pendingUploads.
  ///
  /// In en, this message translates to:
  /// **'Pending uploads'**
  String get pendingUploads;

  /// No description provided for @nothingWaiting.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting to send.'**
  String get nothingWaiting;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} submission(s) will be sent for verification when connection returns.'**
  String pendingCount(int count);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settingsComingLater.
  ///
  /// In en, this message translates to:
  /// **'Appearance and privacy settings come with later builds.'**
  String get settingsComingLater;

  /// No description provided for @volunteerAdmin.
  ///
  /// In en, this message translates to:
  /// **'Volunteer / admin'**
  String get volunteerAdmin;

  /// No description provided for @signedInAsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Signed in as admin — open the verification queue'**
  String get signedInAsAdmin;

  /// No description provided for @verifiersSignIn.
  ///
  /// In en, this message translates to:
  /// **'Verifiers sign in here; everyone else stays anonymous'**
  String get verifiersSignIn;

  /// No description provided for @adminSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Volunteer / admin sign in'**
  String get adminSignInTitle;

  /// No description provided for @adminSignInBlurb.
  ///
  /// In en, this message translates to:
  /// **'Only facility verifiers need an account. Everyone else stays anonymous.'**
  String get adminSignInBlurb;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get signingIn;

  /// No description provided for @noAdminRole.
  ///
  /// In en, this message translates to:
  /// **'Signed in, but this account has no admin role. Ask the project owner to grant it.'**
  String get noAdminRole;

  /// No description provided for @verificationQueue.
  ///
  /// In en, this message translates to:
  /// **'Verification queue'**
  String get verificationQueue;

  /// No description provided for @queueClear.
  ///
  /// In en, this message translates to:
  /// **'Queue is clear — nothing pending.'**
  String get queueClear;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @rejectWhy.
  ///
  /// In en, this message translates to:
  /// **'Reject — why?'**
  String get rejectWhy;

  /// No description provided for @reasonDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get reasonDuplicate;

  /// No description provided for @reasonCantVerify.
  ///
  /// In en, this message translates to:
  /// **'Can\'t verify'**
  String get reasonCantVerify;

  /// No description provided for @reasonStale.
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get reasonStale;

  /// No description provided for @reasonInaccurate.
  ///
  /// In en, this message translates to:
  /// **'Inaccurate'**
  String get reasonInaccurate;

  /// No description provided for @reasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reasonSpam;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @reportClosedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Report {name} as closed?'**
  String reportClosedQuestion(String name);

  /// No description provided for @reportClosedBody.
  ///
  /// In en, this message translates to:
  /// **'This goes to the verification queue — the map changes once an admin confirms it.'**
  String get reportClosedBody;

  /// No description provided for @reportedQueued.
  ///
  /// In en, this message translates to:
  /// **'Reported — queued for verification.'**
  String get reportedQueued;

  /// No description provided for @featureArrivesLater.
  ///
  /// In en, this message translates to:
  /// **'{feature} arrives in a later build.'**
  String featureArrivesLater(String feature);

  /// No description provided for @reviewStatus.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String reviewStatus(String status);

  /// No description provided for @reviewCapacityPeople.
  ///
  /// In en, this message translates to:
  /// **'Capacity: ~{count} people'**
  String reviewCapacityPeople(int count);

  /// No description provided for @reviewCapacityNone.
  ///
  /// In en, this message translates to:
  /// **'Capacity: not specified'**
  String get reviewCapacityNone;

  /// No description provided for @reviewUpdating.
  ///
  /// In en, this message translates to:
  /// **'Updating: {name}'**
  String reviewUpdating(String name);

  /// No description provided for @reviewNewFacility.
  ///
  /// In en, this message translates to:
  /// **'New facility'**
  String get reviewNewFacility;

  /// No description provided for @reviewLocation.
  ///
  /// In en, this message translates to:
  /// **'Location: {lat}, {lng}'**
  String reviewLocation(String lat, String lng);

  /// No description provided for @backendUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Backend not reachable on this build.'**
  String get backendUnreachable;

  /// No description provided for @serverTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server — try again.'**
  String get serverTryAgain;

  /// No description provided for @queueCardNew.
  ///
  /// In en, this message translates to:
  /// **'{type} — new facility'**
  String queueCardNew(String type);

  /// No description provided for @queueCardUpdate.
  ///
  /// In en, this message translates to:
  /// **'{type} — update'**
  String queueCardUpdate(String type);

  /// No description provided for @queueLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the queue: {error}'**
  String queueLoadFailed(String error);

  /// No description provided for @approveFailed.
  ///
  /// In en, this message translates to:
  /// **'Approve failed: {error}'**
  String approveFailed(String error);

  /// No description provided for @rejectFailed.
  ///
  /// In en, this message translates to:
  /// **'Reject failed: {error}'**
  String rejectFailed(String error);

  /// No description provided for @navGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get navGroups;

  /// No description provided for @groupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groupsTitle;

  /// No description provided for @groupsSignInNeeded.
  ///
  /// In en, this message translates to:
  /// **'Groups need you to be online and signed in. Complete the backend setup, then reopen this tab.'**
  String get groupsSignInNeeded;

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups yet. Create one or join with a code.'**
  String get noGroupsYet;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @joinWithCode.
  ///
  /// In en, this message translates to:
  /// **'Join with code'**
  String get joinWithCode;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @groupDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get groupDescription;

  /// No description provided for @groupVisibility.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get groupVisibility;

  /// No description provided for @visibilityHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get visibilityHidden;

  /// No description provided for @visibilityPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get visibilityPublic;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Request sent — an admin must approve you before you see group content.'**
  String get pendingApproval;

  /// No description provided for @membershipPending.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get membershipPending;

  /// No description provided for @tabChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get tabChat;

  /// No description provided for @tabMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get tabMembers;

  /// No description provided for @tabPins.
  ///
  /// In en, this message translates to:
  /// **'Amenities'**
  String get tabPins;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message (end-to-end encrypted)'**
  String get messageHint;

  /// No description provided for @e2eNotice.
  ///
  /// In en, this message translates to:
  /// **'Messages are end-to-end encrypted — only group members can read them.'**
  String get e2eNotice;

  /// No description provided for @cantDecrypt.
  ///
  /// In en, this message translates to:
  /// **'Can\'t decrypt this message.'**
  String get cantDecrypt;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @approveMember.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approveMember;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @member.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get member;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @inviteCreated.
  ///
  /// In en, this message translates to:
  /// **'Invite code (24h, 10 uses): {code}'**
  String inviteCreated(String code);

  /// No description provided for @addAmenity.
  ///
  /// In en, this message translates to:
  /// **'Add amenity'**
  String get addAmenity;

  /// No description provided for @amenityLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get amenityLabel;

  /// No description provided for @noAmenities.
  ///
  /// In en, this message translates to:
  /// **'No group amenities yet.'**
  String get noAmenities;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet. Say hello.'**
  String get noMessages;

  /// No description provided for @groupActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed: {error}'**
  String groupActionFailed(String error);

  /// No description provided for @eventLive.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get eventLive;

  /// No description provided for @eventToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get eventToday;

  /// No description provided for @eventUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get eventUpcoming;

  /// No description provided for @eventVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get eventVerified;

  /// No description provided for @eventDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get eventDetails;

  /// No description provided for @eventDetailsSoon.
  ///
  /// In en, this message translates to:
  /// **'{title} — details arrive with the events build.'**
  String eventDetailsSoon(String title);

  /// No description provided for @eventMainTitle.
  ///
  /// In en, this message translates to:
  /// **'Main gathering — Jantar Mantar'**
  String get eventMainTitle;

  /// No description provided for @eventMainNote.
  ///
  /// In en, this message translates to:
  /// **'Peak crowd expected until 6 PM. Water points at Gates 1 and 3.'**
  String get eventMainNote;

  /// No description provided for @eventMainLocation.
  ///
  /// In en, this message translates to:
  /// **'Jantar Mantar Road'**
  String get eventMainLocation;

  /// No description provided for @eventMedicalTitle.
  ///
  /// In en, this message translates to:
  /// **'Medical volunteer briefing'**
  String get eventMedicalTitle;

  /// No description provided for @eventMedicalNote.
  ///
  /// In en, this message translates to:
  /// **'Shift handover and supply check for all first-aid volunteers.'**
  String get eventMedicalNote;

  /// No description provided for @eventMedicalLocation.
  ///
  /// In en, this message translates to:
  /// **'First-aid tent (main)'**
  String get eventMedicalLocation;

  /// No description provided for @eventMedicalTime.
  ///
  /// In en, this message translates to:
  /// **'Starts 3:00 PM'**
  String get eventMedicalTime;

  /// No description provided for @eventLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal aid desk hours'**
  String get eventLegalTitle;

  /// No description provided for @eventLegalNote.
  ///
  /// In en, this message translates to:
  /// **'Volunteer lawyers available for detention-related queries.'**
  String get eventLegalNote;

  /// No description provided for @eventLegalLocation.
  ///
  /// In en, this message translates to:
  /// **'Gate 2 pavilion'**
  String get eventLegalLocation;

  /// No description provided for @eventLegalTime.
  ///
  /// In en, this message translates to:
  /// **'Starts 4:30 PM'**
  String get eventLegalTime;

  /// No description provided for @eventLangarTitle.
  ///
  /// In en, this message translates to:
  /// **'Community langar'**
  String get eventLangarTitle;

  /// No description provided for @eventLangarNote.
  ///
  /// In en, this message translates to:
  /// **'Food for ~500 people; volunteers needed from 10 AM.'**
  String get eventLangarNote;

  /// No description provided for @eventLangarLocation.
  ///
  /// In en, this message translates to:
  /// **'Parliament Street corner'**
  String get eventLangarLocation;

  /// No description provided for @eventLangarTime.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, 12:00 PM'**
  String get eventLangarTime;

  /// No description provided for @eventLiveNow.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get eventLiveNow;

  /// No description provided for @pickOnMap.
  ///
  /// In en, this message translates to:
  /// **'Place on map'**
  String get pickOnMap;

  /// No description provided for @pickAmenityHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the map to place this amenity, then confirm.'**
  String get pickAmenityHint;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirmLocation;

  /// No description provided for @showGroupPins.
  ///
  /// In en, this message translates to:
  /// **'Show group amenities'**
  String get showGroupPins;

  /// No description provided for @groupPinsLayer.
  ///
  /// In en, this message translates to:
  /// **'Group amenities'**
  String get groupPinsLayer;

  /// No description provided for @groupPinFrom.
  ///
  /// In en, this message translates to:
  /// **'{group} · {label}'**
  String groupPinFrom(String group, String label);

  /// No description provided for @inviteScanHint.
  ///
  /// In en, this message translates to:
  /// **'Have them scan this QR, or share the code below.'**
  String get inviteScanHint;

  /// No description provided for @inviteExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expires in 24 hours · up to 10 uses · they still need admin approval'**
  String get inviteExpiry;

  /// No description provided for @inviteCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get inviteCopied;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @demoMode.
  ///
  /// In en, this message translates to:
  /// **'Demo mode'**
  String get demoMode;

  /// No description provided for @demoModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explore every screen with sample data — no backend or login needed. Turn off to use the live backend.'**
  String get demoModeSubtitle;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'hi':
      return AppL10nHi();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
