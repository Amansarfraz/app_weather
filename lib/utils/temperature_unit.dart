import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-wide Celsius/Fahrenheit preference. A simple ValueNotifier so any
/// widget can rebuild automatically when the unit changes, without needing
/// a full state-management package.
class TemperatureUnit {
  TemperatureUnit._();

  static const _prefsKey = 'is_fahrenheit';

  /// true = Fahrenheit, false = Celsius.
  static final ValueNotifier<bool> isFahrenheit = ValueNotifier<bool>(false);

  /// Call once at app startup to restore the saved preference.
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isFahrenheit.value = prefs.getBool(_prefsKey) ?? false;
    } catch (_) {
      // If shared_preferences isn't available for some reason, just default
      // to Celsius rather than crashing the app.
    }
  }

  static Future<void> toggle() async {
    isFahrenheit.value = !isFahrenheit.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, isFahrenheit.value);
    } catch (_) {
      // Non-fatal: the toggle still works for this session even if saving fails.
    }
  }

  /// Converts a Celsius value to whichever unit is currently selected.
  static double convert(double celsius) {
    return isFahrenheit.value ? (celsius * 9 / 5) + 32 : celsius;
  }

  static String get suffix => isFahrenheit.value ? '°F' : '°C';
}
