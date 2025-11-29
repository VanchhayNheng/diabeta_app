import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diabeta_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DiabetaApp());

    // Verify that splash screen appears
    expect(find.text('DIABETA'), findsOneWidget);
  });
}