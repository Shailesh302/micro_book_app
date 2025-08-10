// lib/providers/favorites_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  // We use the book's title as a unique ID for now.
  List<String> _favoriteBookIds = [];
  static const _favoritesKey = 'favorites';

  List<String> get favoriteBookIds => _favoriteBookIds;

  FavoritesProvider() {
    _loadFavorites(); // Load saved favorites when the app starts
  }

  // Toggles a book's favorite status
  void toggleFavorite(String bookId) {
    if (_favoriteBookIds.contains(bookId)) {
      _favoriteBookIds.remove(bookId);
    } else {
      _favoriteBookIds.add(bookId);
    }
    _saveFavorites();
    notifyListeners(); // Notify widgets to rebuild
  }

  // Checks if a book is a favorite
  bool isFavorite(String bookId) {
    return _favoriteBookIds.contains(bookId);
  }

  // Saves the list of favorites to the device
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteBookIds);
  }

  // Loads the list of favorites from the device
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    _favoriteBookIds = prefs.getStringList(_favoritesKey) ?? [];
    notifyListeners();
  }
}