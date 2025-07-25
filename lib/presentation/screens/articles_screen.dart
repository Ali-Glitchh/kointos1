import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:kointos/core/theme/modern_theme.dart';
import 'package:kointos/presentation/widgets/article_card.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  final Set<String> _bookmarkedArticles = {};

  // Sample data - Replace with real data from backend
  final List<Article> _trendingArticles = [
    Article(
      id: '1',
      title: 'Bitcoin Reaches New All-Time High',
      author: 'CryptoExpert',
      readTime: '5 min read',
      category: 'Bitcoin',
      imageUrl: 'https://via.placeholder.com/300x200',
      excerpt:
          'Bitcoin has surged to unprecedented levels, breaking through key resistance levels...',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 142,
      comments: 28,
    ),
    Article(
      id: '2',
      title: 'DeFi Revolution: The Future of Finance',
      author: 'DeFiGuru',
      readTime: '8 min read',
      category: 'DeFi',
      imageUrl: 'https://via.placeholder.com/300x200',
      excerpt:
          'Decentralized Finance is reshaping the financial landscape with innovative protocols...',
      publishedAt: DateTime.now().subtract(const Duration(hours: 4)),
      likes: 89,
      comments: 15,
    ),
    Article(
      id: '3',
      title: 'NFT Market Analysis: Trends and Predictions',
      author: 'NFTAnalyst',
      readTime: '6 min read',
      category: 'NFTs',
      imageUrl: 'https://via.placeholder.com/300x200',
      excerpt:
          'The NFT market continues to evolve with new trends emerging in digital collectibles...',
      publishedAt: DateTime.now().subtract(const Duration(hours: 6)),
      likes: 64,
      comments: 12,
    ),
  ];

  final List<Article> _latestArticles = [
    Article(
      id: '4',
      title: 'Ethereum 2.0 Staking Guide',
      author: 'StakingPro',
      readTime: '10 min read',
      category: 'Ethereum',
      imageUrl: 'https://via.placeholder.com/300x200',
      excerpt:
          'Learn how to stake your ETH and earn rewards in the new Ethereum 2.0 ecosystem...',
      publishedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      likes: 203,
      comments: 45,
    ),
    Article(
      id: '5',
      title: 'Altcoin Season: What to Watch',
      author: 'AltcoinTrader',
      readTime: '7 min read',
      category: 'Trading',
      imageUrl: 'https://via.placeholder.com/300x200',
      excerpt:
          'Discover which alternative cryptocurrencies are showing promising signals...',
      publishedAt: DateTime.now().subtract(const Duration(hours: 1)),
      likes: 156,
      comments: 32,
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
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: AppTheme.primaryBlack,
              elevation: 0,
              title: Text(
                'Articles',
                style: AppTheme.h1.copyWith(
                  color: AppTheme.pureWhite,
                ),
              ).animate().fadeIn().slideX(begin: -0.3),
              actions: [
                IconButton(
                  onPressed: () {
                    _showSearchDialog(context);
                  },
                  icon: const Icon(
                    Icons.search_rounded,
                    color: AppTheme.pureWhite,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _showBookmarkedArticles();
                  },
                  icon: const Icon(
                    Icons.bookmark_rounded,
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
                  Tab(text: 'Trending'),
                  Tab(text: 'Latest'),
                  Tab(text: 'Bookmarks'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTrendingTab(),
            _buildLatestTab(),
            _buildBookmarksTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToArticleEditor();
        },
        backgroundColor: AppTheme.pureWhite,
        foregroundColor: AppTheme.primaryBlack,
        child: const Icon(Icons.edit_rounded),
      ).animate().scale(delay: 500.ms),
    );
  }

  Widget _buildTrendingTab() {
    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refreshing trending articles
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Trending articles refreshed!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _trendingArticles.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Now',
                  style: AppTheme.h2.copyWith(color: AppTheme.pureWhite),
                ).animate().fadeIn().slideX(begin: -0.3),
                const SizedBox(height: 16),
              ],
            );
          }

          final article = _trendingArticles[index - 1];
          return ArticleCard(
            article: article,
            onTap: () {
              _navigateToArticleDetail(article);
            },
            onLike: () {
              _likeArticle(article.id);
            },
            onComment: () {
              _showCommentsDialog(article);
            },
            onBookmark: () {
              _toggleBookmark(article.id);
            },
            isBookmarked: _bookmarkedArticles.contains(article.id),
          )
              .animate(delay: Duration(milliseconds: index * 100))
              .fadeIn()
              .slideY(begin: 0.3);
        },
      ),
    );
  }

  Widget _buildLatestTab() {
    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refreshing latest articles
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Latest articles refreshed!'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _latestArticles.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest Articles',
                  style: AppTheme.h2.copyWith(color: AppTheme.pureWhite),
                ).animate().fadeIn().slideX(begin: -0.3),
                const SizedBox(height: 16),
              ],
            );
          }

          final article = _latestArticles[index - 1];
          return ArticleCard(
            article: article,
            onTap: () {
              _navigateToArticleDetail(article);
            },
            onLike: () {
              _likeArticle(article.id);
            },
            onComment: () {
              _showCommentsDialog(article);
            },
            onBookmark: () {
              _toggleBookmark(article.id);
            },
            isBookmarked: _bookmarkedArticles.contains(article.id),
          )
              .animate(delay: Duration(milliseconds: index * 100))
              .fadeIn()
              .slideY(begin: 0.3);
        },
      ),
    );
  }

  Widget _buildBookmarksTab() {
    final bookmarkedArticles = [
      ..._trendingArticles,
      ..._latestArticles,
    ].where((article) => _bookmarkedArticles.contains(article.id)).toList();

    if (bookmarkedArticles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bookmark_outline_rounded,
              size: 64,
              color: AppTheme.greyText,
            ),
            const SizedBox(height: 16),
            Text(
              'No bookmarked articles yet',
              style: AppTheme.body1.copyWith(color: AppTheme.greyText),
            ),
            const SizedBox(height: 8),
            Text(
              'Bookmark articles to read them later',
              style: AppTheme.body2.copyWith(color: AppTheme.greyText),
            ),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarkedArticles.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ArticleCard(
            article: bookmarkedArticles[index],
            onTap: () {
              _navigateToArticleDetail(bookmarkedArticles[index]);
            },
            onLike: () {
              _likeArticle(bookmarkedArticles[index].id);
            },
            onComment: () {
              _showCommentsDialog(bookmarkedArticles[index]);
            },
            onBookmark: () {
              _toggleBookmark(bookmarkedArticles[index].id);
            },
            isBookmarked: true,
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBlack,
        title: Text(
          'Search Articles',
          style: AppTheme.h3.copyWith(color: AppTheme.pureWhite),
        ),
        content: TextField(
          autofocus: true,
          style: AppTheme.body1.copyWith(color: AppTheme.pureWhite),
          decoration: InputDecoration(
            hintText: 'Enter search terms...',
            hintStyle: AppTheme.body1
                .copyWith(color: AppTheme.pureWhite.withValues(alpha: 0.6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppTheme.pureWhite.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppTheme.pureWhite.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.cryptoGold),
            ),
          ),
          onSubmitted: (query) {
            Navigator.pop(context);
            _performSearch(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.body1
                  .copyWith(color: AppTheme.pureWhite.withValues(alpha: 0.7)),
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    // Filter articles based on search query
    final filteredArticles = _trendingArticles.where((article) {
      return article.title.toLowerCase().contains(query.toLowerCase()) ||
          article.excerpt.toLowerCase().contains(query.toLowerCase()) ||
          article.author.toLowerCase().contains(query.toLowerCase());
    }).toList();

    // Show search results in a snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Found ${filteredArticles.length} articles matching "$query"'),
        backgroundColor: AppTheme.cardBlack,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBookmarkedArticles() {
    _tabController.animateTo(2); // Navigate to bookmarks tab
  }

  void _toggleBookmark(String articleId) {
    setState(() {
      if (_bookmarkedArticles.contains(articleId)) {
        _bookmarkedArticles.remove(articleId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from bookmarks'),
            backgroundColor: AppTheme.cardBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _bookmarkedArticles.add(articleId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to bookmarks'),
            backgroundColor: AppTheme.cardBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _likeArticle(String articleId) {
    // In a real app, this would call the API to like the article
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Article liked!'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showCommentsDialog(Article article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBlack,
        title: Text(
          'Comments',
          style: AppTheme.h3.copyWith(color: AppTheme.pureWhite),
        ),
        content: Text(
          'Comments feature coming soon!\n\nThis article has ${article.comments} comments.',
          style: AppTheme.body1.copyWith(color: AppTheme.pureWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTheme.body1.copyWith(color: AppTheme.cryptoGold),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToArticleDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleDetailScreen(article: article),
      ),
    );
  }

  void _navigateToArticleEditor() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArticleEditorScreen(),
      ),
    );

    if (result != null && result is Article && mounted) {
      // Article was created/saved, could refresh the list or show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article saved successfully!'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class Article {
  final String id;
  final String title;
  final String author;
  final String readTime;
  final String category;
  final String imageUrl;
  final String excerpt;
  final DateTime publishedAt;
  final int likes;
  final int comments;

  Article({
    required this.id,
    required this.title,
    required this.author,
    required this.readTime,
    required this.category,
    required this.imageUrl,
    required this.excerpt,
    required this.publishedAt,
    required this.likes,
    required this.comments,
  });
}

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: AppTheme.h2.copyWith(color: AppTheme.pureWhite),
            ),
            const SizedBox(height: 8),
            Text(
              'by ${article.author} • ${article.readTime} • ${article.publishedAt}',
              style: AppTheme.body2.copyWith(color: AppTheme.greyText),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                article.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              article.excerpt,
              style: AppTheme.body1.copyWith(color: AppTheme.pureWhite),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    // Show a simple feedback for like action
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Like feature coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.thumb_up_alt_rounded,
                    color: AppTheme.cryptoGold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comments feature coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.comment_rounded,
                    color: AppTheme.cryptoGold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature coming soon!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.share_rounded,
                    color: AppTheme.cryptoGold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleEditorScreen extends StatelessWidget {
  const ArticleEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Article'),
      ),
      body: Center(
        child: Text(
          'Article Editor Screen',
          style: AppTheme.h2.copyWith(color: AppTheme.pureWhite),
        ),
      ),
    );
  }
}
