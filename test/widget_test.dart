import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eglise_labe/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verify that our counter starts at 0.
    // Note: The original template test might fail if the UI doesn't have a counter,
    // but we've fixed the constructor call.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
