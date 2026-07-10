import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.blocked.app/native');

  static Future<void> startProtection({String? dnsServer}) async {
    try {
      await _channel.invokeMethod('startProtection', {
        if (dnsServer != null) 'dnsServer': dnsServer,
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to start protection: '$e'.");
    }
  }

  static Future<void> stopProtection() async {
    try {
      await _channel.invokeMethod('stopProtection');
    } on PlatformException catch (e) {
      debugPrint("Failed to stop protection: '$e'.");
    }
  }
}
