import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/telegram_api.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../widgets/primary_button.dart';

/// Lets the user connect their Telegram chat to their Aligo account so
/// the bot can DM them status-change notifications and let them manage
/// loads without opening the app (see backend `telegramBotHandlers.js`).
class TelegramLinkScreen extends StatefulWidget {
  final String token;
  final UserModel user;

  const TelegramLinkScreen({
    super.key,
    required this.token,
    required this.user,
  });

  @override
  State<TelegramLinkScreen> createState() => _TelegramLinkScreenState();
}

class _TelegramLinkScreenState extends State<TelegramLinkScreen> {
  final _telegramApi = TelegramApi();
  late Future<bool> _statusFuture;
  TelegramLinkCode? _pendingCode;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _statusFuture = _telegramApi.fetchStatus(widget.token);
  }

  void _refresh() {
    setState(() {
      _pendingCode = null;
      _statusFuture = _telegramApi.fetchStatus(widget.token);
    });
  }

  Future<void> _connect() async {
    setState(() => _isBusy = true);
    try {
      final linkCode = await _telegramApi.requestLinkCode(widget.token);
      if (!mounted) return;
      setState(() => _pendingCode = linkCode);

      if (linkCode.deepLink != null) {
        final opened = await launchUrl(
          Uri.parse(linkCode.deepLink!),
          mode: LaunchMode.externalApplication,
        );
        if (!opened && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.telegramCouldNotOpenBot,
              ),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.telegramBotNotConfigured,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _openBotAgain() async {
    final deepLink = _pendingCode?.deepLink;
    if (deepLink == null) return;
    await launchUrl(Uri.parse(deepLink), mode: LaunchMode.externalApplication);
  }

  Future<void> _unlink() async {
    setState(() => _isBusy = true);
    try {
      await _telegramApi.unlink(widget.token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.telegramUnlinkedMessage),
        ),
      );
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.telegramTitle)),
      body: SafeArea(
        child: FutureBuilder<bool>(
          future: _statusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final bool linked = snapshot.data ?? false;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.send,
                        color: AppColors.info,
                        size: 28,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        linked ? l10n.telegramLinked : l10n.telegramNotLinked,
                        style: textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.telegramIntro, style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),
                  if (linked)
                    OutlinedButton(
                      onPressed: _isBusy ? null : _unlink,
                      child: Text(l10n.telegramUnlinkButton),
                    )
                  else ...[
                    PrimaryButton(
                      label: l10n.telegramConnectButton,
                      isLoading: _isBusy,
                      icon: Icons.link,
                      onPressed: _connect,
                    ),
                    if (_pendingCode != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.slateLight
                              : AppColors.offWhite,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: scheme.outline),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.telegramCodeInstructions,
                              style: textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              '/link ${_pendingCode!.code}',
                              style: textTheme.headlineSmall?.copyWith(
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.telegramCodeExpiry(_pendingCode!.ttlMinutes),
                              style: textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            if (_pendingCode!.deepLink != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              TextButton.icon(
                                onPressed: _openBotAgain,
                                icon: const Icon(Icons.open_in_new),
                                label: Text(l10n.telegramOpenBotButton),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
