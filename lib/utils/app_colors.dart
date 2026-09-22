import 'package:flutter/material.dart';

/// Central place for every color used in the app, plus helpers that turn a
/// weather condition ("Clear", "Rain", ...) into a nice gradient.
///
/// Palette is built around the AuraWeather logo: deep navy blue fading into
/// a bright sky blue, with a warm gold accent for the sun.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF2A3FE0);
  static const Color accent = Color(0xFFFFC93C);
  static const Color danger = Color(0xFFFF5C5C);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xCCFFFFFF);
  static const Color textMuted = Color(0x99FFFFFF);

  /// Semi-transparent "glass" card color, laid on top of a gradient.
  static const Color glass = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);

  // AuraWeather brand gradient: deep navy -> bright sky blue.
  static const Color brandDeep = Color(0xFF0B1440);
  static const Color brandNavy = Color(0xFF15209B);
  static const Color brandBlue = Color(0xFF3E7BFA);
  static const Color brandCyan = Color(0xFF5AC8FA);

  static const Color defaultGradientStart = brandNavy;
  static const Color defaultGradientEnd = brandBlue;

  /// The app's signature gradient (splash, auth screens, empty states).
  static const List<Color> brandGradient = [brandDeep, brandNavy, brandBlue];

  /// Returns a gradient that matches the current weather condition.
  ///
  /// [main] is OpenWeather's top-level condition, e.g. "Clear", "Clouds",
  /// "Rain", "Drizzle", "Thunderstorm", "Snow", "Mist"/"Fog"/"Haze".
  static List<Color> gradientForCondition(
    String? main, {
    bool isNight = false,
  }) {
    final condition = (main ?? '').toLowerCase();

    if (isNight) {
      return const [Color(0xFF0B1440), Color(0xFF15209B), Color(0xFF2C5364)];
    }

    switch (condition) {
      case 'clear':
        return const [brandCyan, brandBlue];
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
