// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/favorites_provider.dart';
import '../services/book_service.dart';
import 'book_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final BookService _bookService = BookService();

  // This function fetches all favorite books by mapping over the IDs
  Future<List<Book>> _fetchFavoriteBooks(List<String> bookIds) {
    // Future.wait runs all API calls in parallel for efficiency
    return Future.wait(
      bookIds.map((id) => _bookService.fetchBookById(id)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for changes in the favorites provider
    final provider = Provider.of<FavoritesProvider>(context);
    final favoriteBookIds = provider.favoriteBookIds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
      ),
      body: favoriteBookIds.isEmpty
      // If there are no favorites, show the placeholder message
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Your favorite books will appear here.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      )
      // If there are favorites, fetch them using a FutureBuilder
          : FutureBuilder<List<Book>>(
        future: _fetchFavoriteBooks(favoriteBookIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Could not load favorites.'));
          }

          final favoriteBooks = snapshot.data!;
          // Display the list of favorite books
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: favoriteBooks.length,
            itemBuilder: (context, index) {
              final book = favoriteBooks[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    backgroundImage: book.thumbnail != null
                        ? NetworkImage(book.thumbnail!)
                        : null,
                    child: book.thumbnail == null
                        ? const Icon(Icons.menu_book, color: Colors.white)
                        : null,
                  ),
                  contentPadding: const EdgeInsets.all(10),
                  title: Text(book.title,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
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