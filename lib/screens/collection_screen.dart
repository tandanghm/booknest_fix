// lib/screens/collection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Koleksi Buku'),
        actions: [
          Consumer<BookProvider>(
            builder: (_, provider, __) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${provider.allBooks.length} buku',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search Bar ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Consumer<BookProvider>(
              builder: (_, provider, __) => TextField(
                controller: _searchController,
                onChanged: provider.setSearch,
                decoration: InputDecoration(
                  hintText: 'Cari judul, penulis, atau genre...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF888780)),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Color(0xFF888780)),
                          onPressed: () {
                            _searchController.clear();
                            provider.clearSearch();
                          },
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Filter Chips ──────────────────────────────────────
          Consumer<BookProvider>(
            builder: (_, provider, __) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Semua',
                    isSelected: provider.filterStatus == 'all',
                    onTap: () => provider.setFilter('all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Sedang Dibaca',
                    isSelected: provider.filterStatus == 'reading',
                    onTap: () => provider.setFilter('reading'),
                    color: AppTheme.readingFg,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Selesai',
                    isSelected: provider.filterStatus == 'done',
                    onTap: () => provider.setFilter('done'),
                    color: AppTheme.doneFg,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Wishlist',
                    isSelected: provider.filterStatus == 'wishlist',
                    onTap: () => provider.setFilter('wishlist'),
                    color: AppTheme.wishlistFg,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Book List ─────────────────────────────────────────
          Expanded(
            child: Consumer<BookProvider>(
              builder: (_, provider, __) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  );
                }

                if (provider.books.isEmpty) {
                  return _EmptyState(
                    hasSearch: provider.searchQuery.isNotEmpty,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: provider.books.length,
                  itemBuilder: (ctx, i) {
                    final book = provider.books[i];
                    return BookCard(
                      book: book,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(book: book),
                        ),
                      ).then((_) => provider.loadBooks()),
                      onDelete: () => _showDeleteDialog(ctx, provider, book.id!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, BookProvider provider, String id) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFA32D2D)),
              title: const Text(
                'Hapus Buku',
                style: TextStyle(color: Color(0xFFA32D2D)),
              ),
              onTap: () async {
                Navigator.pop(context);
                final ok = await provider.deleteBook(id);
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Buku berhasil dihapus')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Batal'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Widget: Filter Chip ─────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppTheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFD3D1C7),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF5F5E5A),
          ),
        ),
      ),
    );
  }
}

// ── Widget: Empty State ─────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool hasSearch;

  const _EmptyState({required this.hasSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off : Icons.library_books_outlined,
            size: 64,
            color: const Color(0xFFB4B2A9),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch
                ? 'Buku tidak ditemukan'
                : 'Koleksi masih kosong',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF5F5E5A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Coba kata kunci lain'
                : 'Tambah buku pertamamu!',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF888780),
            ),
          ),
        ],
      ),
    );
  }
}
