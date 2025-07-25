import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:kointos/core/theme/modern_theme.dart';
import 'package:kointos/presentation/widgets/social_post_card.dart';
import 'package:kointos/presentation/widgets/create_post_widget.dart';
import 'package:kointos/presentation/widgets/story_bar.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showCreatePost = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppTheme.primaryBlack,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cryptoGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Social',
                    style: TextStyle(
                      color: AppTheme.primaryBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Spacer(),

                // Points indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.stars_rounded,
                        color: AppTheme.cryptoGold,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '1,250',
                        style: TextStyle(
                          color: AppTheme.pureWhite,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Notifications
                },
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_rounded),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.errorRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Stories
          const SliverToBoxAdapter(
            child: StoryBar(),
          ),

          // Create Post Section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CreatePostWidget(),
            ),
          ),

          // Feed Posts
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: AppTheme.normalAnimation,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: SocialPostCard(
                          post: _dummyPosts[index % _dummyPosts.length],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: 10, // Load more posts
            ),
          ),

          // Loading indicator
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.pureWhite,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button for quick post
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showCreatePost = !_showCreatePost;
          });
        },
        child: Icon(
          _showCreatePost ? Icons.close : Icons.add,
        ),
      ).animate().fadeIn(delay: const Duration(milliseconds: 800)).scale(
            duration: AppTheme.normalAnimation,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

// Dummy data for posts
final List<SocialPost> _dummyPosts = [
  SocialPost(
    id: '1',
    userId: 'user1',
    userName: 'CryptoTrader_Pro',
    userAvatar: '',
    content:
        'Just made a 25% gain on my Bitcoin trade! 🚀 The technical analysis was spot on. Who else is bullish on BTC?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
    likes: 142,
    comments: 23,
    shares: 8,
    cryptoMentions: ['BTC'],
    isLiked: false,
    points: 15,
  ),
  SocialPost(
    id: '2',
    userId: 'user2',
    userName: 'ETH_Maximalist',
    userAvatar: '',
    content:
        'Ethereum 2.0 staking rewards are looking amazing! Just crossed 100 ETH staked. The future is bright for DeFi! 💎',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    likes: 89,
    comments: 15,
    shares: 12,
    cryptoMentions: ['ETH'],
    isLiked: true,
    points: 12,
  ),
  SocialPost(
    id: '3',
    userId: 'user3',
    userName: 'AltcoinHunter',
    userAvatar: '',
    content:
        'Found this gem at 0.05! Already up 400%. Sometimes the best trades are the ones nobody talks about 🔍',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    likes: 256,
    comments: 45,
    shares: 23,
    cryptoMentions: [],
    isLiked: false,
    points: 25,
  ),
];

class SocialPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final int shares;
  final List<String> cryptoMentions;
  final bool isLiked;
  final int points;
  final String? imageUrl;

  SocialPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.cryptoMentions,
    required this.isLiked,
    required this.points,
    this.imageUrl,
  });
}
