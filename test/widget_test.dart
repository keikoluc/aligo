import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aligo/main.dart';

void main() {
  // flutter_secure_storage has no platform implementation in the test
  // environment and its method channel just hangs unanswered rather
  // than throwing — mock it to resolve immediately as "nothing saved
  // yet", matching a genuinely fresh install.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async => null,
        );
  });

  testWidgets('Aligo shows the language picker on a fresh install', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AligoApp());
    await tester.pumpAndSettle();

    // No language saved yet (fresh secure storage) — the picker gates
    // everything else, including the login screen.
    expect(find.text('Choose your language'), findsOneWidget);
  });
}
