import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kointos/core/theme/modern_theme.dart';
import 'package:kointos/presentation/screens/social_feed_screen.dart';

class SocialPostCard extends StatefulWidget {
  final SocialPost post;

  const SocialPostCard({
    super.key,
    required this.post,
  });

  @override
  State<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends State<SocialPostCard>
    with TickerProviderStateMixin {
  late AnimationController _likeController;
  late AnimationController _shareController;
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );
    _shareController = AnimationController(
      duration: AppTheme.fastAnimation,
      vsync: this,
    );

    _isLiked = widget.post.isLiked;
    _likeCount = widget.post.likes;
  }

  @override
  void dispose() {
    _likeController.dispose();
    _shareController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    if (_isLiked) {
      _likeController.forward().then((_) {
        _likeController.reverse();
      });
    }
  }

  void _sharePost() {
    _shareController.forward().then((_) {
      _shareController.reverse();
    });

    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Post shared!'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // User Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.cryptoGradient,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.primaryBlack,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.post.userName,
                            style: const TextStyle(
                              color: AppTheme.pureWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          if (widget.post.points > 0) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.cryptoGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${widget.post.points}',
                                style: const TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatTimeAgo(widget.post.timestamp),
                        style: const TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // More options
                IconButton(
                  onPressed: () {
                    _showPostOptions(context);
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.post.content,
              style: const TextStyle(
                color: AppTheme.pureWhite,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),

          // Crypto mentions
          if (widget.post.cryptoMentions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.post.cryptoMentions.map((crypto) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cryptoGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.cryptoGold.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '\$$crypto',
                      style: const TextStyle(
                        color: AppTheme.cryptoGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: _toggleLike,
                  child: AnimatedBuilder(
                    animation: _likeController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_likeController.value * 0.2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked
                                  ? AppTheme.errorRed
                                  : AppTheme.greyText,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _likeCount.toString(),
                              style: TextStyle(
                                color: _isLiked
                                    ? AppTheme.errorRed
                                    : AppTheme.greyText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 24),

                // Comment button
                GestureDetector(
                  onTap: () {
                    _showComments(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        color: AppTheme.greyText,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.post.comments.toString(),
                        style: const TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                // Share button
                GestureDetector(
                  onTap: _sharePost,
                  child: AnimatedBuilder(
                    animation: _shareController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (_shareController.value * 0.1),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.share_outlined,
                              color: AppTheme.greyText,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.post.shares.toString(),
                              style: const TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),

                // Bookmark button
                IconButton(
                  onPressed: () {
                    // Implement bookmark
                  },
                  icon: const Icon(
                    Icons.bookmark_border,
                    color: AppTheme.greyText,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    ).animate().fadeIn(duration: AppTheme.normalAnimation).slideY(
          begin: 0.1,
          duration: AppTheme.normalAnimation,
          curve: Curves.easeOut,
        );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.greyText,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              _buildOption(Icons.flag_outlined, 'Report Post'),
              _buildOption(Icons.block_outlined, 'Block User'),
              _buildOption(Icons.visibility_off_outlined, 'Hide Post'),
              _buildOption(Icons.link_outlined, 'Copy Link'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.greyText),
      title: Text(
        text,
        style: const TextStyle(color: AppTheme.pureWhite),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.greyText,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Comments',
                    style: TextStyle(
                      color: AppTheme.pureWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.greyText.withValues(alpha: 0.3),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppTheme.greyText,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User $index',
                                      style: const TextStyle(
                                        color: AppTheme.pureWhite,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Great analysis! Thanks for sharing.',
                                      style: TextStyle(
                                        color: AppTheme.accentWhite,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
