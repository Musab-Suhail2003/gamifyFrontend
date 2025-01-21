import 'package:Gamify/pages/quest_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:Gamify/models/quest_model.dart';
import 'package:Gamify/models/user_model.dart';
import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/bloc/quest_model_bloc.dart';
import 'package:Gamify/bloc/user_model_bloc.dart';

// Mock classes
class MockApiBloc extends Mock implements ApiBloc {}
class MockQuestModelBloc extends Mock implements QuestModelBloc {}
class MockUserModelBloc extends Mock implements UserModelBloc {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockApiBloc apiBloc;
  late MockQuestModelBloc questBloc;
  late MockUserModelBloc userBloc;
  late MockNavigatorObserver navigatorObserver;

  final testUser = UserModel(
    user_id: "test_user",
    character_id: "test_character",
    coin: 100,
    XP: 500, name: 'test-name', bio: 'test-bio', questsCompleted: 0, googleId: 'test-google-id',
  );

  final testQuests = [
    QuestModel(
      quest_id: "1",
      quest_name: "Learn Flutter",
      quest_description: "Master Flutter framework",
      user_id: "test_user",
      completion_percent: 75,
    ),
    QuestModel(
      quest_id: "2",
      quest_name: "Learn Dart",
      quest_description: "Master Dart programming",
      user_id: "test_user",
      completion_percent: 50,
    ),
  ];

  setUp(() {
    apiBloc = MockApiBloc();
    questBloc = MockQuestModelBloc();
    userBloc = MockUserModelBloc();
    navigatorObserver = MockNavigatorObserver();

    // Set up default states
    when(() => apiBloc.state).thenReturn(ApiInitial());
    when(() => userBloc.state).thenReturn(UserModelLoaded(testUser));
    when(() => questBloc.state).thenReturn(QuestModelLoaded(testQuests));
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ApiBloc>.value(value: apiBloc),
          BlocProvider<UserModelBloc>.value(value: userBloc),
          BlocProvider<QuestModelBloc>.value(value: questBloc),
        ],
        child: const QuestPage(userId: "test_user"),
      ),
      navigatorObservers: [navigatorObserver],
    );
  }

  group('QuestPage Widget Tests', () {
    testWidgets('shows loading indicator when user model is loading',
            (WidgetTester tester) async {
          when(() => userBloc.state).thenReturn(UserModelLoading());

          await tester.pumpWidget(createWidgetUnderTest());

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

    testWidgets('shows error message when user model fails to load',
            (WidgetTester tester) async {
          when(() => userBloc.state).thenReturn(
              const UserModelError('Failed to load user')
          );

          await tester.pumpWidget(createWidgetUnderTest());

          expect(find.text('Failed to load user'), findsOneWidget);
        });

    testWidgets('displays quests when data is loaded successfully',
            (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          expect(find.text('Learn Flutter'), findsOneWidget);
          expect(find.text('Learn Dart'), findsOneWidget);
          expect(find.text('75% done'), findsOneWidget);
          expect(find.text('50% done'), findsOneWidget);
        });

    testWidgets('shows empty state message when no quests exist',
            (WidgetTester tester) async {
          when(() => questBloc.state).thenReturn(const QuestModelLoaded([]));

          await tester.pumpWidget(createWidgetUnderTest());

          expect(find.text('No Quests Added Yet'), findsOneWidget);
        });

    testWidgets('opens add quest dialog when FAB is pressed',
            (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          expect(find.text('Add New Quest'), findsOneWidget);
          expect(find.byType(TextField), findsNWidgets(2));
        });

    testWidgets('shows delete confirmation dialog on quest long press',
            (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          await tester.longPress(find.text('Learn Flutter'));
          await tester.pumpAndSettle();

          expect(find.text('Delete Quest?'), findsOneWidget);
          expect(find.text('Delete'), findsOneWidget);
        });

    testWidgets('displays user stats in bottom bar',
            (WidgetTester tester) async {
          await tester.pumpWidget(createWidgetUnderTest());

          expect(find.text('coin: 100 XP: 500'), findsOneWidget);
        });
  });

  group('QuestPage Golden Tests', () {
    setUp(() async {
      await loadAppFonts();
    });

    testGoldens('renders correctly in light mode', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [
            Device.phone,
          ],
        )
        ..addScenario(
          widget: createWidgetUnderTest(),
          name: 'default_state',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'quest_page_light_mode');
    });

    testGoldens('renders correctly with no quests', (tester) async {
      when(() => questBloc.state).thenReturn(const QuestModelLoaded([]));

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [Device.phone],
        )
        ..addScenario(
          widget: createWidgetUnderTest(),
          name: 'empty_state',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'quest_page_empty_state');
    });

    testGoldens('renders correctly in loading state', (tester) async {
      when(() => userBloc.state).thenReturn(UserModelLoading());

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [Device.phone],
        )
        ..addScenario(
          widget: createWidgetUnderTest(),
          name: 'loading_state',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'quest_page_loading_state');
    });
  });
}