// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/book_provider.dart';
import '../utils/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Dashboard')),
      body: Consumer<BookProvider>(
        builder: (ctx, provider, _) {
          return FutureBuilder<Map<String, dynamic>>(
            future: _loadDashboardData(provider),
            builder: (ctx, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                );
              }

              if (!snap.hasData) {
                return const Center(child: Text('Gagal memuat data'));
              }

              final data = snap.data!;
              final stats = data['stats'] as Map<String, int>;
              final genres = data['genres'] as Map<String, int>;
              final avgRating = data['avgRating'] as double;

              return RefreshIndicator(
                color: AppTheme.primary,
                onRefresh: () async {
                  await provider.loadBooks();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // ── Kartu Statistik Utama ──────────────────
                    _SectionTitle('Ringkasan Koleksi'),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.0,
                      children: [
                        _StatCard(
                          label: 'Total\nBuku',
                          value: '${stats['total']}',
                          icon: Icons.library_books_outlined,
                          color: AppTheme.primary,
                        ),
                        _StatCard(
                          label: 'Selesai\nDibaca',
                          value: '${stats['done']}',
                          icon: Icons.check_circle_outline,
                          color: AppTheme.doneFg,
                        ),
                        _StatCard(
                          label: 'Sedang\nDibaca',
                          value: '${stats['reading']}',
                          icon: Icons.auto_stories_outlined,
                          color: AppTheme.readingFg,
                        ),
                        _StatCard(
                          label: 'Wishlist',
                          value: '${stats['wishlist']}',
                          icon: Icons.bookmark_outline,
                          color: AppTheme.wishlistFg,
                        ),
                        _StatCard(
                          label: 'Total\nHalaman',
                          value: '${stats['totalPages']}',
                          icon: Icons.menu_book_outlined,
                          color: AppTheme.primaryLight,
                        ),
                        _StatCard(
                          label: 'Avg\nRating',
                          value: avgRating > 0
                              ? avgRating.toStringAsFixed(1)
                              : '-',
                          icon: Icons.star_outline_rounded,
                          color: const Color(0xFFEF9F27),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Reading Goal Progress ──────────────────
                    _SectionTitle('Target Membaca ${DateTime.now().year}'),
                    const SizedBox(height: 12),
                    _ReadingGoalBar(provider: provider),

                    const SizedBox(height: 24),

                    // ── Pie Chart Status ───────────────────────
                    _SectionTitle('Distribusi Status'),
                    const SizedBox(height: 12),
                    _StatusPieChart(stats: stats),

                    const SizedBox(height: 24),

                    // ── Bar Chart Genre ────────────────────────
                    if (genres.isNotEmpty) ...[
                      _SectionTitle('Distribusi Genre'),
                      const SizedBox(height: 12),
                      _GenreBarChart(genres: genres),
                      const SizedBox(height: 24),
                    ],

                    // ── Milestone ─────────────────────────────
                    _SectionTitle('Pencapaian'),
                    const SizedBox(height: 12),
                    _MilestonesCard(stats: stats),

                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadDashboardData(BookProvider provider) async {
    final stats = await provider.getStats();
    final genres = await provider.getGenreDistribution();
    final avgRating = await provider.getAverageRating();
    return {'stats': stats, 'genres': genres, 'avgRating': avgRating};
  }
}

// ── Widget: Section Title ───────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.primary,
      ),
    );
  }
}

// ── Widget: Stat Card ───────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF888780),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget: Reading Goal Bar ────────────────────────────────────────────────
class _ReadingGoalBar extends StatelessWidget {
  final BookProvider provider;

  const _ReadingGoalBar({required this.provider});

  @override
  Widget build(BuildContext context) {
    final finished = provider.booksFinishedThisYear;
    final goal = provider.readingGoal;
    final progress = provider.readingGoalProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$finished dari $goal buku',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
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
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress >= 1.0
                ? '🎉 Target tercapai! Luar biasa!'
                : 'Sisa ${goal - finished} buku untuk mencapai target',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ── Widget: Pie Chart Status ────────────────────────────────────────────────
class _StatusPieChart extends StatelessWidget {
  final Map<String, int> stats;

  const _StatusPieChart({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] ?? 0;
    if (total == 0) {
      return const _EmptyChart();
    }

    final sections = [
      PieChartSectionData(
        value: (stats['done'] ?? 0).toDouble(),
        color: AppTheme.doneFg,
        title: stats['done']! > 0 ? '${stats['done']}' : '',
        radius: 50,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
      ),
      PieChartSectionData(
        value: (stats['reading'] ?? 0).toDouble(),
        color: AppTheme.readingFg,
        title: stats['reading']! > 0 ? '${stats['reading']}' : '',
        radius: 50,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
      ),
      PieChartSectionData(
        value: (stats['wishlist'] ?? 0).toDouble(),
        color: AppTheme.wishlistFg,
        title: stats['wishlist']! > 0 ? '${stats['wishlist']}' : '',
        radius: 50,
        titleStyle: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
      ),
    ].where((s) => s.value > 0).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 140,
            width: 140,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 30,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendItem(
                  color: AppTheme.doneFg,
                  label: 'Selesai',
                  count: stats['done'] ?? 0),
              const SizedBox(height: 10),
              _LegendItem(
                  color: AppTheme.readingFg,
                  label: 'Dibaca',
                  count: stats['reading'] ?? 0),
              const SizedBox(height: 10),
              _LegendItem(
                  color: AppTheme.wishlistFg,
                  label: 'Wishlist',
                  count: stats['wishlist'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem(
      {required this.color, required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5F5E5A))),
        const SizedBox(width: 6),
        Text('$count',
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Widget: Bar Chart Genre ─────────────────────────────────────────────────
class _GenreBarChart extends StatelessWidget {
  final Map<String, int> genres;

  const _GenreBarChart({required this.genres});

  @override
  Widget build(BuildContext context) {
    final entries = genres.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxVal = entries.isEmpty ? 1 : entries.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
      ),
      child: Column(
        children: entries.map((e) {
          final pct = e.value / maxVal;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(
                    e.key,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF5F5E5A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: const Color(0xFFEEECE6),
                      color: AppTheme.primary,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${e.value}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Widget: Milestones ──────────────────────────────────────────────────────
class _MilestonesCard extends StatelessWidget {
  final Map<String, int> stats;

  const _MilestonesCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final done = stats['done'] ?? 0;
    final milestones = [
      _Milestone(target: 1, label: 'Buku pertama selesai', icon: '📖'),
      _Milestone(target: 5, label: '5 buku selesai', icon: '🌟'),
      _Milestone(target: 10, label: '10 buku selesai', icon: '🏆'),
      _Milestone(target: 25, label: '25 buku selesai', icon: '🚀'),
      _Milestone(target: 50, label: '50 buku selesai', icon: '💎'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
      ),
      child: Column(
        children: milestones.map((m) {
          final achieved = done >= m.target;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Text(m.icon, style: TextStyle(
                  fontSize: 20,
                  color: achieved ? null : const Color(0x44000000),
                )),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m.label,
                    style: TextStyle(
                      fontSize: 13,
                      color: achieved
                          ? const Color(0xFF2C2C2A)
                          : const Color(0xFFB4B2A9),
                      fontWeight:
                          achieved ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  achieved
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  size: 18,
                  color: achieved
                      ? AppTheme.doneFg
                      : const Color(0xFFD3D1C7),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Milestone {
  final int target;
  final String label;
  final String icon;
  const _Milestone({required this.target, required this.label, required this.icon});
}

// ── Widget: Empty Chart ─────────────────────────────────────────────────────
class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
      ),
      child: const Center(
        child: Text(
          'Belum ada data buku',
          style: TextStyle(color: Color(0xFF888780)),
        ),
      ),
    );
  }
}
