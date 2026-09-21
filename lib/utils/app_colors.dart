import 'package:flutter/material.dart';

/// Central place for every color used in the app, plus helpers that turn a
/// weather condition ("Clear", "Rain", ...) into a nice gradient.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3E64FF);
  static const Color accent = Color(0xFFFFC93C);
  static const Color danger = Color(0xFFFF5C5C);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xCCFFFFFF);
  static const Color textMuted = Color(0x99FFFFFF);

  /// Semi-transparent "glass" card color, laid on top of a gradient.
  static const Color glass = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);

  static const Color defaultGradientStart = Color(0xFF4776E6);
  static const Color defaultGradientEnd = Color(0xFF8E54E9);

  /// Returns a gradient that matches the current weather condition.
  ///
  /// [main] is OpenWeather's top-level condition, e.g. "Clear", "Clouds",
  /// "Rain", "Drizzle", "Thunderstorm", "Snow", "Mist"/"Fog"/"Haze".
  static List<Color> gradientForCondition(String? main, {bool isNight = false}) {
    final condition = (main ?? '').toLowerCase();

    if (isNight) {
      return const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)];
    }

    switch (condition) {
      case 'clear':
        return const [Color(0xFF56CCF2), Color(0xFF2F80ED)];
      case 'clouds':
        return const [Color(0xFF757F9A), Color(0xFFD7DDE8)];
      case 'rain':
      case 'drizzle':
        return const [Color(0xFF3A6073), Color(0xFF16222A)];
      case 'thunderstorm':
        return const [Color(0xFF232526), Color(0xFF414345)];
      case 'snow':
        return const [Color(0xFFE6DADA), Color(0xFF274046)];
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
        return const [Color(0xFFBDC3C7), Color(0xFF2C3E50)];
      default:
        return const [defaultGradientStart, defaultGradientEnd];
    }
  }
}
