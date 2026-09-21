import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../models/air_quality_model.dart';

import '../models/city_model.dart';
import '../models/favorite_model.dart';
import '../models/weather_model.dart';
import '../utils/app_constants.dart';

/// Thrown whenever a request to the backend fails, with a message that is
/// already safe/friendly to show directly in the UI.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Bundles the current weather + forecast for one search, exactly what the
/// home screen needs after the user searches a city.
class WeatherBundle {
  final CityModel city;
  final List<ForecastItem> forecast;

  const WeatherBundle({required this.city, required this.forecast});
}

class ApiService {
  final String _baseUrl;

  ApiService({String? baseUrl}) : _baseUrl = baseUrl ?? AppConstants.baseUrl;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    return Uri.parse('$_baseUrl$path').replace(
      queryParameters: query?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }

  Future<dynamic> _getJson(Uri uri) async {
    try {
      final response = await http.get(uri).timeout(AppConstants.requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      }

      String detail = 'Something went wrong (${response.statusCode}).';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['detail'] != null) {
          detail = decoded['detail'].toString();
        }
      } catch (_) {
        // ignore body-parsing errors, keep the generic message
      }
      throw ApiException(detail);
    } on SocketException {
      throw const ApiException(
        'Could not reach the server. Check your internet / backend URL.',
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  /// Fetches current weather + 5-day/3-hour forecast for [city] in a single
  /// call, and (server-side) logs it into the search history.
  Future<WeatherBundle> fetchWeatherFor(String city) async {
    final json = await _getJson(
      _uri('/weather/full/${Uri.encodeComponent(city)}'),
    );

    final cityJson = (json['city'] as Map).cast<String, dynamic>();
    final forecastJson = (json['forecast'] as Map).cast<String, dynamic>();
    final list = forecastJson['list'] as List<dynamic>?;

    return WeatherBundle(
      city: CityModel.fromJson(cityJson),
      forecast: ForecastItem.listFromJson(list),
    );
  }

  Future<List<HistoryItem>> fetchHistory() async {
    final json = await _getJson(_uri('/history'));
    final list = (json as List<dynamic>);
    return list
        .whereType<Map>()
        .map((e) => HistoryItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<void> deleteHistoryItem(String id) async {
    try {
      final response = await http
          .delete(_uri('/history/$id'))
          .timeout(AppConstants.requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ApiException('Could not delete this item.');
      }
    } on SocketException {
      throw const ApiException('Could not reach the server.');
    }
  }

  Future<void> clearHistory() async {
    try {
      final response = await http
          .delete(_uri('/history'))
          .timeout(AppConstants.requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ApiException('Could not clear history.');
      }
    } on SocketException {
      throw const ApiException('Could not reach the server.');
    }
  }

  // ---------------------------------------------------------------------
  // Air quality
  // ---------------------------------------------------------------------

  Future<AirQualityModel> fetchAirQuality(
    double latitude,
    double longitude,
  ) async {
    final json = await _getJson(
      _uri('/weather/air-quality', {
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    final data = (json['data'] as Map).cast<String, dynamic>();
    return AirQualityModel.fromJson(data);
  }
  // ---------------------------------------------------------------------
  // Favorites
  // ---------------------------------------------------------------------

  Future<List<FavoriteItem>> fetchFavorites() async {
    final json = await _getJson(_uri('/favorites'));
    final list = (json as List<dynamic>);
    return list
        .whereType<Map>()
        .map((e) => FavoriteItem.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  /// Fetches weather straight from GPS coordinates, skipping the city
  /// name lookup entirely.
  Future<WeatherBundle> fetchWeatherByLocation(
    double latitude,
    double longitude,
  ) async {
    final json = await _getJson(
      _uri('/weather/by-location', {
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    final cityJson = (json['city'] as Map).cast<String, dynamic>();
    final forecastJson = (json['forecast'] as Map).cast<String, dynamic>();
    final list = forecastJson['list'] as List<dynamic>?;

    return WeatherBundle(
      city: CityModel.fromJson(cityJson),
      forecast: ForecastItem.listFromJson(list),
    );
  }

  Future<FavoriteItem> addFavorite(
    String city, {
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http
          .post(
            _uri('/favorites'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'city': city,
              'latitude': latitude,
              'longitude': longitude,
            }),
          )
          .timeout(AppConstants.requestTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return FavoriteItem.fromJson(
          (jsonDecode(response.body) as Map).cast<String, dynamic>(),
        );
      }
      throw const ApiException('Could not add this city to favorites.');
    } on SocketException {
      throw const ApiException('Could not reach the server.');
    }
  }

  Future<void> removeFavoriteById(String id) async {
    try {
      final response = await http
          .delete(_uri('/favorites/$id'))
          .timeout(AppConstants.requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ApiException('Could not remove this favorite.');
      }
    } on SocketException {
      throw const ApiException('Could not reach the server.');
    }
  }

  Future<void> removeFavoriteByCity(String city) async {
    try {
      final response = await http
          .delete(_uri('/favorites/by-city/${Uri.encodeComponent(city)}'))
          .timeout(AppConstants.requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ApiException('Could not remove this favorite.');
      }
    } on SocketException {
      throw const ApiException('Could not reach the server.');
    }
  }
}
