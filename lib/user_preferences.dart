import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const _keyHasOnboarded = 'has_onboarded';
  static const _keyForecastType = 'forecast_type';

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasOnboarded) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasOnboarded, true);
  }

  static Future<void> setForecastType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForecastType, type);
  }

  static Future<String> getForecastType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyForecastType) ?? 'current';
  }
}
