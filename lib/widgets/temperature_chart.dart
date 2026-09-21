import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/weather_model.dart';
import '../utils/app_colors.dart';
import '../utils/temperature_unit.dart';

/// A small line chart showing the temperature trend across the given
/// forecast items (typically the next ~24 hours).
class TemperatureChart extends StatelessWidget {
  final List<ForecastItem> items;

  const TemperatureChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.length < 2) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 20, 12),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Temperature Trend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 140,
            child: ValueListenableBuilder<bool>(
              valueListenable: TemperatureUnit.isFahrenheit,
              builder: (context, _, __) {
                final temps = items
                    .map((item) => TemperatureUnit.convert(item.temp))
                    .toList();

                final minTemp = temps.reduce((a, b) => a < b ? a : b);
                final maxTemp = temps.reduce((a, b) => a > b ? a : b);
                final padding = (maxTemp - minTemp).abs() < 4 ? 4.0 : 2.0;

                return LineChart(
                  LineChartData(
                    minY: minTemp - padding,
                    maxY: maxTemp + padding,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) =>
                            Colors.black.withValues(alpha: 0.75),
                        getTooltipItems: (spots) => spots.map((spot) {
                          final index = spot.x.toInt();
                          if (index < 0 || index >= items.length) return null;
                          final time = DateFormat(
                            'h a',
                          ).format(items[index].dateTime);
                          return LineTooltipItem(
                            '$time\n${spot.y.round()}${TemperatureUnit.suffix}',
                            const TextStyle(color: Colors.white, fontSize: 12),
                          );
                        }).toList(),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: (items.length / 4).ceilToDouble().clamp(
                            1,
                            100,
                          ),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= items.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                DateFormat('h a').format(items[index].dateTime),
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (int i = 0; i < temps.length; i++)
                            FlSpot(i.toDouble(), temps[i]),
                        ],
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: AppColors.accent,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.accent.withValues(alpha: 0.28),
                              AppColors.accent.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
