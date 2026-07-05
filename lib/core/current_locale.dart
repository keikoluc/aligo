import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// Tracks the app's active locale outside the widget tree, so plain
/// Dart classes without a BuildContext (API clients) can still produce
/// localized fallback messages. Kept in sync by [AligoApp].
final ValueNotifier<Locale> currentLocaleNotifier = ValueNotifier(
  const Locale('uz'),
);

/// Localized strings resolved from [currentLocaleNotifier], for use in
/// plain Dart classes that don't have a BuildContext.
AppLocalizations get currentL10n =>
    lookupAppLocalizations(currentLocaleNotifier.value);
