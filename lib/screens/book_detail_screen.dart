// lib/screens/book_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';
import '../providers/continue_reading_provider.dart';
import '../providers/favorites_provider.dart';
// ✅ FIX: The import for 'reader_screen.dart' has been removed

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  Future<void> _launchURL(String? urlString, BuildContext context) async {
    if (urlString != null && await canLaunchUrl(Uri.parse(urlString))) {
      await launchUrl(Uri.parse(urlString));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, provider, child) {
              final isBookFavorite = provider.isFavorite(book.id);
              return IconButton(
                tooltip: 'Add to favorites',
                icon: Icon(
                  isBookFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isBookFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  provider.toggleFavorite(book.id);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Hero(
              tag: 'book_cover_${book.id}',
              child: Container(
                height: 250,
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                  image: (book.thumbnail != null) ? DecorationImage(image: NetworkImage(book.thumbnail!), fit: BoxFit.cover) : null,
                ),
                child: (book.thumbnail == null) ? const Icon(Icons.book_outlined, size: 80, color: Colors.grey) : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Text(book.title, textAlign: TextAlign.center, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("by ${book.authors.join(', ')}", textAlign: TextAlign.center, style: textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
                ],
              ),
            ),
            const Divider(height: 40, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(book.description, textAlign: TextAlign.justify, style: textTheme.bodyLarge?.copyWith(height: 1.6)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: _buildActionButton(context, book),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, Book book) {
    bool hasPreview = book.previewLink != null;
    if ((book.saleability == 'FREE' || book.saleability == 'FOR_SALE') && hasPreview) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.chrome_reader_mode_outlined),
        label: const Text('Read Preview'),
        onPressed: () {
          Provider.of<ContinueReadingProvider>(context, listen: false).addBook(book.id);
          _launchURL(book.previewLink, context);
        },
      );
    }
    else {
      return ElevatedButton.icon(
        icon: const Icon(Icons.block),
        label: const Text('Not Available'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey,
        ),
        onPressed: null,
      );
    }
  }
}