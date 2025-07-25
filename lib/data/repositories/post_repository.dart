import 'dart:io';
import 'package:kointos/core/services/api_service.dart';
import 'package:kointos/core/services/storage_interface.dart';
import 'package:kointos/domain/entities/post.dart';

class PostRepository {
  final ApiService _apiService;
  final StorageInterface _storageService;

  PostRepository({
    required ApiService apiService,
    required StorageInterface storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<List<Post>> getPosts({
    String? authorId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/posts',
        queryParameters: {
          if (authorId != null) 'authorId': authorId,
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Post> createPost(Post post) async {
    try {
      // First upload any images
      final imageUrls = await Future.wait(
        post.images.map((imagePath) => _uploadImage(post.authorId, imagePath)),
      );

      // Create post with image URLs
      final response = await _apiService.post(
        '/posts',
        {
          ...post.toJson(),
          'images': imageUrls,
        },
      );

      return Post.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likePost(String postId) async {
    try {
      await _apiService.post(
        '/posts/$postId/like',
        {},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unlikePost(String postId) async {
    try {
      await _apiService.post(
        '/posts/$postId/unlike',
        {},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _apiService.delete('/posts/$postId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Post>> getFeed({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/posts/feed',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Post>> searchPosts(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/posts/search',
        queryParameters: {
          'query': query,
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((json) => Post.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add missing methods for API controllers
  Future<Post?> getPostById(String postId) async {
    try {
      final response = await _apiService.get('/posts/$postId');
      return Post.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<Post> updatePost(Post post) async {
    try {
      final response = await _apiService.put('/posts/${post.id}', post.toJson());
      return Post.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPostComments(String postId, {int page = 1, int limit = 10}) async {
    try {
      final response = await _apiService.get(
        '/posts/$postId/comments',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      return List<Map<String, dynamic>>.from(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> addComment(String postId, String userId, String content) async {
    try {
      final response = await _apiService.post('/posts/$postId/comments', {
        'userId': userId,
        'content': content,
      });
      return response['id'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Post>> getUserPosts(String userId, {int page = 1, int limit = 10}) async {
    try {
      return await getPosts(authorId: userId, page: page, limit: limit);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _uploadImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      final key =
          'posts/$userId/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      await _storageService.uploadFile(key, file);
      return key;
    } catch (e) {
      rethrow;
    }
  }
}
