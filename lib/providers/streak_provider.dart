// lib/providers/streak_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class StreakProvider extends ChangeNotifier {
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastSessionDate;
  final Set<DateTime> _completedDates = {};

  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  Set<DateTime> get completedDates => _completedDates;

  StreakProvider() {
    _loadStreakData();
  }

  void startReadingSession() {
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);

    if (_lastSessionDate == null) {
      // First session ever
      _currentStreak = 1;
    } else {
      final lastDateOnly = DateTime(_lastSessionDate!.year, _lastSessionDate!.month, _lastSessionDate!.day);

      // If the last session was yesterday
      if (isSameDay(lastDateOnly, todayDateOnly.subtract(const Duration(days: 1)))) {
        _currentStreak++;
      }
      // If the last session was not today (and not yesterday), reset the streak
      else if (!isSameDay(lastDateOnly, todayDateOnly)) {
        _currentStreak = 1;
      }
      // If the last session was today, do nothing to the streak count
    }

    // Update longest streak if necessary
    if (_currentStreak > _longestStreak) {
      _longestStreak = _currentStreak;
    }

    // Update the last session date and add to completed set
    _lastSessionDate = today;
    _completedDates.add(todayDateOnly);

    _saveStreakData();
    notifyListeners();
  }

  Future<void> _saveStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('longestStreak', _longestStreak);
    if (_lastSessionDate != null) {
      await prefs.setString('lastSessionDate', _lastSessionDate!.toIso8601String());
    }
    // Convert DateTime objects to strings to save them
    final dateStrings = _completedDates.map((date) => date.toIso8601String()).toList();
    await prefs.setStringList('completedDates', dateStrings);
  }

  Future<void> _loadStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _longestStreak = prefs.getInt('longestStreak') ?? 0;
    final lastDateString = prefs.getString('lastSessionDate');
    if (lastDateString != null) {
      _lastSessionDate = DateTime.parse(lastDateString);
    }
    final dateStrings = prefs.getStringList('completedDates') ?? [];
    _completedDates.clear();
    for (var dateString in dateStrings) {
      _completedDates.add(DateTime.parse(dateString));
    }
    notifyListeners();
  }
}