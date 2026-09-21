import 'package:flutter/material.dart';

import '../models/air_quality_model.dart';
import '../utils/app_colors.dart';

/// A small glass card showing the US AQI number, category and color badge.
class AirQualityCard extends StatelessWidget {
  final AirQualityModel airQuality;

  const AirQualityCard({super.key, required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final aqi = airQuality.usAqi;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: airQuality.color.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                aqi?.toString() ?? '--',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Air Quality',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  airQuality.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (airQuality.pm25 != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'PM2.5: ${airQuality.pm25!.toStringAsFixed(1)} μg/m³',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
