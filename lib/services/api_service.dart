// lib/services/api_service.dart
// Menggunakan Open Library API (https://openlibrary.org/developers/api)

import 'dart:convert';
import 'package:http/http.dart' as http;

class BookSearchResult {
  final String title;
  final String author;
  final int year;
  final int pages;
  final String coverUrl;
  final String synopsis;
  final List<String> subjects;
  final String openLibraryKey;

  BookSearchResult({
    required this.title,
    required this.author,
    this.year = 0,
    this.pages = 0,
    this.coverUrl = '',
    this.synopsis = '',
    this.subjects = const [],
    this.openLibraryKey = '',
  });
}

class ApiService {
  static const _baseUrl = 'https://openlibrary.org';
  static const _coverUrl = 'https://covers.openlibrary.org/b/id';

  // Cari buku berdasarkan query (judul atau penulis)
  static Future<List<BookSearchResult>> searchBooks(String query,
      {int limit = 10}) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url =
          '$_baseUrl/search.json?q=$encodedQuery&limit=$limit&fields=key,title,author_name,first_publish_year,number_of_pages_median,cover_i,subject';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final docs = data['docs'] as List<dynamic>? ?? [];

      return docs.map((doc) {
        final coverId = doc['cover_i'];
        final cover =
            coverId != null ? '$_coverUrl/$coverId-M.jpg' : '';

        final authors = doc['author_name'] as List<dynamic>?;
        final author =
            authors != null && authors.isNotEmpty ? authors.first as String : 'Unknown';

        final subjects = (doc['subject'] as List<dynamic>?)
                ?.take(5)
                .map((s) => s.toString())
                .toList() ??
            [];

        return BookSearchResult(
          title: doc['title'] ?? '',
          author: author,
          year: doc['first_publish_year'] ?? 0,
          pages: doc['number_of_pages_median'] ?? 0,
          coverUrl: cover,
          subjects: subjects,
          openLibraryKey: doc['key'] ?? '',
        );
      }).where((b) => b.title.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }

  // Ambil detail buku dari Open Library (termasuk sinopsis)
  static Future<BookSearchResult?> getBookDetails(
      String openLibraryKey) async {
    try {
      final url = '$_baseUrl$openLibraryKey.json';
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);

      // Sinopsis bisa berupa String atau Map
      String synopsis = '';
      final desc = data['description'];
      if (desc is String) {
        synopsis = desc;
      } else if (desc is Map) {
        synopsis = desc['value'] ?? '';
      }

      return BookSearchResult(
        title: data['title'] ?? '',
        author: '',
        synopsis: synopsis.length > 500
            ? '${synopsis.substring(0, 500)}...'
            : synopsis,
        openLibraryKey: openLibraryKey,
      );
    } catch (e) {
      return null;
    }
  }
}
