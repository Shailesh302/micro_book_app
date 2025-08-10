// lib/providers/continue_reading_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContinueReadingProvider extends ChangeNotifier {
  List<String> _bookIds = [];
  static const _continueReadingKey = 'continue_reading';

  List<String> get continueReadingIds => _bookIds;

  ContinueReadingProvider() {
    _loadList();
  }

  void addBook(String bookId) {
    if (!_bookIds.contains(bookId)) {
      _bookIds.add(bookId);
      _saveList();
      notifyListeners();
    }
  }

  void removeBook(String bookId) {
    if (_bookIds.contains(bookId)) {
      _bookIds.remove(bookId);
      _saveList();
      notifyListeners();
    }
  }

  Future<void> _saveList() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_continueReadingKey, _bookIds);
  }

  Future<void> _loadList() async {
    final prefs = await SharedPreferences.getInstance();
    _bookIds = prefs.getStringList(_continueReadingKey) ?? [];
    notifyListeners();
  }
}