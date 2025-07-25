import 'package:flutter/material.dart';
import '../../domain/entities/cryptocurrency.dart';
import '../../domain/entities/article.dart';
import '../screens/crypto_detail_screen.dart';
import '../screens/article_detail_screen.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock search results - in real app, this would call your API
    final mockCryptos = [
      Cryptocurrency(
        id: '1',
        name: 'Bitcoin',
        symbol: 'BTC',
        currentPrice: 45000.0,
        marketCap: 850000000000,
        marketCapRank: 1,
        totalVolume: 25000000000,
        priceChangePercentage24h: 2.5,
        imageUrl: 'https://via.placeholder.com/40',
      ),
      Cryptocurrency(
        id: '2',
        name: 'Ethereum',
        symbol: 'ETH',
        currentPrice: 3200.0,
        marketCap: 380000000000,
        marketCapRank: 2,
        totalVolume: 15000000000,
        priceChangePercentage24h: -1.2,
        imageUrl: 'https://via.placeholder.com/40',
      ),
    ];

    final mockArticles = [
      Article(
        id: '1',
        authorId: 'author1',
        authorName: 'Crypto Expert',
        title: 'Understanding Bitcoin Fundamentals',
        content: 'Bitcoin is the first cryptocurrency...',
        summary: 'A comprehensive guide to Bitcoin',
        tags: const ['bitcoin', 'cryptocurrency'],
        images: const [],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        likesCount: 25,
        commentsCount: 8,
        status: ArticleStatus.published,
        contentKey: 'article1_content',
      ),
    ];

    // Filter results based on query
    final filteredCryptos = mockCryptos
        .where((crypto) =>
            crypto.name.toLowerCase().contains(query.toLowerCase()) ||
            crypto.symbol.toLowerCase().contains(query.toLowerCase()))
        .toList();

    final filteredArticles = mockArticles
        .where((article) =>
            article.title.toLowerCase().contains(query.toLowerCase()) ||
            article.content.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (mounted) {
      setState(() {
        _searchResults = [...filteredCryptos, ...filteredArticles];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search cryptocurrencies and articles...',
                        border: InputBorder.none,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchResults = [];
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: _performSearch,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            // Search Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _searchQuery.isEmpty
                                    ? Icons.search
                                    : Icons.search_off,
                                size: 64,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Start typing to search...'
                                    : 'No results found for "$_searchQuery"',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: 0.7),
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final item = _searchResults[index];
                            if (item is Cryptocurrency) {
                              return _buildCryptoResultItem(item);
                            } else if (item is Article) {
                              return _buildArticleResultItem(item);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCryptoResultItem(Cryptocurrency crypto) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(
          crypto.symbol.substring(0, 2).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(crypto.name),
      subtitle: Text(crypto.symbol),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '\$${crypto.currentPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            '${(crypto.priceChangePercentage24h ?? 0) > 0 ? '+' : ''}${(crypto.priceChangePercentage24h ?? 0).toStringAsFixed(2)}%',
            style: TextStyle(
              color: (crypto.priceChangePercentage24h ?? 0) > 0
                  ? Colors.green
                  : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CryptoDetailScreen(cryptocurrency: crypto),
          ),
        );
      },
    );
  }

  Widget _buildArticleResultItem(Article article) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.article),
      ),
      title: Text(
        article.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'By ${article.authorName}',
        style: TextStyle(
          color:
              Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${article.likesCount} likes',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            '${article.commentsCount} comments',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArticleDetailScreen(article: article),
          ),
        );
      },
    );
  }
}
