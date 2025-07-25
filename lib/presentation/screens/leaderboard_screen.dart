import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kointos/core/theme/modern_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sample leaderboard data
  final List<LeaderboardUser> _weeklyLeaders = [
    LeaderboardUser(
      id: '1',
      username: 'CryptoKing',
      avatar: 'CK',
      points: 2850,
      rank: 1,
      articlesPublished: 15,
      postsShared: 42,
      trend: LeaderboardTrend.up,
    ),
    LeaderboardUser(
      id: '2',
      username: 'BitcoinGuru',
      avatar: 'BG',
      points: 2720,
      rank: 2,
      articlesPublished: 12,
      postsShared: 38,
      trend: LeaderboardTrend.up,
    ),
    LeaderboardUser(
      id: '3',
      username: 'DeFiExpert',
      avatar: 'DE',
      points: 2540,
      rank: 3,
      articlesPublished: 8,
      postsShared: 55,
      trend: LeaderboardTrend.down,
    ),
    LeaderboardUser(
      id: '4',
      username: 'ETHTrader',
      avatar: 'ET',
      points: 2390,
      rank: 4,
      articlesPublished: 6,
      postsShared: 48,
      trend: LeaderboardTrend.up,
    ),
    LeaderboardUser(
      id: '5',
      username: 'AltcoinPro',
      avatar: 'AP',
      points: 2240,
      rank: 5,
      articlesPublished: 10,
      postsShared: 32,
      trend: LeaderboardTrend.same,
    ),
  ];

  final List<LeaderboardUser> _monthlyLeaders = [
    LeaderboardUser(
      id: '2',
      username: 'BitcoinGuru',
      avatar: 'BG',
      points: 8450,
      rank: 1,
      articlesPublished: 35,
      postsShared: 120,
      trend: LeaderboardTrend.up,
    ),
    LeaderboardUser(
      id: '1',
      username: 'CryptoKing',
      avatar: 'CK',
      points: 8320,
      rank: 2,
      articlesPublished: 42,
      postsShared: 98,
      trend: LeaderboardTrend.down,
    ),
    LeaderboardUser(
      id: '3',
      username: 'DeFiExpert',
      avatar: 'DE',
      points: 7890,
      rank: 3,
      articlesPublished: 28,
      postsShared: 145,
      trend: LeaderboardTrend.up,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: AppTheme.primaryBlack,
              elevation: 0,
              title: Text(
                'Leaderboard',
                style: AppTheme.h1.copyWith(
                  color: AppTheme.pureWhite,
                ),
              ).animate().fadeIn().slideX(begin: -0.3),
              actions: [
                IconButton(
                  onPressed: () {
                    _showRewardInfo(context);
                  },
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.pureWhite,
                  ),
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppTheme.pureWhite,
                unselectedLabelColor: AppTheme.greyText,
                indicatorColor: AppTheme.pureWhite,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Weekly'),
                  Tab(text: 'Monthly'),
                  Tab(text: 'All Time'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLeaderboardTab(_weeklyLeaders, 'This Week'),
            _buildLeaderboardTab(_monthlyLeaders, 'This Month'),
            _buildLeaderboardTab(_weeklyLeaders, 'All Time'),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab(List<LeaderboardUser> users, String period) {
    return RefreshIndicator(
      onRefresh: () async {
        // Simulate data refresh
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Leaderboard refreshed!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length + 2, // +2 for header and your rank
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader(period);
          }

          if (index == 1) {
            return _buildYourRank();
          }

          final user = users[index - 2];
          return _buildLeaderboardItem(user, index - 2);
        },
      ),
    );
  }

  Widget _buildHeader(String period) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Performers - $period',
          style: AppTheme.h2.copyWith(color: AppTheme.pureWhite),
        ).animate().fadeIn().slideX(begin: -0.3),
        const SizedBox(height: 8),
        Text(
          'Earn points by writing articles, sharing posts, and engaging with the community',
          style: AppTheme.body2.copyWith(color: AppTheme.greyText),
        ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.3),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildYourRank() {
    return Card(
      color: AppTheme.cardBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.pureWhite.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_rounded,
                  color: AppTheme.pureWhite,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Rank',
                  style: AppTheme.body1.copyWith(
                    color: AppTheme.pureWhite,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildRankBadge(15, isYours: true),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You (YourUsername)',
                        style: AppTheme.body1.copyWith(
                          color: AppTheme.pureWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '1,240 points',
                        style: AppTheme.body2.copyWith(
                          color: AppTheme.greyText,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.trending_up_rounded,
                  color: AppTheme.successGreen,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3);
  }

  Widget _buildLeaderboardItem(LeaderboardUser user, int listIndex) {
    final isTopThree = user.rank <= 3;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isTopThree
          ? AppTheme.pureWhite.withValues(alpha: 0.05)
          : AppTheme.cardBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isTopThree
            ? BorderSide(
                color: _getRankColor(user.rank).withValues(alpha: 0.3),
                width: 1,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank Badge
            _buildRankBadge(user.rank),

            const SizedBox(width: 16),

            // User Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.pureWhite.withValues(alpha: 0.1),
              child: Text(
                user.avatar,
                style: AppTheme.body1.copyWith(
                  color: AppTheme.pureWhite,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        user.username,
                        style: AppTheme.body1.copyWith(
                          color: AppTheme.pureWhite,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTrendIcon(user.trend),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatPoints(user.points)} points',
                    style: AppTheme.body2.copyWith(
                      color: AppTheme.greyText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.articlesPublished} articles • ${user.postsShared} posts',
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),

            // Points Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRankColor(user.rank).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _formatPoints(user.points),
                style: AppTheme.caption.copyWith(
                  color: _getRankColor(user.rank),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: (listIndex + 1) * 100))
        .fadeIn()
        .slideY(begin: 0.3);
  }

  Widget _buildRankBadge(int rank, {bool isYours = false}) {
    final color = isYours ? AppTheme.pureWhite : _getRankColor(rank);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: AppTheme.caption.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIcon(LeaderboardTrend trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case LeaderboardTrend.up:
        icon = Icons.trending_up_rounded;
        color = AppTheme.successGreen;
        break;
      case LeaderboardTrend.down:
        icon = Icons.trending_down_rounded;
        color = AppTheme.errorRed;
        break;
      case LeaderboardTrend.same:
        icon = Icons.trending_flat_rounded;
        color = AppTheme.greyText;
        break;
    }

    return Icon(
      icon,
      size: 16,
      color: color,
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppTheme.cryptoGold;
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.pureWhite;
    }
  }

  String _formatPoints(int points) {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}k';
    }
    return points.toString();
  }

  void _showRewardInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'How Points Work',
          style: AppTheme.h3.copyWith(color: AppTheme.pureWhite),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRewardItem('Write an Article', '100 points'),
            _buildRewardItem('Share a Post', '10 points'),
            _buildRewardItem('Comment on Article', '5 points'),
            _buildRewardItem('Like/React', '2 points'),
            _buildRewardItem('Follow Someone', '5 points'),
            const SizedBox(height: 16),
            Text(
              'Rankings reset weekly. Compete with the community and climb the leaderboard!',
              style: AppTheme.body2.copyWith(color: AppTheme.greyText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: AppTheme.body1.copyWith(color: AppTheme.pureWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String action, String points) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            action,
            style: AppTheme.body2.copyWith(color: AppTheme.pureWhite),
          ),
          Text(
            points,
            style: AppTheme.body2.copyWith(
              color: AppTheme.successGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardUser {
  final String id;
  final String username;
  final String avatar;
  final int points;
  final int rank;
  final int articlesPublished;
  final int postsShared;
  final LeaderboardTrend trend;

  LeaderboardUser({
    required this.id,
    required this.username,
    required this.avatar,
    required this.points,
    required this.rank,
    required this.articlesPublished,
    required this.postsShared,
    required this.trend,
  });
}

enum LeaderboardTrend { up, down, same }
