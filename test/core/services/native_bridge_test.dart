import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blocked_app/core/services/native_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.blocked.app/native');

  group('NativeBridge', () {
    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        log.add(methodCall);
        return null;
      });
    });

    tearDown(() {
      log.clear();
    });

    test('startProtection invokes startProtection method', () async {
      await NativeBridge.startProtection();
      expect(log, hasLength(1));
      expect(log.first.method, 'startProtection');
    });

    test('stopProtection invokes stopProtection method', () async {
      await NativeBridge.stopProtection();
      expect(log, hasLength(1));
      expect(log.first.method, 'stopProtection');
    });

    test('handles PlatformException in startProtection', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(code: 'ERROR', message: 'Test error');
      });

      await expectLater(NativeBridge.startProtection(), completes);
    });

    test('handles PlatformException in stopProtection', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        throw PlatformException(code: 'ERROR', message: 'Test error');
      });

      await expectLater(NativeBridge.stopProtection(), completes);
    });
  });
}
