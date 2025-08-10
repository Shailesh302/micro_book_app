// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/streak_provider.dart';
import 'book_list_screen.dart';
import 'timer_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _allCategories = [
    {'name': 'Self-help', 'icon': Icons.self_improvement}, {'name': 'Psychology', 'icon': Icons.psychology}, {'name': 'Business', 'icon': Icons.business_center}, {'name': 'Technology', 'icon': Icons.memory}, {'name': 'Fiction', 'icon': Icons.auto_stories}, {'name': 'Science', 'icon': Icons.science}, {'name': 'History', 'icon': Icons.history_edu_outlined}, {'name': 'Biography', 'icon': Icons.person_pin_outlined}, {'name': 'Philosophy', 'icon': Icons.lightbulb_outline}, {'name': 'Health', 'icon': Icons.fitness_center_outlined}, {'name': 'Productivity', 'icon': Icons.show_chart_outlined}, {'name': 'Marketing', 'icon': Icons.campaign_outlined},
  ];
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = _allCategories;
  }

  void _filterCategories(String query) {
    List<Map<String, dynamic>> filteredList;
    if (query.isEmpty) {
      filteredList = _allCategories;
    } else {
      filteredList = _allCategories.where((category) => category['name'].toLowerCase().contains(query.toLowerCase())).toList();
    }
    setState(() {
      _filteredCategories = filteredList;
    });
  }

  // ✅ THIS IS THE MISSING METHOD
  void _showTimeSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.timer_10_outlined),
                title: const Text('10 Minutes'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const TimerScreen(durationInMinutes: 10),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer_outlined),
                title: const Text('15 Minutes'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const TimerScreen(durationInMinutes: 15),
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.timelapse_outlined),
                title: const Text('30 Minutes'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const TimerScreen(durationInMinutes: 30),
                  ));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          final user = snapshot.data;

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Hello, ${user?.displayName ?? user?.email?.split('@').first ?? 'Reader'}!',
                            style: textTheme.titleMedium
                        ),
                        Text('Find your next great read', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          label: const Text('Start Daily Reading Session'),
                          onPressed: () => _showTimeSelectionSheet(context),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          onChanged: _filterCategories,
                          decoration: InputDecoration(
                            hintText: 'Search for categories...',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Theme.of(context).cardTheme.color,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Categories', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                AnimationLimiter(
                  child: SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16,
                        childAspectRatio: 1.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final category = _filteredCategories[index];
                          return AnimationConfiguration.staggeredGrid(
                            position: index, columnCount: 2, duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Card(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookListScreen(category: category['name']))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(category['icon'], size: 40, color: colorScheme.primary),
                                          Text(
                                            category['name'],
                                            style: textTheme.titleLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: _filteredCategories.length,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}