import 'dart:convert';
import 'dart:io';

import 'package:kointos/core/constants/app_constants.dart';
import 'package:kointos/core/services/auth_service.dart';
import 'package:kointos/core/services/service_locator.dart';
import 'package:kointos/data/repositories/article_repository.dart';
import 'package:kointos/domain/entities/article.dart';
import 'package:logger/logger.dart';

class ArticleController {
  final Logger _logger = Logger();
  final ArticleRepository _articleRepository = getService<ArticleRepository>();
  final AuthService _authService = getService<AuthService>();
  
  Future<void> getAllArticles(HttpRequest request) async {
    try {
      // Get query parameters
      final page = int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '${AppConstants.defaultPageSize}') 
          ?? AppConstants.defaultPageSize;
      final tag = request.uri.queryParameters['tag'];
      
      // Get articles from repository
      final articles = await _articleRepository.getArticles(
        page: page,
        limit: limit,
      );
      
      // Send response
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'articles': articles.map((article) => article.toJson()).toList(),
        'page': page,
        'limit': limit,
        'tag': tag,
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting articles: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve articles'});
    }
  }

  Future<void> getArticleById(HttpRequest request, String articleId) async {
    try {
      final article = await _articleRepository.getArticleById(articleId);
      
      if (article == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'Article not found'});
        return;
      }
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, article.toJson());
    } catch (e, stackTrace) {
      _logger.e('Error getting article: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve article'});
    }
  }

  Future<void> createArticle(HttpRequest request) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId(request);
      
      // Parse request body
      final content = await utf8.decodeStream(request);
      final data = json.decode(content) as Map<String, dynamic>;
      
      // Validate required fields
      final requiredFields = ['title', 'content'];
      for (final field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null) {
          request.response.statusCode = HttpStatus.badRequest;
          _sendJsonResponse(request.response, {'error': 'Missing required field: $field'});
          return;
        }
      }
      
      // Extract data from request
      final title = data['title'] as String;
      final contentText = data['content'] as String;
      final summary = data['summary'] as String? ?? '';
      final coverImageUrl = data['coverImageUrl'] as String?;
      final tags = data['tags'] != null ? List<String>.from(data['tags']) : <String>[];
      final images = data['images'] != null ? List<String>.from(data['images']) : <String>[];
      
      // Create article
      final article = Article(
        id: 'article_${DateTime.now().millisecondsSinceEpoch}',
        authorId: userId,
        authorName: 'User $userId', // NOTE: Using placeholder - user profile integration pending
        title: title,
        content: contentText,
        summary: summary,
        coverImageUrl: coverImageUrl,
        tags: tags,
        images: images,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        status: ArticleStatus.draft,
        contentKey: 'articles/$userId/${DateTime.now().millisecondsSinceEpoch}',
      );

      final createdArticleId = await _articleRepository.createArticleFromData(article);      request.response.statusCode = HttpStatus.created;
      _sendJsonResponse(request.response, {'id': createdArticleId, 'message': 'Article created successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error creating article: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to create article'});
    }
  }

  Future<void> updateArticle(HttpRequest request, String articleId) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId(request);
      
      // Get current article
      final currentArticle = await _articleRepository.getArticleById(articleId);
      if (currentArticle == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'Article not found'});
        return;
      }
      
      // Verify ownership
      if (currentArticle.authorId != userId) {
        request.response.statusCode = HttpStatus.forbidden;
        _sendJsonResponse(request.response, {'error': 'Not authorized to update this article'});
        return;
      }
      
      // Parse request body
      final content = await utf8.decodeStream(request);
      final data = json.decode(content) as Map<String, dynamic>;
      
      // Update article with new data
      final updatedArticle = Article(
        id: articleId,
        authorId: userId,
        authorName: currentArticle.authorName,
        title: data['title'] ?? currentArticle.title,
        summary: data['summary'] ?? currentArticle.summary,
        content: data['content'] ?? currentArticle.content,
        coverImageUrl: data['coverImageUrl'] ?? currentArticle.coverImageUrl,
        images: data['images'] != null 
            ? List<String>.from(data['images'])
            : currentArticle.images,
        tags: data['tags'] != null 
            ? List<String>.from(data['tags'])
            : currentArticle.tags,
        likesCount: currentArticle.likesCount,
        commentsCount: currentArticle.commentsCount,
        isLiked: currentArticle.isLiked,
        status: data['status'] != null 
            ? ArticleStatus.values.firstWhere((e) => e.toString().split('.').last == data['status'])
            : currentArticle.status,
        contentKey: currentArticle.contentKey,
        createdAt: currentArticle.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await _articleRepository.updateArticle(updatedArticle);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'Article updated successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error updating article: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to update article'});
    }
  }

  Future<void> deleteArticle(HttpRequest request, String articleId) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId(request);
      
      // Get current article
      final currentArticle = await _articleRepository.getArticleById(articleId);
      if (currentArticle == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'Article not found'});
        return;
      }
      
      // Verify ownership
      if (currentArticle.authorId != userId) {
        request.response.statusCode = HttpStatus.forbidden;
        _sendJsonResponse(request.response, {'error': 'Not authorized to delete this article'});
        return;
      }
      
      // Delete article
      await _articleRepository.deleteArticle(currentArticle);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'Article deleted successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error deleting article: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to delete article'});
    }
  }

  Future<void> likeArticle(HttpRequest request, String articleId) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId(request);
      
      // Like article
      await _articleRepository.likeArticle(articleId, userId);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'Article liked successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error liking article: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to like article'});
    }
  }

  Future<void> unlikeArticle(HttpRequest request, String articleId) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId(request);
      
      // Unlike article
      await _articleRepository.unlikeArticle(articleId, userId);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'Article unliked successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error unliking article: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to unlike article'});
    }
  }

  Future<void> getArticleComments(HttpRequest request, String articleId) async {
    try {
      // Get query parameters
      final page = int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '${AppConstants.defaultPageSize}') 
          ?? AppConstants.defaultPageSize;
      
      // Get comments from repository
      final comments = await _articleRepository.getArticleComments(
        articleId,
        page: page,
        limit: limit,
      );
      
      // Send response
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'comments': comments,
        'page': page,
        'limit': limit,
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting article comments: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve article comments'});
    }
  }

  Future<void> addArticleComment(HttpRequest request, String articleId) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId(request);
      
      // Parse request body
      final content = await utf8.decodeStream(request);
      final data = json.decode(content) as Map<String, dynamic>;
      
      // Validate required fields
      if (!data.containsKey('content') || data['content'] == null) {
        request.response.statusCode = HttpStatus.badRequest;
        _sendJsonResponse(request.response, {'error': 'Missing required field: content'});
        return;
      }
      
      // Add comment
      final commentId = await _articleRepository.addComment(
        articleId,
        userId,
        data['content'],
      );
      
      request.response.statusCode = HttpStatus.created;
      _sendJsonResponse(request.response, {'id': commentId, 'message': 'Comment added successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error adding comment: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to add comment'});
    }
  }

  Future<void> getFeaturedArticles(HttpRequest request) async {
    try {
      // Get query parameters
      final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '5') ?? 5;
      
      // Get featured articles from repository
      final articles = await _articleRepository.getFeaturedArticles(limit: limit);
      
      // Send response
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'articles': articles.map((article) => article.toJson()).toList(),
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting featured articles: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve featured articles'});
    }
  }

  Future<void> getUserArticles(HttpRequest request, String userId) async {
    try {
      // Get query parameters
      final page = int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '${AppConstants.defaultPageSize}') 
          ?? AppConstants.defaultPageSize;
      
      // Get articles from repository
      final articles = await _articleRepository.getUserArticles(
        userId,
        page: page,
        limit: limit,
      );
      
      // Send response
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'articles': articles.map((article) => article.toJson()).toList(),
        'page': page,
        'limit': limit,
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting user articles: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve user articles'});
    }
  }

  Future<String> _getCurrentUserId(HttpRequest request) async {
    final authHeader = request.headers.value('Authorization');
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      throw Exception('Missing or invalid authorization header');
    }
    
    final token = authHeader.substring(7);
    return _authService.getUserIdFromToken(token);
  }

  void _sendJsonResponse(HttpResponse response, Map<String, dynamic> data) {
    response.headers.contentType = ContentType.json;
    response.write(json.encode(data));
    response.close();
  }
}
