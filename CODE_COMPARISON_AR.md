# دليل مقارنة الكود: GetX مقابل Provider

هذا الملف يربط المفاهيم التي درستها بالملفات الفعلية داخل النسختين.

## 1. أين توجد إدارة الحالة؟

| المهمة | GetX | Provider |
|---|---|---|
| كلاس الحالة | `student_auth_app_getx/lib/controllers/auth_controller.dart` | `student_auth_app_provider/lib/providers/auth_provider.dart` |
| تسجيل الاعتماديات | `lib/bindings/app_binding.dart` | `lib/main.dart` داخل `MultiProvider` |
| صفحة تسجيل الدخول | `lib/views/auth/login_page.dart` | `lib/views/auth/login_page.dart` |
| مصدر البيانات | `lib/repositories/auth_repository_impl.dart` في النسختين | نفس الملف والمنطق |

## 2. تعريف الحالة

### GetX

```dart
final RxBool isLoading = false.obs;
final Rxn<UserModel> currentUser = Rxn<UserModel>();
final Rxn<String> errorMessage = Rxn<String>();
```

هذه متغيرات تفاعلية. تقرأ القيمة وتكتبها باستخدام `.value`.

### Provider

```dart
bool _isLoading = false;
UserModel? _currentUser;
String? _errorMessage;

bool get isLoading => _isLoading;
UserModel? get currentUser => _currentUser;
```

هذه متغيرات Dart عادية. بعد تغييرها يستدعي الكلاس `notifyListeners()` لإعلام المستمعين.

## 3. توفير Controller أو Provider

### GetX — `AppBinding`

```dart
Get.put<AuthRepository>(AuthRepositoryImpl(), permanent: true);
Get.put<AuthController>(
  AuthController(Get.find<AuthRepository>()),
  permanent: true,
);
```

`Get.put` يسجل الكائن، و`Get.find` يسترجع النسخة المسجلة. استخدمنا `permanent: true` لأن حالة المصادقة مشتركة بين صفحات الدخول والتسجيل واستعادة كلمة المرور.

### Provider — `MultiProvider`

```dart
MultiProvider(
  providers: [
    Provider<AuthRepository>(create: (_) => AuthRepositoryImpl()),
    ChangeNotifierProvider<AuthProvider>(
      create: (context) => AuthProvider(context.read<AuthRepository>()),
    ),
  ],
  child: const AppView(),
)
```

`Provider` يوفّر الـ Repository، و`ChangeNotifierProvider` ينشئ `AuthProvider` ويهتم باستدعاء `dispose` للكائن الذي أنشأه عند إزالة المزود من الشجرة.

## 4. كيف تتحدث الواجهة؟

### GetX

```dart
// داخل AuthController
isLoading.value = true;

// داخل الصفحة
Obx(() => Text(
  controller.isLoading.value ? 'Loading' : 'Ready',
));
```

لا تحتاج `update()` عند استعمال Rx مع `Obx`.

### Provider

```dart
// داخل AuthProvider
_isLoading = true;
notifyListeners();

// داخل واجهة تستخدم BuildContext
final auth = context.watch<AuthProvider>();
Text(auth.isLoading.toString());
```

`watch` يسجل اشتراكًا في التغييرات ويؤدي إلى إعادة بناء الـ Widget التي تستخدمه.

ويمكن تضييق نطاق الاستماع باستعمال:

```dart
Consumer<AuthProvider>(
  builder: (context, auth, child) => Text(auth.isLoading.toString()),
)
```

أو مراقبة قيمة محددة فقط باستخدام `context.select` أو `Selector`.

## 5. استدعاء الدوال من الأزرار

### GetX

```dart
Get.find<AuthController>().login(request);
```

### Provider

```dart
context.read<AuthProvider>().login(request);
```

كلاهما يستدعي نفس حالة المصادقة المشتركة، لكن آلية الوصول مختلفة.

## 6. مسار عملية تسجيل الدخول

في النسختين، منطق المصادقة وقواعد التحقق موجودة في Repository ولم نكررها داخل مكتبة إدارة الحالة:

`LoginPage → AuthController/AuthProvider → AuthRepository → AuthRepositoryImpl`

عند نجاح العملية، تحفظ حالة المستخدم في Controller/Provider؛ وعند الفشل تحفظ رسالة الخطأ. الفرق بين النسختين هو كيفية تخزين الحالة وإشعار الواجهة بالتغيير، وليس قواعد المصادقة نفسها.

## 7. GetBuilder مقابل Obx

نسخة GetX المرفقة تستخدم `.obs` و`Obx` لأنها مناسبة لحالات التحميل ورسائل النجاح والخطأ والمستخدم الحالي.

أما `GetBuilder` فهو البديل اليدوي البسيط:

```dart
class CounterController extends GetxController {
  int count = 0;

  void increment() {
    count++;
    update();
  }
}

GetBuilder<CounterController>(
  builder: (controller) => Text('${controller.count}'),
)
```

لا تخلط بين الطريقتين لنفس المتغير: إما Rx مع Obx، أو متغير عادي مع GetBuilder و`update()`.

## 8. ملاحظة الاختبارات

أُبقيت اختبارات Repository والتحقق من المدخلات، وحُوّلت اختبارات حالة المصادقة لتناسب نوع الكلاس في كل نسخة. لم يتم تشغيل الاختبارات في بيئة الإنشاء لعدم توفر Flutter/Dart SDK فيها؛ لذلك يجب تنفيذ `flutter pub get` ثم `flutter analyze` ثم `flutter test` داخل كل مجلد.
