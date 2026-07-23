import 'package:flutter/material.dart';

/// Tracks the app's active theme mode outside the widget tree, mirroring
/// [currentLocaleNotifier]. Kept in sync by [AligoApp].
final ValueNotifier<ThemeMode> currentThemeModeNotifier = ValueNotifier(
  ThemeMode.system,
);
