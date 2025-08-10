// lib/screens/continue_reading_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/continue_reading_provider.dart';
import '../services/book_service.dart';
import 'book_detail_screen.dart';

class ContinueReadingScreen extends StatefulWidget {
  const ContinueReadingScreen({super.key});

  @override
  State<ContinueReadingScreen> createState() => _ContinueReadingScreenState();
}

class _ContinueReadingScreenState extends State<ContinueReadingScreen> {
  final BookService _bookService = BookService();

  Future<List<Book>> _fetchBooks(List<String> bookIds) {
    return Future.wait(
      bookIds.map((id) => _bookService.fetchBookById(id)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ContinueReadingProvider>(context);
    final bookIds = provider.continueReadingIds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Continue Reading'),
        centerTitle: true,
      ),
      body: bookIds.isEmpty
          ? const Center(
        child: Text(
          'Books you start reading will appear here.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : FutureBuilder<List<Book>>(
        future: _fetchBooks(bookIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Could not load books.'));
          }
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
                    backgroundImage: book.thumbnail != null
                        ? NetworkImage(book.thumbnail!)
                        : null,
                  ),
                  title: Text(book.title,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(book.authors.join(', ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                    onPressed: () {
                      provider.removeBook(book.id);
                    },
                  ),
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