import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class NativeBridge {
  static const MethodChannel _channel = MethodChannel('com.blocked.app/native');

  static Future<void> startProtection() async {
    try {
      await _channel.invokeMethod('startProtection');
    } on PlatformException catch (e) {
      debugPrint("Failed to start protection: '${e.message}'.");
    }
  }

  static Future<void> stopProtection() async {
    try {
      await _channel.invokeMethod('stopProtection');
    } on PlatformException catch (e) {
      debugPrint("Failed to stop protection: '${e.message}'.");
    }
  }
}
