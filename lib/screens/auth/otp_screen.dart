import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/auth_api.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/primary_button.dart';
import '../home/home_screen.dart';
import '../onboarding/role_select_screen.dart';

/// Six-digit email verification step. Submits the code to the Aligo
/// backend, stores the returned session token, then enters the app.
class OtpScreen extends StatefulWidget {
  final String email;
  final String? fullName;

  const OtpScreen({super.key, required this.email, this.fullName});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codeController = TextEditingController();
  final _authApi = AuthApi();
  final _sessionStorage = SessionStorage();

  bool _isVerifying = false;
  bool _isResending = false;
  String? _errorText;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final String code = _codeController.text.trim();
    if (code.length != 6) {
      setState(
        () => _errorText = AppLocalizations.of(context)!.enterSixDigitCode,
      );
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    try {
      final result = await _authApi.verifyOtp(
        email: widget.email,
        code: code,
        fullName: widget.fullName,
      );
      await _sessionStorage.saveToken(result.token);
      if (!mounted) return;
      final Widget destination = result.user.role == null
          ? RoleSelectScreen(token: result.token, user: result.user)
          : HomeScreen(token: result.token, user: result.user);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => destination),
        (route) => false,
      );
    } on ApiException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
      _errorText = null;
    });

    try {
      await _authApi.sendOtp(widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.newCodeSent)),
      );
    } on ApiException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyEmailTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.enterCodeTitle, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(l10n.otpSentTo(widget.email), style: textTheme.bodyMedium),
              const SizedBox(height: AppSpacing.xl),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                style: textTheme.headlineMedium?.copyWith(letterSpacing: 12),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  errorText: _errorText,
                ),
                onChanged: (_) {
                  if (_errorText != null) setState(() => _errorText = null);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n.verifyAndContinue,
                isLoading: _isVerifying,
                onPressed: _verify,
              ),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: TextButton(
                  onPressed: _isResending ? null : _resendCode,
                  child: Text(
                    _isResending ? l10n.sending : l10n.resendPrompt,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
