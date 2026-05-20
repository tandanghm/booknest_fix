// lib/screens/book_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/book_provider.dart';
import '../utils/app_theme.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    final colorIdx = AppTheme.getGenreColorIndex(_book.genre);
    final coverBg = AppTheme.getCoverColor(colorIdx);
    final coverFg = AppTheme.getCoverTextColor(colorIdx);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar dengan Cover ───────────────────────
          SliverAppBar(
            backgroundColor: AppTheme.primary,
            expandedHeight: 280,
            pinned: true,
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (v) {
                  if (v == 'delete') _confirmDelete(context);
                  if (v == 'edit_progress') _showProgressDialog(context);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit_progress',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Update Progress'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 18, color: Color(0xFFA32D2D)),
                      SizedBox(width: 8),
                      Text('Hapus Buku',
                          style: TextStyle(color: Color(0xFFA32D2D))),
                    ]),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    // Cover buku
                    Container(
                      width: 100,
                      height: 140,
                      decoration: BoxDecoration(
                        color: coverBg,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            _book.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: coverFg,
                              height: 1.3,
                            ),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _book.author,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Status & Rating Row
                Row(
                  children: [
                    _StatusPill(status: _book.status),
                    const SizedBox(width: 8),
                    if (_book.genre.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _book.genre,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F5E5A),
                          ),
                        ),
                      ),
                    const Spacer(),
                    if (_book.rating > 0)
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 16, color: Color(0xFFEF9F27)),
                          const SizedBox(width: 3),
                          Text(
                            '${_book.rating.toInt()}/5',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Progress Membaca ──────────────────────────
                if (_book.status == 'reading') ...[
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progress Membaca',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () => _showProgressDialog(context),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(
                                  color: AppTheme.primaryLight,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: _book.progress,
                            backgroundColor: const Color(0xFFEEECE6),
                            color: AppTheme.primary,
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Halaman ${_book.pagesRead} dari ${_book.pages}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF888780),
                              ),
                            ),
                            Text(
                              '${(_book.progress * 100).round()}%',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Info Metadata ─────────────────────────────
                _DetailCard(
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.menu_book_outlined,
                        label: 'Total Halaman',
                        value: '${_book.pages} halaman',
                      ),
                      if (_book.year > 0) ...[
                        const _Divider(),
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Tahun Terbit',
                          value: '${_book.year}',
                        ),
                      ],
                      const _Divider(),
                      _InfoRow(
                        icon: Icons.access_time_outlined,
                        label: 'Ditambahkan',
                        value: _formatDate(_book.addedAt),
                      ),
                      if (_book.status == 'done') ...[
                        const _Divider(),
                        _InfoRow(
                          icon: Icons.check_circle_outline,
                          label: 'Status',
                          value: 'Selesai dibaca ✓',
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Ganti Status ──────────────────────────────
                _DetailCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubah Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ChangeStatusBtn(
                            label: 'Wishlist',
                            value: 'wishlist',
                            current: _book.status,
                            onTap: () => _changeStatus('wishlist'),
                          ),
                          const SizedBox(width: 8),
                          _ChangeStatusBtn(
                            label: 'Dibaca',
                            value: 'reading',
                            current: _book.status,
                            onTap: () => _changeStatus('reading'),
                          ),
                          const SizedBox(width: 8),
                          _ChangeStatusBtn(
                            label: 'Selesai',
                            value: 'done',
                            current: _book.status,
                            onTap: () => _changeStatus('done'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Sinopsis ──────────────────────────────────
                if (_book.synopsis.isNotEmpty) ...[
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sinopsis',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _book.synopsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5F5E5A),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Catatan Pribadi ───────────────────────────
                if (_book.notes.isNotEmpty) ...[
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                size: 16, color: Color(0xFFEF9F27)),
                            SizedBox(width: 6),
                            Text(
                              'Catatan Pribadi',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _book.notes,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF5F5E5A),
                            height: 1.6,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialog Update Progress ────────────────────────────────────────────────
  void _showProgressDialog(BuildContext context) {
    int current = _book.pagesRead;
    final ctrl = TextEditingController(text: '$current');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Progress Membaca',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Halaman saat ini',
                suffixText: '/ ${_book.pages}',
              ),
            ),
            const SizedBox(height: 16),
            // Slider
            StatefulBuilder(
              builder: (_, setS) => Column(
                children: [
                  Slider(
                    value: (int.tryParse(ctrl.text) ?? 0)
                        .clamp(0, _book.pages)
                        .toDouble(),
                    min: 0,
                    max: _book.pages.toDouble(),
                    activeColor: AppTheme.primary,
                    onChanged: (v) {
                      setS(() {
                        ctrl.text = v.round().toString();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                final pages = int.tryParse(ctrl.text) ?? 0;
                if (pages < 0 || pages > _book.pages) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Halaman tidak valid')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final provider = context.read<BookProvider>();
                await provider.updateProgress(_book.id!, pages);

                // Jika sudah selesai, tanya apakah ubah status
                if (pages >= _book.pages && _book.status != 'done') {
                  if (context.mounted) _askMarkDone(context, provider);
                } else {
                  await provider.loadBooks();
                  // Refresh tampilan
                  final updated = provider.allBooks
                      .firstWhere((b) => b.id == _book.id, orElse: () => _book);
                  if (mounted) setState(() => _book = updated);
                }
              },
              child: const Text('Simpan Progress'),
            ),
          ],
        ),
      ),
    );
  }

  void _askMarkDone(BuildContext context, BookProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tandai Selesai?'),
        content: const Text(
            'Kamu sudah menyelesaikan buku ini! Ubah status menjadi Selesai?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _changeStatus('done');
            },
            child: const Text('Ya, Tandai Selesai'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(String status) async {
    final provider = context.read<BookProvider>();
    await provider.updateStatus(_book.id!, status);
    await provider.loadBooks();
    final updated = provider.allBooks
        .firstWhere((b) => b.id == _book.id, orElse: () => _book);
    if (mounted) setState(() => _book = updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah ke "${_book.statusLabel}"')),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Buku?'),
        content: Text(
            'Yakin ingin menghapus "${_book.title}"? Tindakan ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA32D2D)),
            onPressed: () async {
              Navigator.pop(context);
              await context.read<BookProvider>().deleteBook(_book.id!);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Buku berhasil dihapus')),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Helper Widgets ──────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF888780)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF888780))),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFEEECE6));
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case 'reading':
        bg = AppTheme.readingBg;
        fg = AppTheme.readingFg;
        label = 'Sedang Dibaca';
        icon = Icons.auto_stories_outlined;
        break;
      case 'done':
        bg = AppTheme.doneBg;
        fg = AppTheme.doneFg;
        label = 'Selesai';
        icon = Icons.check_circle_outline;
        break;
      default:
        bg = AppTheme.wishlistBg;
        fg = AppTheme.wishlistFg;
        label = 'Wishlist';
        icon = Icons.bookmark_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}

class _ChangeStatusBtn extends StatelessWidget {
  final String label;
  final String value;
  final String current;
  final VoidCallback onTap;

  const _ChangeStatusBtn({
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = current == value;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? Colors.white : const Color(0xFF5F5E5A),
            ),
          ),
        ),
      ),
    );
  }
}
