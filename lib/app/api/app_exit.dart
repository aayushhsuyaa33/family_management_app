import 'package:flutter/services.dart';

class AppExitHelper {
  static const platform = MethodChannel(
    'com.home.family_management_home_ops/exit',
  );

  static Future<void> minimizeApp() async {
    try {
      await platform.invokeMethod('minimizeApp');
    } on PlatformException catch (e) {
      print("Failed to minimize app: ${e.message}");
    }
  }
}
