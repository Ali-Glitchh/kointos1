import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kointos/core/theme/modern_theme.dart';
import 'package:kointos/presentation/screens/articles_screen.dart';

class ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onBookmark;
  final bool isBookmarked;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onLike,
    this.onComment,
    this.onBookmark,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppTheme.cardBlack,
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                height: 200,
                color: AppTheme.secondaryBlack,
                child: CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.secondaryBlack,
                          AppTheme.cardBlack,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.article_rounded,
                        size: 48,
                        color: AppTheme.greyText,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.secondaryBlack,
                          AppTheme.cardBlack,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.article_rounded,
                        size: 48,
                        color: AppTheme.greyText,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Article Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Read Time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article.category,
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.pureWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.greyText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        article.readTime,
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.greyText,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTimeAgo(article.publishedAt),
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Article Title
                  Text(
                    article.title,
                    style: AppTheme.h3.copyWith(
                      fontSize: 18,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Article Excerpt
                  Text(
                    article.excerpt,
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.greyText,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Author & Stats
                  Row(
                    children: [
                      // Author Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.pureWhite.withValues(alpha: 0.1),
                        child: Text(
                          article.author[0].toUpperCase(),
                          style: AppTheme.caption.copyWith(
                            color: AppTheme.pureWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Author Name
                      Expanded(
                        child: Text(
                          article.author,
                          style: AppTheme.body2.copyWith(
                            color: AppTheme.pureWhite,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // Like Button & Count
                      _buildActionButton(
                        icon: Icons.favorite_border_rounded,
                        count: article.likes,
                        onTap: onLike,
                      ),

                      const SizedBox(width: 16),

                      // Comment Button & Count
                      _buildActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        count: article.comments,
                        onTap: onComment,
                      ),

                      const SizedBox(width: 16),

                      // Bookmark Button
                      InkWell(
                        onTap: onBookmark,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 20,
                            color: AppTheme.greyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppTheme.greyText,
            ),
            const SizedBox(width: 4),
            Text(
              _formatCount(count),
              style: AppTheme.caption.copyWith(
                color: AppTheme.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
