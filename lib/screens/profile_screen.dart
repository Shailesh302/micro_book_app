// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/continue_reading_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/streak_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showThemeSelectionDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'), value: ThemeMode.light, groupValue: themeProvider.themeMode,
              onChanged: (value) { if (value != null) themeProvider.setThemeMode(value); Navigator.of(context).pop(); },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'), value: ThemeMode.dark, groupValue: themeProvider.themeMode,
              onChanged: (value) { if (value != null) themeProvider.setThemeMode(value); Navigator.of(context).pop(); },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'), value: ThemeMode.system, groupValue: themeProvider.themeMode,
              onChanged: (value) { if (value != null) themeProvider.setThemeMode(value); Navigator.of(context).pop(); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = snapshot.data;

          return Consumer3<FavoritesProvider, ContinueReadingProvider, StreakProvider>(
            builder: (context, favoritesProvider, continueReadingProvider, streakProvider, child) {
              final theme = Theme.of(context);
              return Scaffold(
                appBar: AppBar(
                  title: const Text('My Dashboard'),
                  centerTitle: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                      },
                    )
                  ],
                ),
                body: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                          child: user?.photoURL == null ? const Icon(Icons.person, size: 35) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.displayName ?? user?.email?.split('@').first ?? 'User',
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(user?.email ?? 'user@example.com', style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 40),
                    Text('Activity', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard(context, icon: Icons.local_fire_department, value: streakProvider.currentStreak.toString(), label: 'Current Streak')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(context, icon: Icons.bookmark, value: continueReadingProvider.continueReadingIds.length.toString(), label: 'Reading')),
                        const SizedBox(width: 16),
                        Expanded(child: _buildStatCard(context, icon: Icons.favorite, value: favoritesProvider.favoriteBookIds.length.toString(), label: 'Favorites')),
                      ],
                    ),
                    const Divider(height: 40),
                    Text('Reading Calendar', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Card(
                      child: Consumer<StreakProvider>(
                        builder: (context, streakProvider, child) {
                          return TableCalendar(
                            focusedDay: DateTime.now(),
                            firstDay: DateTime.now().subtract(const Duration(days: 365)),
                            lastDay: DateTime.now().add(const Duration(days: 365)),
                            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.5), shape: BoxShape.circle),
                              selectedDecoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                            ),
                            eventLoader: (day) => streakProvider.completedDates.contains(DateTime(day.year, day.month, day.day)) ? [1] : [],
                            calendarBuilders: CalendarBuilders(
                              markerBuilder: (context, date, events) {
                                if (events.isNotEmpty) return Positioned(right: 1, bottom: 1, child: Icon(Icons.local_fire_department, color: Colors.orange.shade700, size: 18));
                                return null;
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 40),
                    Text('Settings', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.palette_outlined),
                            title: const Text('App Appearance'),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                            onTap: () => _showThemeSelectionDialog(context, Provider.of<ThemeProvider>(context, listen: false)),
                          ),
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.redAccent),
                            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                            onTap: () => Provider.of<AuthService>(context, listen: false).signOut(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ✅ THIS IS THE COMPLETE, CORRECTED HELPER METHOD
  Widget _buildStatCard(BuildContext context, {required IconData icon, required String value, required String label}) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label, style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}