// lib/models/book.dart

class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final String? thumbnail;
  final String saleability;
  final String? previewLink;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    this.thumbnail,
    required this.saleability,
    this.previewLink,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'] as Map<String, dynamic>;
    final saleInfo = json['saleInfo'] as Map<String, dynamic>?;
    return Book(
      id: json['id'] as String,
      title: volumeInfo['title'] as String? ?? 'No Title',
      authors: (volumeInfo['authors'] as List<dynamic>?)?.map((author) => author as String).toList() ?? ['Unknown Author'],
      description: volumeInfo['description'] as String? ?? 'No description available.',
      thumbnail: (volumeInfo['imageLinks'] as Map<String, dynamic>?)?['thumbnail'] as String?,
      saleability: saleInfo?['saleability'] as String? ?? 'NOT_FOR_SALE',
      previewLink: volumeInfo['previewLink'] as String?,
    );
  }
}