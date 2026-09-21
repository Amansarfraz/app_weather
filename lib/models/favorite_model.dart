/// A single favorited (starred) city, as returned by the backend's
/// /favorites endpoint.
class FavoriteItem {
  final String id;
  final String city;
  final double? latitude;
  final double? longitude;
  final DateTime addedAt;

  const FavoriteItem({
    required this.id,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.addedAt,
  });

  factory FavoriteItem.fromJson(Map<String, dynamic> json) {
    return FavoriteItem(
      id: (json['id'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      latitude: json['latitude'] == null
          ? null
          : (json['latitude'] as num).toDouble(),
      longitude: json['longitude'] == null
          ? null
          : (json['longitude'] as num).toDouble(),
      addedAt:
          DateTime.tryParse(json['added_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
