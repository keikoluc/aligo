import 'package:flutter/material.dart';

import '../../core/storage/locale_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../main.dart';
import '../../widgets/aligo_logo.dart';
import '../../widgets/primary_button.dart';
import '../auth/login_screen.dart';

const List<(String code, String flag)> _languages = [
  ('uz', '🇺🇿'),
  ('ru', '🇷🇺'),
  ('en', '🇬🇧'),
];

/// Shown once on first launch so the user picks their app language
/// before anything else, and reachable again later from the home
/// drawer to change it. On first launch, confirming moves on to
/// [LoginScreen]; when reopened later, confirming just pops back.
class LanguagePickerScreen extends StatefulWidget {
  final bool isInitialSetup;

  const LanguagePickerScreen({super.key, this.isInitialSetup = true});

  @override
  State<LanguagePickerScreen> createState() => _LanguagePickerScreenState();
}

class _LanguagePickerScreenState extends State<LanguagePickerScreen> {
  final _localeStorage = LocaleStorage();
  String _selected = 'uz';

  String _labelFor(AppLocalizations l10n, String code) {
    switch (code) {
      case 'uz':
        return l10n.languageUzbek;
      case 'ru':
        return l10n.languageRussian;
      default:
        return l10n.languageEnglish;
    }
  }

  Future<void> _confirm() async {
    await _localeStorage.saveLanguageCode(_selected);
    if (!mounted) return;
    AligoApp.setLocale(context, Locale(_selected));
    if (widget.isInitialSetup) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Preview strings in the language the user has tapped, without
    // touching the app's actual active locale (and thus without
    // disturbing which screen MaterialApp.home resolves to) until
    // they confirm.
    final AppLocalizations l10n = lookupAppLocalizations(Locale(_selected));
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: widget.isInitialSetup
          ? null
          : AppBar(title: Text(l10n.language)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      const Center(child: AligoLogo()),
                      const SizedBox(height: AppSpacing.xl),
                      Center(
                        child: Text(
                          l10n.languagePickerTitle,
                          style: textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          l10n.languagePickerSubtitle,
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ..._languages.map(
                        (lang) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: InkWell(
                            onTap: () => setState(() => _selected = lang.$1),
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: _selected == lang.$1
                                    ? AppColors.amber.withValues(alpha: isDark ? 0.18 : 0.12)
                                    : (isDark ? AppColors.slateLight : AppColors.offWhite),
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                border: Border.all(
                                  color: _selected == lang.$1 ? AppColors.amber : scheme.outline,
                                  width: _selected == lang.$1 ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(lang.$2, style: const TextStyle(fontSize: 28)),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      _labelFor(l10n, lang.$1),
                                      style: textTheme.titleMedium,
                                    ),
                                  ),
                                  if (_selected == lang.$1)
                                    Icon(Icons.check_circle, color: AppColors.amber),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryButton(label: l10n.continueButton, onPressed: _confirm),
                    ],
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
