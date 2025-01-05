import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataStorage {
  static const String _onboardingKey = 'onboarding_seen';
  static const String _placesKey = 'saved_places';

  static Future<bool> isOnboardingSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> setOnboardingSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // Сохранение списка
  static Future<void> savePlaces(List<Map<String, dynamic>> places) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(places);
    await prefs.setString(_placesKey, encodedData);
  }

  // Получение списка
  static Future<List<Map<String, dynamic>>> getPlaces() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_placesKey);

    if (encodedData != null) {
      final List<dynamic> decodedData = jsonDecode(encodedData);
      return List<Map<String, dynamic>>.from(decodedData);
    }
    return [];
  }

  
}
