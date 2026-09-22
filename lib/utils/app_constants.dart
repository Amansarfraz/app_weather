/// App wide constants: API base URL, timing, limits.
class AppConstants {
  AppConstants._();

  /// Backend base URL.
  ///
  /// IMPORTANT — change this depending on where you run the app:
  ///  - Android emulator  -> http://10.0.2.2:8000   (maps to your PC's localhost)
  ///  - iOS simulator     -> http://127.0.0.1:8000
  ///  - Real phone (same Wi-Fi as your PC) -> http://<your-pc-LAN-ip>:8000
  ///  - Web / Windows / macOS / Linux desktop -> http://127.0.0.1:8000
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const Duration splashDuration = Duration(milliseconds: 2600);
  static const Duration requestTimeout = Duration(seconds: 20);

  static const int maxHourlyItems = 8; // ~24 hours of 3-hour slots
  static const int maxHistoryItems = 20;

  static const String appName = 'AuraWeather';
  static const String appTagline = 'Weather, beautifully clear';
  static const String logoAssetPath = 'assets/images/app_logo.png';
}
