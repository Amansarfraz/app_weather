/// Represents the "current weather" payload for a city, as returned by the
/// backend's /weather/full/{city} (the `city` key) or /weather/city/{city}
/// (the `data` key). The underlying data comes from OpenWeatherMap's
/// "current weather" response shape via the RapidAPI proxy.
class CityModel {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;

  final double windSpeed;
  final int windDeg;

  final String main; // e.g. "Clear", "Rain"
  final String description; // e.g. "clear sky"
  final String icon; // e.g. "01d"

  final int sunrise;
  final int sunset;
  final int timezoneOffset; // seconds from UTC
  final int observedAt; // unix timestamp (dt)

  const CityModel({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    required this.main,
    required this.description,
    required this.icon,
    required this.sunrise,
    required this.sunset,
    required this.timezoneOffset,
    required this.observedAt,
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

  factory CityModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> coord =
        (json['coord'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, dynamic> main =
        (json['main'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, dynamic> wind =
        (json['wind'] as Map?)?.cast<String, dynamic>() ?? {};
    final Map<String, dynamic> sys =
        (json['sys'] as Map?)?.cast<String, dynamic>() ?? {};

    final List weatherList = (json['weather'] as List?) ?? const [];
    final Map<String, dynamic> weather = weatherList.isNotEmpty
        ? (weatherList.first as Map).cast<String, dynamic>()
        : <String, dynamic>{};

    return CityModel(
      name: (json['name'] ?? '').toString(),
      country: (sys['country'] ?? '').toString(),
      latitude: _toDouble(coord['lat']),
      longitude: _toDouble(coord['lon']),
      temperature: _toDouble(main['temp']),
      feelsLike: _toDouble(main['feels_like']),
      tempMin: _toDouble(main['temp_min']),
      tempMax: _toDouble(main['temp_max']),
      humidity: _toInt(main['humidity']),
      pressure: _toInt(main['pressure']),
      windSpeed: _toDouble(wind['speed']),
      windDeg: _toInt(wind['deg']),
      main: (weather['main'] ?? '').toString(),
      description: (weather['description'] ?? '').toString(),
      icon: (weather['icon'] ?? '').toString(),
      sunrise: _toInt(sys['sunrise']),
      sunset: _toInt(sys['sunset']),
      timezoneOffset: _toInt(json['timezone']),
      observedAt: _toInt(json['dt']),
    );
  }

  bool get isNight => icon.endsWith('n');
}

/// A single entry in the user's search history, as returned by the
/// backend's /history endpoint.
class HistoryItem {
  final String id;
  final String city;
  final double? latitude;
  final double? longitude;
  final DateTime searchedAt;

  const HistoryItem({
    required this.id,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.searchedAt,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: (json['id'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      latitude: json['latitude'] == null
          ? null
          : (json['latitude'] as num).toDouble(),
      longitude: json['longitude'] == null
          ? null
          : (json['longitude'] as num).toDouble(),
      searchedAt:
          DateTime.tryParse(json['searched_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }
}
