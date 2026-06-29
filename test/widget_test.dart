import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blocked_app/main.dart';

void main() {
  testWidgets('Dashboard UI renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the title text is present
    expect(find.text('Blocked Dashboard'), findsOneWidget);

    // Verify that the initial protection status is displayed
    expect(find.text('Unprotected'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);

    // Verify our AnimatedSwitcher and Icon are there
    expect(find.byType(AnimatedSwitcher), findsOneWidget);
  });
}
