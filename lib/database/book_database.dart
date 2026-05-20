// lib/database/book_database.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/book.dart';

class BookDatabase {
  static final BookDatabase instance = BookDatabase._init();
  static Database? _database;

  BookDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('booknest.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        genre TEXT,
        pages INTEGER NOT NULL DEFAULT 0,
        pages_read INTEGER NOT NULL DEFAULT 0,
        status TEXT NOT NULL DEFAULT 'wishlist',
        rating REAL NOT NULL DEFAULT 0,
        notes TEXT,
        synopsis TEXT,
        cover_url TEXT,
        year INTEGER,
        added_at TEXT NOT NULL
      )
    ''');

    // Seed data awal supaya app tidak kosong saat pertama dibuka
    final now = DateTime.now();
    final seedBooks = [
      {
        'id': 'book-1',
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'genre': 'Self-Help',
        'pages': 303,
        'pages_read': 217,
        'status': 'reading',
        'rating': 5.0,
        'notes': 'Kutipan favorit: "You don\'t rise to the level of your goals, you fall to the level of your systems."',
        'synopsis': 'Panduan praktis membentuk kebiasaan baik dan menghilangkan kebiasaan buruk melalui perubahan kecil yang konsisten.',
        'cover_url': '',
        'year': 2018,
        'added_at': now.subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 'book-2',
        'title': 'Sapiens',
        'author': 'Yuval Noah Harari',
        'genre': 'Sejarah',
        'pages': 443,
        'pages_read': 0,
        'status': 'wishlist',
        'rating': 0.0,
        'notes': 'Direkomendasikan oleh dosen. Masuk antrian berikutnya!',
        'synopsis': 'Sejarah singkat umat manusia sejak zaman batu hingga era modern.',
        'cover_url': '',
        'year': 2011,
        'added_at': now.subtract(const Duration(days: 15)).toIso8601String(),
      },
      {
        'id': 'book-3',
        'title': 'Rich Dad Poor Dad',
        'author': 'Robert Kiyosaki',
        'genre': 'Bisnis & Keuangan',
        'pages': 336,
        'pages_read': 336,
        'status': 'done',
        'rating': 4.0,
        'notes': 'Mengubah cara pandang tentang aset vs liabilitas.',
        'synopsis': 'Pelajaran keuangan dari dua ayah dengan paradigma berbeda tentang uang, investasi, dan kebebasan finansial.',
        'cover_url': '',
        'year': 1997,
        'added_at': now.subtract(const Duration(days: 60)).toIso8601String(),
      },
      {
        'id': 'book-4',
        'title': 'The Alchemist',
        'author': 'Paulo Coelho',
        'genre': 'Fiksi',
        'pages': 197,
        'pages_read': 197,
        'status': 'done',
        'rating': 5.0,
        'notes': 'Novel penuh makna tentang perjalanan menemukan diri sendiri.',
        'synopsis': 'Kisah Santiago, seorang gembala muda yang melakukan perjalanan panjang untuk menemukan harta karunnya.',
        'cover_url': '',
        'year': 1988,
        'added_at': now.subtract(const Duration(days: 90)).toIso8601String(),
      },
      {
        'id': 'book-5',
        'title': 'Clean Code',
        'author': 'Robert C. Martin',
        'genre': 'Sains & Teknologi',
        'pages': 431,
        'pages_read': 120,
        'status': 'reading',
        'rating': 4.0,
        'notes': 'Wajib baca untuk developer. Bab tentang naming convention sangat berguna.',
        'synopsis': 'Panduan menulis kode yang bersih, mudah dibaca, dan mudah di-maintain.',
        'cover_url': '',
        'year': 2008,
        'added_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];

    for (final book in seedBooks) {
      await db.insert('books', book);
    }
  }

  // CREATE — Tambah buku baru
  Future<Book> createBook(Book book) async {
    final db = await database;
    await db.insert('books', book.toMap());
    return book;
  }

  // READ — Ambil semua buku
  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final result = await db.query(
      'books',
      orderBy: 'added_at DESC',
    );
    return result.map((map) => Book.fromMap(map)).toList();
  }

  // READ — Ambil buku berdasarkan ID
  Future<Book?> getBookById(String id) async {
    final db = await database;
    final result = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isEmpty) return null;
    return Book.fromMap(result.first);
  }

  // READ — Ambil buku berdasarkan status
  Future<List<Book>> getBooksByStatus(String status) async {
    final db = await database;
    final result = await db.query(
      'books',
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'added_at DESC',
    );
    return result.map((map) => Book.fromMap(map)).toList();
  }

  // READ — Pencarian buku berdasarkan judul/penulis
  Future<List<Book>> searchBooks(String query) async {
    final db = await database;
    final result = await db.query(
      'books',
      where: 'title LIKE ? OR author LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'title ASC',
    );
    return result.map((map) => Book.fromMap(map)).toList();
  }

  // UPDATE — Update data buku
  Future<int> updateBook(Book book) async {
    final db = await database;
    return await db.update(
      'books',
      book.toMap(),
      where: 'id = ?',
      whereArgs: [book.id],
    );
  }

  // UPDATE — Update progress halaman
  Future<int> updateProgress(String id, int pagesRead) async {
    final db = await database;
    return await db.update(
      'books',
      {'pages_read': pagesRead},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UPDATE — Update status buku
  Future<int> updateStatus(String id, String status) async {
    final db = await database;
    return await db.update(
      'books',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE — Hapus buku
  Future<int> deleteBook(String id) async {
    final db = await database;
    return await db.delete(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // STATS — Hitung total per status
  Future<Map<String, int>> getStats() async {
    final db = await database;
    final total = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM books')) ?? 0;
    final done = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM books WHERE status = 'done'")) ?? 0;
    final reading = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM books WHERE status = 'reading'")) ?? 0;
    final wishlist = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM books WHERE status = 'wishlist'")) ?? 0;
    final totalPages = Sqflite.firstIntValue(
        await db.rawQuery('SELECT SUM(pages_read) FROM books')) ?? 0;

    return {
      'total': total,
      'done': done,
      'reading': reading,
      'wishlist': wishlist,
      'totalPages': totalPages,
    };
  }

  // STATS — Distribusi genre
  Future<Map<String, int>> getGenreDistribution() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT genre, COUNT(*) as count FROM books WHERE genre != "" GROUP BY genre ORDER BY count DESC',
    );
    return {
      for (final row in result)
        (row['genre'] as String): (row['count'] as int),
    };
  }

  // STATS — Rata-rata rating
  Future<double> getAverageRating() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avg FROM books WHERE rating > 0',
    );
    if (result.isEmpty || result.first['avg'] == null) return 0;
    return (result.first['avg'] as num).toDouble();
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
