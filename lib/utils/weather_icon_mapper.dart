import 'package:flutter/material.dart';

/// Maps OpenWeather's condition codes / names to Material icons, so the app
/// doesn't depend on any bundled image assets.
class WeatherIconMapper {
  WeatherIconMapper._();

  static IconData iconFor(String? main, {String? icon}) {
    final condition = (main ?? '').toLowerCase();
    final isNight = icon != null && icon.endsWith('n');

    switch (condition) {
      case 'clear':
        return isNight ? Icons.nightlight_round : Icons.wb_sunny_rounded;
      case 'clouds':
        return isNight ? Icons.nights_stay_rounded : Icons.cloud_rounded;
      case 'rain':
        return Icons.beach_access_rounded; // umbrella
      case 'drizzle':
        return Icons.grain_rounded;
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'mist':
      case 'fog':
      case 'haze':
      case 'smoke':
      case 'dust':
      case 'sand':
        return Icons.blur_on_rounded;
      case 'tornado':
      case 'squall':
        return Icons.storm_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }
}
