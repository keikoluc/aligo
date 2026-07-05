import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aligo/core/theme/app_theme.dart';
import 'package:aligo/l10n/app_localizations.dart';
import 'package:aligo/models/cargo_listing_model.dart';
import 'package:aligo/widgets/cargo_status_pill.dart';

void main() {
  Future<void> pump(WidgetTester tester, CargoListingStatus status) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: CargoStatusPill(status: status)),
      ),
    );
  }

  testWidgets('shows the matching label for every status', (tester) async {
    const expectedLabels = {
      CargoListingStatus.open: 'Open',
      CargoListingStatus.accepted: 'Accepted',
      CargoListingStatus.inTransit: 'In transit',
      CargoListingStatus.completed: 'Completed',
      CargoListingStatus.cancelled: 'Cancelled',
    };

    for (final entry in expectedLabels.entries) {
      await pump(tester, entry.key);
      expect(find.text(entry.value), findsOneWidget);
    }
  });
}
