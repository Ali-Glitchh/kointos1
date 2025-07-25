import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:kointos/core/services/logger_service.dart';
import 'package:kointos/amplify_outputs.dart';

class KointosAmplifyConfig {
  static bool _isConfigured = false;

  static Future<void> configureAmplify() async {
    if (_isConfigured) return;

    try {
      // Add Amplify plugins for Gen 2
      final auth = AmplifyAuthCognito();
      final api = AmplifyAPI();
      final storage = AmplifyStorageS3();
      
      await Amplify.addPlugins([auth, api, storage]);

      // Configure Amplify with Gen 2 outputs
      await Amplify.configure(json.encode(amplifyConfig));
      _isConfigured = true;
      LoggerService.info('Amplify Gen 2 configured successfully');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to configure Amplify Gen 2', e, stackTrace);
      rethrow;
    }
  }

  static Future<bool> isConfigured() async {
    try {
      await Amplify.Auth.getCurrentUser();
      return true;
    } catch (e) {
      return false;
    }
  }
}
