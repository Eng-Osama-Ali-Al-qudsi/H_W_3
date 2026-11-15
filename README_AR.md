# مشروع Student Auth بنسختين: GetX وProvider

## محتويات الحزمة

- `student_auth_app_getx/`: نسخة GetX.
- `student_auth_app_provider/`: نسخة Provider.

كل نسخة مشروع Flutter مستقل. المشروع الأصلي الذي أرسلته لم يتم تعديله؛ هذه نسخ مشتقة منه.

## أهم الفروق عند دراسة الكود

| المفهوم | GetX | Provider |
|---|---|---|
| كلاس الحالة | `AuthController extends GetxController` | `AuthProvider extends ChangeNotifier` |
| تسجيل الحالة | `AppBinding` + `Get.put` | `MultiProvider` + `ChangeNotifierProvider` |
| الحصول على الحالة | `Get.find<AuthController>()` | `context.watch/read<AuthProvider>()` |
| المتغيرات | `RxBool`, `Rxn<T>` | حقول Dart عادية وgetters |
| تحديث الواجهة | `.value` يتغير داخل `Obx` | `notifyListeners()` ثم `watch` يعيد البناء |
| دورة الحياة | يديرها GetX وفق التسجيل وسياسة SmartManagement؛ هنا اعتمدنا permanent لحالة التطبيق | `ChangeNotifierProvider` يتولى dispose للكائن الذي أنشأه عبر create |

## التشغيل

من داخل مجلد كل نسخة نفّذ:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## طريقة الدراسة المقترحة

1. افتح `main.dart` في النسختين وقارن طريقة توفير الاعتماديات.
2. قارن `AuthController` مع `AuthProvider`.
3. افتح `login_page.dart` وقارن استدعاء الحالة.
4. تتبع عملية تسجيل الدخول من الصفحة إلى Controller/Provider ثم Repository.
5. قارن طريقة عرض `isLoading` ورسائل الخطأ والنجاح.
6. شغّل الاختبارات في كل نسخة وقارن النتائج.

## تنبيه حول المشروع

حافظنا على سلوك المشروع الأصلي: حسابات تجريبية في الذاكرة، تأخير شبكة محاكى، ورمز OTP تجريبي `123456`. لا توجد خدمة Backend أو إرسال بريد حقيقي.

## ملاحظة التحقق

تم تجهيز الملفات والتحويلات ومراجعة التغييرات نصيًا. بيئة العمل الحالية لا تحتوي على Flutter/Dart SDK، لذلك لم أتمكن من تشغيل `flutter pub get`, `flutter analyze` أو `flutter test` هنا. نفّذ الأوامر أعلاه في بيئة Flutter لديك قبل اعتماد النسخ نهائيًا؛ لا أصف الاختبارات بأنها ناجحة قبل تشغيلها.
