import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/models/quest_model.dart';
import 'package:Gamify/models/milestone_model.dart';
import 'package:Gamify/models/task_model.dart';
import 'google_sign_in_provider_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApiRepository', () {
    late ApiRepository apiRepository;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      apiRepository = ApiRepository();
    });

    test('fetchQuestModel returns a QuestModel if the http call completes successfully', () async {
      final questId = 1;
      final responseJson = {
        'id': questId,
        'name': 'Test Quest',
        'description': 'Test Description',
        'milestones': []
      };

      when(mockClient.get(Uri.parse('http://localhost:3000/quests/$questId')))
          .thenAnswer((_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiRepository.fetchQuestModel(questId);

      expect(result, isA<QuestModel>());
      expect(result.quest_name, 'Test Quest');
      expect(result.quest_description, 'Test Description');
    });

    test('fetchMilestone returns a Milestone if the http call completes successfully', () async {
      final milestoneId = 1;
      final responseJson = {
        'id': milestoneId,
        'title': 'Test Milestone',
        'description': 'Test Description',
        'dueDate': '2023-01-01T00:00:00.000Z',
        'isCompleted': false,
        'tasks': []
      };

      when(mockClient.get(Uri.parse('http://localhost:3000/milestones/$milestoneId')))
          .thenAnswer((_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiRepository.fetchMilestone(milestoneId);

      expect(result, isA<Milestone>());
      expect(result.title, 'Test Milestone');
      expect(result.description, 'Test Description');
    });

    test('fetchTask returns a Task if the http call completes successfully', () async {
      final taskId = 1;
      final responseJson = {
        'id': taskId,
        'title': 'Test Task',
        'description': 'Test Description',
        'level': 'easy'
      };

      when(mockClient.get(Uri.parse('http://localhost:3000/tasks/$taskId')))
          .thenAnswer((_) async => http.Response(jsonEncode(responseJson), 200));

      final result = await apiRepository.fetchTask(taskId);

      expect(result, isA<Task>());
      expect(result.title, 'Test Task');
      expect(result.description, 'Test Description');
    });

    test('fetchQuestModel throws an exception if the http call completes with an error', () async {
      final questId = 1;

      when(mockClient.get(Uri.parse('http://localhost:3000/quests/$questId')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => apiRepository.fetchQuestModel(questId), throwsException);
    });

    test('fetchMilestone throws an exception if the http call completes with an error', () async {
      final milestoneId = 1;

      when(mockClient.get(Uri.parse('http://localhost:3000/milestones/$milestoneId')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => apiRepository.fetchMilestone(milestoneId), throwsException);
    });

    test('fetchTask throws an exception if the http call completes with an error', () async {
      final taskId = 1;

      when(mockClient.get(Uri.parse('http://localhost:3000/tasks/$taskId')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => apiRepository.fetchTask(taskId), throwsException);
    });
  });
}