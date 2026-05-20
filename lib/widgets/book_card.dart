// lib/widgets/book_card.dart

import 'package:flutter/material.dart';
import '../models/book.dart';
import '../utils/app_theme.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorIdx = AppTheme.getGenreColorIndex(book.genre);
    final coverBg = AppTheme.getCoverColor(colorIdx);
    final coverFg = AppTheme.getCoverTextColor(colorIdx);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD3D1C7), width: 0.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover buku
            _BookCoverWidget(
              title: book.title,
              coverUrl: book.coverUrl,
              bg: coverBg,
              fg: coverFg,
            ),
            const SizedBox(width: 12),
            // Info buku
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onDelete != null)
                        GestureDetector(
                          onTap: onDelete,
                          child: const Icon(Icons.more_vert,
                              size: 18, color: Color(0xFF888780)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _StatusBadge(status: book.status),
                      if (book.rating > 0) ...[
                        const SizedBox(width: 8),
                        _StarRating(rating: book.rating),
                      ],
                    ],
                  ),
                  // Progress bar untuk buku yang sedang dibaca
                  if (book.status == 'reading') ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: book.progress,
                        backgroundColor: const Color(0xFFEEECE6),
                        color: AppTheme.primary,
                        minHeight: 5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hal. ${book.pagesRead} / ${book.pages}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget cover buku (gambar atau placeholder warna)
class _BookCoverWidget extends StatelessWidget {
  final String title;
  final String coverUrl;
  final Color bg;
  final Color fg;

  const _BookCoverWidget({
    required this.title,
    required this.coverUrl,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 80,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: coverUrl.isNotEmpty
          ? Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _PlaceholderCover(title: title, fg: fg),
            )
          : _PlaceholderCover(title: title, fg: fg),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  final String title;
  final Color fg;

  const _PlaceholderCover({required this.title, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          height: 1.3,
        ),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Badge status buku
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'reading':
        bg = AppTheme.readingBg;
        fg = AppTheme.readingFg;
        label = 'Dibaca';
        break;
      case 'done':
        bg = AppTheme.doneBg;
        fg = AppTheme.doneFg;
        label = 'Selesai';
        break;
      default:
        bg = AppTheme.wishlistBg;
        fg = AppTheme.wishlistFg;
        label = 'Wishlist';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// Widget bintang rating
class _StarRating extends StatelessWidget {
  final double rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: const Color(0xFFEF9F27),
        );
      }),
    );
  }
}

// Widget kartu versi compact untuk beranda (horizontal scroll)
class BookCardCompact extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCardCompact({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorIdx = AppTheme.getGenreColorIndex(book.genre);
    final coverBg = AppTheme.getCoverColor(colorIdx);
    final coverFg = AppTheme.getCoverTextColor(colorIdx);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 160,
              decoration: BoxDecoration(
                color: coverBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    book.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: coverFg,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              book.author,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF888780),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
