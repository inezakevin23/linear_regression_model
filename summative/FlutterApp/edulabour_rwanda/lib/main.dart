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
    const seedColor = Color(0xFF245B8F);

    return MaterialApp(
      title: 'EduLabour Rwanda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F9FC),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: const PredictionScreen(),
    );
  }
}
