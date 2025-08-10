// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/favorites_provider.dart';
import 'providers/continue_reading_provider.dart';
import 'providers/streak_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart'; // <-- ADD THIS IMPORT
import 'widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        // ✅ ADD YOUR AUTHSERVICE PROVIDER HERE
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (context) => FavoritesProvider()),
        ChangeNotifierProvider(create: (context) => ContinueReadingProvider()),
        ChangeNotifierProvider(create: (context) => StreakProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MicroBookApp(),
    ),
  );
}

class MicroBookApp extends StatelessWidget {
  const MicroBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00796B),
        brightness: Brightness.light,
        primary: const Color(0xFF00796B),
        secondary: const Color(0xFFFFA000),
        surface: Colors.white,
        background: const Color(0xFFF5F5F5),
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        color: Colors.white,
        shadowColor: Colors.grey.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00796B),
        unselectedItemColor: Colors.grey.shade600,
        elevation: 2,
      ),
    );

    final darkTheme = ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4DB6AC),
        brightness: Brightness.dark,
        primary: const Color(0xFF4DB6AC),
        secondary: const Color(0xFFFFCA28),
        surface: const Color(0xFF2C3E50),
        background: const Color(0xFF1B2631),
      ),
      scaffoldBackgroundColor: const Color(0xFF1B2631),
      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme.apply(
        displayColor: Colors.white,
        bodyColor: Colors.grey.shade400,
      )),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF2C3E50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF2C3E50),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade600,
      ),
    );

    return MaterialApp(
      title: 'Micro-Book App',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}