import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('ar'),
    Locale('fr')
  ];

  /// The name of the application
  ///
  /// In ar, this message translates to:
  /// **'بلّغ'**
  String get appName;

  /// App tagline shown on splash/onboarding
  ///
  /// In ar, this message translates to:
  /// **'صوتك يصنع الفرق'**
  String get appTagline;

  /// Language setting label
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// Arabic language option
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// French language option
  ///
  /// In ar, this message translates to:
  /// **'الفرنسية'**
  String get french;

  /// Generic continue button
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueButton;

  /// Generic save button
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get saveButton;

  /// Generic cancel button
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelButton;

  /// Generic delete button
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteButton;

  /// Generic confirm button
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirmButton;

  /// Generic back button
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get backButton;

  /// Generic loading indicator text
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get loading;

  /// Generic error label
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// Generic success label
  ///
  /// In ar, this message translates to:
  /// **'تم بنجاح'**
  String get success;

  /// Retry button label
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// Bottom nav: Home tab
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// Bottom nav: Map tab
  ///
  /// In ar, this message translates to:
  /// **'الخريطة'**
  String get navMap;

  /// Bottom nav: Report tab
  ///
  /// In ar, this message translates to:
  /// **'إبلاغ'**
  String get navReport;

  /// Bottom nav: My Reports tab
  ///
  /// In ar, this message translates to:
  /// **'تقاريري'**
  String get navMyReports;

  /// Bottom nav: Settings tab
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// Home screen welcome title
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في بلّغ'**
  String get homeWelcome;

  /// Home screen subtitle
  ///
  /// In ar, this message translates to:
  /// **'ساهم في تحسين مدينتك بالإبلاغ عن المشكلات'**
  String get homeSubtitle;

  /// Section title for recent reports on home
  ///
  /// In ar, this message translates to:
  /// **'أحدث البلاغات'**
  String get homeRecentReports;

  /// Empty state message on home screen
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بلاغات حتى الآن. كن أول من يبلّغ!'**
  String get homeNoReports;

  /// Quick report button label on home
  ///
  /// In ar, this message translates to:
  /// **'بلاغ سريع'**
  String get homeQuickReport;

  /// View map button on home
  ///
  /// In ar, this message translates to:
  /// **'عرض الخريطة'**
  String get homeViewMap;

  /// Title for the create report screen
  ///
  /// In ar, this message translates to:
  /// **'إنشاء بلاغ جديد'**
  String get reportTitle;

  /// Report form: category field label
  ///
  /// In ar, this message translates to:
  /// **'فئة المشكلة'**
  String get reportCategory;

  /// Report form: category hint text
  ///
  /// In ar, this message translates to:
  /// **'اختر فئة'**
  String get reportSelectCategory;

  /// Report form: description field label
  ///
  /// In ar, this message translates to:
  /// **'وصف المشكلة'**
  String get reportDescription;

  /// Report form: description hint text
  ///
  /// In ar, this message translates to:
  /// **'اشرح المشكلة بالتفصيل...'**
  String get reportDescriptionHint;

  /// Report form: location field label
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get reportLocation;

  /// Report form: location hint text
  ///
  /// In ar, this message translates to:
  /// **'اختر الموقع على الخريطة'**
  String get reportLocationHint;

  /// Report form: photo field label
  ///
  /// In ar, this message translates to:
  /// **'صورة المشكلة'**
  String get reportPhoto;

  /// Report form: add photo button
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get reportAddPhoto;

  /// Report form: change photo button
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get reportChangePhoto;

  /// Report form: submit button
  ///
  /// In ar, this message translates to:
  /// **'إرسال البلاغ'**
  String get reportSubmit;

  /// Success message after submitting a report
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال بلاغك بنجاح!'**
  String get reportSubmitSuccess;

  /// Error message when report submission fails
  ///
  /// In ar, this message translates to:
  /// **'فشل إرسال البلاغ. حاول مجدداً.'**
  String get reportSubmitError;

  /// Validation message for category field
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار فئة المشكلة'**
  String get reportValidationCategory;

  /// Validation message for description field
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال وصف للمشكلة'**
  String get reportValidationDescription;

  /// Validation message for location field
  ///
  /// In ar, this message translates to:
  /// **'الرجاء تحديد موقع المشكلة'**
  String get reportValidationLocation;

  /// Report category: Electricity
  ///
  /// In ar, this message translates to:
  /// **'كهرباء'**
  String get categoryElectricity;

  /// Report category: Road
  ///
  /// In ar, this message translates to:
  /// **'طرق'**
  String get categoryRoad;

  /// Report category: Flood
  ///
  /// In ar, this message translates to:
  /// **'فيضانات'**
  String get categoryFlood;

  /// Report category: Security
  ///
  /// In ar, this message translates to:
  /// **'أمن'**
  String get categorySecurity;

  /// Report category: Water
  ///
  /// In ar, this message translates to:
  /// **'ماء'**
  String get categoryWater;

  /// Report category: Health
  ///
  /// In ar, this message translates to:
  /// **'صحة'**
  String get categoryHealth;

  /// Report category: Internet
  ///
  /// In ar, this message translates to:
  /// **'إنترنت'**
  String get categoryInternet;

  /// Report category: Market
  ///
  /// In ar, this message translates to:
  /// **'أسواق'**
  String get categoryMarket;

  /// Report category: Government
  ///
  /// In ar, this message translates to:
  /// **'حكومة'**
  String get categoryGovernment;

  /// Report category: Fire
  ///
  /// In ar, this message translates to:
  /// **'حرائق'**
  String get categoryFire;

  /// Report category: Infrastructure
  ///
  /// In ar, this message translates to:
  /// **'بنية تحتية'**
  String get categoryInfrastructure;

  /// Report category: Fraud
  ///
  /// In ar, this message translates to:
  /// **'احتيال'**
  String get categoryFraud;

  /// Report status: Pending
  ///
  /// In ar, this message translates to:
  /// **'قيد الانتظار'**
  String get statusPending;

  /// Report status: Validated
  ///
  /// In ar, this message translates to:
  /// **'موثّق'**
  String get statusValidated;

  /// Report status: False Report
  ///
  /// In ar, this message translates to:
  /// **'بلاغ كاذب'**
  String get statusFalseReport;

  /// My Reports screen title
  ///
  /// In ar, this message translates to:
  /// **'تقاريري'**
  String get myReportsTitle;

  /// Empty state for my reports screen
  ///
  /// In ar, this message translates to:
  /// **'لم تقم بإنشاء أي بلاغات بعد.'**
  String get myReportsEmpty;

  /// Filter button label on my reports
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get myReportsFilter;

  /// Filter: All reports
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get myReportsAll;

  /// Report detail screen title
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل البلاغ'**
  String get reportDetailTitle;

  /// Report detail: date label
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإبلاغ'**
  String get reportDetailDate;

  /// Report detail: status label
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get reportDetailStatus;

  /// Report detail: category label
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get reportDetailCategory;

  /// Report detail: description label
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get reportDetailDescription;

  /// Report detail: location label
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get reportDetailLocation;

  /// Map screen title
  ///
  /// In ar, this message translates to:
  /// **'خريطة البلاغات'**
  String get mapTitle;

  /// Map filter: All reports
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get mapFilterAll;

  /// Map loading message
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحميل الخريطة...'**
  String get mapLoading;

  /// Map: error getting user location
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد موقعك'**
  String get mapNoLocation;

  /// Map: instruction to select a location
  ///
  /// In ar, this message translates to:
  /// **'اضغط لتحديد الموقع'**
  String get mapSelectLocation;

  /// Settings screen title
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// Settings: language section label
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// Settings: notifications toggle label
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get settingsNotifications;

  /// Settings: notifications subtitle
  ///
  /// In ar, this message translates to:
  /// **'استقبل إشعارات عند تحديث بلاغاتك'**
  String get settingsNotificationsSubtitle;

  /// Settings: about section label
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get settingsAbout;

  /// Settings: app version label
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get settingsVersion;

  /// Settings: privacy policy label
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get settingsPrivacy;

  /// Settings: contact us label
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get settingsContact;

  /// Settings: theme label
  ///
  /// In ar, this message translates to:
  /// **'المظهر'**
  String get settingsTheme;

  /// Settings: light theme
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get settingsThemeLight;

  /// Settings: dark theme
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get settingsThemeDark;

  /// Settings: system theme
  ///
  /// In ar, this message translates to:
  /// **'تلقائي'**
  String get settingsThemeSystem;

  /// Location permission dialog title
  ///
  /// In ar, this message translates to:
  /// **'إذن الموقع'**
  String get permissionLocationTitle;

  /// Location permission dialog message
  ///
  /// In ar, this message translates to:
  /// **'يحتاج التطبيق إلى إذن الوصول لموقعك لتحديد مكان المشكلة بدقة.'**
  String get permissionLocationMessage;

  /// Grant location permission button
  ///
  /// In ar, this message translates to:
  /// **'منح الإذن'**
  String get permissionLocationGrant;

  /// Deny location permission button
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get permissionLocationDeny;

  /// No description provided for @navAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات'**
  String get navAlerts;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navAccount;

  /// Alerts/Notifications screen title
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get alertsTitle;

  /// Empty state for alerts screen
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات'**
  String get alertsEmpty;

  /// Alert type: report status updated
  ///
  /// In ar, this message translates to:
  /// **'تحديث حالة البلاغ'**
  String get alertStatusUpdate;

  /// Alert type: new report nearby
  ///
  /// In ar, this message translates to:
  /// **'بلاغ جديد في منطقتك'**
  String get alertNewReport;

  /// Tooltip: mark all alerts as read
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل كمقروء'**
  String get alertMarkAllRead;

  /// Generic alert/notification tile title
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get alertTileTitle;

  /// Account: join date label
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الانضمام'**
  String get accountJoinDate;

  /// Account: reports count label
  ///
  /// In ar, this message translates to:
  /// **'البلاغات المقدمة'**
  String get accountReportsSubmitted;

  /// Account: settings button
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get accountSettings;

  /// Account: emergency numbers button
  ///
  /// In ar, this message translates to:
  /// **'أرقام الطوارئ'**
  String get accountEmergencyNumbers;

  /// Account: logout button
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get accountLogout;

  /// Report detail: confirm vote button
  ///
  /// In ar, this message translates to:
  /// **'صحيح'**
  String get reportDetailVoteConfirm;

  /// Report detail: reject vote button
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get reportDetailVoteReject;

  /// Report detail: vote success message
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل صوتك!'**
  String get reportDetailVoteSuccess;

  /// Report detail: vote error message
  ///
  /// In ar, this message translates to:
  /// **'فشل تسجيل الصوت. حاول مجدداً.'**
  String get reportDetailVoteError;

  /// Report detail: credibility section label
  ///
  /// In ar, this message translates to:
  /// **'المصداقية'**
  String get reportDetailCredibility;

  /// Report detail: open map button
  ///
  /// In ar, this message translates to:
  /// **'فتح على الخريطة'**
  String get reportDetailOpenMap;

  /// Emergency numbers screen title
  ///
  /// In ar, this message translates to:
  /// **'أرقام الطوارئ'**
  String get emergencyTitle;

  /// Emergency: police
  ///
  /// In ar, this message translates to:
  /// **'الشرطة'**
  String get emergencyPolice;

  /// Emergency: ambulance
  ///
  /// In ar, this message translates to:
  /// **'الإسعاف'**
  String get emergencyAmbulance;

  /// Emergency: fire department
  ///
  /// In ar, this message translates to:
  /// **'الدفاع المدني'**
  String get emergencyFire;

  /// Emergency: civil protection
  ///
  /// In ar, this message translates to:
  /// **'الحماية المدنية'**
  String get emergencyCivilProtection;

  /// Emergency: call button
  ///
  /// In ar, this message translates to:
  /// **'اتصال'**
  String get emergencyCall;

  /// Splash screen title
  ///
  /// In ar, this message translates to:
  /// **'بلّغ لايت'**
  String get splashTitle;

  /// Splash screen subtitle
  ///
  /// In ar, this message translates to:
  /// **'صوتك يصنع الفرق'**
  String get splashSubtitle;

  /// Splash: start button
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get splashStart;

  /// Splash: skip button
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get splashSkip;

  /// Generic network error message
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الاتصال بالشبكة. تحقق من اتصالك بالإنترنت.'**
  String get networkError;

  /// Generic unknown error message
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ غير متوقع. حاول مجدداً.'**
  String get unknownError;

  /// Login button label
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// Register button label
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get register;

  /// Email field label
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get email;

  /// Password field label
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// Username field label
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// Confirm password field label
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPassword;

  /// Pluralized report count
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد بلاغات} =1{بلاغ واحد} =2{بلاغان} few{{count} بلاغات} many{{count} بلاغاً} other{{count} بلاغ}}'**
  String reportCount(int count);

  /// Elapsed time in minutes (e.g. 'منذ 5 دقائق')
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منذ دقيقة} =2{منذ دقيقتين} few{منذ {count} دقائق} many{منذ {count} دقيقة} other{منذ {count} دقيقة}}'**
  String timeAgoMinutes(int count);

  /// Elapsed time in hours (e.g. 'منذ 3 ساعات')
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منذ ساعة} =2{منذ ساعتين} few{منذ {count} ساعات} many{منذ {count} ساعة} other{منذ {count} ساعة}}'**
  String timeAgoHours(int count);

  /// Elapsed time in days (e.g. 'منذ 4 أيام')
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{منذ يوم} =2{منذ يومين} few{منذ {count} أيام} many{منذ {count} يوماً} other{منذ {count} يوم}}'**
  String timeAgoDays(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
