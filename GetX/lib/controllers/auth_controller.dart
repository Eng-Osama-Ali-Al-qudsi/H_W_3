import 'package:get/get.dart';

import '../models/login_request.dart';
import '../models/password_reset_request.dart';
import '../models/register_request.dart';
import '../models/reset_password_request.dart';
import '../models/user_model.dart';
import '../repositories/auth_exception.dart';
import '../repositories/auth_repository.dart';

/// Coordinates authentication use cases and exposes reactive UI state.
/// Repository rules and in-memory storage remain outside this controller.
class AuthController extends GetxController {
  AuthController(this._repository);

  final AuthRepository _repository;

  // Rx values are observed by Obx widgets. Read/write their contents via .value.
  final RxBool isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();
  final Rxn<String> errorMessage = Rxn<String>();
  final Rxn<String> successMessage = Rxn<String>();

  bool get isAuthenticated => currentUser.value != null;

  Future<bool> login(LoginRequest request) {
    return _execute(() async {
      currentUser.value = await _repository.login(request);
    }, success: 'Login successful.');
  }

  Future<bool> register(RegisterRequest request) {
    return _execute(() async {
      await _repository.register(request);
    }, success: 'Account created successfully.');
  }

  Future<bool> sendPasswordResetCode(PasswordResetRequest request) {
    return _execute(() async {
      await _repository.sendPasswordResetCode(request);
    }, success: 'Verification code sent successfully.');
  }

  Future<bool> resetPassword(ResetPasswordRequest request) {
    return _execute(() async {
      await _repository.resetPassword(request);
    }, success: 'Password updated successfully.');
  }

  Future<bool> _execute(
    Future<void> Function() operation, {
    required String success,
  }) async {
    if (isLoading.value) {
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;
    successMessage.value = null;

    try {
      await operation();
      successMessage.value = success;
      return true;
    } on AuthException catch (exception) {
      errorMessage.value = exception.message;
      return false;
    } catch (_) {
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearMessages() {
    errorMessage.value = null;
    successMessage.value = null;
  }

  void logout() {
    currentUser.value = null;
    errorMessage.value = null;
    successMessage.value = null;
  }
}
