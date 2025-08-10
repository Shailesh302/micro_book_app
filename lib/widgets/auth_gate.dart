// lib/widgets/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_page.dart';
import '../screens/main_screen.dart';
import '../screens/permission_welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // Helper method to decide which screen to show
  Future<Widget> _getHomeScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasSeenPermissions = prefs.getBool('permissions_viewed') ?? false;

    if (hasSeenPermissions) {
      return const MainScreen();
    } else {
      return const PermissionWelcomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // If the user is logged in
        if (snapshot.hasData) {
          // Use a FutureBuilder to check the permissions flag before navigating
          return FutureBuilder<Widget>(
            future: _getHomeScreen(),
            builder: (context, screenSnapshot) {
              if (screenSnapshot.connectionState == ConnectionState.done) {
                return screenSnapshot.data ?? const MainScreen();
              }
              // Show a loading indicator while checking the flag
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            },
          );
        }

        // If the user is not logged in
        return const LoginPage();
      },
    );
  }
}