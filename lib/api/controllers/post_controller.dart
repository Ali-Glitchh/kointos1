import 'dart:convert';
import 'dart:io';

import 'package:kointos/core/constants/app_constants.dart';
import 'package:kointos/core/services/auth_service.dart';
import 'package:kointos/core/services/service_locator.dart';
import 'package:kointos/data/repositories/post_repository.dart';
import 'package:kointos/domain/entities/post.dart';
import 'package:logger/logger.dart';

class PostController {
  final Logger _logger = Logger();
  final PostRepository _postRepository = getService<PostRepository>();
  final AuthService _authService = getService<AuthService>();
  
  Future<void> getAllPosts(HttpRequest request) async {
    try {
      // Get query parameters
      final page = int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '${AppConstants.defaultPageSize}') 
          ?? AppConstants.defaultPageSize;
      final tag = request.uri.queryParameters['tag'];
      
      // Get posts from repository
      final posts = await _postRepository.getPosts(
        page: page,
        limit: limit,
      );
      
      // Send response
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'posts': posts.map((post) => post.toJson()).toList(),
        'page': page,
        'limit': limit,
        'tag': tag,
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting posts: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve posts'});
    }
  }

  Future<void> getPostById(HttpRequest request, String postId) async {
    try {
      final post = await _postRepository.getPostById(postId);
      
      if (post == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'Post not found'});
        return;
      }
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, post.toJson());
    } catch (e, stackTrace) {
      _logger.e('Error getting post: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve post'});
    }
  }

  Future<void> createPost(HttpRequest request) async {
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
      
      // Extract data from request
      final contentText = data['content'] as String;
      final images = data['images'] != null ? List<String>.from(data['images']) : <String>[];
      final tags = data['tags'] != null ? List<String>.from(data['tags']) : <String>[];
      
      // Create post
      final post = Post(
        id: 'post_${DateTime.now().millisecondsSinceEpoch}',
        authorId: userId,
        authorName: 'User $userId', // TODO: Get actual user name
        authorAvatar: '', // TODO: Get actual user avatar
        content: contentText,
        images: images,
        tags: tags,
        createdAt: DateTime.now(),
      );
      
      final createdPost = await _postRepository.createPost(post);
      
      request.response.statusCode = HttpStatus.created;
      _sendJsonResponse(request.response, {'id': createdPost.id, 'message': 'Post created successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error creating post: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to create post'});
    }
  }

  Future<void> updatePost(HttpRequest request, String postId) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId(request);
      
      // Get current post
      final currentPost = await _postRepository.getPostById(postId);
      if (currentPost == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'Post not found'});
        return;
      }
      
      // Verify ownership
      if (currentPost.authorId != userId) {
        request.response.statusCode = HttpStatus.forbidden;
        _sendJsonResponse(request.response, {'error': 'Not authorized to update this post'});
        return;
      }
      
      // Parse request body
      final content = await utf8.decodeStream(request);
      final data = json.decode(content) as Map<String, dynamic>;
      
      // Update post with new data
      final updatedPost = Post(
        id: postId,
        authorId: userId,
        authorName: currentPost.authorName,
        authorAvatar: currentPost.authorAvatar,
        content: data['content'] ?? currentPost.content,
        images: data['images'] != null 
            ? List<String>.from(data['images'])
            : currentPost.images,
        tags: data['tags'] != null 
            ? List<String>.from(data['tags'])
            : currentPost.tags,
        likesCount: currentPost.likesCount,
        commentsCount: currentPost.commentsCount,
        isLiked: currentPost.isLiked,
        type: currentPost.type,
        createdAt: currentPost.createdAt,
      );
      
      await _postRepository.updatePost(updatedPost);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'Post updated successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error updating post: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to update post'});
    }
  }

  Future<void> deletePost(HttpRequest request, String postId) async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId(request);
      
      // Get current post
      final currentPost = await _postRepository.getPostById(postId);
      if (currentPost == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'Post not found'});
        return;
      }
      
      // Verify ownership
      if (currentPost.authorId != userId) {
        request.response.statusCode = HttpStatus.forbidden;
        _sendJsonResponse(request.response, {'error': 'Not authorized to delete this post'});
        return;
      }
      
      // Delete post
      await _postRepository.deletePost(postId);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'Post deleted successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error deleting post: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to delete post'});
    }
  }

  Future<void> likePost(HttpRequest request, String postId) async {
    try {
      // Like post
      await _postRepository.likePost(postId);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'Post liked successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error liking post: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to like post'});
    }
  }

  Future<void> unlikePost(HttpRequest request, String postId) async {
    try {
      // Unlike post
      await _postRepository.unlikePost(postId);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'Post unliked successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error unliking post: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to unlike post'});
    }
  }

  Future<void> getPostComments(HttpRequest request, String postId) async {
    try {
      // Get query parameters
      final page = int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '${AppConstants.defaultPageSize}') 
          ?? AppConstants.defaultPageSize;
      
      // Get comments from repository
      final comments = await _postRepository.getPostComments(
        postId,
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
      _logger.e('Error getting post comments: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve post comments'});
    }
  }

  Future<void> addPostComment(HttpRequest request, String postId) async {
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
      final commentId = await _postRepository.addComment(
        postId,
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

  Future<void> getUserPosts(HttpRequest request, String userId) async {
    try {
      // Get query parameters
      final page = int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '${AppConstants.defaultPageSize}') 
          ?? AppConstants.defaultPageSize;
      
      // Get posts from repository
      final posts = await _postRepository.getUserPosts(
        userId,
        page: page,
        limit: limit,
      );
      
      // Send response
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'posts': posts.map((post) => post.toJson()).toList(),
        'page': page,
        'limit': limit,
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting user posts: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve user posts'});
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
