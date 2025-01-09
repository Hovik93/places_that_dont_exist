import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataStorage {
  static const String _onboardingKey = 'onboarding_seen';
  static const String _placesKey = 'saved_places';
  static const String _quotesKey = 'saved_quotes';
  static const String _tipsKey = 'saved_tips';

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

  // Сохранение quotesList в SharedPreferences
  static Future<void> saveQuotes(List<Map<String, dynamic>> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedQuotes = jsonEncode(quotes); // Кодируем в строку JSON
    await prefs.setString('quotesList', encodedQuotes); // Сохраняем
  }

  // Получение quotesList из SharedPreferences
  static Future<List<Map<String, dynamic>>> getQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final storedQuotes = prefs.getString('quotesList');
    if (storedQuotes != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(storedQuotes));
    }
    return [];
  }

  // Сохранение tipsData
  static Future<void> saveTips(List<Map<String, dynamic>> tips) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedTips = jsonEncode(tips);
    await prefs.setString(_tipsKey, encodedTips);
  }

  // Загрузка tipsData
  static Future<List<Map<String, dynamic>>> getTips() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTips = prefs.getString(_tipsKey);
    if (savedTips != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(savedTips));
    }
    return [];
  }
}
