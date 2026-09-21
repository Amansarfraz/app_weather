import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../utils/app_colors.dart';
import '../widgets/forecast_card.dart';

class WeatherScreen extends StatelessWidget {
  final String cityName;
  final List<ForecastItem> forecast;

  const WeatherScreen({
    super.key,
    required this.cityName,
    required this.forecast,
  });

  @override
  Widget build(BuildContext context) {
    final days = DailyForecast.groupByDay(forecast);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.defaultGradientStart, AppColors.defaultGradientEnd],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '5-Day Forecast',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            cityName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: days.isEmpty
                    ? const Center(
                        child: Text(
                          'No forecast data available.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        itemCount: days.length,
                        itemBuilder: (context, index) => ForecastCard(
                          day: days[index],
                          index: index,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
