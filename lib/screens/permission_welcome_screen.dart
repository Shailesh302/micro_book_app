// lib/screens/permission_welcome_screen.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class PermissionWelcomeScreen extends StatelessWidget {
  const PermissionWelcomeScreen({super.key});

  Future<void> _requestPermissionsAndNavigate(BuildContext context) async {
    // Request all permissions at once
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();

    // Mark that the user has seen this screen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permissions_viewed', true);

    // Navigate to the main app, replacing this screen
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.shield_outlined, size: 80, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                'Permissions Required',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'To provide the best experience, our app needs a few permissions to function correctly. This includes access to storage for offline books and your camera for profile pictures.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _requestPermissionsAndNavigate(context),
                child: const Text('Allow Permissions'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}