import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupGoogleSignInMock() {
  const MethodChannel channel = MethodChannel('plugins.flutter.io/google_sign_in');

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'init':
        return null;
      case 'signIn':
        return {
          'displayName': 'Test User',
          'email': 'testuser@example.com',
          'id': 'test_id',
          'photoUrl': 'http://example.com/photo.jpg',
          'serverAuthCode': 'test_server_auth_code',
        };
      case 'signOut':
        return null;
      case 'disconnect':
        return null;
      default:
        return null;
    }
  });
}