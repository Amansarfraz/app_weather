import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/city_model.dart';
import '../utils/app_colors.dart';
import '../utils/temperature_unit.dart';
import '../utils/weather_icon_mapper.dart';

/// The big "hero" card on the home screen: city name, temperature, a
/// gently floating weather icon, and quick stat chips.
class CurrentWeatherCard extends StatefulWidget {
  final CityModel weather;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onShare;

  const CurrentWeatherCard({
    super.key,
    required this.weather,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.onShare,
  });

  @override
  State<CurrentWeatherCard> createState() => _CurrentWeatherCardState();
}

class _CurrentWeatherCardState extends State<CurrentWeatherCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _float = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.weather;
    final icon = WeatherIconMapper.iconFor(w.main, icon: w.icon);
    final updatedAt = w.observedAt > 0
        ? DateFormat(
            'h:mm a',
          ).format(DateTime.fromMillisecondsSinceEpoch(w.observedAt * 1000))
        : null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(children: [_buildCardContent(w, icon, updatedAt)]),
          if (widget.onToggleFavorite != null)
            Positioned(
              top: -8,
              right: -8,
              child: _RoundGlassButton(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    widget.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    key: ValueKey(widget.isFavorite),
                    color: widget.isFavorite ? AppColors.accent : Colors.white,
                    size: 24,
                  ),
                ),
                onTap: widget.onToggleFavorite!,
              ),
            ),
          if (widget.onShare != null)
            Positioned(
              top: -8,
              left: -8,
              child: _RoundGlassButton(
                child: const Icon(
                  Icons.share_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onTap: widget.onShare!,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent(CityModel w, IconData icon, String? updatedAt) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                w.country.isNotEmpty ? '${w.name}, ${w.country}' : w.name,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (updatedAt != null) ...[
          const SizedBox(height: 4),
          Text(
            'Updated $updatedAt',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _float,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _float.value),
              child: child,
            );
          },
          child: Icon(icon, size: 96, color: Colors.white),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: TemperatureUnit.isFahrenheit,
          builder: (context, _, __) {
            return Text(
              '${TemperatureUnit.convert(w.temperature).round()}${TemperatureUnit.suffix}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 72,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            );
          },
        ),
        Text(
          w.description.isNotEmpty
              ? w.description[0].toUpperCase() + w.description.substring(1)
              : '',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
        ),
        const SizedBox(height: 4),
        ValueListenableBuilder<bool>(
          valueListenable: TemperatureUnit.isFahrenheit,
          builder: (context, _, __) {
            final feelsLike = TemperatureUnit.convert(w.feelsLike).round();
            final min = TemperatureUnit.convert(w.tempMin).round();
            final max = TemperatureUnit.convert(w.tempMax).round();
            return Text(
              'Feels like $feelsLike°  ·  $min° / $max°',
              style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
            );
          },
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _StatChip(
                icon: Icons.water_drop_rounded,
                label: 'Humidity',
                value: '${w.humidity}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatChip(
                icon: Icons.air_rounded,
                label: 'Wind',
                value: '${w.windSpeed.toStringAsFixed(1)} m/s',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundGlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _RoundGlassButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.25),
      shape: const CircleBorder(side: BorderSide(color: AppColors.glassBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(10), child: child),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
