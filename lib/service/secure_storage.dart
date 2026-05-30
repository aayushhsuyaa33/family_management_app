import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static Future<void> save({required String key, required String data}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  static Future<String?> read({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> delete({required key}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> deleteKeysOnLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("email");
    await prefs.remove("name");
    await prefs.remove("uid");
    await prefs.remove("savedRole");
    await prefs.remove("boardId");
    await prefs.remove("imagePath");
  }

  // Save the onboarding status
  static Future<void> setIsFirstInstall(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstInstall', value);
  }

  // Get the onboarding status
  static Future<bool?> getIsFirstInstall() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isFirstInstall");
  }
}
