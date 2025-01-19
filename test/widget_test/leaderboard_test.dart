import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:Gamify/bloc/leaderboard_bloc.dart';
import 'package:Gamify/pages/leaderboard.dart';
import 'package:Gamify/models/character_model.dart';
import 'package:Gamify/models/user_model.dart';

class MockLeaderboardBloc extends Mock implements LeaderboardBloc {}

void main() {
  late MockLeaderboardBloc leaderboardBloc;

  final testUserData = {
    '_id': 'test-id',
    'name': 'Test User',
    'coin': 100,
    'XP': 500,
    'Character': 'test-character-id',
  };

  final testLeaderboardEntries = [
    LeaderboardEntry(
      user: UserModel(user_id: 'test-id-1', name: 'User 1', coin: 1000, XP: 5000, character_id: 'character-1',
          bio: '', googleId: 'google-id', questsCompleted: 0),
      character: Character(id: 'character-1', userId: 'Character 1'),
      rank: 1,
    ),
    LeaderboardEntry(
      user: UserModel(
          user_id: 'test-id-2', name: 'User 2', coin: 800, XP: 4000, character_id: 'character-2',
          bio: '', googleId: 'google-id', questsCompleted: 0
      ),
      character: Character(id: 'character-2', userId: 'Character 2'),
      rank: 2,
    ),
  ];

  setUp(() {
    leaderboardBloc = MockLeaderboardBloc();
    when(() => leaderboardBloc.stream).thenAnswer((_) => Stream.value(LeaderboardLoading()));
  });

  testWidgets('LeaderboardView displays loading state', (WidgetTester tester) async {
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LeaderboardBloc>.value(
          value: leaderboardBloc,
          child: LeaderboardView(userData: testUserData),
        ),
      ),
    );

    // Wait for the widget tree to settle
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LeaderboardView displays error state', (WidgetTester tester) async {
    const errorMessage = 'Failed to load leaderboard';
    when(() => leaderboardBloc.state).thenReturn(LeaderboardError(errorMessage));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LeaderboardBloc>.value(
          value: leaderboardBloc,
          child: LeaderboardView(userData: testUserData),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Error: $errorMessage'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('LeaderboardView displays loaded state', (WidgetTester tester) async {
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoaded(testLeaderboardEntries));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LeaderboardBloc>.value(
          value: leaderboardBloc,
          child: LeaderboardView(userData: testUserData),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('User 1'), findsOneWidget);
    expect(find.text('User 2'), findsOneWidget);
    expect(find.text('5000 XP'), findsOneWidget);
    expect(find.text('4000 XP'), findsOneWidget);
  });

  testWidgets('LeaderboardView handles refresh', (WidgetTester tester) async {
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoaded(testLeaderboardEntries));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LeaderboardBloc>.value(
          value: leaderboardBloc,
          child: LeaderboardView(userData: testUserData),
        ),
      ),
    );

    await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
    await tester.pumpAndSettle();

    verify(() => leaderboardBloc.add(RefreshLeaderboard())).called(1);
  });

  testWidgets('LeaderboardView golden test', (WidgetTester tester) async {
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoaded(testLeaderboardEntries));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<LeaderboardBloc>.value(
          value: leaderboardBloc,
          child: LeaderboardView(userData: testUserData),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LeaderboardView),
      matchesGoldenFile('goldens/leaderboard_view.png'),
    );
  });
}
