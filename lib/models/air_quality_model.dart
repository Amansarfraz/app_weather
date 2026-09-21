import 'package:flutter/material.dart';

/// Air quality reading from Open-Meteo, with a helper to turn the raw
/// US AQI number into a human-readable category + color.
class AirQualityModel {
  final int? usAqi;
  final int? europeanAqi;
  final double? pm25;
  final double? pm10;
  final double? ozone;

  const AirQualityModel({
    required this.usAqi,
    required this.europeanAqi,
    required this.pm25,
    required this.pm10,
    required this.ozone,
  });

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final current = (json['current'] as Map?)?.cast<String, dynamic>() ?? {};

    return AirQualityModel(
      usAqi: _toInt(current['us_aqi']),
      europeanAqi: _toInt(current['european_aqi']),
      pm25: _toDouble(current['pm2_5']),
      pm10: _toDouble(current['pm10']),
      ozone: _toDouble(current['ozone']),
    );
  }

  /// Human-readable category based on the US AQI scale.
  String get category {
    final aqi = usAqi;
    if (aqi == null) return 'Unknown';
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  Color get color {
    final aqi = usAqi;
    if (aqi == null) return Colors.grey;
    if (aqi <= 50) return const Color(0xFF4CAF50); // green
    if (aqi <= 100) return const Color(0xFFFFC107); // yellow
    if (aqi <= 150) return const Color(0xFFFF9800); // orange
    if (aqi <= 200) return const Color(0xFFF44336); // red
    if (aqi <= 300) return const Color(0xFF9C27B0); // purple
    return const Color(0xFF7E0023); // maroon
  }
}
