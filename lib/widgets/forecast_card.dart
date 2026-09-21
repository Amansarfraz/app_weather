import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../utils/app_colors.dart';
import '../utils/temperature_unit.dart';
import '../utils/weather_icon_mapper.dart';

/// A single day's row in the 5-day forecast list. Wrap several of these in
/// a [ListView.builder] passing an increasing [index] to get a nice
/// staggered fade + slide-in entrance.
class ForecastCard extends StatelessWidget {
  final DailyForecast day;
  final int index;

  const ForecastCard({super.key, required this.day, this.index = 0});

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEEE').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final icon = WeatherIconMapper.iconFor(day.main, icon: day.icon);

    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              _dayLabel(day.date),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              day.description.isNotEmpty
                  ? day.description[0].toUpperCase() +
                        day.description.substring(1)
                  : '',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: TemperatureUnit.isFahrenheit,
            builder: (context, _, __) {
              final max = TemperatureUnit.convert(day.maxTemp).round();
              final min = TemperatureUnit.convert(day.minTemp).round();
              return Row(
                children: [
                  Text(
                    '$max°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$min°',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset((1 - value) * 40, 0),
            child: child,
          ),
        );
      },
      child: card,
    );
  }
}
