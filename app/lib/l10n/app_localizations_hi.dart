// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppL10nHi extends AppL10n {
  AppL10nHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'CommonGround';

  @override
  String get navMap => 'नक्शा';

  @override
  String get navEvents => 'कार्यक्रम';

  @override
  String get navAlerts => 'चेतावनी';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get filterAll => 'सभी';

  @override
  String get typeWater => 'पानी';

  @override
  String get typeFood => 'भोजन';

  @override
  String get typeShelter => 'आश्रय';

  @override
  String get typeMedical => 'चिकित्सा';

  @override
  String get typeToilet => 'शौचालय';

  @override
  String get typeSafeArea => 'सुरक्षित क्षेत्र';

  @override
  String get typeDanger => 'ख़तरा';

  @override
  String get statusGood => 'पर्याप्त';

  @override
  String get statusLow => 'कम';

  @override
  String get statusOut => 'समाप्त';

  @override
  String get statusClosed => 'बंद';

  @override
  String get report => 'रिपोर्ट करें';

  @override
  String get recenter => 'नक्शा फिर केंद्रित करें';

  @override
  String get sos => 'SOS';

  @override
  String get nearby => 'आस-पास';

  @override
  String get beFirstToReport =>
      'यहाँ अभी कोई सुविधा नहीं है — सबसे पहले रिपोर्ट करें।';

  @override
  String get notYetVerified => 'अभी सत्यापित नहीं';

  @override
  String verifiedAgo(String time) {
    return '$time सत्यापित';
  }

  @override
  String verifiedAgoRecheck(String time) {
    return '$time सत्यापित — दोबारा जाँच ज़रूरी';
  }

  @override
  String get justNow => 'अभी-अभी';

  @override
  String minAgo(int count) {
    return '$count मिनट पहले';
  }

  @override
  String hoursAgo(int count) {
    return '$count घंटे पहले';
  }

  @override
  String daysAgo(int count) {
    return '$count दिन पहले';
  }

  @override
  String get mayBeOutdated => 'यह जानकारी पुरानी हो सकती है।';

  @override
  String get updateThis => 'इसे अपडेट करें';

  @override
  String get reportClosed => 'बंद बताएँ';

  @override
  String get directions => 'रास्ता';

  @override
  String get share => 'साझा करें';

  @override
  String capacityFor(int count) {
    return 'लगभग $count के लिए';
  }

  @override
  String get expiredRecheck => 'समय समाप्त — दोबारा जाँच ज़रूरी';

  @override
  String directionsFailed(String coords) {
    return 'कोई मैप ऐप नहीं खुल सका। निर्देशांक: $coords';
  }

  @override
  String get copiedToClipboard => 'क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get reportFacilityTitle => 'सुविधा की रिपोर्ट करें';

  @override
  String get updateFacilityTitle => 'सुविधा अपडेट करें';

  @override
  String get back => 'पीछे';

  @override
  String get next => 'आगे';

  @override
  String get submitForVerification => 'सत्यापन के लिए भेजें';

  @override
  String get savedWillSend =>
      'सहेजा गया — कनेक्शन लौटते ही सत्यापन के लिए भेजा जाएगा।';

  @override
  String get stepCategoryQuestion => 'आप क्या रिपोर्ट कर रहे हैं?';

  @override
  String get stepLocationQuestion => 'यह कहाँ है?';

  @override
  String get stepLocationHint => 'नक्शे को खींचें ताकि पिन सही जगह पर आ जाए।';

  @override
  String get updatingExisting => 'मौजूदा सुविधा अपडेट कर रहे हैं';

  @override
  String get locationStaysMapped => 'स्थान नक्शे के अनुसार रहेगा';

  @override
  String duplicateHint(String type, int meters) {
    return '$meters मीटर दूर एक जैसा $type है — उसे अपडेट करें?';
  }

  @override
  String updateNamed(String name) {
    return '$name अपडेट करें';
  }

  @override
  String get stepCapacityQuestion => 'यह लगभग कितने लोगों के लिए है?';

  @override
  String get skipIfNotApplicable => 'अगर लागू न हो तो छोड़ दें।';

  @override
  String get skip => 'छोड़ें';

  @override
  String get stepStatusQuestion => 'अभी इसकी स्थिति क्या है?';

  @override
  String get noteOptional => 'टिप्पणी (वैकल्पिक)';

  @override
  String get noteHint => 'जैसे: लंबी कतार, टैंकर 5 बजे भरता है';

  @override
  String get addPhoto => 'फ़ोटो जोड़ें';

  @override
  String get photoComingSoon =>
      'अपलोड से पहले स्थान और कैमरा जानकारी हटा दी जाती है।';

  @override
  String get photoStripped => 'इस फ़ोटो से स्थान और कैमरा जानकारी हटा दी गई।';

  @override
  String get photoTakePhoto => 'फ़ोटो लें';

  @override
  String get photoChooseFromGallery => 'गैलरी से चुनें';

  @override
  String get photoRemove => 'फ़ोटो हटाएँ';

  @override
  String get photoUnsupported =>
      'यह फ़ाइल फ़ोटो के रूप में नहीं पढ़ी जा सकी, इसलिए संलग्न नहीं की गई।';

  @override
  String photoFailed(String error) {
    return 'फ़ोटो संलग्न नहीं हो सकी: $error';
  }

  @override
  String get review => 'समीक्षा';

  @override
  String get reviewNewNotice =>
      'नई सुविधाएँ सत्यापन के बाद ही सार्वजनिक दिखती हैं। तब तक यह \"लंबित (आपकी)\" दिखेगी।';

  @override
  String get reviewUpdateNotice =>
      'यह अपडेट सार्वजनिक नक्शा बदलने से पहले सत्यापन कतार में जाता है।';

  @override
  String get alertInfo => 'सूचना';

  @override
  String get alertWarning => 'चेतावनी';

  @override
  String get alertCritical => 'गंभीर';

  @override
  String get verifiedByAdmin => 'व्यवस्थापक द्वारा सत्यापित';

  @override
  String get areaAlert => 'क्षेत्र चेतावनी';

  @override
  String get noActiveAlerts =>
      'कोई सक्रिय चेतावनी नहीं।\nगंभीर चेतावनियाँ यहाँ और नक्शे पर तुरंत दिखती हैं।';

  @override
  String get cachedMayBeOutdated =>
      'स्थानीय कैश से दिखाया गया — ऑफ़लाइन में पुराना हो सकता है।';

  @override
  String get alertComposeTitle => 'नई सार्वजनिक चेतावनी';

  @override
  String get alertPublicWarning =>
      'यह सभी के लिए सार्वजनिक नक्शे पर जाएगी — केवल समूह सदस्यों तक सीमित नहीं, और एन्क्रिप्टेड नहीं। निजी रखना हो तो समूह प्रसारण का उपयोग करें।';

  @override
  String get alertBody => 'संदेश';

  @override
  String get alertBodyHint => 'लोगों को क्या जानना चाहिए, और क्या करना चाहिए।';

  @override
  String get alertExpiry => 'समाप्ति अवधि';

  @override
  String get alertExpiryWhy =>
      'चेतावनियाँ अपने आप हट जाती हैं। पुरानी चेतावनी न होने से भी बदतर है।';

  @override
  String alertExpiresHours(int count) {
    return '$count घंटे';
  }

  @override
  String alertExpiresMinutes(int count) {
    return '$count मिनट';
  }

  @override
  String get alertPublish => 'चेतावनी प्रकाशित करें';

  @override
  String get alertPublished => 'चेतावनी प्रकाशित हो गई।';

  @override
  String get alertConfirmCriticalTitle => 'गंभीर चेतावनी प्रकाशित करें?';

  @override
  String get alertConfirmCriticalBody =>
      'गंभीर चेतावनियाँ आस-पास के सभी लोगों के नक्शे के ऊपर दिखती हैं। इनका उपयोग तब करें जब लोगों को हटना हो या रुकना हो।';

  @override
  String get alertDemoNote => 'डेमो मोड: यह केवल इस डिवाइस पर सहेजा गया है।';

  @override
  String get alertLocalOnly =>
      'इस डिवाइस पर सहेजा गया, पर सर्वर तक नहीं भेजा जा सका — अभी इसे कोई और नहीं देख सकता।';

  @override
  String get newAlert => 'नई चेतावनी';

  @override
  String get sosHoldInstruction =>
      'स्वयंसेवकों को SOS भेजने के लिए बटन को 2–3 सेकंड दबाए रखें। सीधे कॉल करना नीचे हमेशा उपलब्ध है।';

  @override
  String get sosQueuedInstruction =>
      'SOS कतार में है — कनेक्शन लौटते ही भेजा जाएगा। सीधे कॉल करना सबसे तेज़ है।';

  @override
  String get sosHoldToSend => 'SOS\nभेजने के लिए दबाए रखें';

  @override
  String get sosQueued => 'SOS कतार में';

  @override
  String get imSafeReset => 'मैं सुरक्षित हूँ — रीसेट';

  @override
  String callPolice(String number) {
    return 'आपातकाल (पुलिस) — $number';
  }

  @override
  String callAmbulance(String number) {
    return 'एम्बुलेंस — $number';
  }

  @override
  String callLegalAid(String number) {
    return 'कानूनी सहायता हेल्पलाइन — $number';
  }

  @override
  String get nearestMedical => 'नक्शे पर निकटतम चिकित्सा';

  @override
  String get shareLocationLater =>
      'स्पष्ट और हर बार। आपका स्थान हमारे सर्वर पर कभी संग्रहीत नहीं होता — यह सीधे आपके चुने ऐप को जाता है।';

  @override
  String get shareMyLocation => 'मेरा स्थान साझा करें';

  @override
  String get shareLocationTitle => 'अपना स्थान एक बार साझा करें';

  @override
  String get shareLocationBody =>
      'यह एक बार GPS पढ़ता है और आपके चुने हुए ऐप को दे देता है — संदेश, कॉल, जो भी आप उपयोग करते हैं। यह इस डिवाइस पर सहेजा नहीं जाता और हमारे सर्वर तक कभी नहीं पहुँचता। जिसे आप भेजेंगे वह देख सकेगा कि आप कहाँ हैं।';

  @override
  String get shareLocationConfirm => 'मेरा स्थान लें';

  @override
  String shareLocationMessage(String url, int meters, String time) {
    return 'मैं यहाँ हूँ: $url ($meters मी. के भीतर, $time बजे)';
  }

  @override
  String get locationServiceOff => 'इस डिवाइस पर स्थान बंद है।';

  @override
  String get locationDenied =>
      'स्थान की अनुमति अस्वीकार की गई। कुछ भी साझा नहीं हुआ।';

  @override
  String get locationDeniedForever =>
      'सिस्टम सेटिंग्स में इस ऐप के लिए स्थान अवरुद्ध है।';

  @override
  String get locationTimeout => 'स्थान नहीं मिल सका। कुछ भी साझा नहीं हुआ।';

  @override
  String couldNotDial(String number) {
    return 'डायलर नहीं खुला — $number डायल करें';
  }

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get pendingUploads => 'लंबित अपलोड';

  @override
  String get nothingWaiting => 'भेजने के लिए कुछ नहीं।';

  @override
  String pendingCount(int count) {
    return '$count सबमिशन कनेक्शन लौटते ही सत्यापन के लिए भेजे जाएँगे।';
  }

  @override
  String get language => 'भाषा';

  @override
  String get settingsComingLater =>
      'रूप-रंग और गोपनीयता सेटिंग्स बाद के संस्करणों में आएँगी।';

  @override
  String get volunteerAdmin => 'स्वयंसेवक / व्यवस्थापक';

  @override
  String get signedInAsAdmin =>
      'व्यवस्थापक के रूप में साइन इन — सत्यापन कतार खोलें';

  @override
  String get verifiersSignIn =>
      'सत्यापनकर्ता यहाँ साइन इन करें; बाकी सभी अनाम रहते हैं';

  @override
  String get adminSignInTitle => 'स्वयंसेवक / व्यवस्थापक साइन इन';

  @override
  String get adminSignInBlurb =>
      'केवल सुविधा सत्यापनकर्ताओं को खाता चाहिए। बाकी सभी अनाम रहते हैं।';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signingIn => 'साइन इन हो रहा है…';

  @override
  String get noAdminRole =>
      'साइन इन हो गया, पर इस खाते में व्यवस्थापक भूमिका नहीं है। प्रोजेक्ट मालिक से अनुरोध करें।';

  @override
  String get verificationQueue => 'सत्यापन कतार';

  @override
  String get queueClear => 'कतार खाली है — कुछ लंबित नहीं।';

  @override
  String get approve => 'स्वीकृत करें';

  @override
  String get reject => 'अस्वीकार करें';

  @override
  String get rejectWhy => 'अस्वीकार — क्यों?';

  @override
  String get reasonDuplicate => 'डुप्लिकेट';

  @override
  String get reasonCantVerify => 'सत्यापित नहीं कर सकते';

  @override
  String get reasonStale => 'पुराना';

  @override
  String get reasonInaccurate => 'ग़लत';

  @override
  String get reasonSpam => 'स्पैम';

  @override
  String get reporterHistory => 'रिपोर्टर';

  @override
  String get reporterRecent => 'हाल की रिपोर्टें';

  @override
  String get reporterNone => 'अभी तक कोई रिपोर्ट नहीं।';

  @override
  String get reporterOnHold => 'व्यवस्थापक द्वारा स्थिति रोकी गई';

  @override
  String get revokeVerifier => 'सत्यापनकर्ता वापस लें';

  @override
  String get revokeReasonPrompt => 'यह स्थिति क्यों वापस ली जा रही है?';

  @override
  String get revokeConfirmBody =>
      'यह खाते को \'नया\' पर ले आता है और वहीं रोक देता है। स्वीकृतियाँ गिनी जाती रहेंगी पर व्यवस्थापक के बहाल करने तक पदोन्नति नहीं होगी।';

  @override
  String get revokeDone => 'स्थिति वापस ली गई और रोकी गई।';

  @override
  String get restoreTrust => 'स्थिति बहाल करें';

  @override
  String get restoreConfirmBody =>
      'यह रोक हटाता है और खाते के रिकॉर्ड से स्तर की पुनर्गणना करता है। पुराना स्तर अपने आप वापस नहीं मिलता।';

  @override
  String get restoreDone => 'रोक हटाई गई।';

  @override
  String moderationFailed(String error) {
    return 'लागू नहीं हो सका: $error';
  }

  @override
  String get yourStanding => 'आपकी स्थिति';

  @override
  String get tierNew => 'नया रिपोर्टर';

  @override
  String get tierTrusted => 'विश्वसनीय रिपोर्टर';

  @override
  String get tierVerifier => 'सत्यापनकर्ता';

  @override
  String get tierNewBody =>
      'आपकी रिपोर्ट सत्यापन के लिए व्यवस्थापक के पास जाती है।';

  @override
  String get tierTrustedBody => 'आपकी रिपोर्ट कतार में प्राथमिकता पाती है।';

  @override
  String get tierVerifierBody =>
      'आप मौजूदा सुविधाओं के अपडेट स्वीकृत कर सकते हैं। नई सुविधाएँ, अस्वीकृति और चेतावनियाँ व्यवस्थापकों के पास रहती हैं।';

  @override
  String standingCounts(int approved, int rejected) {
    return '$approved स्वीकृत · $rejected अस्वीकृत';
  }

  @override
  String standingRemaining(int count) {
    return 'अगले स्तर तक $count और स्वीकृत रिपोर्ट';
  }

  @override
  String get standingTop => 'उच्चतम स्तर प्राप्त।';

  @override
  String get verifierCannotReject => 'अस्वीकृति केवल व्यवस्थापक कर सकते हैं।';

  @override
  String get verifierNeedsAdmin => 'नई सुविधा के लिए व्यवस्थापक चाहिए।';

  @override
  String get alertSignals => 'गंभीर चेतावनी संकेत';

  @override
  String get alertVibrate => 'कंपन';

  @override
  String get alertVibrateSubtitle => 'गंभीर चेतावनी आने पर दो बार कंपन।';

  @override
  String get alertSound => 'ध्वनि';

  @override
  String get alertSoundSubtitle =>
      'डिफ़ॉल्ट रूप से बंद — अचानक बजी आवाज़ भीड़ में आपकी पहचान करा सकती है।';

  @override
  String get auditLog => 'ऑडिट लॉग';

  @override
  String get auditLogEmpty => 'अभी तक कोई व्यवस्थापक कार्रवाई दर्ज नहीं।';

  @override
  String get auditLogAppendOnly =>
      'केवल जोड़ा जा सकता है। प्रविष्टियाँ संपादित या हटाई नहीं जा सकतीं — व्यवस्थापक भी नहीं।';

  @override
  String get auditApproved => 'एक सबमिशन स्वीकृत किया';

  @override
  String get auditRejected => 'एक सबमिशन अस्वीकार किया';

  @override
  String get auditAlert => 'एक चेतावनी प्रकाशित की';

  @override
  String get auditCorroborated => 'पुष्टि द्वारा प्रकाशित';

  @override
  String get auditPromoted => 'रिपोर्टर पदोन्नत';

  @override
  String get auditDemoted => 'रिपोर्टर पदावनत';

  @override
  String get auditAutomatic => 'स्वचालित — किसी व्यवस्थापक का निर्णय नहीं';

  @override
  String auditBy(String actor) {
    return '$actor द्वारा';
  }

  @override
  String get selectMode => 'चुनें';

  @override
  String selectedCount(int count) {
    return '$count चुने गए';
  }

  @override
  String get approveSelected => 'चुने हुए स्वीकृत करें';

  @override
  String approveSelectedConfirm(int count) {
    return '$count सबमिशन स्वीकृत करें? हर एक तुरंत सार्वजनिक नक्शे पर प्रकाशित होगा।';
  }

  @override
  String batchApproved(int count) {
    return '$count स्वीकृत।';
  }

  @override
  String batchPartial(int done, int failed) {
    return '$done स्वीकृत, $failed विफल।';
  }

  @override
  String get cancel => 'रद्द करें';

  @override
  String get refresh => 'ताज़ा करें';

  @override
  String reportClosedQuestion(String name) {
    return '$name को बंद बताएँ?';
  }

  @override
  String get reportClosedBody =>
      'यह सत्यापन कतार में जाता है — व्यवस्थापक की पुष्टि के बाद नक्शा बदलता है।';

  @override
  String get reportedQueued => 'रिपोर्ट किया गया — सत्यापन के लिए कतार में।';

  @override
  String featureArrivesLater(String feature) {
    return '$feature बाद के संस्करण में आएगा।';
  }

  @override
  String reviewStatus(String status) {
    return 'स्थिति: $status';
  }

  @override
  String reviewCapacityPeople(int count) {
    return 'क्षमता: लगभग $count लोग';
  }

  @override
  String get reviewCapacityNone => 'क्षमता: निर्दिष्ट नहीं';

  @override
  String reviewUpdating(String name) {
    return 'अपडेट: $name';
  }

  @override
  String get reviewNewFacility => 'नई सुविधा';

  @override
  String reviewLocation(String lat, String lng) {
    return 'स्थान: $lat, $lng';
  }

  @override
  String get backendUnreachable => 'इस बिल्ड पर बैकएंड उपलब्ध नहीं है।';

  @override
  String get serverTryAgain => 'सर्वर तक नहीं पहुँच सके — फिर कोशिश करें।';

  @override
  String queueCardNew(String type) {
    return '$type — नई सुविधा';
  }

  @override
  String queueCardUpdate(String type) {
    return '$type — अपडेट';
  }

  @override
  String queueLoadFailed(String error) {
    return 'कतार लोड नहीं हो सकी: $error';
  }

  @override
  String approveFailed(String error) {
    return 'स्वीकृति विफल: $error';
  }

  @override
  String rejectFailed(String error) {
    return 'अस्वीकृति विफल: $error';
  }

  @override
  String get navGroups => 'समूह';

  @override
  String get groupsTitle => 'समूह';

  @override
  String get groupsSignInNeeded =>
      'समूहों के लिए ऑनलाइन और साइन-इन होना ज़रूरी है। बैकएंड सेटअप पूरा करें, फिर यह टैब दोबारा खोलें।';

  @override
  String get noGroupsYet => 'अभी कोई समूह नहीं। एक बनाएँ या कोड से जुड़ें।';

  @override
  String get createGroup => 'समूह बनाएँ';

  @override
  String get joinWithCode => 'कोड से जुड़ें';

  @override
  String get groupName => 'समूह का नाम';

  @override
  String get groupDescription => 'विवरण (वैकल्पिक)';

  @override
  String get groupVisibility => 'दृश्यता';

  @override
  String get visibilityHidden => 'छिपा हुआ';

  @override
  String get visibilityPublic => 'सार्वजनिक';

  @override
  String get create => 'बनाएँ';

  @override
  String get join => 'जुड़ें';

  @override
  String get inviteCode => 'आमंत्रण कोड';

  @override
  String get pendingApproval =>
      'अनुरोध भेजा गया — समूह सामग्री देखने से पहले व्यवस्थापक की स्वीकृति ज़रूरी है।';

  @override
  String get membershipPending => 'स्वीकृति लंबित';

  @override
  String get tabChat => 'चैट';

  @override
  String get tabMembers => 'सदस्य';

  @override
  String get tabPins => 'सुविधाएँ';

  @override
  String get messageHint => 'संदेश (एंड-टू-एंड एन्क्रिप्टेड)';

  @override
  String get e2eNotice =>
      'संदेश एंड-टू-एंड एन्क्रिप्टेड हैं — केवल समूह सदस्य ही पढ़ सकते हैं।';

  @override
  String get cantDecrypt => 'यह संदेश डिक्रिप्ट नहीं हो सका।';

  @override
  String get send => 'भेजें';

  @override
  String get approveMember => 'स्वीकृत करें';

  @override
  String get admin => 'व्यवस्थापक';

  @override
  String get member => 'सदस्य';

  @override
  String get removeMember => 'हटाएँ';

  @override
  String removeMemberTitle(String name) {
    return '$name को हटाएँ?';
  }

  @override
  String get removeMemberBody =>
      'उनकी इस समूह तक पहुँच समाप्त हो जाएगी और नई एन्क्रिप्शन कुंजी जारी होगी, इसलिए अब से भेजे गए संदेश वे नहीं पढ़ पाएँगे। जो संदेश उन्हें पहले मिल चुके हैं, वे उनके डिवाइस पर बने रहेंगे।';

  @override
  String get memberRemoved =>
      'हटा दिया गया। समूह को नई एन्क्रिप्शन कुंजी जारी की गई।';

  @override
  String rekeyWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count सदस्यों की डिवाइस कुंजी अभी नहीं है; ऐप खोलने तक उन्हें नई कुंजी नहीं मिलेगी।',
      one:
          '1 सदस्य की डिवाइस कुंजी अभी नहीं है; ऐप खोलने तक उन्हें नई कुंजी नहीं मिलेगी।',
    );
    return '$_temp0';
  }

  @override
  String get invite => 'आमंत्रण';

  @override
  String inviteCreated(String code) {
    return 'आमंत्रण कोड (24 घंटे, 10 उपयोग): $code';
  }

  @override
  String get addAmenity => 'सुविधा जोड़ें';

  @override
  String get amenityLabel => 'नाम';

  @override
  String get noAmenities => 'अभी कोई समूह सुविधा नहीं।';

  @override
  String get noMessages => 'अभी कोई संदेश नहीं। नमस्ते कहें।';

  @override
  String get chatOffline => 'ऑफ़लाइन — सहेजे गए संदेश दिखाए जा रहे हैं';

  @override
  String get broadcast => 'प्रसारण';

  @override
  String broadcastTitle(String group) {
    return '$group को प्रसारण';
  }

  @override
  String get broadcastHint =>
      'इस समूह के सभी सदस्य इसे चैट के ऊपर और अलर्ट में देखेंगे।';

  @override
  String get broadcastSend => 'प्रसारण भेजें';

  @override
  String get broadcastSeverity => 'तात्कालिकता';

  @override
  String get groupBroadcasts => 'आपके समूहों से';

  @override
  String get groupBroadcastNote => 'समूह प्रसारण · केवल सदस्यों के लिए';

  @override
  String get messageSending => 'भेजा जा रहा है…';

  @override
  String groupActionFailed(String error) {
    return 'कार्य विफल: $error';
  }

  @override
  String get eventLive => 'लाइव';

  @override
  String get eventToday => 'आज';

  @override
  String get eventUpcoming => 'आगामी';

  @override
  String get eventVerified => 'सत्यापित';

  @override
  String get eventDetails => 'विवरण';

  @override
  String eventDetailsSoon(String title) {
    return '$title — विवरण इवेंट्स बिल्ड के साथ आएगा।';
  }

  @override
  String get eventMainTitle => 'मुख्य सभा — जंतर मंतर';

  @override
  String get eventMainNote =>
      'शाम 6 बजे तक अधिक भीड़ रहेगी। गेट 1 और 3 पर पानी उपलब्ध।';

  @override
  String get eventMainLocation => 'जंतर मंतर रोड';

  @override
  String get eventMedicalTitle => 'चिकित्सा स्वयंसेवक बैठक';

  @override
  String get eventMedicalNote =>
      'सभी प्राथमिक-उपचार स्वयंसेवकों के लिए शिफ्ट और सामान की जाँच।';

  @override
  String get eventMedicalLocation => 'प्राथमिक उपचार तंबू (मुख्य)';

  @override
  String get eventMedicalTime => 'दोपहर 3:00 बजे से';

  @override
  String get eventLegalTitle => 'कानूनी सहायता डेस्क';

  @override
  String get eventLegalNote =>
      'हिरासत संबंधी सवालों के लिए स्वयंसेवक वकील उपलब्ध।';

  @override
  String get eventLegalLocation => 'गेट 2 पवेलियन';

  @override
  String get eventLegalTime => 'शाम 4:30 बजे से';

  @override
  String get eventLangarTitle => 'सामुदायिक लंगर';

  @override
  String get eventLangarNote =>
      'लगभग 500 लोगों के लिए भोजन; सुबह 10 बजे से स्वयंसेवक चाहिए।';

  @override
  String get eventLangarLocation => 'पार्लियामेंट स्ट्रीट कोना';

  @override
  String get eventLangarTime => 'कल, दोपहर 12:00 बजे';

  @override
  String get eventLiveNow => 'अभी लाइव';

  @override
  String get jumpToSite => 'किसी स्थल पर जाएँ';

  @override
  String get eventDelhiSitInTitle => 'रात भर का धरना';

  @override
  String get eventDelhiSitInNote =>
      'गर्म कपड़े साथ लाएँ; रात 9 बजे के बाद छाया टेंट सोने के लिए इस्तेमाल होंगे।';

  @override
  String get eventDelhiSitInLocation => 'जंतर मंतर, नई दिल्ली';

  @override
  String get eventDelhiSitInTime => 'आज रात 9:00 बजे';

  @override
  String get eventLondonTitle => 'पार्लियामेंट स्क्वायर सभा';

  @override
  String get eventLondonNote =>
      'गांधी प्रतिमा से भाषण। कानूनी पर्यवेक्षक नारंगी जैकेट में।';

  @override
  String get eventLondonLocation => 'पार्लियामेंट स्क्वायर, लंदन';

  @override
  String get eventLondonTime => 'अभी लाइव';

  @override
  String get eventLondonLegalTitle => 'अपने अधिकार जानें — सत्र';

  @override
  String get eventLondonLegalNote =>
      'रोक-तलाशी और हिरासत में क्या करें, इस पर छोटा सत्र।';

  @override
  String get eventLondonLegalLocation => 'वेस्टमिंस्टर ब्रिज उत्तरी छोर, लंदन';

  @override
  String get eventLondonLegalTime => 'शाम 5:00 बजे से';

  @override
  String get eventBengaluruTitle => 'टाउन हॉल सभा';

  @override
  String get eventBengaluruNote =>
      'स्थल पर पानी का टैंकर और सामुदायिक भोजन काउंटर।';

  @override
  String get eventBengaluruLocation => 'टाउन हॉल, बेंगलुरु';

  @override
  String get eventBengaluruTime => 'अभी लाइव';

  @override
  String get eventBengaluruWaterTitle => 'छाया टेंट लगाना';

  @override
  String get eventBengaluruWaterNote =>
      'दोपहर की गर्मी से पहले छह और टेंट लगाने के लिए स्वयंसेवक चाहिए।';

  @override
  String get eventBengaluruWaterLocation => 'जेसी रोड की ओर, बेंगलुरु';

  @override
  String get eventBengaluruWaterTime => 'कल सुबह 7:00 बजे';

  @override
  String get pickOnMap => 'नक्शे पर रखें';

  @override
  String get pickAmenityHint =>
      'इस सुविधा को रखने के लिए नक्शा खींचें, फिर पुष्टि करें।';

  @override
  String get confirmLocation => 'स्थान की पुष्टि करें';

  @override
  String get showGroupPins => 'समूह सुविधाएँ दिखाएँ';

  @override
  String get groupPinsLayer => 'समूह सुविधाएँ';

  @override
  String groupPinFrom(String group, String label) {
    return '$group · $label';
  }

  @override
  String get scanInvite => 'आमंत्रण QR स्कैन करें';

  @override
  String get scanInviteHint =>
      'कैमरे को आमंत्रण QR पर रखें। स्वीकृति फिर भी व्यवस्थापक से लेनी होगी।';

  @override
  String get scanUnavailable =>
      'ब्राउज़र में कैमरा स्कैन उपलब्ध नहीं है। कोड माँगकर दर्ज करें।';

  @override
  String scanFailed(String error) {
    return 'कैमरा उपलब्ध नहीं ($error)। कोड दर्ज करें।';
  }

  @override
  String get enterCodeInstead => 'इसके बजाय कोड दर्ज करें';

  @override
  String get scan => 'स्कैन';

  @override
  String get inviteScanHint =>
      'उनसे यह QR स्कैन करवाएँ, या नीचे दिया कोड साझा करें।';

  @override
  String get inviteExpiry =>
      '24 घंटे में समाप्त · अधिकतम 10 उपयोग · व्यवस्थापक की स्वीकृति फिर भी ज़रूरी';

  @override
  String get inviteCopied => 'आमंत्रण कोड कॉपी हुआ';

  @override
  String get copyCode => 'कोड कॉपी करें';

  @override
  String get done => 'हो गया';

  @override
  String get panicWipe => 'आपातकालीन मिटाव';

  @override
  String get panicWipeSubtitle =>
      'इस डिवाइस से कुंजियाँ, सहेजी गई चैट और स्थानीय रिपोर्ट मिटाएँ, और साइन आउट करें।';

  @override
  String get panicWipeConfirmTitle => 'इस डिवाइस से सब कुछ मिटाएँ?';

  @override
  String get panicWipeConfirmBody =>
      'यह आपकी एन्क्रिप्शन कुंजियाँ, सहेजी गई समूह चैट, कतार में पड़ी रिपोर्ट और आपका सत्र मिटा देता है। जो चैट आप फिर डिक्रिप्ट नहीं कर पाएँगे, वह इस डिवाइस पर हमेशा के लिए चली जाएगी।\n\nयह सर्वर या दूसरे सदस्यों के डिवाइस तक नहीं पहुँच सकता: पहले पहुँच चुके संदेश वहीं रहेंगे, और सर्वर पर आपकी सदस्यता बनी रहेगी।';

  @override
  String get panicWipeConfirm => 'अभी मिटाएँ';

  @override
  String get panicWipeDone =>
      'मिटा दिया गया। इस डिवाइस पर कोई कुंजी, चैट या रिपोर्ट नहीं है।';

  @override
  String panicWipeFailed(String error) {
    return 'मिटाव विफल: $error';
  }

  @override
  String get webLimitedTitle => 'ब्राउज़र संस्करण — केवल आज़माने के लिए';

  @override
  String get webLimitedBody =>
      'यह बिल्ड ब्राउज़र में चलता है, इसलिए यह फ़ोन की सुरक्षित कुंजी-स्टोरेज, ऑफ़लाइन नक्शा कैश या कैमरा उपयोग नहीं कर सकता। एन्क्रिप्शन कुंजियाँ ब्राउज़र स्टोरेज में रहती हैं, जिन्हें ऐप न खोलने पर Safari लगभग एक सप्ताह बाद हटा सकता है — तब समूह चैट का इतिहास स्थायी रूप से चला जाएगा। वास्तविक उपयोग के लिए इंस्टॉल किया गया ऐप ही उपयोग करें।';

  @override
  String get demoMode => 'डेमो मोड';

  @override
  String get demoModeSubtitle =>
      'हर स्क्रीन को नमूना डेटा के साथ देखें — बैकएंड या लॉगिन की ज़रूरत नहीं। लाइव बैकएंड के लिए बंद करें।';
}
