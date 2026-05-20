// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/book_card.dart';
import 'book_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<BookProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: provider.loadBooks,
            child: CustomScrollView(
              slivers: [
                // ── App Bar ──────────────────────────────────────
                SliverAppBar(
                  backgroundColor: AppTheme.primary,
                  expandedHeight: 140,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      '📚 BookNest',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    background: Container(
                      color: AppTheme.primary,
                      child: const Padding(
                        padding:
                            EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Text(
                          'Selamat datang! 👋',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Body ─────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([

                      // Reading Goal Card
                      _ReadingGoalCard(provider: provider),
                      const SizedBox(height: 24),

                      // Sedang Dibaca
                      if (provider.currentlyReading.isNotEmpty) ...[
                        _SectionHeader(
                          title: 'Sedang Dibaca',
                          count: provider.currentlyReading.length,
                        ),
                        const SizedBox(height: 12),
                        ...provider.currentlyReading.map((book) => BookCard(
                              book: book,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookDetailScreen(book: book),
                                ),
                              ).then((_) => provider.loadBooks()),
                            )),
                        const SizedBox(height: 16),
                      ],

                      // Buku Terbaru
                      _SectionHeader(
                        title: 'Baru Ditambahkan',
                        count: provider.recentBooks.length,
                      ),
                      const SizedBox(height: 12),
                      ...provider.recentBooks
                          .where((b) => b.status != 'reading')
                          .take(3)
                          .map((book) => BookCard(
                                book: book,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BookDetailScreen(book: book),
                                  ),
                                ).then((_) => provider.loadBooks()),
                              )),

                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Widget: Reading Goal Card ───────────────────────────────────────────────
class _ReadingGoalCard extends StatelessWidget {
  final BookProvider provider;

  const _ReadingGoalCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final finished = provider.booksFinishedThisYear;
    final goal = provider.readingGoal;
    final progress = provider.readingGoalProgress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Target Membaca 2025',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              GestureDetector(
                onTap: () => _showGoalDialog(context, provider),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$finished',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ $goal buku',
                style: const TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress >= 1.0
                ? '🎉 Target tercapai!'
                : '${(progress * 100).round()}% tercapai · ${goal - finished} buku lagi',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog(BuildContext context, BookProvider provider) {
    final controller = TextEditingController(
      text: provider.readingGoal.toString(),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ubah Target Membaca'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target buku per tahun',
            suffixText: 'buku',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                provider.setReadingGoal(val);
              }
              Navigator.pop(context);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

// ── Widget: Section Header ──────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryLight,
            ),
          ),
        ),
      ],
    );
  }
}
