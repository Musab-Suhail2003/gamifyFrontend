import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/pages/login.dart';
import 'package:Gamify/pages/quest_page.dart';

import 'login_page_test.mocks.dart';

@GenerateMocks([ApiRepository, GoogleSignInProvider, LoginPage, QuestPage])
void main() {
  late MockApiRepository mockApiRepository;
  late MockGoogleSignInProvider mockGoogleSignInProvider;

  setUp(() {
    mockApiRepository = MockApiRepository();
    mockGoogleSignInProvider = MockGoogleSignInProvider();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => ApiBloc(apiRepository: mockApiRepository),
        child: const LoginPage(),
      ),
    );
  }

  testWidgets('LoginPage displays login button', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Login With Google'), findsOneWidget);
  });

  blocTest<AuthBloc, AuthState>(
    'emits [ApiLoading, ApiLoaded<void>] when GoogleSignInRequested is added',
    build: () {
      when(mockGoogleSignInProvider.signInWithGoogle())
          .thenAnswer((_) async => Future.value());
      return AuthBloc(googleSignInProvider: mockGoogleSignInProvider);
    },
    act: (bloc) => bloc.add(GoogleSignInRequested()),
    expect: () => [ApiLoading(), const ApiLoaded<void>(null)],
  );

  testWidgets('navigates to QuestPage on successful login', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final bloc = BlocProvider.of<ApiBloc>(tester.element(find.byType(MaterialPageRoute)));
    bloc.emit(ApiLoaded<void>(null));

    await tester.pumpAndSettle();

    expect(find.byType(QuestPage), findsOneWidget);
  });

  testWidgets('shows error message on login failure', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final bloc = BlocProvider.of<ApiBloc>(tester.element(find.byType(GoogleSignIn)));
    bloc.emit(ApiError('Failed to sign in'));

    await tester.pump();

    expect(find.text('Failed to sign in'), findsOneWidget);
  });
}