import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../l10n/app_localizations.dart';

/// Shows a 1-5 star rating dialog with an optional comment. Returns the
/// chosen (stars, comment) once submitted, or null if dismissed.
Future<(int, String?)?> showRatingDialog(
  BuildContext context, {
  required String title,
  int initialStars = 5,
  String? initialComment,
}) {
  return showDialog<(int, String?)>(
    context: context,
    builder: (_) => _RatingDialog(
      title: title,
      initialStars: initialStars,
      initialComment: initialComment,
    ),
  );
}

class _RatingDialog extends StatefulWidget {
  final String title;
  final int initialStars;
  final String? initialComment;

  const _RatingDialog({
    required this.title,
    required this.initialStars,
    this.initialComment,
  });

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  late int _stars = widget.initialStars;
  late final _commentController = TextEditingController(text: widget.initialComment);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final int starValue = i + 1;
              return IconButton(
                onPressed: () => setState(() => _stars = starValue),
                icon: Icon(
                  starValue <= _stars ? Icons.star : Icons.star_outline,
                  color: scheme.secondary,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(hintText: l10n.commentOptional),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((
            _stars,
            _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
          )),
          child: Text(l10n.submit),
        ),
      ],
    );
  }
}
