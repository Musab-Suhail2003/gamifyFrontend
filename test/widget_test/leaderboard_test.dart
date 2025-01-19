// test/widget_test/leaderboard_test.dart

import 'package:Gamify/bloc/leaderboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/pages/leaderboard.dart';
import 'package:mockito/mockito.dart';
import '../helper/test_helper.dart';

void main() {
  late MockLeaderboardBloc leaderboardBloc;
  final testUserData = {
    '_id': 'test-id',
    'name': 'Test User',
    'coin': 100,
    'XP': 500,
    'Character': 'test-character-id',
  };

  setUp(() {
    leaderboardBloc = MockLeaderboardBloc();
  });

  testWidgets('LeaderboardView displays loading state', (WidgetTester tester) async {
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading() as LeaderboardState Function());

    await tester.pumpWidget(
      BlocProvider<LeaderboardBloc>.value(
        value: leaderboardBloc,
        child: makeTestableWidget(LeaderboardView(userData: testUserData)),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LeaderboardView displays error state', (WidgetTester tester) async {
    const errorMessage = 'Failed to load leaderboard';
    when(() => leaderboardBloc.state).thenReturn(LeaderboardError(errorMessage) as LeaderboardState Function());

    await tester.pumpWidget(
      BlocProvider<LeaderboardBloc>.value(
        value: leaderboardBloc,
        child: makeTestableWidget(LeaderboardView(userData: testUserData)),
      ),
    );

    expect(find.text('Error: $errorMessage'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);
  });

  testWidgets('LeaderboardView golden test', (WidgetTester tester) async {
    when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading() as LeaderboardState Function());

    await tester.pumpWidget(
      BlocProvider<LeaderboardBloc>.value(
        value: leaderboardBloc,
        child: makeTestableWidget(LeaderboardView(userData: testUserData)),
      ),
    );

    await expectLater(
      find.byType(LeaderboardView),
      matchesGoldenFile('goldens/leaderboard_view.png'),
    );
  });
}