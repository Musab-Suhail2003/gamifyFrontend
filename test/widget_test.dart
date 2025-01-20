import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/models/quest_model.dart';
import 'package:Gamify/pages/characterpage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:Gamify/bloc/character_bloc.dart';
import 'package:Gamify/bloc/leaderboard_bloc.dart';
import 'package:Gamify/bloc/milestone_bloc.dart';
import 'package:Gamify/models/character_model.dart';
import 'package:Gamify/models/user_model.dart';
import 'package:Gamify/models/milestone_model.dart';
import 'package:Gamify/pages/characterTile.dart';
import 'package:Gamify/pages/leaderboard.dart';
import 'package:Gamify/pages/milestone_page.dart';

// Mock classes
class MockCharacterBloc extends MockBloc<CharacterEvent, CharacterState> implements CharacterBloc {}
class MockLeaderboardBloc extends MockBloc<LeaderboardEvent, LeaderboardState> implements LeaderboardBloc {}
class MockMilestoneBloc extends MockBloc<MilestoneEvent, MilestoneState> implements MilestoneBloc {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class MockApiBloc extends MockBloc<ApiEvent, ApiState> implements ApiBloc {}
class MockApiRepository extends Mock implements ApiRepository {}
class MockCharacter extends Mock implements Character {}

void main() {
  late MockCharacterBloc characterBloc;
  late MockLeaderboardBloc leaderboardBloc;
  late MockMilestoneBloc milestoneBloc;
  late MockNavigatorObserver navigatorObserver;
  late MockApiBloc apiBloc;
  late MockApiRepository apirepo;

  final testUserId = "test-user-123";

  setUpAll(() async {
    registerFallbackValue(FetchUserModel(testUserId));
    await loadAppFonts();
  });

  setUp(() {
    characterBloc = MockCharacterBloc();
    leaderboardBloc = MockLeaderboardBloc();
    milestoneBloc = MockMilestoneBloc();
    navigatorObserver = MockNavigatorObserver();
    apiBloc = MockApiBloc();
    apirepo = MockApiRepository();

    when(() => apiBloc.state).thenReturn(ApiInitial());
  });


  final testCharacter = Character(
    id: "char-123",
    userId: testUserId,
    hairstyleIndex: 0,
    outfitIndex: 0,
    backgroundIndex: 0,
    faceIndex: 0,
    bodyIndex: 0,
    eyeIndex: 0,
    backAccessoryIndex: 0,
    headWearIndex: 0,
    noseIndex: 0,
    irisIndex: 0,
  );

  Widget createTestWidget({
    required Widget child,
    bool wrapWithScaffold = true,
  }) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<CharacterBloc>.value(value: characterBloc),
          BlocProvider<LeaderboardBloc>.value(value: leaderboardBloc),
          BlocProvider<MilestoneBloc>.value(value: milestoneBloc),
          BlocProvider<ApiBloc>.value(value: apiBloc), // Add ApiBloc provider
        ],
        child: wrapWithScaffold ? Scaffold(body: child) : child,
      ),
      navigatorObservers: [navigatorObserver],
    );
  }


  group('CharacterTile Widget Tests', () {
    testWidgets('renders loading state correctly', (WidgetTester tester) async {
      when(() => characterBloc.state).thenReturn(CharacterLoading());

      await tester.pumpWidget(createTestWidget(
        child: CharacterTile(userId: testUserId),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders error state correctly', (WidgetTester tester) async {
      const errorMessage = 'Test error message';
      when(() => characterBloc.state).thenReturn(CharacterError(errorMessage));

      await tester.pumpWidget(createTestWidget(
        child: CharacterTile(userId: testUserId),
      ));

      expect(find.text(errorMessage), findsOneWidget);
    });

    testGoldens('Character Tile Golden Test - Loaded State', (tester) async {
      await mockNetworkImagesFor(() async {
        when(() => characterBloc.state).thenReturn(CharacterLoaded(testCharacter));

        await tester.pumpWidget(createTestWidget(
          child: Center(child: CharacterTile(userId: testUserId)),
        ));

        await screenMatchesGolden(tester, 'character_tile_loaded');
      });
    });
  });

  group('LeaderboardPage Widget Tests', () {
    final testUser = UserModel(
      user_id: testUserId,
      name: "Test User",
      googleId: "test@test.com",
      profilePicture: "https://test.com/pic.jpg",
      XP: 100,
      coin: 50,
      questsCompleted: 5,
      bio: "Test bio",
    );

    testWidgets('renders loading state correctly', (WidgetTester tester) async {
      when(() => leaderboardBloc.state).thenReturn(LeaderboardLoading());

      await tester.pumpWidget(createTestWidget(
        child: LeaderBoardPage(userData: testUser),
      ));

      expect(find.byType(LeaderBoardPage), findsOneWidget);
    });

    testGoldens('Leaderboard Page Golden Test', (tester) async {
      await mockNetworkImagesFor(() async {
        final entries = [
          LeaderboardEntry(
            user: testUser,
            character: testCharacter,
            rank: 1,
          ),
        ];

        when(() => leaderboardBloc.state).thenReturn(LeaderboardLoaded(entries));
        when(() => characterBloc.state).thenReturn(CharacterLoaded(testCharacter));

        await tester.pumpWidget(createTestWidget(
          child: LeaderBoardPage(userData: testUser),
        ));

        await screenMatchesGolden(tester, 'leaderboard_page');
      });
    });
  });

  group('MilestonePage Widget Tests', () {
    final testMilestone = Milestone(
      milestone_id: 1,
      questId: "quest-123",
      title: "Test Milestone",
      description: "Test Description",
      days: 7,
      completionPercent: 0,
    );

    testWidgets('MilestoneBloc is available in widget tree', (WidgetTester tester) async {
      when(() => milestoneBloc.state).thenReturn(MilestonesLoaded([testMilestone]));

      await tester.pumpWidget(createTestWidget(
        child: Builder(
          builder: (context) {
            // This will throw if the bloc is not found
            context.read<MilestoneBloc>();
            return const SizedBox();
          },
        ),
      ));

      expect(true, isTrue);
    });

    testWidgets('renders empty state correctly', (WidgetTester tester) async {
      when(() => milestoneBloc.state).thenReturn(MilestonesLoaded([testMilestone]));
      when(() => apiBloc.add(any<ApiEvent>())).thenReturn(null);

      await tester.pumpWidget(createTestWidget(
        child: MilestonePage(
          quest: QuestModel(
            quest_id: "quest-123",
            user_id: 'user-123',
            quest_name: "Test Quest",
            completion_percent: 0,
            quest_description: "Test Description",
          ),
        ),
      ));

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testGoldens('Milestone Page Golden Test', (tester) async {
      when(() => milestoneBloc.state)
          .thenReturn(MilestonesLoaded([testMilestone]));

      await tester.pumpWidget(createTestWidget(
        child: MilestonePage(
          quest: QuestModel(
            quest_id: "quest-123",
            user_id: 'user-123',
            quest_name: "Test Quest",
            completion_percent: 0,
            quest_description: "Test Description",
          ),
        ),
      ));

      await screenMatchesGolden(tester, 'milestone_page');
    });

  });


  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<CharacterBloc>(
        create: (context) => characterBloc,
        child: CharacterCustomizationScreen(
          character_id: 'test-character-id',
          userId: testUserId,
        ),
      ),
    );
  }

  group('CharacterCustomizationScreen Widget Tests', () {
    testWidgets('renders AppBar with correct title and changes display', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Character Customization'), findsOneWidget);
      expect(find.text('0 changes • 0 coins'), findsOneWidget);
    });

    testWidgets('renders CharacterTile widget', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(CharacterTile), findsOneWidget);
    });

    testWidgets('renders customization options', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final options = [
        'Hairstyle',
        'Outfit',
        'Background',
        'Face',
        'Body',
        'Eyes',
        'Back Accessory',
        'Head Wear',
        'Nose',
        'Iris',
      ];

      for (final option in options) {
        expect(find.text(option), findsOneWidget);
      }
    });

    testWidgets('updates totalChanges and coins when state changes', (tester) async {
      when(() => characterBloc.state).thenReturn(CharacterLoaded(
        Character(
          id: 'test-character-id',
          userId: testUserId,
          hairstyleIndex: 1,
          outfitIndex: 2,
          backgroundIndex: 3,
          faceIndex: 4,
          bodyIndex: 5,
          eyeIndex: 6,
          backAccessoryIndex: 7,
          headWearIndex: 8,
          noseIndex: 9,
          irisIndex: 10,
        ),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assuming 10 changes detected
      expect(find.text('10 changes • 1000 coins'), findsOneWidget);
    });

    testWidgets('tapping customization option triggers bloc event', (tester) async {
      when(() => characterBloc.state).thenReturn(CharacterLoaded(
        Character(
          id: 'test-character-id',
          userId: testUserId,
          hairstyleIndex: 0,
          outfitIndex: 0,
          backgroundIndex: 0,
          faceIndex: 0,
          bodyIndex: 0,
          eyeIndex: 0,
          backAccessoryIndex: 0,
          headWearIndex: 0,
          noseIndex: 0,
          irisIndex: 0,
        ),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final hairstyleOption = find.text('Hairstyle');
      await tester.tap(hairstyleOption);
      await tester.pumpAndSettle();

      verify(() => characterBloc.add(any(that: isA<ChangeHairstyle>()))).called(1);
    });
  });

  group('CharacterCustomizationScreen Golden Tests', () {
    testGoldens('renders correctly with initial state', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'character_customization_screen_initial');
    });

    testGoldens('renders correctly with changes', (tester) async {
      when(() => characterBloc.state).thenReturn(CharacterLoaded(
        Character(
          id: 'test-charcter-id',
          userId: testUserId,
          hairstyleIndex: 1,
          outfitIndex: 2,
          backgroundIndex: 3,
        ),
      ));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await screenMatchesGolden(tester, 'character_customization_screen_with_changes');
    });
  });
}