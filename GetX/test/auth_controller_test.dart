import 'package:flutter_test/flutter_test.dart';
import 'package:student_auth_app_getx/controllers/auth_controller.dart';
import 'package:student_auth_app_getx/models/login_request.dart';
import 'package:student_auth_app_getx/models/password_reset_request.dart';
import 'package:student_auth_app_getx/models/register_request.dart';
import 'package:student_auth_app_getx/models/reset_password_request.dart';
import 'package:student_auth_app_getx/repositories/auth_repository_impl.dart';

void main() {
  late AuthRepositoryImpl repository;
  late AuthController controller;

  const registration = RegisterRequest(
    fullName: 'Student Example',
    academicId: '123456789',
    universityEmail: 'student@university.edu',
    password: 'Student123',
    acceptedTerms: true,
  );

  setUp(() {
    repository = AuthRepositoryImpl(simulationDelay: Duration.zero);
    controller = AuthController(repository);
  });

  group('AuthController state', () {
    test('starts idle and unauthenticated', () {
      expect(controller.isLoading.value, isFalse);
      expect(controller.currentUser.value, isNull);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.errorMessage.value, isNull);
      expect(controller.successMessage.value, isNull);
    });

    test('register exposes success state and returns true', () async {
      final result = await controller.register(registration);

      expect(result, isTrue);
      expect(controller.isLoading.value, isFalse);
      expect(controller.successMessage.value, 'Account created successfully.');
      expect(controller.errorMessage.value, isNull);
      expect(controller.currentUser.value, isNull);
    });

    test('login sets current user and authenticated state', () async {
      await repository.register(registration);

      final result = await controller.login(
        const LoginRequest(
          identifier: '123456789',
          password: 'Student123',
          rememberMe: false,
        ),
      );

      expect(result, isTrue);
      expect(controller.currentUser.value?.academicId, '123456789');
      expect(controller.isAuthenticated, isTrue);
      expect(controller.successMessage.value, 'Login successful.');
      expect(controller.errorMessage.value, isNull);
      expect(controller.isLoading.value, isFalse);
    });

    test(
      'login failure exposes repository error without authenticating',
      () async {
        final result = await controller.login(
          const LoginRequest(
            identifier: 'unknown@university.edu',
            password: 'Wrong123',
            rememberMe: false,
          ),
        );

        expect(result, isFalse);
        expect(controller.currentUser.value, isNull);
        expect(controller.isAuthenticated, isFalse);
        expect(
          controller.errorMessage.value,
          'Invalid Academic ID/email or password.',
        );
        expect(controller.successMessage.value, isNull);
        expect(controller.isLoading.value, isFalse);
      },
    );

    test('clearMessages clears success and error messages', () async {
      await controller.register(registration);
      expect(controller.successMessage.value, isNotNull);

      controller.clearMessages();

      expect(controller.successMessage.value, isNull);
      expect(controller.errorMessage.value, isNull);
    });

    test('logout clears the current user and messages', () async {
      await repository.register(registration);
      await controller.login(
        const LoginRequest(
          identifier: '123456789',
          password: 'Student123',
          rememberMe: false,
        ),
      );

      controller.logout();

      expect(controller.currentUser.value, isNull);
      expect(controller.isAuthenticated, isFalse);
      expect(controller.errorMessage.value, isNull);
      expect(controller.successMessage.value, isNull);
    });
  });

  group('AuthController password reset', () {
    setUp(() async {
      await repository.register(registration);
    });

    test('send code and reset password expose success states', () async {
      final sendResult = await controller.sendPasswordResetCode(
        const PasswordResetRequest(identifier: '123456789'),
      );

      expect(sendResult, isTrue);
      expect(controller.successMessage.value, 'Verification code sent successfully.');

      final resetResult = await controller.resetPassword(
        const ResetPasswordRequest(
          identifier: '123456789',
          otp: AuthRepositoryImpl.demoOtp,
          newPassword: 'NewStudent123',
        ),
      );

      expect(resetResult, isTrue);
      expect(controller.successMessage.value, 'Password updated successfully.');
      expect(controller.errorMessage.value, isNull);
      expect(controller.isLoading.value, isFalse);
    });

    test('reset failure exposes error and returns false', () async {
      final result = await controller.resetPassword(
        const ResetPasswordRequest(
          identifier: '123456789',
          otp: '000000',
          newPassword: 'NewStudent123',
        ),
      );

      expect(result, isFalse);
      expect(
        controller.errorMessage.value,
        'The verification code is invalid or expired.',
      );
      expect(controller.successMessage.value, isNull);
      expect(controller.isLoading.value, isFalse);
    });
  });
}
