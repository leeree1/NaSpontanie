// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mobile/main.dart';

void main() {
  testWidgets('unauthenticated users see the auth screen', (
    WidgetTester tester,
  ) async {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-key',
    );

    await tester.pumpWidget(const NaSpontanieApp());
    await tester.pumpAndSettle();

    expect(find.text('NaSpontanie'), findsOneWidget);
    expect(find.text('Zaloguj się'), findsOneWidget);
  });
}
