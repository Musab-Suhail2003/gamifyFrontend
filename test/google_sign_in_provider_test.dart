import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:Gamify/api/api_repo.dart';
import 'google_sign_in_method_channel_mock.dart';

import 'google_sign_in_provider_test.mocks.dart';

@GenerateMocks([GoogleSignIn, GoogleSignInAccount, GoogleSignInAuthentication, http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupGoogleSignInMock();

  group('GoogleSignInProvider', () {
    late GoogleSignInProvider googleSignInProvider;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockGoogleSignInAccount mockGoogleSignInAccount;
    late MockGoogleSignInAuthentication mockGoogleSignInAuthentication;
    late MockClient mockClient;

    setUp(() {
      mockGoogleSignIn = MockGoogleSignIn();
      mockGoogleSignInAccount = MockGoogleSignInAccount();
      mockGoogleSignInAuthentication = MockGoogleSignInAuthentication();
      mockClient = MockClient();
      googleSignInProvider = GoogleSignInProvider();
      });

   
    test('signInWithGoogle successfully signs in', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuthentication);
      when(mockGoogleSignInAuthentication.idToken).thenReturn('mock_id_token');
      when(mockClient.post(
        Uri.parse('http://localhost:3000/users/google-login'),
        headers: anyNamed('headers'),
        body: {token: mockGoogleSignInAuthentication.idToken}
      )).thenAnswer((_) async => http.Response('{"message": "Successfully signed in with Google"}', 200));

      await googleSignInProvider.signInWithGoogle();

      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockGoogleSignInAccount.authentication).called(1);
      verify(mockClient.post(
        Uri.parse('http://localhost:3000/users/google-login'),
        headers: anyNamed('headers'),
        body: {token: mockGoogleSignInAuthentication.idToken}
      )).called(1);
    });

    test('signInWithGoogle fails to sign in', () async {
      when(mockGoogleSignIn.signIn()).thenAnswer((_) async => mockGoogleSignInAccount);
      when(mockGoogleSignInAccount.authentication).thenAnswer((_) async => mockGoogleSignInAuthentication);
      when(mockGoogleSignInAuthentication.idToken).thenReturn('mock_id_token');
      when(mockClient.get(
        Uri.parse('http://localhost:3000/auth/google?idToken=mock_id_token'),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response('Failed to sign in with Google', 400));

      expect(() async => await googleSignInProvider.signInWithGoogle(), throwsException);

      verify(mockGoogleSignIn.signIn()).called(1);
      verify(mockGoogleSignInAccount.authentication).called(1);
      verify(mockClient.get(
        Uri.parse('http://localhost:3000/auth/google?idToken=mock_id_token'),
        headers: anyNamed('headers'),
      )).called(1);
    });
  });
}