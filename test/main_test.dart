import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blocked_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const MethodChannel channel = MethodChannel('com.blocked.app/native');

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('Dashboard initializes as Unprotected when status is not CONNECTED', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getStatus') {
        return 'DISCONNECTED';
      }
      return null;
    });

    await tester.pumpWidget(const MaterialApp(home: Dashboard(initialIsProtected: false)));
    await tester.pumpAndSettle();

    expect(find.text('Unprotected'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.byIcon(Icons.shield_outlined), findsOneWidget);
  });

  testWidgets('Dashboard initializes as Protection Active when status is CONNECTED', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getStatus') {
        return 'CONNECTED';
      }
      return null;
    });

    await tester.pumpWidget(const MaterialApp(home: Dashboard(initialIsProtected: true)));
    await tester.pumpAndSettle();

    expect(find.text('Protection Active'), findsOneWidget);
    expect(find.text('STOP'), findsOneWidget);
    expect(find.byIcon(Icons.shield), findsOneWidget);
  });

  testWidgets('Start Protection updates UI to Protection Active on SUCCESS', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getStatus') {
        return 'DISCONNECTED';
      }
      if (methodCall.method == 'startProtection') {
        return 'CONNECTED';
      }
      return null;
    });

    await tester.pumpWidget(const MaterialApp(home: Dashboard(initialIsProtected: false)));
    await tester.pumpAndSettle();

    expect(find.text('Unprotected'), findsOneWidget);

    // Tap START button
    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();

    expect(find.text('Protection Active'), findsOneWidget);
    expect(find.text('STOP'), findsOneWidget);
  });

  testWidgets('Stop Protection updates UI to Unprotected on SUCCESS', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getStatus') {
        return 'CONNECTED'; // Initialize as connected
      }
      if (methodCall.method == 'stopProtection') {
        return 'DISCONNECTED';
      }
      return null;
    });

    await tester.pumpWidget(const MaterialApp(home: Dashboard(initialIsProtected: true)));
    await tester.pumpAndSettle();

    expect(find.text('Protection Active'), findsOneWidget);

    // Tap STOP button
    await tester.tap(find.text('STOP'));
    await tester.pumpAndSettle();

    expect(find.text('Unprotected'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('Start Protection shows SnackBar on PERMISSION_DENIED', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getStatus') {
        return 'DISCONNECTED';
      }
      if (methodCall.method == 'startProtection') {
        return 'PERMISSION_DENIED';
      }
      return null;
    });

    await tester.pumpWidget(const MaterialApp(home: Dashboard(initialIsProtected: false)));
    await tester.pumpAndSettle();

    // Tap START button
    await tester.tap(find.text('START'));
    await tester.pump(); // Pump once to start animation
    await tester.pump(const Duration(seconds: 1)); // Pump to show SnackBar

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Permission denied. VPN cannot start.'), findsOneWidget);
  });

  testWidgets('Start Protection shows SnackBar on PlatformException', (WidgetTester tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getStatus') {
        return 'DISCONNECTED';
      }
      if (methodCall.method == 'startProtection') {
        throw PlatformException(code: 'ERROR', message: 'Test error message');
      }
      return null;
    });

    await tester.pumpWidget(const MaterialApp(home: Dashboard(initialIsProtected: false)));
    await tester.pumpAndSettle();

    // Tap START button
    await tester.tap(find.text('START'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('An unexpected error occurred. Please try again.'), findsOneWidget);
  });
}
