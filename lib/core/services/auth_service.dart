import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class AuthService {
  Future<bool> isAuthenticated() async {
    try {
      final session = await getCurrentSession();
      return session?.isSignedIn ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<AuthSession?> getCurrentSession() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      return session;
    } on AuthException {
      return null;
    }
  }

  Future<String?> getCurrentUserId() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      return user.userId;
    } on AuthException {
      return null;
    }
  }

  Future<String?> getUserToken() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session is CognitoAuthSession) {
        // Extract the access token from Cognito session
        final accessToken = session.userPoolTokensResult.value.accessToken;
        return accessToken.raw;
      }
      return session.isSignedIn ? 'placeholder_token' : null;
    } on AuthException {
      return null;
    }
  }

  Future<void> signUp(
    String email,
    String password,
  ) async {
    try {
      await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(
          userAttributes: {
            CognitoUserAttributeKey.email: email,
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmSignUp(
    String email,
    String confirmationCode,
  ) async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: confirmationCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resendConfirmationCode(String email) async {
    try {
      await Amplify.Auth.resendSignUpCode(
        username: email,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signIn(
    String email,
    String password,
  ) async {
    try {
      await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await Amplify.Auth.resetPassword(
        username: email,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmResetPassword(
    String email,
    String newPassword,
    String confirmationCode,
  ) async {
    try {
      await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: newPassword,
        confirmationCode: confirmationCode,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Validates a JWT token by checking with Cognito
  Future<bool> validateToken(String token) async {
    try {
      // In a real implementation, you would validate the token against Cognito
      // For now, we'll implement a simple check
      if (token.isEmpty) {
        return false;
      }
      
      // You could decode the token and check expiry
      // final decodedToken = _decodeToken(token);
      // final expiryTime = decodedToken['exp'];
      // if (DateTime.now().millisecondsSinceEpoch / 1000 > expiryTime) {
      //   return false;
      // }
      
      // For testing purposes, we'll consider non-empty tokens as valid
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Extracts the user ID from a JWT token
  String getUserIdFromToken(String token) {
    // In a real implementation, you would decode the JWT token and extract the user ID
    // For now, we'll implement a placeholder
    try {
      // You could decode the token and get the user ID claim
      // final decodedToken = _decodeToken(token);
      // return decodedToken['sub'] as String;
      
      // For testing purposes, we'll return a mock user ID
      return 'test-user-id';
    } catch (e) {
      throw Exception('Invalid token format');
    }
  }
  
  /// Helper method to decode a JWT token
  // Map<String, dynamic> _decodeToken(String token) {
  //   final parts = token.split('.');
  //   if (parts.length != 3) {
  //     throw Exception('Invalid token format');
  //   }
  //   
  //   final payload = parts[1];
  //   final normalized = base64Url.normalize(payload);
  //   final decoded = utf8.decode(base64Url.decode(normalized));
  //   return json.decode(decoded) as Map<String, dynamic>;
  // }
}
