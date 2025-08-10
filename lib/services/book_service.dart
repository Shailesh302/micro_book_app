// lib/services/book_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  final String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  Future<List<Book>> fetchBooksByCategory(String category) async {
    // ... this method remains the same
    final String query = category.replaceAll(' ', '+');
    final response =
    await http.get(Uri.parse('$_baseUrl?q=subject:$query&maxResults=20'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> items = data['items'] ?? [];
      return items.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  // ✅ ADD THIS NEW METHOD
  // Fetches a single book by its unique volume ID
  Future<Book> fetchBookById(String bookId) async {
    final response = await http.get(Uri.parse('$_baseUrl/$bookId'));

    if (response.statusCode == 200) {
      return Book.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load book details');
    }
  }
}