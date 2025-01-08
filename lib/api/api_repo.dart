import 'dart:convert';
import 'package:Gamify/bloc/leaderboard_bloc.dart';
import 'package:Gamify/models/character_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:Gamify/models/quest_model.dart';
import 'package:Gamify/models/milestone_model.dart';
import 'package:Gamify/models/task_model.dart';
import 'package:Gamify/models/user_model.dart';

const String baseUrl = 'https://gamifybackend.vercel.app/';
Map<String, dynamic>? user;
String? token;

class ApiRepository {
  final http.Client client = http.Client();


  Future<List<Character>> getAllCharacters() async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Character.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Character> getCharacterById(String id) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/$id'));
      
      if (response.statusCode == 200) {
        return Character.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load character');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<Character> getCharactersByUserId(String userId) async {
    try {
      final response = await client.get(Uri.parse('$baseUrl/characters/user/$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']['character'];
        final char = Character.fromJson(data);
        print('printing character');
        print(data);
        return char;
      } else {
        throw Exception('Failed to load user characters');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<void> updateCharacter(String id, Map<String, dynamic> characterData) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/characters/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(characterData),
      );
      
      if (response.statusCode > 299) {
        print(response.body);
        throw Exception('Failed to save character');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  Future<List<QuestModel>> fetchUsersQuests() async {
    final response = await client.get(
      Uri.parse('$baseUrl/quests/user/${user!['_id']}')
    );
  
    if (response.statusCode == 200) {
      // Parse the JSON array from response body
      final List<dynamic> questsJson = jsonDecode(response.body);
      
      // Convert each JSON object to a QuestModel
      return questsJson.map((questJson) => QuestModel.fromJson(questJson)).toList();
    } else {
      throw Exception('Failed to load quests');
    }
  }

  Future<QuestModel> fetchQuestModel(int questId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/quests/$questId')
    );

    if (response.statusCode == 200) {
      return QuestModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load quest');
    }
  }

  Future<List<Milestone>> fetchMilestonesbyQuest(dynamic questId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/milestones/quest/$questId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> milestonesJson = jsonDecode(response.body); // Decode as a list of dynamic
      return milestonesJson.map((milestoneJson) => Milestone.fromJson(milestoneJson)).toList();
    } else {
      throw Exception('Failed to load milestones');
    }
  }

  Future<Milestone> fetchMilestone(dynamic milestoneId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/milestones/$milestoneId')
    );

    if (response.statusCode == 200) {
      return Milestone.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load milestone');
    }
  }

  Future<Task> fetchTask(dynamic taskId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/tasks/$taskId')
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load task');
    }
  }

  Future<List<Task>> fetchTaskbyMilestone(String milestoneId) async {
  final response = await http.get(Uri.parse('$baseUrl/tasks/milestone/$milestoneId'));

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body)['data']['tasks'];

    // Convert each JSON object to a Task
    return jsonData.map((data) => Task.fromJson(data)).toList();
  } else {
    throw Exception('Failed to fetch tasks');
  }
}


  Future<dynamic> updateTask(task_id)async{
    print('$baseUrl/tasks/$task_id');
    final response = await client.patch(
      Uri.parse('$baseUrl/tasks/$task_id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({"isCompleted": true}),
    );

    if (response.statusCode > 299) {
      throw Exception('Failed to update task');
    }
  }

  Future<UserModel> fetchUserModel(dynamic userId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/users/$userId')
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> postUserModel(UserModel userModel) async {
    final response = await client.post(
      Uri.parse('$baseUrl/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(userModel.toJson()),
    );

    if (response.statusCode > 299) {
      throw Exception('Failed to create user');
    }
  }

  Future<void> postQuestModelbyUser(QuestModel questModel) async {
    final response = await client.post(
      Uri.parse('$baseUrl/quests/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(questModel.toJson()),
    );

    if (response.statusCode > 299) {
      throw Exception('Failed to create quest');
    }
  }

  Future<void> postMilestone(Milestone milestone) async {
    print('adding milestone');
    print(milestone.toJson());
    final response = await client.post(
      Uri.parse('$baseUrl/milestones/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(milestone.toJson()),
    );

    if (response.statusCode > 299) {
      throw Exception('Failed to create milestone');
    }
  }

  Future<void> postTask(Task task) async {
    final response = await client.post(
      Uri.parse('$baseUrl/tasks/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(task.toJson()),
    );
    print('added task $task');
    if (response.statusCode > 299) {
      throw Exception('Failed to create task');
    }
  }

   Future<List<LeaderboardEntry>> getLeaderboard() async {
    try {
      // First fetch all users sorted by XP
      final response = await client.get(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body)['data']['users'];
        List<LeaderboardEntry> leaderboard = [];

        // For each user, fetch their character info and combine the data
        for (var userJson in usersJson) {
          final user = UserModel.fromJson(userJson);
          
          // Fetch the user's main character
          final charactersResponse = await client.get(
            Uri.parse('$baseUrl/characters/user/${user.user_id}')
          );

          if (charactersResponse.statusCode == 200) {

            final characterJson = json.decode(charactersResponse.body)['data']['character'];
            print(characterJson);
            final character = Character.fromJson(characterJson);

            // Create a leaderboard entry combining user and character data
            leaderboard.add(LeaderboardEntry(
              user: user,
              character: character,
              rank: leaderboard.length + 1
            ));
          }
        }

        return leaderboard;
      } else {
        throw Exception('Failed to load leaderboard data');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}

class GoogleSignInProvider {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '295830871666-ubmfg8eg3nogfdbjivt48amijmok435d.apps.googleusercontent.com',
    scopes: ['profile', 'email'],
  );
  final http.Client _client = http.Client();

  GoogleSignInProvider();

  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return {'error': 'User canceled sign-in'};
      }

      print(googleUser);

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken; // Use idToken for user authentication
      print('printing google id token: ');
      print(idToken);

      if (idToken == null) {
        throw Exception('Failed to retrieve ID token');
      }

      // Send the idToken to your Node.js backend
      final response = await _client.post(
        Uri.parse('$baseUrl/users/google-login'), // Ensure this is the correct endpoint
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "token" : idToken
        })
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        user = result['user'];
        token = result['token'];
        return result; // Successfully authenticated
      } else {
        final error = jsonDecode(response.body);
        print(error);
        return {
          'error': error['message'] ?? 'Google Authentication Failed',
        };
      }
    } catch (error) {
      print('Error during Google sign-in: $error');
      return {'error': 'An unexpected error occurred'};
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
