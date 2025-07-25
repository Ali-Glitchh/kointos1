import 'dart:io';
import 'package:kointos/core/services/api_service.dart';
import 'package:kointos/core/services/storage_interface.dart';
import 'package:kointos/domain/entities/user.dart';

class UserProfileRepository {
  final ApiService _apiService;
  final StorageInterface _storageService;

  UserProfileRepository({
    required ApiService apiService,
    required StorageInterface storageService,
  })  : _apiService = apiService,
        _storageService = storageService;

  Future<List<User>> getUsers({
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/users',
        queryParameters: {
          if (query != null) 'query': query,
          'page': page,
          'limit': limit,
        },
      );

      final List<dynamic> data = response['data'];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<User> createProfile(User profile) async {
    try {
      final response = await _apiService.post(
        '/users',
        profile.toJson(),
      );

      return User.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile(
      String userId, Map<String, dynamic> profileData) async {
    try {
      final response = await _apiService.put(
        '/users/$userId',
        profileData,
      );

      return User.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfileImage(String userId, String imagePath) async {
    try {
      final file = File(imagePath);
      final key = 'users/$userId/profile.jpg';
      await _storageService.uploadFile(key, file);

      await _apiService.put(
        '/users/$userId',
        {
          'profileImage': key,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> followUser(String currentUserId, String targetUserId) async {
    try {
      await _apiService.post(
        '/users/$targetUserId/follow',
        {},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    try {
      await _apiService.delete(
        '/users/$targetUserId/follow',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getFollowers(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/followers');
      final List<dynamic> data = response['data'];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getFollowing(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/following');
      final List<dynamic> data = response['data'];
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<User?> getUserById(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId');
      return User.fromJson(response);
    } catch (e) {
      return null;
    }
  }
  
  Future<User> createUser(User user) async {
    try {
      final response = await _apiService.post('/users', user.toJson());
      return User.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> updateUser(User user) async {
    try {
      await _apiService.put('/users/${user.id}', user.toJson());
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> deleteUser(String userId) async {
    try {
      await _apiService.delete('/users/$userId');
    } catch (e) {
      rethrow;
    }
  }
  
  Future<dynamic> getUserProfile(String userId) async {
    try {
      final response = await _apiService.get('/users/$userId/profile');
      return response;
    } catch (e) {
      return null;
    }
  }
  
  Future<void> updateUserProfile(dynamic profile) async {
    try {
      await _apiService.put('/users/${profile.userId}/profile', profile.toJson());
    } catch (e) {
      rethrow;
    }
  }
}
