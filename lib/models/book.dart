// lib/models/book.dart

class Book {
  final String? id;
  final String title;
  final String author;
  final String genre;
  final int pages;
  final int pagesRead;
  final String status; // 'wishlist' | 'reading' | 'done'
  final double rating;
  final String notes;
  final String synopsis;
  final String coverUrl;
  final int year;
  final DateTime addedAt;

  Book({
    this.id,
    required this.title,
    required this.author,
    this.genre = '',
    required this.pages,
    this.pagesRead = 0,
    this.status = 'wishlist',
    this.rating = 0,
    this.notes = '',
    this.synopsis = '',
    this.coverUrl = '',
    this.year = 0,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  // Status label yang ramah pengguna
  String get statusLabel {
    switch (status) {
      case 'reading':
        return 'Sedang Dibaca';
      case 'done':
        return 'Selesai';
      default:
        return 'Wishlist';
    }
  }

  // Persentase progress membaca (0.0 – 1.0)
  double get progress {
    if (pages == 0) return 0;
    return (pagesRead / pages).clamp(0.0, 1.0);
  }

  // Konversi ke Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'pages': pages,
      'pages_read': pagesRead,
      'status': status,
      'rating': rating,
      'notes': notes,
      'synopsis': synopsis,
      'cover_url': coverUrl,
      'year': year,
      'added_at': addedAt.toIso8601String(),
    };
  }

  // Buat Book dari Map SQLite
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      genre: map['genre'] ?? '',
      pages: map['pages'] ?? 0,
      pagesRead: map['pages_read'] ?? 0,
      status: map['status'] ?? 'wishlist',
      rating: (map['rating'] ?? 0).toDouble(),
      notes: map['notes'] ?? '',
      synopsis: map['synopsis'] ?? '',
      coverUrl: map['cover_url'] ?? '',
      year: map['year'] ?? 0,
      addedAt: DateTime.tryParse(map['added_at'] ?? '') ?? DateTime.now(),
    );
  }

  // CopyWith untuk update sebagian field
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? genre,
    int? pages,
    int? pagesRead,
    String? status,
    double? rating,
    String? notes,
    String? synopsis,
    String? coverUrl,
    int? year,
    DateTime? addedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      pages: pages ?? this.pages,
      pagesRead: pagesRead ?? this.pagesRead,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      synopsis: synopsis ?? this.synopsis,
      coverUrl: coverUrl ?? this.coverUrl,
      year: year ?? this.year,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  String toString() => 'Book(id: $id, title: $title, author: $author)';
}
