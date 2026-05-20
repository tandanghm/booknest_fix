// lib/screens/add_book_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _pagesCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _synopsisCtrl = TextEditingController();

  // State form
  String _genre = '';
  String _status = 'wishlist';
  double _rating = 0;
  String _coverUrl = '';
  bool _isSaving = false;

  // State pencarian API
  bool _isSearching = false;
  List<BookSearchResult> _searchResults = [];
  bool _showResults = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _pagesCtrl.dispose();
    _yearCtrl.dispose();
    _notesCtrl.dispose();
    _synopsisCtrl.dispose();
    super.dispose();
  }

  // ── Pencarian Open Library API ─────────────────────────────────────────
  Future<void> _searchOpenLibrary() async {
    final query = _titleCtrl.text.trim();
    if (query.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan minimal 3 karakter untuk mencari')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _showResults = true;
    });

    final results = await ApiService.searchBooks(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  // Isi form otomatis dari hasil pencarian API
  void _fillFromApi(BookSearchResult result) {
    setState(() {
      _titleCtrl.text = result.title;
      _authorCtrl.text = result.author;
      if (result.pages > 0) _pagesCtrl.text = result.pages.toString();
      if (result.year > 0) _yearCtrl.text = result.year.toString();
      if (result.synopsis.isNotEmpty) _synopsisCtrl.text = result.synopsis;
      _coverUrl = result.coverUrl;
      _showResults = false;
    });

    // Ambil sinopsis detail jika ada key
    if (result.openLibraryKey.isNotEmpty && result.synopsis.isEmpty) {
      ApiService.getBookDetails(result.openLibraryKey).then((detail) {
        if (detail != null && detail.synopsis.isNotEmpty && mounted) {
          setState(() => _synopsisCtrl.text = detail.synopsis);
        }
      });
    }
  }

  // ── Simpan Buku ────────────────────────────────────────────────────────
  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<BookProvider>();
    final ok = await provider.addBook(
      title: _titleCtrl.text,
      author: _authorCtrl.text,
      genre: _genre,
      pages: int.parse(_pagesCtrl.text),
      status: _status,
      rating: _rating,
      notes: _notesCtrl.text,
      synopsis: _synopsisCtrl.text,
      coverUrl: _coverUrl,
      year: int.tryParse(_yearCtrl.text) ?? 0,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${_titleCtrl.text}" berhasil ditambahkan!')),
        );
        _clearForm();
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _titleCtrl.clear();
    _authorCtrl.clear();
    _pagesCtrl.clear();
    _yearCtrl.clear();
    _notesCtrl.clear();
    _synopsisCtrl.clear();
    setState(() {
      _genre = '';
      _status = 'wishlist';
      _rating = 0;
      _coverUrl = '';
      _showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Tambah Buku'),
        actions: [
          TextButton(
            onPressed: _clearForm,
            child: const Text('Reset', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Judul + Tombol Cari API ─────────────────────────
            _SectionTitle(icon: Icons.book_outlined, title: 'Informasi Buku'),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Judul Buku *',
                      hintText: 'Masukkan judul',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Judul tidak boleh kosong';
                      }
                      if (v.trim().length < 2) {
                        return 'Judul minimal 2 karakter';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol cari ke Open Library API
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: _isSearching
                      ? const SizedBox(
                          width: 50, height: 50,
                          child: Center(
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.primary),
                            ),
                          ))
                      : ElevatedButton(
                          onPressed: _searchOpenLibrary,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(50, 50),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Icon(Icons.search),
                        ),
                ),
              ],
            ),

            // ── Hasil Pencarian API ────────────────────────────
            if (_showResults) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
                ),
                child: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(color: AppTheme.primary),
                        ),
                      )
                    : _searchResults.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Buku tidak ditemukan di Open Library',
                              style: TextStyle(color: Color(0xFF888780)),
                            ),
                          )
                        : Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${_searchResults.length} hasil dari Open Library',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF888780),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _showResults = false),
                                      child: const Icon(Icons.close,
                                          size: 16, color: Color(0xFF888780)),
                                    ),
                                  ],
                                ),
                              ),
                              ..._searchResults.take(5).map((r) => ListTile(
                                    dense: true,
                                    title: Text(r.title,
                                        style: const TextStyle(fontSize: 13)),
                                    subtitle: Text(
                                      '${r.author} · ${r.year > 0 ? r.year : "?"}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Color(0xFF888780),
                                    ),
                                    onTap: () => _fillFromApi(r),
                                  )),
                            ],
                          ),
              ),
            ],

            const SizedBox(height: 12),

            // ── Penulis ────────────────────────────────────────
            TextFormField(
              controller: _authorCtrl,
              decoration: const InputDecoration(
                labelText: 'Penulis *',
                hintText: 'Nama penulis',
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Penulis tidak boleh kosong';
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── Genre ──────────────────────────────────────────
            DropdownButtonFormField<String>(
              value: _genre.isEmpty ? null : _genre,
              decoration: const InputDecoration(labelText: 'Genre'),
              hint: const Text('Pilih genre'),
              items: AppConstants.genres
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _genre = v ?? ''),
            ),
            const SizedBox(height: 12),

            // ── Halaman & Tahun ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pagesCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Halaman *',
                      hintText: '0',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Wajib diisi';
                      }
                      final n = int.tryParse(v);
                      if (n == null || n < 1) {
                        return 'Angka positif';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _yearCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tahun Terbit',
                      hintText: '2024',
                    ),
                    validator: (v) {
                      if (v != null && v.isNotEmpty) {
                        final n = int.tryParse(v);
                        if (n == null || n < 1000 || n > DateTime.now().year) {
                          return 'Tahun tidak valid';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Status & Rating ────────────────────────────────
            _SectionTitle(icon: Icons.bookmark_outlined, title: 'Status & Rating'),
            const SizedBox(height: 12),

            // Status Chips
            Row(
              children: [
                _StatusOption(
                  label: 'Wishlist',
                  value: 'wishlist',
                  selected: _status,
                  onTap: (v) => setState(() => _status = v),
                ),
                const SizedBox(width: 8),
                _StatusOption(
                  label: 'Sedang Dibaca',
                  value: 'reading',
                  selected: _status,
                  onTap: (v) => setState(() => _status = v),
                ),
                const SizedBox(width: 8),
                _StatusOption(
                  label: 'Selesai',
                  value: 'done',
                  selected: _status,
                  onTap: (v) => setState(() => _status = v),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Rating Bintang
            const Text(
              'Rating',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF5F5E5A),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ...List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        i < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 32,
                        color: const Color(0xFFEF9F27),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                if (_rating > 0)
                  Text(
                    '${_rating.toInt()}/5',
                    style: const TextStyle(
                      color: Color(0xFF888780),
                      fontSize: 13,
                    ),
                  ),
                if (_rating > 0)
                  GestureDetector(
                    onTap: () => setState(() => _rating = 0),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: Color(0xFF888780),
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Catatan Pribadi ────────────────────────────────
            _SectionTitle(icon: Icons.notes_outlined, title: 'Catatan'),
            const SizedBox(height: 12),

            TextFormField(
              controller: _synopsisCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Sinopsis',
                hintText: 'Deskripsi singkat buku...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan Pribadi',
                hintText: 'Kesan, kutipan favorit, atau pengingat...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 32),

            // ── Tombol Simpan ──────────────────────────────────
            ElevatedButton(
              onPressed: _isSaving ? null : _saveBook,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Simpan Buku'),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ── Widget: Section Title ───────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryLight),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}

// ── Widget: Status Option ───────────────────────────────────────────────────
class _StatusOption extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final ValueChanged<String> onTap;

  const _StatusOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : AppTheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primary : const Color(0xFFD3D1C7),
              width: 0.5,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Colors.white : const Color(0xFF5F5E5A),
            ),
          ),
        ),
      ),
    );
  }
}

// Import AppConstants
class AppConstants {
  static const List<String> genres = [
    'Self-Help', 'Fiksi', 'Sains & Teknologi',
    'Bisnis & Keuangan', 'Sejarah', 'Filsafat',
    'Biografi', 'Psikologi', 'Seni & Budaya', 'Lainnya',
  ];
}
