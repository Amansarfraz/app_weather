/// A single 3-hour forecast slot from OpenWeather's 5 day / 3 hour forecast.
class ForecastItem {
  final DateTime dateTime;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String main;
  final String description;
  final String icon;
  final double pop; // probability of precipitation (0.0 - 1.0)

  const ForecastItem({
    required this.dateTime,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.main,
    required this.description,
    required this.icon,
    required this.pop,
  });

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  factory ForecastItem.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> main =
        (json['main'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, dynamic> wind =
        (json['wind'] as Map?)?.cast<String, dynamic>() ?? {};

    final List weatherList = (json['weather'] as List?) ?? const [];
    final Map<String, dynamic> weather = weatherList.isNotEmpty
        ? (weatherList.first as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    final String dtTxt = (json['dt_txt'] ?? '').toString();
    DateTime parsedDate;
    if (dtTxt.isNotEmpty) {
      // OpenWeather uses "yyyy-MM-dd HH:mm:ss" (UTC).
      parsedDate = DateTime.tryParse(dtTxt.replaceFirst(' ', 'T')) ??
          DateTime.fromMillisecondsSinceEpoch(_toInt(json['dt']) * 1000);
    } else {
      parsedDate = DateTime.fromMillisecondsSinceEpoch(_toInt(json['dt']) * 1000);
    }

    return ForecastItem(
      dateTime: parsedDate,
      temp: _toDouble(main['temp']),
      feelsLike: _toDouble(main['feels_like']),
      humidity: _toInt(main['humidity']),
      windSpeed: _toDouble(wind['speed']),
      main: (weather['main'] ?? '').toString(),
      description: (weather['description'] ?? '').toString(),
      icon: (weather['icon'] ?? '').toString(),
      pop: _toDouble(json['pop']),
    );
  }

  static List<ForecastItem> listFromJson(List<dynamic>? list) {
    if (list == null) return [];
    return list
        .whereType<Map>()
        .map((e) => ForecastItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }
}

/// A single day's summary, built by grouping [ForecastItem]s that share the
/// same calendar date.
class DailyForecast {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final String main;
  final String description;
  final String icon;
  final List<ForecastItem> items;

  const DailyForecast({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.main,
    required this.description,
    required this.icon,
    required this.items,
  });

  /// Groups a flat list of 3-hour items into one entry per calendar day.
  /// The representative icon/description for the day is taken from the
  /// item closest to midday (a good visual proxy for "what the day looks
  /// like"), falling back to the first item of the day.
  static List<DailyForecast> groupByDay(List<ForecastItem> items) {
    final Map<String, List<ForecastItem>> byDay = {};

    for (final item in items) {
      final key =
          '${item.dateTime.year}-${item.dateTime.month}-${item.dateTime.day}';
      byDay.putIfAbsent(key, () => []).add(item);
    }

    final List<DailyForecast> result = [];

    for (final entry in byDay.entries) {
      final dayItems = entry.value;
      dayItems.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      double minTemp = dayItems.first.temp;
      double maxTemp = dayItems.first.temp;
      for (final item in dayItems) {
        if (item.temp < minTemp) minTemp = item.temp;
        if (item.temp > maxTemp) maxTemp = item.temp;
      }

      ForecastItem representative = dayItems.first;
      int smallestDiff = 24;
      for (final item in dayItems) {
        final diff = (item.dateTime.hour - 13).abs();
        if (diff < smallestDiff) {
          smallestDiff = diff;
          representative = item;
        }
      }

      result.add(
        DailyForecast(
          date: dayItems.first.dateTime,
          minTemp: minTemp,
          maxTemp: maxTemp,
          main: representative.main,
          description: representative.description,
          icon: representative.icon,
          items: dayItems,
        ),
      );
    }

    result.sort((a, b) => a.date.compareTo(b.date));
    return result;
  }
}
