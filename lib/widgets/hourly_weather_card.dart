import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../utils/app_colors.dart';
import '../utils/temperature_unit.dart';
import '../utils/weather_icon_mapper.dart';

/// A compact vertical card used in the horizontal "next hours" list.
class HourlyWeatherCard extends StatelessWidget {
  final ForecastItem item;
  final bool isNow;

  const HourlyWeatherCard({super.key, required this.item, this.isNow = false});

  @override
  Widget build(BuildContext context) {
    final icon = WeatherIconMapper.iconFor(item.main, icon: item.icon);
    final label = isNow ? 'Now' : DateFormat('h a').format(item.dateTime);

    return Container(
      width: 76,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isNow ? Colors.white.withValues(alpha: 0.22) : AppColors.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNow ? Colors.white : AppColors.glassBorder,
          width: isNow ? 1.4 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isNow ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          ValueListenableBuilder<bool>(
            valueListenable: TemperatureUnit.isFahrenheit,
            builder: (context, _, __) {
              return Text(
                '${TemperatureUnit.convert(item.temp).round()}°',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
