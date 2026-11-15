import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../models/login_request.dart';
import '../../utils/form_validators.dart';
import 'auth_widgets.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await Get.find<AuthController>().login(
      LoginRequest(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      ),
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF167647),
          content: Text(
            'تم تسجيل الدخول بنجاح | Login successful',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  Future<void> _openRegister() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );

    if (!mounted) {
      return;
    }

    if (created == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF167647),
          content: Text(
            'تم إنشاء الحساب بنجاح. يمكنك تسجيل الدخول الآن.\n'
            'Account created. You can log in now.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }

  void _openForgotPassword() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Builder(
      builder: (context) {
        return AuthPageShell(
          arabicTitle: 'تسجيل الدخول',
          englishTitle: 'Student Login',
          arabicSubtitle: 'أدخل بياناتك الأكاديمية للوصول إلى حسابك',
          englishSubtitle:
              'Enter your academic credentials to access your account.',
          icon: Icons.lock_open_rounded,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BilingualField(
                  fieldKey: const ValueKey('login_identifier'),
                  controller: _identifierController,
                  arabicLabel: 'المعرف الأكاديمي أو البريد الإلكتروني',
                  englishLabel: 'Academic ID or Email',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                  validator: (value) => bilingualValidationMessage(
                    FormValidators.loginIdentifier(value),
                  ),
                ),
                const SizedBox(height: 18),
                BilingualPasswordField(
                  fieldKey: const ValueKey('login_password'),
                  controller: _passwordController,
                  arabicLabel: 'كلمة المرور',
                  englishLabel: 'Password',
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (value) => bilingualValidationMessage(
                    FormValidators.loginPassword(value),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      key: const ValueKey('login_remember_me'),
                      value: _rememberMe,
                      activeColor: authBlue,
                      onChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تذكرني',
                            style: TextStyle(
                              color: authNavy,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Remember me',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(color: authMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    AuthTextLink(
                      linkKey: const ValueKey('go_forgot_password'),
                      arabicLabel: 'نسيت كلمة المرور؟',
                      englishLabel: 'Forgot password?',
                      onPressed: _openForgotPassword,
                    ),
                  ],
                ),
                Obx(() => AuthFeedback(
                      errorMessage: controller.errorMessage.value,
                      successMessage: controller.successMessage.value,
                    )),
                Obx(() => AuthPrimaryButton(
                      buttonKey: const ValueKey('login_submit'),
                      arabicLabel: 'تسجيل الدخول',
                      englishLabel: 'Sign In',
                      isLoading: controller.isLoading.value,
                      onPressed: _submit,
                    )),
                const SizedBox(height: 18),
                const Divider(color: Color(0xFFE8EDF5)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      child: Text(
                        'ليس لديك حساب؟',
                        style: TextStyle(color: authMuted, fontSize: 12),
                      ),
                    ),
                    AuthTextLink(
                      linkKey: const ValueKey('go_register'),
                      arabicLabel: 'إنشاء حساب جديد',
                      englishLabel: 'Create account',
                      onPressed: _openRegister,
                    ),
                  ],
                ),
                Obx(() {
                  final user = controller.currentUser.value;
                  if (user == null) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF3),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFC8EAD5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'مرحباً، ${user.fullName}',
                          style: const TextStyle(
                            color: Color(0xFF12643C),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Academic ID: ${user.academicId}',
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Color(0xFF12643C),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          user.universityEmail,
                          textDirection: TextDirection.ltr,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Color(0xFF12643C),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            key: const ValueKey('logout_button'),
                            onPressed: controller.logout,
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text('تسجيل الخروج | Sign out'),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
