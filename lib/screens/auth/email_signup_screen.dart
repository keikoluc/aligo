import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/auth_api.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/primary_button.dart';
import 'otp_screen.dart';

/// Collects a name and email, requests a one-time verification code
/// from the Aligo backend, then hands off to [OtpScreen].
class EmailSignupScreen extends StatefulWidget {
  const EmailSignupScreen({super.key});

  @override
  State<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends State<EmailSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _authApi = AuthApi();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.enterFullName;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final RegExp emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (value == null || !emailPattern.hasMatch(value.trim())) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    return null;
  }

  Future<void> _sendCode() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final String email = _emailController.text.trim();
      await _authApi.sendOtp(email);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              OtpScreen(email: email, fullName: _nameController.text.trim()),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createAccountTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.joinAligo, style: textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(l10n.signupSubtitle, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.xl),
                AppTextField(
                  controller: _nameController,
                  label: l10n.fullNameLabel,
                  hint: l10n.fullNameHint,
                  prefixIcon: Icons.person_outline,
                  validator: _validateName,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _emailController,
                  label: l10n.emailAddressLabel,
                  hint: l10n.emailAddressHint,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: l10n.sendVerificationCode,
                  isLoading: _isSubmitting,
                  onPressed: _sendCode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
