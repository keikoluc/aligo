import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/auth_api.dart';
import '../../core/network/google_auth_service.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/aligo_logo.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/google_logo.dart';
import '../../widgets/primary_button.dart';
import '../home/home_screen.dart';
import '../onboarding/role_select_screen.dart';
import 'email_signup_screen.dart';
import 'otp_screen.dart';

/// Production login surface for the Aligo logistics ecosystem.
///
/// Sign-in is email + one-time code, matching the registration flow:
/// the same backend endpoint creates the account on first verify, so
/// this screen never asks for a password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  final _authApi = AuthApi();
  final _sessionStorage = SessionStorage();

  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final RegExp emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (value == null || !emailPattern.hasMatch(value.trim())) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    return null;
  }

  Future<void> _handleContinue() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final String email = _emailController.text.trim();
      await _authApi.sendOtp(email);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => OtpScreen(email: email)),
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

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleSubmitting = true);
    try {
      final String? idToken = await GoogleAuthService.signInAndGetIdToken();
      if (idToken == null) return;

      final result = await _authApi.signInWithGoogle(idToken);
      await _sessionStorage.saveToken(result.token);
      if (!mounted) return;

      final Widget destination = result.user.role == null
          ? RoleSelectScreen(token: result.token, user: result.user)
          : HomeScreen(token: result.token, user: result.user);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => destination),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.googleSignInFailed('$e')),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        const Center(child: AligoLogo()),
                        const SizedBox(height: AppSpacing.lg),
                        Center(
                          child: Text(
                            l10n.loginWelcomeTitle,
                            style: textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            l10n.loginWelcomeSubtitle,
                            style: textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          controller: _emailController,
                          label: l10n.emailAddressLabel,
                          hint: l10n.emailAddressHint,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          validator: _validateEmail,
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        PrimaryButton(
                          label: l10n.continueWithEmail,
                          isLoading: _isSubmitting,
                          onPressed: _handleContinue,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(child: Divider(color: scheme.outline)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                l10n.orContinueWith,
                                style: textTheme.bodySmall,
                              ),
                            ),
                            Expanded(child: Divider(color: scheme.outline)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _isGoogleSubmitting
                                    ? null
                                    : _handleGoogleSignIn,
                                icon: _isGoogleSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const GoogleLogo(size: 18),
                                label: Text(l10n.google),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.apple, size: 20),
                                label: Text(l10n.apple),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.lg),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                l10n.noAccountPrompt,
                                style: textTheme.bodyMedium,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => const EmailSignupScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  l10n.createOne,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: scheme.secondary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (kIsWeb) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Center(
                            child: TextButton.icon(
                              onPressed: () => launchUrl(
                                Uri.parse('https://aligoo.uz/download/'),
                                mode: LaunchMode.externalApplication,
                              ),
                              icon: const Icon(Icons.android, size: 18),
                              label: Text(l10n.getAndroidApp),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
