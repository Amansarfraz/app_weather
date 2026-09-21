import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'routes/app_routes.dart';
import 'screens/splash_screen.dart';
import 'utils/app_constants.dart';
import 'utils/temperature_unit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TemperatureUnit.init();
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTextTheme = ThemeData.dark().textTheme;

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E64FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF16222A),
        textTheme: GoogleFonts.poppinsTextTheme(baseTextTheme),
        splashFactory: InkRipple.splashFactory,
      ),
      initialRoute: AppRoutes.splash,
      routes: {AppRoutes.splash: (context) => const SplashScreen()},
    );
  }
}
