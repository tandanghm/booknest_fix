# 📚 BookNest — Flutter App

Aplikasi manajemen koleksi buku pribadi dengan fitur lengkap.

---

## 🚀 Cara Menjalankan Project

### Prasyarat
- Flutter SDK >= 3.0.0 sudah terinstall ([unduh di flutter.dev](https://flutter.dev))
- Android Studio / VS Code dengan plugin Flutter
- Perangkat Android (minSdk 21) atau emulator

### Langkah Instalasi

```bash
# 1. Masuk ke folder project
cd booknest

# 2. Install semua dependency
flutter pub get

# 3. Jalankan app
flutter run
```

---

## 📁 Struktur Folder

```
booknest/
├── lib/
│   ├── main.dart                        ← Entry point + navigasi utama
│   ├── models/
│   │   └── book.dart                    ← Model data buku
│   ├── database/
│   │   └── book_database.dart           ← SQLite CRUD helper
│   ├── providers/
│   │   └── book_provider.dart           ← State management (Provider)
│   ├── services/
│   │   └── api_service.dart             ← Open Library API
│   ├── utils/
│   │   └── app_theme.dart               ← Tema & konstanta warna
│   ├── screens/
│   │   ├── home_screen.dart             ← Beranda + Reading Goal
│   │   ├── collection_screen.dart       ← Daftar buku + cari + filter
│   │   ├── add_book_screen.dart         ← Form tambah buku + validasi
│   │   ├── book_detail_screen.dart      ← Detail buku + update progress
│   │   └── dashboard_screen.dart        ← Statistik + chart
│   └── widgets/
│       └── book_card.dart               ← Widget kartu buku reusable
├── pubspec.yaml                         ← Konfigurasi & dependency
└── README.md
```

---

## ✅ Checklist Fitur Tugas

### 2 Fitur Baru
| Fitur | Penjelasan |
|---|---|
| **Reading Goal Tracker** | Target membaca per tahun dengan progress bar, bisa diubah via dialog |
| **Live Search + Filter** | Pencarian real-time judul/penulis/genre + filter by status |

### UI/UX yang Ditingkatkan
- Bottom navigation bar 4 tab (Beranda, Koleksi, Tambah, Dashboard)
- Status badge berwarna (Dibaca 🔵 / Selesai 🟢 / Wishlist 🟠)
- Progress bar per buku di card dan halaman detail
- Sliver App Bar dengan animasi collapse di Home & Detail
- Toast/SnackBar feedback setelah setiap aksi

### Implementasi (Local Database + API + State Management)

#### SQLite (sqflite)
- File: `lib/database/book_database.dart`
- Operasi: CREATE, READ, UPDATE, DELETE
- Query: search, filter by status, aggregate stats

#### Open Library API
- File: `lib/services/api_service.dart`
- Endpoint: `https://openlibrary.org/search.json`
- Fitur: cari buku lalu auto-fill form (judul, penulis, tahun, halaman, cover)

#### Provider (State Management)
- File: `lib/providers/book_provider.dart`
- Mengelola: daftar buku, filter, search, reading goal
- Semua screen subscribe ke BookProvider, UI auto-refresh saat data berubah

### Validasi Form (`add_book_screen.dart`)
| Field | Aturan Validasi |
|---|---|
| Judul | Tidak boleh kosong, minimal 2 karakter |
| Penulis | Tidak boleh kosong |
| Halaman | Wajib diisi, harus angka positif |
| Tahun Terbit | Opsional, jika diisi harus 1000–tahun sekarang |
| Rating | Dipilih via tap bintang (1–5), opsional |

### Halaman Detail & Dashboard
- **BookDetailScreen**: cover, metadata, progress bar, ubah status, sinopsis, catatan, hapus buku
- **DashboardScreen**: 6 stat card, reading goal bar, pie chart status, bar chart genre, milestone badges

---

## 🗂 Penjelasan Tiap File (untuk Presentasi)

### `main.dart`
Entry point aplikasi. Membungkus app dengan `ChangeNotifierProvider` agar `BookProvider` tersedia di seluruh widget tree. `MainNavigation` mengelola `IndexedStack` untuk 4 tab navigasi.

### `models/book.dart`
Data class `Book` dengan field lengkap: id, title, author, genre, pages, pagesRead, status, rating, notes, synopsis, coverUrl, year, addedAt. Berisi method `toMap()`, `fromMap()`, `copyWith()`, getter `progress` dan `statusLabel`.

### `database/book_database.dart`
Singleton SQLite helper. Tabel `books` dibuat saat pertama kali app dijalankan beserta 5 data seed. Method CRUD: `createBook`, `getAllBooks`, `getBookById`, `searchBooks`, `updateBook`, `updateProgress`, `updateStatus`, `deleteBook`, `getStats`, `getGenreDistribution`, `getAverageRating`.

### `providers/book_provider.dart`
`ChangeNotifier` yang jadi single source of truth. Menyimpan `_books`, `_filteredBooks`, `_searchQuery`, `_filterStatus`. Method `_applyFilter()` dipanggil setiap kali search/filter berubah, lalu `notifyListeners()` untuk refresh UI.

### `services/api_service.dart`
Kelas statis dengan 2 method: `searchBooks(query)` hit endpoint Open Library search dan `getBookDetails(key)` untuk ambil sinopsis. Dipakai di `AddBookScreen` untuk auto-fill form dari data buku nyata.

### `screens/home_screen.dart`
SliverAppBar dengan `FlexibleSpaceBar`. Menampilkan `_ReadingGoalCard` (target tahunan + progress) dan daftar buku sedang dibaca + terbaru ditambahkan.

### `screens/collection_screen.dart`
ListView dengan search bar + filter chips (Semua / Dibaca / Selesai / Wishlist). Tap card → navigasi ke `BookDetailScreen`. Long press → bottom sheet opsi hapus.

### `screens/add_book_screen.dart`
Form dengan `GlobalKey<FormState>`. Setiap field punya `validator`. Tombol search memanggil Open Library API dan menampilkan hasil di dropdown inline. Rating dipilih via bintang interaktif.

### `screens/book_detail_screen.dart`
SliverAppBar dengan cover buku. Menampilkan: status pill, progress bar (jika reading), metadata, tombol ubah status, sinopsis, catatan pribadi. Dialog update progress menggunakan Slider + TextField tersinkronisasi.

### `screens/dashboard_screen.dart`
`FutureBuilder` memuat stats dari database. Menampilkan: 6 `_StatCard`, reading goal bar, `PieChart` distribusi status (fl_chart), bar chart genre, dan milestone achievements.

### `widgets/book_card.dart`
Widget reusable `BookCard` (untuk list) dan `BookCardCompact` (untuk horizontal scroll). Menampilkan cover placeholder berwarna per genre, badge status, bintang rating, progress bar untuk buku yang sedang dibaca.
