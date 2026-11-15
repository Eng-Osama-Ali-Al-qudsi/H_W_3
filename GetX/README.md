# Student Auth — GetX Edition

This is the GetX rewrite of the supplied Student Auth Flutter project.
The original UI, validation rules, request models, repository behavior, and
four authentication flows are retained.

## Run

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## State-management architecture

- `repositories/`: authentication contract and in-memory demo implementation.
- `controllers/auth_controller.dart`: `AuthController extends GetxController`; owns UI state and use-case orchestration.
- `bindings/app_binding.dart`: registers the repository and controller once through GetX dependency injection.
- `main.dart`: uses `GetMaterialApp` and `initialBinding`.
- `views/auth/`: retrieve the shared controller with `Get.find<AuthController>()`; use narrowly-scoped `Obx` widgets for loading, feedback messages, and the authenticated-user card.
- `models/` and `utils/`: unchanged request/user models and form validation.

## Key GetX patterns used

```dart
// Register dependencies in AppBinding.
Get.put<AuthRepository>(AuthRepositoryImpl(), permanent: true);
Get.put<AuthController>(
  AuthController(Get.find<AuthRepository>()),
  permanent: true,
);

// Retrieve the already registered controller in a page.
final controller = Get.find<AuthController>();

// Declare observable state in the controller.
final RxBool isLoading = false.obs;

// Read it inside an Obx widget.
Obx(() => Text(controller.isLoading.value ? 'Loading' : 'Ready'));
```

This implementation uses GetX **Reactive State Management** (`.obs` + `Obx`).
`GetBuilder` is intentionally not mixed into the same auth state flow; it is
GetX's alternative simple/manual state manager and is better learned as a
separate variant using `update()`.

The four pages continue using Flutter's `Navigator` so the comparison focuses
on state management and dependency injection, not route behavior. `GetX`
Navigation can be introduced separately without changing the auth logic.

## Demo limitations retained from the original

- Accounts live in memory and are lost when the app process restarts.
- The repository simulates network delay; it is not connected to a backend.
- Password reset uses the demo OTP `123456`; no email is sent.
- This is an educational authentication flow, not production authentication.
