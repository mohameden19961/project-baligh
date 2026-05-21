// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'بلّغ';

  @override
  String get appTagline => 'صوتك يصنع الفرق';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get french => 'الفرنسية';

  @override
  String get continueButton => 'متابعة';

  @override
  String get saveButton => 'حفظ';

  @override
  String get cancelButton => 'إلغاء';

  @override
  String get deleteButton => 'حذف';

  @override
  String get confirmButton => 'تأكيد';

  @override
  String get backButton => 'رجوع';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'تم بنجاح';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navMap => 'الخريطة';

  @override
  String get navReport => 'إبلاغ';

  @override
  String get navMyReports => 'تقاريري';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get homeWelcome => 'مرحباً بك في بلّغ';

  @override
  String get homeSubtitle => 'ساهم في تحسين مدينتك بالإبلاغ عن المشكلات';

  @override
  String get homeRecentReports => 'أحدث البلاغات';

  @override
  String get homeNoReports => 'لا توجد بلاغات حتى الآن. كن أول من يبلّغ!';

  @override
  String get homeQuickReport => 'بلاغ سريع';

  @override
  String get homeViewMap => 'عرض الخريطة';

  @override
  String get reportTitle => 'إنشاء بلاغ جديد';

  @override
  String get reportCategory => 'فئة المشكلة';

  @override
  String get reportSelectCategory => 'اختر فئة';

  @override
  String get reportDescription => 'وصف المشكلة';

  @override
  String get reportDescriptionHint => 'اشرح المشكلة بالتفصيل...';

  @override
  String get reportLocation => 'الموقع';

  @override
  String get reportLocationHint => 'اختر الموقع على الخريطة';

  @override
  String get reportPhoto => 'صورة المشكلة';

  @override
  String get reportAddPhoto => 'إضافة صورة';

  @override
  String get reportChangePhoto => 'تغيير الصورة';

  @override
  String get reportSubmit => 'إرسال البلاغ';

  @override
  String get reportSubmitSuccess => 'تم إرسال بلاغك بنجاح!';

  @override
  String get reportSubmitError => 'فشل إرسال البلاغ. حاول مجدداً.';

  @override
  String get reportValidationCategory => 'الرجاء اختيار فئة المشكلة';

  @override
  String get reportValidationDescription => 'الرجاء إدخال وصف للمشكلة';

  @override
  String get reportValidationLocation => 'الرجاء تحديد موقع المشكلة';

  @override
  String get categoryRoads => 'طرق وأرصفة';

  @override
  String get categoryLighting => 'إنارة عامة';

  @override
  String get categoryWaste => 'نفايات وصرف صحي';

  @override
  String get categoryWater => 'ماء وكهرباء';

  @override
  String get categoryParks => 'حدائق ومساحات خضراء';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusInProgress => 'قيد المعالجة';

  @override
  String get statusResolved => 'تم الحل';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get myReportsTitle => 'تقاريري';

  @override
  String get myReportsEmpty => 'لم تقم بإنشاء أي بلاغات بعد.';

  @override
  String get myReportsFilter => 'تصفية';

  @override
  String get myReportsAll => 'الكل';

  @override
  String get reportDetailTitle => 'تفاصيل البلاغ';

  @override
  String get reportDetailDate => 'تاريخ الإبلاغ';

  @override
  String get reportDetailStatus => 'الحالة';

  @override
  String get reportDetailCategory => 'الفئة';

  @override
  String get reportDetailDescription => 'الوصف';

  @override
  String get reportDetailLocation => 'الموقع';

  @override
  String get mapTitle => 'خريطة البلاغات';

  @override
  String get mapFilterAll => 'الكل';

  @override
  String get mapLoading => 'جارٍ تحميل الخريطة...';

  @override
  String get mapNoLocation => 'تعذّر تحديد موقعك';

  @override
  String get mapSelectLocation => 'اضغط لتحديد الموقع';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsNotificationsSubtitle =>
      'استقبل إشعارات عند تحديث بلاغاتك';

  @override
  String get settingsAbout => 'عن التطبيق';

  @override
  String get settingsVersion => 'الإصدار';

  @override
  String get settingsPrivacy => 'سياسة الخصوصية';

  @override
  String get settingsContact => 'تواصل معنا';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'تلقائي';

  @override
  String get permissionLocationTitle => 'إذن الموقع';

  @override
  String get permissionLocationMessage =>
      'يحتاج التطبيق إلى إذن الوصول لموقعك لتحديد مكان المشكلة بدقة.';

  @override
  String get permissionLocationGrant => 'منح الإذن';

  @override
  String get permissionLocationDeny => 'رفض';

  @override
  String get navAlerts => 'تنبيهات';

  @override
  String get navAccount => 'حسابي';

  @override
  String get networkError => 'تعذّر الاتصال بالشبكة. تحقق من اتصالك بالإنترنت.';

  @override
  String get unknownError => 'حدث خطأ غير متوقع. حاول مجدداً.';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count بلاغ',
      many: '$count بلاغاً',
      few: '$count بلاغات',
      two: 'بلاغان',
      one: 'بلاغ واحد',
      zero: 'لا توجد بلاغات',
    );
    return '$_temp0';
  }

  @override
  String timeAgoMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      many: 'منذ $count دقيقة',
      few: 'منذ $count دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة',
    );
    return '$_temp0';
  }

  @override
  String timeAgoHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count ساعة',
      many: 'منذ $count ساعة',
      few: 'منذ $count ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة',
    );
    return '$_temp0';
  }

  @override
  String timeAgoDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوم',
      many: 'منذ $count يوماً',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
      one: 'منذ يوم',
    );
    return '$_temp0';
  }
}
