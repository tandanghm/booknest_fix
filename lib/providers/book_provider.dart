// lib/providers/book_provider.dart

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/book.dart';
import '../database/book_database.dart';

class BookProvider extends ChangeNotifier {
  final _db = BookDatabase.instance;
  final _uuid = const Uuid();

  List<Book> _books = [];
  List<Book> _filteredBooks = [];
  String _searchQuery = '';
  String _filterStatus = 'all'; // 'all' | 'reading' | 'done' | 'wishlist'
  bool _isLoading = false;
  String? _error;

  // Reading Goal
  int _readingGoal = 24;
  int _currentYear = DateTime.now().year;

  // ──────────────────────────────────────────────
  // Getters
  // ──────────────────────────────────────────────

  List<Book> get books => _filteredBooks;
  List<Book> get allBooks => _books;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;
  String get searchQuery => _searchQuery;
  int get readingGoal => _readingGoal;

  // Buku yang sedang dibaca (untuk beranda)
  List<Book> get currentlyReading =>
      _books.where((b) => b.status == 'reading').toList();

  // Buku terbaru 5 buku (untuk beranda)
  List<Book> get recentBooks => _books.take(5).toList();

  // Jumlah buku selesai tahun ini (untuk reading goal)
  int get booksFinishedThisYear {
    return _books.where((b) =>
        b.status == 'done' && b.addedAt.year == _currentYear).length;
  }

  double get readingGoalProgress =>
      (booksFinishedThisYear / _readingGoal).clamp(0.0, 1.0);

  // ──────────────────────────────────────────────
  // Load Data
  // ──────────────────────────────────────────────

  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _books = await _db.getAllBooks();
      _applyFilter();
    } catch (e) {
      _error = 'Gagal memuat data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────
  // CRUD Operations
  // ──────────────────────────────────────────────

  Future<bool> addBook({
    required String title,
    required String author,
    required String genre,
    required int pages,
    required String status,
    double rating = 0,
    String notes = '',
    String synopsis = '',
    String coverUrl = '',
    int year = 0,
  }) async {
    try {
      final book = Book(
        id: _uuid.v4(),
        title: title.trim(),
        author: author.trim(),
        genre: genre,
        pages: pages,
        status: status,
        rating: rating,
        notes: notes.trim(),
        synopsis: synopsis.trim(),
        coverUrl: coverUrl,
        year: year,
      );

      await _db.createBook(book);
      _books.insert(0, book);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menambah buku: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBook(Book book) async {
    try {
      await _db.updateBook(book);
      final idx = _books.indexWhere((b) => b.id == book.id);
      if (idx != -1) {
        _books[idx] = book;
        _applyFilter();
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = 'Gagal mengupdate buku: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProgress(String id, int pagesRead) async {
    try {
      await _db.updateProgress(id, pagesRead);
      final idx = _books.indexWhere((b) => b.id == id);
      if (idx != -1) {
        _books[idx] = _books[idx].copyWith(pagesRead: pagesRead);
        _applyFilter();
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status) async {
    try {
      await _db.updateStatus(id, status);
      final idx = _books.indexWhere((b) => b.id == id);
      if (idx != -1) {
        _books[idx] = _books[idx].copyWith(status: status);
        _applyFilter();
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBook(String id) async {
    try {
      await _db.deleteBook(id);
      _books.removeWhere((b) => b.id == id);
      _applyFilter();
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal menghapus buku: $e';
      notifyListeners();
      return false;
    }
  }

  // ──────────────────────────────────────────────
  // Search & Filter
  // ──────────────────────────────────────────────

  void setSearch(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var result = List<Book>.from(_books);

    // Filter by status
    if (_filterStatus != 'all') {
      result = result.where((b) => b.status == _filterStatus).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((b) {
        return b.title.toLowerCase().contains(q) ||
            b.author.toLowerCase().contains(q) ||
            b.genre.toLowerCase().contains(q);
      }).toList();
    }

    _filteredBooks = result;
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilter();
    notifyListeners();
  }

  // ──────────────────────────────────────────────
  // Stats
  // ──────────────────────────────────────────────

  Future<Map<String, int>> getStats() => _db.getStats();
  Future<Map<String, int>> getGenreDistribution() => _db.getGenreDistribution();
  Future<double> getAverageRating() => _db.getAverageRating();

  void setReadingGoal(int goal) {
    _readingGoal = goal;
    notifyListeners();
  }
}
