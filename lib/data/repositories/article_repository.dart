import 'dart:io';
import 'package:kointos/core/services/auth_service.dart';
import 'package:kointos/core/services/storage_interface.dart';
import 'package:kointos/domain/entities/article.dart';
import 'package:uuid/uuid.dart';

class ArticleRepository {
  final AuthService _authService;
  final StorageInterface _storageService;
  final _uuid = const Uuid();

  ArticleRepository({
    required AuthService authService,
    required StorageInterface storageService,
  })  : _authService = authService,
        _storageService = storageService;

  Future<Article> getArticle(String articleId) async {
    try {
      // NOTE: Mock data - API integration pending
      final article = await _getMockArticleAsync(articleId);
      final content = await _storageService.downloadData(article.contentKey);
      return article.copyWith(content: content);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getArticles({
    String? authorId,
    ArticleStatus? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // NOTE: Mock data - API integration pending
      await Future.delayed(const Duration(seconds: 1));
      final futures = List.generate(
        10,
        (index) => _getMockArticleAsync('article_${page}_$index'),
      );
      return await Future.wait(futures);
    } catch (e) {
      rethrow;
    }
  }

  Future<Article> createArticle() async {
    try {
      final userId = await _authService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final userName = 'User $userId'; // NOTE: Using placeholder - user profile integration pending
      final articleId = _uuid.v4();

      final article = Article.draft(
        id: articleId,
        authorId: userId,
        authorName: userName,
      );

      // Initialize article content
      await _storageService.uploadData(
        article.contentKey,
        '',
      );

      // NOTE: Article metadata storage - API integration pending
      return article;
    } catch (e) {
      rethrow;
    }
  }

  Future<Article> updateArticle(
    Article article, {
    String? title,
    String? content,
    String? summary,
    String? coverImageUrl,
    List<String>? tags,
    List<String>? images,
    ArticleStatus? status,
  }) async {
    try {
      final updatedArticle = article.copyWith(
        title: title,
        content: content,
        summary: summary,
        coverImageUrl: coverImageUrl,
        tags: tags,
        images: images,
        status: status,
        updatedAt: DateTime.now(),
      );

      if (content != null) {
        await _storageService.uploadData(article.contentKey, content);
      }

      // NOTE: Article metadata update - API integration pending
      return updatedArticle;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteArticle(Article article) async {
    try {
      await _storageService.removeFile(article.contentKey);
      // NOTE: Article metadata deletion - API integration pending
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> searchArticles(
    String query, {
    ArticleStatus? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // NOTE: Mock search data - API integration pending
      await Future.delayed(const Duration(seconds: 1));
      final futures = List.generate(
        5,
        (index) => _getMockArticleAsync('search_${page}_$index'),
      );
      return await Future.wait(futures);
    } catch (e) {
      rethrow;
    }
  }

  Future<Article> uploadArticleImage(String articleId, String imagePath) async {
    try {
      final file = File(imagePath);
      final key =
          'articles/$articleId/images/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      await _storageService.uploadFile(key, file);

      // NOTE: Article image metadata update - API integration pending
      final article = await getArticle(articleId);
      return article.copyWith(
        images: [...article.images, key],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Add missing methods for API controllers
  Future<Article?> getArticleById(String articleId) async {
    try {
      return await getArticle(articleId);
    } catch (e) {
      return null;
    }
  }

  Future<String> createArticleFromData(Article article) async {
    try {
      // NOTE: Article creation - API integration pending
      return article.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likeArticle(String articleId, String userId) async {
    try {
      // NOTE: Like functionality - API integration pending
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlikeArticle(String articleId, String userId) async {
    try {
      // NOTE: Unlike functionality - API integration pending
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getArticleComments(String articleId, {int page = 1, int limit = 10}) async {
    try {
      // NOTE: Comment system - API integration pending
      await Future.delayed(const Duration(milliseconds: 100));
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addComment(String articleId, String userId, String content) async {
    try {
      // NOTE: Comment adding - API integration pending
      await Future.delayed(const Duration(milliseconds: 100));
      return 'comment_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getFeaturedArticles({int limit = 10}) async {
    try {
      return await getArticles(status: ArticleStatus.published, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getUserArticles(String userId, {int page = 1, int limit = 10}) async {
    try {
      return await getArticles(authorId: userId, page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  Future<Article> _getMockArticleAsync(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    return Article(
      id: id,
      authorId: 'author_1',
      authorName: 'John Doe',
      title: 'Sample Article $id',
      content: 'This is a sample article content for $id.',
      summary: 'Sample article summary',
      coverImageUrl: 'https://picsum.photos/seed/$id/800/400',
      tags: ['crypto', 'bitcoin', 'trading'],
      images: ['https://picsum.photos/seed/${id}_1/800/400'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      likesCount: 42,
      commentsCount: 7,
      isLiked: false,
      status: ArticleStatus.published,
      contentKey: 'articles/author_1/$id/content.md',
    );
  }
}
