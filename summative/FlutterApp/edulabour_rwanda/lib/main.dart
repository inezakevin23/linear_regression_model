import 'package:flutter/material.dart';

import 'screens/prediction_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EduLabourApp());
}

class EduLabourApp extends StatelessWidget {
  const EduLabourApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryNavy = Color(0xFF0F294A);
    const accentTeal = Color(0xFF0D9488);
    const canvasLight = Color(0xFFF4F6F9);

    return MaterialApp(
      title: 'EduLabour Rwanda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          primary: primaryNavy,
          secondary: accentTeal,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: canvasLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryNavy, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.4),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFF334155),
            fontWeight: FontWeight.w500,
          ),
          helperStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primaryNavy,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
      home: const PredictionScreen(),
    );
  }
}
