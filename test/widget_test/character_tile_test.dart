// test/widget_test/character_tile_test.dart

import 'package:Gamify/bloc/character_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/pages/characterTile.dart';
import 'package:mockito/mockito.dart';
import '../helper/test_helper.dart';

void main() {
  late MockCharacterBloc characterBloc;

  setUp(() {
    characterBloc = MockCharacterBloc();
  });

  testWidgets('CharacterTile displays loading state', (WidgetTester tester) async {
    when(() => characterBloc.state).thenReturn(CharacterLoading() as CharacterState Function());

    await tester.pumpWidget(
      BlocProvider<CharacterBloc>.value(
        value: characterBloc,
        child: makeTestableWidget(CharacterTile(userId: 'test-id')),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('CharacterTile displays error state', (WidgetTester tester) async {
    const errorMessage = 'Error loading character';
    when(() => characterBloc.state).thenReturn(CharacterError(errorMessage) as CharacterState Function());

    await tester.pumpWidget(
      BlocProvider<CharacterBloc>.value(
        value: characterBloc,
        child: makeTestableWidget(CharacterTile(userId: 'test-id')),
      ),
    );

    expect(find.text(errorMessage), findsOneWidget);
  });

  testWidgets('CharacterTile golden test', (WidgetTester tester) async {
    when(() => characterBloc.state).thenReturn(CharacterLoading() as CharacterState Function());

    await tester.pumpWidget(
      BlocProvider<CharacterBloc>.value(
        value: characterBloc,
        child: makeTestableWidget(CharacterTile(userId: 'test-id')),
      ),
    );

    await expectLater(
      find.byType(CharacterTile),
      matchesGoldenFile('goldens/character_tile.png'),
    );
  });
}