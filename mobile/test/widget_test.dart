// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/auth_service.dart';

void main() {
  test('validates a strong password', () {
    expect(AuthService.validatePassword('StrongPass1!'), isNull);
    expect(AuthService.validatePassword('weakpass'), isNotNull);
  });

  test('validates email and username input', () {
    expect(AuthService.validateEmail('user@example.com'), isNull);
    expect(AuthService.validateEmail('not-an-email'), isNotNull);
    expect(AuthService.validateDisplayName('user_123'), isNull);
    expect(AuthService.validateDisplayName('<script>'), isNotNull);
  });
}
