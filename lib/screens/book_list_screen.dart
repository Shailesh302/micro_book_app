// lib/screens/book_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import 'book_detail_screen.dart';
import '../widgets/app_footer.dart'; // <-- ADD THIS IMPORT

class BookListScreen extends StatefulWidget {
  final String category;
  const BookListScreen({super.key, required this.category});
  @override
  State<BookListScreen> createState() => _BookListScreenState();
}
class _BookListScreenState extends State<BookListScreen> {
  late Future<List<Book>> _booksFuture;
  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _booksFuture = _bookService.fetchBooksByCategory(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('No books found.'));

          final books = snapshot.data!;
          return AnimationLimiter(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.7,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  columnCount: 2,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Card(
                        child: InkWell(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Hero(
                                  tag: 'book_cover_${book.id}',
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: (book.thumbnail != null)
                                        ? Image.network(book.thumbnail!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                        : const Icon(Icons.book_outlined, size: 40, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(book.title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(book.authors.join(', '), style: Theme.of(context).textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      // ✅ Add the footer to the bottom of this screen's Scaffold
      bottomNavigationBar: const AppFooter(),
    );
  }
}