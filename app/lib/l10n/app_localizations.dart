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
  /// **'Recentre the map'**
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

  /// No description provided for @clusterOf.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 facility here} other{{count} facilities here}}'**
  String clusterOf(int count);

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

  /// No description provided for @directionsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open a map app. Coordinates: {coords}'**
  String directionsFailed(String coords);

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

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
  /// **'Location and camera data are removed before anything is uploaded.'**
  String get photoComingSoon;

  /// No description provided for @photoStripped.
  ///
  /// In en, this message translates to:
  /// **'Location and camera data removed from this photo.'**
  String get photoStripped;

  /// No description provided for @photoTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get photoTakePhoto;

  /// No description provided for @photoChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get photoChooseFromGallery;

  /// No description provided for @photoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get photoRemove;

  /// No description provided for @photoUnsupported.
  ///
  /// In en, this message translates to:
  /// **'That file could not be read as a photo, so it was not attached.'**
  String get photoUnsupported;

  /// No description provided for @photoFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not attach the photo: {error}'**
  String photoFailed(String error);

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

  /// No description provided for @alertComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'New public alert'**
  String get alertComposeTitle;

  /// No description provided for @alertPublicWarning.
  ///
  /// In en, this message translates to:
  /// **'This goes on the public map for everyone — not just group members, and not encrypted. Use a group broadcast if it should stay private.'**
  String get alertPublicWarning;

  /// No description provided for @alertBody.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get alertBody;

  /// No description provided for @alertBodyHint.
  ///
  /// In en, this message translates to:
  /// **'What people need to know, and what to do about it.'**
  String get alertBodyHint;

  /// No description provided for @alertExpiry.
  ///
  /// In en, this message translates to:
  /// **'Expires after'**
  String get alertExpiry;

  /// No description provided for @alertExpiryWhy.
  ///
  /// In en, this message translates to:
  /// **'Alerts disappear automatically. A stale warning is worse than none.'**
  String get alertExpiryWhy;

  /// No description provided for @alertExpiresHours.
  ///
  /// In en, this message translates to:
  /// **'{count} h'**
  String alertExpiresHours(int count);

  /// No description provided for @alertExpiresMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min'**
  String alertExpiresMinutes(int count);

  /// No description provided for @alertPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish alert'**
  String get alertPublish;

  /// No description provided for @alertPublished.
  ///
  /// In en, this message translates to:
  /// **'Alert published.'**
  String get alertPublished;

  /// No description provided for @alertConfirmCriticalTitle.
  ///
  /// In en, this message translates to:
  /// **'Publish a CRITICAL alert?'**
  String get alertConfirmCriticalTitle;

  /// No description provided for @alertConfirmCriticalBody.
  ///
  /// In en, this message translates to:
  /// **'Critical alerts take over the top of the map for everyone nearby. Use them when people need to move or stop what they are doing.'**
  String get alertConfirmCriticalBody;

  /// No description provided for @alertDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo mode: this is saved on this device only.'**
  String get alertDemoNote;

  /// No description provided for @alertLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device, but it could NOT be sent to the server — nobody else can see it yet.'**
  String get alertLocalOnly;

  /// No description provided for @newAlert.
  ///
  /// In en, this message translates to:
  /// **'New alert'**
  String get newAlert;

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
  /// **'Explicit and per use. Your location is never stored on our servers — it goes straight to the app you pick.'**
  String get shareLocationLater;

  /// No description provided for @shareMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Share my location'**
  String get shareMyLocation;

  /// No description provided for @shareLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your location once'**
  String get shareLocationTitle;

  /// No description provided for @shareLocationBody.
  ///
  /// In en, this message translates to:
  /// **'This takes a single GPS reading and hands it to the app you choose — a message, a call, whatever you already use. It is not stored on this device and never reaches our servers. Anyone you send it to can see where you are.'**
  String get shareLocationBody;

  /// No description provided for @shareLocationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Get my location'**
  String get shareLocationConfirm;

  /// No description provided for @shareLocationMessage.
  ///
  /// In en, this message translates to:
  /// **'I am here: {url} (within {meters} m, at {time})'**
  String shareLocationMessage(String url, int meters, String time);

  /// No description provided for @locationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location is switched off on this device.'**
  String get locationServiceOff;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was declined. Nothing was shared.'**
  String get locationDenied;

  /// No description provided for @locationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked for this app in system settings.'**
  String get locationDeniedForever;

  /// No description provided for @locationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Could not get a location fix. Nothing was shared.'**
  String get locationTimeout;

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

  /// No description provided for @reporterHistory.
  ///
  /// In en, this message translates to:
  /// **'Reporter'**
  String get reporterHistory;

  /// No description provided for @reporterRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent reports'**
  String get reporterRecent;

  /// No description provided for @reporterNone.
  ///
  /// In en, this message translates to:
  /// **'No reports yet.'**
  String get reporterNone;

  /// No description provided for @reporterOnHold.
  ///
  /// In en, this message translates to:
  /// **'Standing held by an admin'**
  String get reporterOnHold;

  /// No description provided for @revokeVerifier.
  ///
  /// In en, this message translates to:
  /// **'Revoke verifier'**
  String get revokeVerifier;

  /// No description provided for @revokeReasonPrompt.
  ///
  /// In en, this message translates to:
  /// **'Why is this standing being revoked?'**
  String get revokeReasonPrompt;

  /// No description provided for @revokeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This drops the account to New and holds it there. Approvals will keep counting but will not promote it again until an admin restores it.'**
  String get revokeConfirmBody;

  /// No description provided for @revokeDone.
  ///
  /// In en, this message translates to:
  /// **'Standing revoked and held.'**
  String get revokeDone;

  /// No description provided for @restoreTrust.
  ///
  /// In en, this message translates to:
  /// **'Restore standing'**
  String get restoreTrust;

  /// No description provided for @restoreConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This lifts the hold and recomputes the level from the account\'s record. It does not hand back the old level automatically.'**
  String get restoreConfirmBody;

  /// No description provided for @restoreDone.
  ///
  /// In en, this message translates to:
  /// **'Hold lifted.'**
  String get restoreDone;

  /// No description provided for @moderationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not apply that: {error}'**
  String moderationFailed(String error);

  /// No description provided for @senderUnverified.
  ///
  /// In en, this message translates to:
  /// **'Not verified as this sender'**
  String get senderUnverified;

  /// No description provided for @reportRoute.
  ///
  /// In en, this message translates to:
  /// **'Report a blocked route'**
  String get reportRoute;

  /// No description provided for @routeImpassable.
  ///
  /// In en, this message translates to:
  /// **'Impassable'**
  String get routeImpassable;

  /// No description provided for @routeDifficult.
  ///
  /// In en, this message translates to:
  /// **'Hard to pass'**
  String get routeDifficult;

  /// No description provided for @routeCleared.
  ///
  /// In en, this message translates to:
  /// **'Reopened'**
  String get routeCleared;

  /// No description provided for @causeFlood.
  ///
  /// In en, this message translates to:
  /// **'Flooded'**
  String get causeFlood;

  /// No description provided for @causeCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapsed'**
  String get causeCollapse;

  /// No description provided for @causeDebris.
  ///
  /// In en, this message translates to:
  /// **'Debris'**
  String get causeDebris;

  /// No description provided for @causeBlocked.
  ///
  /// In en, this message translates to:
  /// **'Closed off'**
  String get causeBlocked;

  /// No description provided for @causeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get causeOther;

  /// No description provided for @routeName.
  ///
  /// In en, this message translates to:
  /// **'Which road or bridge?'**
  String get routeName;

  /// No description provided for @routeUnnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed route'**
  String get routeUnnamed;

  /// No description provided for @routePlaceStart.
  ///
  /// In en, this message translates to:
  /// **'Move the map to one end of the affected stretch.'**
  String get routePlaceStart;

  /// No description provided for @routePlaceEnd.
  ///
  /// In en, this message translates to:
  /// **'Now move to the other end.'**
  String get routePlaceEnd;

  /// No description provided for @routePlacedBoth.
  ///
  /// In en, this message translates to:
  /// **'Both ends set. Tap again to start over.'**
  String get routePlacedBoth;

  /// No description provided for @routeSetStart.
  ///
  /// In en, this message translates to:
  /// **'Set start'**
  String get routeSetStart;

  /// No description provided for @routeSetEnd.
  ///
  /// In en, this message translates to:
  /// **'Set end'**
  String get routeSetEnd;

  /// No description provided for @routeExpiryWhy.
  ///
  /// In en, this message translates to:
  /// **'Every report expires. A blockage left on the map after the water drops sends people the long way round — or away from the only road out.'**
  String get routeExpiryWhy;

  /// No description provided for @routeSave.
  ///
  /// In en, this message translates to:
  /// **'Save route report'**
  String get routeSave;

  /// No description provided for @routeSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Saved on this device. Route reports do not sync yet.'**
  String get routeSavedLocally;

  /// No description provided for @routeNoSafeClaim.
  ///
  /// In en, this message translates to:
  /// **'This shows hazards only. A road with no line on it has not been checked — it is not marked safe.'**
  String get routeNoSafeClaim;

  /// No description provided for @ttlHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String ttlHours(int hours);

  /// No description provided for @offlineShowingSaved.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved data.'**
  String get offlineShowingSaved;

  /// No description provided for @couldNotLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load this. You may be offline.'**
  String get couldNotLoad;

  /// No description provided for @queueClearBody.
  ///
  /// In en, this message translates to:
  /// **'Nothing is waiting for review right now.'**
  String get queueClearBody;

  /// No description provided for @mapSemanticsPick.
  ///
  /// In en, this message translates to:
  /// **'Map. Drag to move the crosshair to the place you mean.'**
  String get mapSemanticsPick;

  /// No description provided for @sosSemanticsHold.
  ///
  /// In en, this message translates to:
  /// **'SOS. Hold for two and a half seconds to send. Release to cancel.'**
  String get sosSemanticsHold;

  /// No description provided for @washTitle.
  ///
  /// In en, this message translates to:
  /// **'Against humanitarian minimums'**
  String get washTitle;

  /// No description provided for @washLatrines.
  ///
  /// In en, this message translates to:
  /// **'Toilets'**
  String get washLatrines;

  /// No description provided for @washWater.
  ///
  /// In en, this message translates to:
  /// **'Water points'**
  String get washWater;

  /// No description provided for @washPerLatrine.
  ///
  /// In en, this message translates to:
  /// **'{count} people per toilet'**
  String washPerLatrine(int count);

  /// No description provided for @washPerWaterPoint.
  ///
  /// In en, this message translates to:
  /// **'{count} people per water point'**
  String washPerWaterPoint(int count);

  /// No description provided for @washNoLatrines.
  ///
  /// In en, this message translates to:
  /// **'none mapped here'**
  String get washNoLatrines;

  /// No description provided for @washNoWater.
  ///
  /// In en, this message translates to:
  /// **'none mapped here'**
  String get washNoWater;

  /// No description provided for @washLatrineStandard.
  ///
  /// In en, this message translates to:
  /// **'Emergency maximum is {max} people per toilet.'**
  String washLatrineStandard(int max);

  /// No description provided for @washWaterStandard.
  ///
  /// In en, this message translates to:
  /// **'Standard is {tap} people per tap, {pump} per hand pump.'**
  String washWaterStandard(int tap, int pump);

  /// No description provided for @washCoverage.
  ///
  /// In en, this message translates to:
  /// **'Counted {count} mapped facilities within {meters} m. The map is incomplete, so treat this as an indicator, not a survey.'**
  String washCoverage(int count, int meters);

  /// No description provided for @yourStanding.
  ///
  /// In en, this message translates to:
  /// **'Your standing'**
  String get yourStanding;

  /// No description provided for @tierNew.
  ///
  /// In en, this message translates to:
  /// **'New reporter'**
  String get tierNew;

  /// No description provided for @tierTrusted.
  ///
  /// In en, this message translates to:
  /// **'Trusted reporter'**
  String get tierTrusted;

  /// No description provided for @tierVerifier.
  ///
  /// In en, this message translates to:
  /// **'Verifier'**
  String get tierVerifier;

  /// No description provided for @tierNewBody.
  ///
  /// In en, this message translates to:
  /// **'Your reports go to an admin for verification.'**
  String get tierNewBody;

  /// No description provided for @tierTrustedBody.
  ///
  /// In en, this message translates to:
  /// **'Your reports are prioritised in the queue.'**
  String get tierTrustedBody;

  /// No description provided for @tierVerifierBody.
  ///
  /// In en, this message translates to:
  /// **'You can approve updates to existing facilities. New facilities, rejections and alerts stay with admins.'**
  String get tierVerifierBody;

  /// No description provided for @standingCounts.
  ///
  /// In en, this message translates to:
  /// **'{approved} approved · {rejected} rejected'**
  String standingCounts(int approved, int rejected);

  /// No description provided for @standingRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count} more approved reports to the next level'**
  String standingRemaining(int count);

  /// No description provided for @standingApprovedCaption.
  ///
  /// In en, this message translates to:
  /// **'approved'**
  String get standingApprovedCaption;

  /// No description provided for @standingTop.
  ///
  /// In en, this message translates to:
  /// **'Highest level reached.'**
  String get standingTop;

  /// No description provided for @verifierCannotReject.
  ///
  /// In en, this message translates to:
  /// **'Rejecting is admin-only.'**
  String get verifierCannotReject;

  /// No description provided for @verifierNeedsAdmin.
  ///
  /// In en, this message translates to:
  /// **'A new facility needs an admin.'**
  String get verifierNeedsAdmin;

  /// No description provided for @alertSignals.
  ///
  /// In en, this message translates to:
  /// **'Critical alert signals'**
  String get alertSignals;

  /// No description provided for @alertVibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate'**
  String get alertVibrate;

  /// No description provided for @alertVibrateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Buzz twice when a critical alert arrives.'**
  String get alertVibrateSubtitle;

  /// No description provided for @alertSound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get alertSound;

  /// No description provided for @alertSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Off by default — an unexpected chime can identify you in a crowd.'**
  String get alertSoundSubtitle;

  /// No description provided for @auditLog.
  ///
  /// In en, this message translates to:
  /// **'Audit log'**
  String get auditLog;

  /// No description provided for @auditLogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No admin actions recorded yet.'**
  String get auditLogEmpty;

  /// No description provided for @auditLogAppendOnly.
  ///
  /// In en, this message translates to:
  /// **'Append-only. Entries cannot be edited or deleted, including by admins.'**
  String get auditLogAppendOnly;

  /// No description provided for @auditApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved a submission'**
  String get auditApproved;

  /// No description provided for @auditRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected a submission'**
  String get auditRejected;

  /// No description provided for @auditAlert.
  ///
  /// In en, this message translates to:
  /// **'Published an alert'**
  String get auditAlert;

  /// No description provided for @auditCorroborated.
  ///
  /// In en, this message translates to:
  /// **'Published by corroboration'**
  String get auditCorroborated;

  /// No description provided for @auditPromoted.
  ///
  /// In en, this message translates to:
  /// **'Reporter promoted'**
  String get auditPromoted;

  /// No description provided for @auditDemoted.
  ///
  /// In en, this message translates to:
  /// **'Reporter demoted'**
  String get auditDemoted;

  /// No description provided for @auditAutomatic.
  ///
  /// In en, this message translates to:
  /// **'automatic — no admin decision'**
  String get auditAutomatic;

  /// No description provided for @auditBy.
  ///
  /// In en, this message translates to:
  /// **'by {actor}'**
  String auditBy(String actor);

  /// No description provided for @selectMode.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectMode;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @approveSelected.
  ///
  /// In en, this message translates to:
  /// **'Approve selected'**
  String get approveSelected;

  /// No description provided for @approveSelectedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Approve {count} submissions? Each one publishes to the public map immediately.'**
  String approveSelectedConfirm(int count);

  /// No description provided for @batchApproved.
  ///
  /// In en, this message translates to:
  /// **'{count} approved.'**
  String batchApproved(int count);

  /// No description provided for @batchPartial.
  ///
  /// In en, this message translates to:
  /// **'{done} approved, {failed} failed.'**
  String batchPartial(int done, int failed);

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

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeMember;

  /// No description provided for @removeMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeMemberTitle(String name);

  /// No description provided for @removeMemberBody.
  ///
  /// In en, this message translates to:
  /// **'They lose access to this group and a new encryption key is issued, so they cannot read anything sent from now on. Messages they already received stay on their device.'**
  String get removeMemberBody;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed. New encryption key issued to the group.'**
  String get memberRemoved;

  /// No description provided for @rekeyWarning.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =1{1 member has no device key yet and will not receive the new key until they open the app.} other{{count} members have no device key yet and will not receive the new key until they open the app.}}'**
  String rekeyWarning(int count);

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

  /// No description provided for @chatOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing saved messages'**
  String get chatOffline;

  /// No description provided for @broadcast.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get broadcast;

  /// No description provided for @broadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'Broadcast to {group}'**
  String broadcastTitle(String group);

  /// No description provided for @broadcastHint.
  ///
  /// In en, this message translates to:
  /// **'Everyone in this group sees this at the top of the chat and in Alerts.'**
  String get broadcastHint;

  /// No description provided for @broadcastSend.
  ///
  /// In en, this message translates to:
  /// **'Send broadcast'**
  String get broadcastSend;

  /// No description provided for @broadcastSeverity.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get broadcastSeverity;

  /// No description provided for @groupBroadcasts.
  ///
  /// In en, this message translates to:
  /// **'From your groups'**
  String get groupBroadcasts;

  /// No description provided for @groupBroadcastNote.
  ///
  /// In en, this message translates to:
  /// **'Group broadcast · members only'**
  String get groupBroadcastNote;

  /// No description provided for @messageSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get messageSending;

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

  /// No description provided for @jumpToSite.
  ///
  /// In en, this message translates to:
  /// **'Jump to a site'**
  String get jumpToSite;

  /// No description provided for @eventDelhiSitInTitle.
  ///
  /// In en, this message translates to:
  /// **'Overnight sit-in'**
  String get eventDelhiSitInTitle;

  /// No description provided for @eventDelhiSitInNote.
  ///
  /// In en, this message translates to:
  /// **'Bring warm layers; shade tents convert to sleeping cover after 9 PM.'**
  String get eventDelhiSitInNote;

  /// No description provided for @eventDelhiSitInLocation.
  ///
  /// In en, this message translates to:
  /// **'Jantar Mantar, New Delhi'**
  String get eventDelhiSitInLocation;

  /// No description provided for @eventDelhiSitInTime.
  ///
  /// In en, this message translates to:
  /// **'Tonight, 9:00 PM'**
  String get eventDelhiSitInTime;

  /// No description provided for @eventLondonTitle.
  ///
  /// In en, this message translates to:
  /// **'Parliament Square assembly'**
  String get eventLondonTitle;

  /// No description provided for @eventLondonNote.
  ///
  /// In en, this message translates to:
  /// **'Speeches from the Gandhi statue. Legal observers in orange hi-vis.'**
  String get eventLondonNote;

  /// No description provided for @eventLondonLocation.
  ///
  /// In en, this message translates to:
  /// **'Parliament Square, London'**
  String get eventLondonLocation;

  /// No description provided for @eventLondonTime.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get eventLondonTime;

  /// No description provided for @eventLondonLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Know-your-rights briefing'**
  String get eventLondonLegalTitle;

  /// No description provided for @eventLondonLegalNote.
  ///
  /// In en, this message translates to:
  /// **'Short session on stop-and-search and what to do if detained.'**
  String get eventLondonLegalNote;

  /// No description provided for @eventLondonLegalLocation.
  ///
  /// In en, this message translates to:
  /// **'Westminster Bridge north side, London'**
  String get eventLondonLegalLocation;

  /// No description provided for @eventLondonLegalTime.
  ///
  /// In en, this message translates to:
  /// **'Starts 5:00 PM'**
  String get eventLondonLegalTime;

  /// No description provided for @eventBengaluruTitle.
  ///
  /// In en, this message translates to:
  /// **'Town Hall gathering'**
  String get eventBengaluruTitle;

  /// No description provided for @eventBengaluruNote.
  ///
  /// In en, this message translates to:
  /// **'Water tanker and community meal counter on site.'**
  String get eventBengaluruNote;

  /// No description provided for @eventBengaluruLocation.
  ///
  /// In en, this message translates to:
  /// **'Town Hall, Bengaluru'**
  String get eventBengaluruLocation;

  /// No description provided for @eventBengaluruTime.
  ///
  /// In en, this message translates to:
  /// **'Live now'**
  String get eventBengaluruTime;

  /// No description provided for @eventBengaluruWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Shade tent build'**
  String get eventBengaluruWaterTitle;

  /// No description provided for @eventBengaluruWaterNote.
  ///
  /// In en, this message translates to:
  /// **'Volunteers needed to raise six more tents before the afternoon heat.'**
  String get eventBengaluruWaterNote;

  /// No description provided for @eventBengaluruWaterLocation.
  ///
  /// In en, this message translates to:
  /// **'JC Road side, Bengaluru'**
  String get eventBengaluruWaterLocation;

  /// No description provided for @eventBengaluruWaterTime.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow, 7:00 AM'**
  String get eventBengaluruWaterTime;

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

  /// No description provided for @scanInvite.
  ///
  /// In en, this message translates to:
  /// **'Scan invite QR'**
  String get scanInvite;

  /// No description provided for @scanInviteHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the invite QR. You will still need admin approval.'**
  String get scanInviteHint;

  /// No description provided for @scanUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera scanning is not available in the browser. Ask for the code and enter it instead.'**
  String get scanUnavailable;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable ({error}). Enter the code instead.'**
  String scanFailed(String error);

  /// No description provided for @enterCodeInstead.
  ///
  /// In en, this message translates to:
  /// **'Enter code instead'**
  String get enterCodeInstead;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

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

  /// No description provided for @panicWipe.
  ///
  /// In en, this message translates to:
  /// **'Panic wipe'**
  String get panicWipe;

  /// No description provided for @panicWipeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Erase keys, cached chat and local reports from this device, and sign out.'**
  String get panicWipeSubtitle;

  /// No description provided for @panicWipeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Erase everything on this device?'**
  String get panicWipeConfirmTitle;

  /// No description provided for @panicWipeConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This deletes your encryption keys, all cached group chat, your queued reports and your session. Group chat you can no longer decrypt is gone for good on this handset.\n\nIt cannot reach the server or other members\' devices: messages already delivered stay delivered, and your group memberships still exist on the server.'**
  String get panicWipeConfirmBody;

  /// No description provided for @panicWipeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Erase now'**
  String get panicWipeConfirm;

  /// No description provided for @panicWipeDone.
  ///
  /// In en, this message translates to:
  /// **'Erased. This device holds no keys, chat or reports.'**
  String get panicWipeDone;

  /// No description provided for @panicWipeFailed.
  ///
  /// In en, this message translates to:
  /// **'Wipe failed: {error}'**
  String panicWipeFailed(String error);

  /// No description provided for @webLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Browser version — for trying it out'**
  String get webLimitedTitle;

  /// No description provided for @webLimitedBody.
  ///
  /// In en, this message translates to:
  /// **'This build runs in a browser, so it cannot use the phone\'s secure key storage, offline map caching, or the camera. Encryption keys are kept in browser storage, which Safari can delete after about a week of not opening the app — that would permanently lose your group chat history. Use the installed app for anything real.'**
  String get webLimitedBody;

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

  /// Persistent banner shown on every screen while Demo Mode is on.
  ///
  /// In en, this message translates to:
  /// **'Sample data — for exploring the app. Not real reports.'**
  String get demoBannerSampleData;
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
