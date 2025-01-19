// test/helper/test_helper.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:Gamify/bloc/character_bloc.dart';
import 'package:Gamify/bloc/leaderboard_bloc.dart';
import 'package:Gamify/bloc/quest_model_bloc.dart';
import 'package:Gamify/models/character_model.dart';
import 'package:mockito/mockito.dart';

class MockCharacterBloc extends MockBloc<CharacterEvent, CharacterState> implements CharacterBloc {}
class MockLeaderboardBloc extends MockBloc<LeaderboardEvent, LeaderboardState> implements LeaderboardBloc {}
class MockQuestModelBloc extends MockBloc<QuestModelEvent, QuestModelState> implements QuestModelBloc {}

// Helper function to wrap widget with MaterialApp and needed providers
Widget makeTestableWidget(Widget child) {
  return MaterialApp(
    home: child,
  );
}

// Test theme data
ThemeData getTestTheme() {
  return ThemeData(
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.green,
      tertiary: Colors.orange,
    ),
  );
}