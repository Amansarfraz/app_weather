import 'package:flutter/material.dart';

import '../models/air_quality_model.dart';
import '../models/city_model.dart';
import '../models/weather_model.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/share_helper.dart';
import '../utils/temperature_unit.dart';
import '../widgets/air_quality_card.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/hourly_weather_card.dart';
import '../widgets/temperature_chart.dart';
import 'favorites_screen.dart';
import 'history_screen.dart';
import 'weather_screen.dart';

/// Shows everything about one city's weather: current conditions, air
/// quality, temperature trend, hourly strip, and a way to open the 5-day
/// forecast, favorites, and history. Reached from the home screen after a
/// search or "use my location".
class WeatherDetailsScreen extends StatefulWidget {
  final String? cityQuery;
  final double? latitude;
  final double? longitude;

  const WeatherDetailsScreen({
    super.key,
    this.cityQuery,
    this.latitude,
    this.longitude,
  }) : assert(cityQuery != null || (latitude != null && longitude != null));

  @override
  State<WeatherDetailsScreen> createState() => _WeatherDetailsScreenState();
}

class _WeatherDetailsScreenState extends State<WeatherDetailsScreen> {
  final ApiService _apiService = ApiService();
  final GlobalKey _weatherCardKey = GlobalKey();

  bool _isLoading = true;
  String? _error;
  CityModel? _city;
  List<ForecastItem> _forecast = [];
  AirQualityModel? _airQuality;

  Set<String> _favoriteCities = {};
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _load();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _apiService.fetchFavorites();
      if (!mounted) return;
      setState(() {
        _favoriteCities = favorites.map((f) => f.city.toLowerCase()).toSet();
      });
    } catch (_) {
      // Silent: favorites are a nice-to-have.
    }
  }

  Future<void> _load({String? overrideCity}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bundle = overrideCity != null
          ? await _apiService.fetchWeatherFor(overrideCity)
          : widget.cityQuery != null
          ? await _apiService.fetchWeatherFor(widget.cityQuery!)
          : await _apiService.fetchWeatherByLocation(
              widget.latitude!,
              widget.longitude!,
            );

      if (!mounted) return;
      setState(() {
        _city = bundle.city;
        _forecast = bundle.forecast;
        _isLoading = false;
      });
      _loadAirQuality(bundle.city.latitude, bundle.city.longitude);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAirQuality(double latitude, double longitude) async {
    setState(() => _airQuality = null);
    try {
      final aq = await _apiService.fetchAirQuality(latitude, longitude);
      if (!mounted) return;
      setState(() => _airQuality = aq);
    } catch (_) {
      // Silent: nice-to-have.
    }
  }

  bool get _isCurrentCityFavorite =>
      _city != null && _favoriteCities.contains(_city!.name.toLowerCase());

  Future<void> _toggleFavorite() async {
    final city = _city;
    if (city == null || _isTogglingFavorite) return;

    setState(() => _isTogglingFavorite = true);
    final wasFavorite = _isCurrentCityFavorite;

    try {
      if (wasFavorite) {
        await _apiService.removeFavoriteByCity(city.name);
        if (!mounted) return;
        setState(() => _favoriteCities.remove(city.name.toLowerCase()));
      } else {
        await _apiService.addFavorite(
          city.name,
          latitude: city.latitude,
          longitude: city.longitude,
        );
        if (!mounted) return;
        setState(() => _favoriteCities.add(city.name.toLowerCase()));
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isTogglingFavorite = false);
    }
  }

  Future<void> _shareWeatherCard() async {
    try {
      final cityName = _city?.name ?? 'this location';
      await ShareHelper.shareWidgetAsImage(
        _weatherCardKey,
        fileName: 'weather_$cityName.png',
        text: 'Weather in $cityName',
      );
    } on ShareException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _openHistory() async {
    final selectedCity = await Navigator.of(
      context,
    ).push<String>(AppRoutes.slide(const HistoryScreen()));
    if (selectedCity != null && selectedCity.isNotEmpty) {
      _load(overrideCity: selectedCity);
    }
  }

  Future<void> _openFavorites() async {
    final selectedCity = await Navigator.of(
      context,
    ).push<String>(AppRoutes.slide(const FavoritesScreen()));
    if (selectedCity != null && selectedCity.isNotEmpty) {
      _load(overrideCity: selectedCity);
    }
  }

  void _openFiveDayForecast() {
    if (_city == null || _forecast.isEmpty) return;
    Navigator.of(context).push(
      AppRoutes.slide(
        WeatherScreen(cityName: _city!.name, forecast: _forecast),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = AppColors.gradientForCondition(
      _city?.main,
      isNight: _city?.isNight ?? false,
    );

    final now = DateTime.now();
    final hourly = _forecast
        .where(
          (item) =>
              item.dateTime.isAfter(now.subtract(const Duration(hours: 3))),
        )
        .take(AppConstants.maxHourlyItems)
        .toList();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 12, 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        _city?.name ?? 'Weather',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const _UnitToggleButton(),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.star_rounded, color: Colors.white),
                      onPressed: _openFavorites,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.history_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _openHistory,
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildBody(hourly)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<ForecastItem> hourly) {
    if (_isLoading && _city == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return _MessageState(
        icon: Icons.cloud_off_rounded,
        title: "Couldn't load weather",
        message: _error!,
        actionLabel: 'Try again',
        onAction: () => _load(),
      );
    }

    if (_city == null) return const SizedBox.shrink();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          RepaintBoundary(
            key: _weatherCardKey,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: CurrentWeatherCard(
                key: ValueKey(_city!.name + _city!.observedAt.toString()),
                weather: _city!,
                isFavorite: _isCurrentCityFavorite,
                onToggleFavorite: _toggleFavorite,
                onShare: _shareWeatherCard,
              ),
            ),
          ),
          if (_airQuality != null) ...[
            const SizedBox(height: 16),
            AirQualityCard(airQuality: _airQuality!),
          ],
          if (hourly.length >= 2) ...[
            const SizedBox(height: 16),
            TemperatureChart(items: hourly),
          ],
          if (hourly.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                'Next hours',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              height: 118,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourly.length,
                itemBuilder: (context, index) =>
                    HourlyWeatherCard(item: hourly[index], isNow: index == 0),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openFiveDayForecast,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.glassBorder),
                ),
              ),
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('View 5-Day Forecast'),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitToggleButton extends StatelessWidget {
  const _UnitToggleButton();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: TemperatureUnit.isFahrenheit,
      builder: (context, isFahrenheit, _) {
        return IconButton(
          onPressed: TemperatureUnit.toggle,
          icon: Text(
            isFahrenheit ? '°F' : '°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      },
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
