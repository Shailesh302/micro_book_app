// lib/screens/trending_screen.dart

import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'book_detail_screen.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({super.key});

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  late Future<List<Book>> _trendingBooksFuture;
  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
    // We'll fetch books from a popular category to simulate a "trending" list
    _trendingBooksFuture = _bookService.fetchBooksByCategory("popular psychology");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Books'),
        centerTitle: true,
      ),
      // Use a FutureBuilder to handle the loading and display of book data
      body: FutureBuilder<List<Book>>(
        future: _trendingBooksFuture,
        builder: (context, snapshot) {
          // While the data is loading, show a progress indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If there's an error, display it
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // If there's no data, show a message
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trending books found.'));
          }

          // When the data is ready, display it in a list
          final books = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade50,
                    backgroundImage: book.thumbnail != null
                        ? NetworkImage(book.thumbnail!)
                        : null,
                    child: book.thumbnail == null
                        ? const Icon(Icons.menu_book, color: Colors.deepPurple)
                        : null,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  title: Text(book.title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(book.authors.join(', ')),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(book: book),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}