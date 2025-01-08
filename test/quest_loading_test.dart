import 'package:Gamify/pages/quest_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/bloc/quest_model_bloc.dart';
import 'package:Gamify/models/quest_model.dart';

import 'quest_loading_test.mocks.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/bloc/quest_model_bloc.dart';
import 'package:Gamify/models/quest_model.dart';

// Mock the Bloc and its state
@GenerateMocks([QuestModelBloc])
void main() {
  late MockQuestModelBloc mockQuestModelBloc;

  setUp(() {
    mockQuestModelBloc = MockQuestModelBloc();

    // Stub the state getter with an initial state
    when(mockQuestModelBloc.state).thenReturn(const QuestModelLoaded( []));
  });

  testWidgets('New ListTile appears after a quest is added', (WidgetTester tester) async {
    // Mock user data
    final mockUserData = {'_id': 'test_user_id'};

    // Pump the widget with the mocked Bloc
    await tester.pumpWidget(
      BlocProvider<QuestModelBloc>.value(
        value: mockQuestModelBloc,
        child: MaterialApp(
          home: QuestPage(userData: mockUserData),
        ),
      ),
    );

    // Verify no ListTile is displayed initially
    expect(find.byType(ListTile), findsNothing);

    // Trigger the Add Quest dialog
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify the dialog is displayed
    expect(find.text('Add New Quest'), findsOneWidget);
    expect(find.text('Quest Name'), findsOneWidget);
    expect(find.text('Quest Description'), findsOneWidget);

    // Fill in the quest details
    await tester.enterText(find.byType(TextField).at(0), 'New Quest');
    await tester.enterText(find.byType(TextField).at(1), 'Description of the new quest');

    // Mock the Bloc state to include the new quest after it's added
    final newQuest = QuestModel(
      quest_name: 'New Quest',
      quest_description: 'Description of the new quest',
      user_id: 'test_user_id',
      completion_percent: 0,
    );
    when(mockQuestModelBloc.state).thenReturn(
      QuestModelLoaded( [newQuest]),
    );

    // Tap the "Add" button
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify the new ListTile is displayed
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('New Quest'), findsOneWidget);
    expect(find.text('Description of the new quest'), findsOneWidget);
  });
}
