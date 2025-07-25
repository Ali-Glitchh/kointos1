import 'dart:convert';
import 'dart:io';

import 'package:kointos/core/constants/app_constants.dart';
import 'package:kointos/core/services/auth_service.dart';
import 'package:kointos/core/services/service_locator.dart';
import 'package:kointos/data/repositories/user_profile_repository.dart';
import 'package:kointos/domain/entities/user.dart';
import 'package:kointos/domain/entities/user_profile.dart';
import 'package:logger/logger.dart';

class UserController {
  final Logger _logger = Logger();
  final UserProfileRepository _userRepository = getService<UserProfileRepository>();
  final AuthService _authService = getService<AuthService>();
  
  Future<void> getAllUsers(HttpRequest request) async {
    try {
      // Get query parameters
      final page = int.tryParse(request.uri.queryParameters['page'] ?? '1') ?? 1;
      final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '${AppConstants.defaultPageSize}') 
          ?? AppConstants.defaultPageSize;
      
      // Get users from repository
      final users = await _userRepository.getUsers(page: page, limit: limit);
      
      // Send response
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {
        'users': users.map((user) => user.toJson()).toList(),
        'page': page,
        'limit': limit,
      });
    } catch (e, stackTrace) {
      _logger.e('Error getting users: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve users'});
    }
  }

  Future<void> getUserById(HttpRequest request, String userId) async {
    try {
      final user = await _userRepository.getUserById(userId);
      
      if (user == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'User not found'});
        return;
      }
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, user.toJson());
    } catch (e, stackTrace) {
      _logger.e('Error getting user: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve user'});
    }
  }

  Future<void> createUser(HttpRequest request) async {
    try {
      // Parse request body
      final content = await utf8.decodeStream(request);
      final data = json.decode(content) as Map<String, dynamic>;
      
      // Validate required fields
      final requiredFields = ['username', 'email', 'password'];
      for (final field in requiredFields) {
        if (!data.containsKey(field) || data[field] == null) {
          request.response.statusCode = HttpStatus.badRequest;
          _sendJsonResponse(request.response, {'error': 'Missing required field: $field'});
          return;
        }
      }
      
      // Register user with auth service
      await _authService.signUp(
        data['email'],
        data['password'],
      );
      
      // In a real implementation, we would get the user ID from the sign-up response
      // For now, we'll generate a mock user ID
      final userId = 'user-${DateTime.now().millisecondsSinceEpoch}';
      
      // Create user profile
      final user = User(
        id: userId,
        username: data['username'],
        email: data['email'],
        displayName: data['displayName'] as String?,
        bio: data['bio'] as String?,
      );
      
      await _userRepository.createUser(user);
      
      request.response.statusCode = HttpStatus.created;
      _sendJsonResponse(request.response, {'id': userId, 'message': 'User created successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error creating user: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to create user'});
    }
  }

  Future<void> updateUser(HttpRequest request, String userId) async {
    try {
      // Get current user from token
      final currentUserId = await _getCurrentUserId(request);
      
      // Check if user is updating their own profile
      if (currentUserId != userId) {
        request.response.statusCode = HttpStatus.forbidden;
        _sendJsonResponse(request.response, {'error': 'Not authorized to update this user'});
        return;
      }
      
      // Parse request body
      final content = await utf8.decodeStream(request);
      final data = json.decode(content) as Map<String, dynamic>;
      
      // Get current user data
      final currentUser = await _userRepository.getUserById(userId);
      if (currentUser == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'User not found'});
        return;
      }
      
      // Update user with new data while preserving existing data
      final updatedUser = User(
        id: currentUser.id,
        username: data['username'] ?? currentUser.username,
        email: currentUser.email, // Don't allow email updates through this endpoint
        displayName: data['displayName'] ?? currentUser.displayName,
        profileImageUrl: data['profileImageUrl'] ?? currentUser.profileImageUrl,
        bio: data['bio'] ?? currentUser.bio,
        points: currentUser.points,
        level: currentUser.level,
        badges: currentUser.badges,
        following: currentUser.following,
        followersCount: currentUser.followersCount,
        followingCount: currentUser.followingCount,
        createdAt: currentUser.createdAt,
        lastActive: DateTime.now(),
      );
      
      await _userRepository.updateUser(updatedUser);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'User updated successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error updating user: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to update user'});
    }
  }

  Future<void> deleteUser(HttpRequest request, String userId) async {
    try {
      // Get current user from token
      final currentUserId = await _getCurrentUserId(request);
      
      // Check if user is deleting their own account
      if (currentUserId != userId) {
        request.response.statusCode = HttpStatus.forbidden;
        _sendJsonResponse(request.response, {'error': 'Not authorized to delete this user'});
        return;
      }
      
      // Delete user
      await _userRepository.deleteUser(userId);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'User deleted successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error deleting user: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to delete user'});
    }
  }

  Future<void> getUserProfile(HttpRequest request, String userId) async {
    try {
      final profile = await _userRepository.getUserProfile(userId);
      
      if (profile == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'User profile not found'});
        return;
      }
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, profile.toJson());
    } catch (e, stackTrace) {
      _logger.e('Error getting user profile: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to retrieve user profile'});
    }
  }

  Future<void> updateUserProfile(HttpRequest request, String userId) async {
    try {
      // Get current user from token
      final currentUserId = await _getCurrentUserId(request);
      
      // Check if user is updating their own profile
      if (currentUserId != userId) {
        request.response.statusCode = HttpStatus.forbidden;
        _sendJsonResponse(request.response, {'error': 'Not authorized to update this profile'});
        return;
      }
      
      // Parse request body
      final content = await utf8.decodeStream(request);
      final data = json.decode(content) as Map<String, dynamic>;
      
      // Get current profile
      final currentProfile = await _userRepository.getUserProfile(userId);
      if (currentProfile == null) {
        request.response.statusCode = HttpStatus.notFound;
        _sendJsonResponse(request.response, {'error': 'User profile not found'});
        return;
      }
      
      // Update profile with new data
      final updatedProfile = UserProfile(
        id: currentProfile.id,
        userId: userId,
        displayName: data['displayName'] ?? currentProfile.displayName,
        bio: data['bio'] ?? currentProfile.bio,
        avatarUrl: data['avatarUrl'] ?? currentProfile.avatarUrl,
      );
      
      await _userRepository.updateUserProfile(updatedProfile);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'Profile updated successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error updating user profile: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to update user profile'});
    }
  }

  Future<void> followUser(HttpRequest request, String userId) async {
    try {
      // Get current user from token
      final currentUserId = await _getCurrentUserId(request);
      
      // Check that user is not trying to follow themselves
      if (currentUserId == userId) {
        request.response.statusCode = HttpStatus.badRequest;
        _sendJsonResponse(request.response, {'error': 'Cannot follow yourself'});
        return;
      }
      
      // Follow user
      await _userRepository.followUser(currentUserId, userId);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'User followed successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error following user: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to follow user'});
    }
  }

  Future<void> unfollowUser(HttpRequest request, String userId) async {
    try {
      // Get current user from token
      final currentUserId = await _getCurrentUserId(request);
      
      // Unfollow user
      await _userRepository.unfollowUser(currentUserId, userId);
      
      request.response.statusCode = HttpStatus.ok;
      _sendJsonResponse(request.response, {'message': 'User unfollowed successfully'});
    } catch (e, stackTrace) {
      _logger.e('Error unfollowing user: $e', error: e, stackTrace: stackTrace);
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJsonResponse(request.response, {'error': 'Failed to unfollow user'});
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
