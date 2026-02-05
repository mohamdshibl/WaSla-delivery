// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'وصلة';

  @override
  String get welcome => 'مرحباً بك مجدداً';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get displayName => 'الاسم الشخصي';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get darkMode => 'الوضعية الليلية';

  @override
  String get enabled => 'مفعل';

  @override
  String get disabled => 'معطل';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get orderHistory => 'سجل الطلبات (المنفذة)';

  @override
  String get noOrdersYet => 'لا توجد طلبات بعد. ابدأ بإنشاء طلب جديد!';

  @override
  String get noDeliveredOrders => 'لا توجد طلبات منفذة بعد';

  @override
  String get createOrder => 'إنشاء طلب';

  @override
  String errorLoadingOrders(String error) {
    return 'خطأ في تحميل الطلبات: $error';
  }

  @override
  String get language => 'اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get nameCannotBeEmpty => 'لا يمكن ترك الاسم فارغاً';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي!';

  @override
  String anErrorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get enterYourName => 'أدخل اسمك';

  @override
  String get user => 'مستخدم';

  @override
  String get newOrder => 'طلب جديد';

  @override
  String get waslaVendor => 'وصلة - مزود';

  @override
  String get waslaHome => 'وصلة - الرئيسي';

  @override
  String welcomeBackUser(String name) {
    return 'مرحباً بك مجدداً، $name!';
  }

  @override
  String get myActiveOrders => 'طلباتي النشطة';

  @override
  String get availableForDelivery => 'طلبات متاحة للتوصيل';

  @override
  String get noNewOrdersAvailable => 'لا توجد طلبات جديدة متاحة';

  @override
  String get notLoggedIn => 'لم يتم تسجيل الدخول';

  @override
  String get friend => 'صديقنا';

  @override
  String errorLoadingHistory(String error) {
    return 'خطأ في تحميل السجل: $error';
  }

  @override
  String get noActiveOrders => 'لا توجد طلبات نشطة';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusAccepted => 'تم القبول';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusUnknown => 'غير معروف';

  @override
  String deliveredBy(String name) {
    return 'تم التوصيل بواسطة $name';
  }

  @override
  String get provider => 'المزود';

  @override
  String get noOrdersFound => 'لم يتم العثور على طلبات';

  @override
  String get customerLabel => 'العميل';

  @override
  String get unknownCustomer => 'عميل غير معروف';

  @override
  String get errorLoadingName => 'خطأ في تحميل الاسم';

  @override
  String get acceptOrder => 'قبول الطلب';

  @override
  String get orderAccepted => 'تم قبول الطلب!';

  @override
  String failedToAccept(String error) {
    return 'فشل: $error';
  }

  @override
  String orderIdLabel(String id) {
    return 'طلب رقم $id';
  }

  @override
  String get statusPickedUp => 'تم الاستلام';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get chat => 'المحادثة';

  @override
  String get pickUp => 'استلام';

  @override
  String get deliver => 'توصيل';

  @override
  String get statusUpdated => 'تم تحديث الحالة!';

  @override
  String failedToUpdateStatus(String error) {
    return 'فشل في تحديث الحالة: $error';
  }

  @override
  String get orderNotFound => 'الطلب غير موجود';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get chatWithProvider => 'تحدث مع المزود';

  @override
  String get chatWithCustomer => 'تحدث مع العميل';

  @override
  String get chatWithSupport => 'تحدث مع الدعم الفني';

  @override
  String get updatedJustNow => 'تم التحديث الآن';

  @override
  String get newDelivery => 'تسجيل طلب جديد';

  @override
  String get whatCanWeGetYou => 'ماذا يمكننا أن نوفر لك؟';

  @override
  String get itemDescription => 'وصف الطلب';

  @override
  String get supportingPhotos => 'صور توضيحية';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'المعرض';

  @override
  String get postMyOrder => 'نشر الطلب';

  @override
  String get orderCreatedSuccessfully => 'تم إنشاء الطلب بنجاح!';

  @override
  String get pleaseEnterWhatYouNeed => 'يرجى إدخال وصف للطلب';

  @override
  String get customer => 'العميل';

  @override
  String get noMessagesYet => 'لا توجد رسائل بعد';

  @override
  String get startConversation => 'ابدأ المحادثة الآن!';

  @override
  String get typeAMessage => 'اكتب رسالة...';

  @override
  String get price => 'السعر';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get totalEarnings => 'إجمالي الأرباح';

  @override
  String get wallet => 'المحفظة';

  @override
  String get myEarnings => 'أرباحي';

  @override
  String get estimatedFee => 'الرسوم التقديرية';

  @override
  String get totalPrice => 'السعر الإجمالي';

  @override
  String get currency => 'ج.م';
}
