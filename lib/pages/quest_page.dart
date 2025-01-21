import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/pages/characterTile.dart';
import 'package:Gamify/pages/characterpage.dart';
import 'package:Gamify/pages/leaderboard.dart';
import 'package:Gamify/pages/settingspage.dart';
import 'package:Gamify/ui_elements/progressBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/bloc/quest_model_bloc.dart';
import 'package:Gamify/bloc/user_model_bloc.dart';
import 'package:Gamify/models/quest_model.dart';
import 'package:Gamify/models/user_model.dart';
import 'milestone_page.dart';

class QuestPage extends StatefulWidget {
  final String userId;
  const QuestPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ApiRepository().fetchAndSendToken(widget.userId);
    context.read<UserModelBloc>().add(LoadUserModel(widget.userId));
    context.read<QuestModelBloc>().add(LoadQuestModel(widget.userId));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<UserModelBloc>().add(RefreshUserModel(widget.userId));
      context.read<QuestModelBloc>().add(LoadQuestModel(widget.userId));
    }
  }

  Future<void> _navigateToPage(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
    // Reload data after navigation
    if (mounted) {
      context.read<UserModelBloc>().add(RefreshUserModel(widget.userId));
      context.read<QuestModelBloc>().add(LoadQuestModel(widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApiBloc, ApiState>(
      listener: (context, state) {
        if (state is ApiLoaded) {
          // Reload data after successful API call
          context.read<UserModelBloc>().add(RefreshUserModel(widget.userId));
          context.read<QuestModelBloc>().add(LoadQuestModel(widget.userId));
        }
      },
      child: BlocBuilder<UserModelBloc, UserModelState>(
        builder: (context, userState) {
          if (userState is UserModelLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (userState is UserModelLoaded) {
            return _buildScaffold(userState.userModel);
          } else if (userState is UserModelError) {
            return Center(child: Text(userState.message));
          }
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.leaderboard, weight: 50),
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              title: const Text('Quests'),
              centerTitle: true,
              actions: [
                IconButton(
                    onPressed: () => _navigateToPage(const SettingsPage()),
                    icon: const Icon(Icons.settings)
                ),
              ],
            ),
            body: Center(child: Text('Something went wrong')),
          );
        },
      ),
    );
  }

  Widget _buildScaffold(UserModel user) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _navigateToPage(LeaderBoardPage(userData: user)),
          icon: const Icon(Icons.leaderboard, weight: 50),
        ),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        title: const Text('Quests'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () => _navigateToPage(const SettingsPage()),
              icon: const Icon(Icons.settings)
          ),
        ],
      ),
      body: BlocBuilder<QuestModelBloc, QuestModelState>(
        builder: (context, state) {
          if (state is QuestModelInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuestModelLoaded) {
            return _buildQuestList(state, user);
          } else {
            return const Center(child: Text('Failed to load quests.'));
          }
        },
      ),
    );
  }

  Widget _buildQuestList(QuestModelLoaded state, UserModel user) {
    return Column(
      children: [
        Expanded(
          flex: 10,
          child: state.quests.isEmpty
              ? const Center(child: Text("No Quests Added Yet"))
              : ListView.builder(
            itemCount: state.quests.length,
            itemBuilder: (context, index) => _buildQuestTile(state.quests[index]),
          ),
        ),
        Expanded(
          flex: 0,
          child: _buildBottomBar(user),
        ),
      ],
    );
  }

  Widget _buildQuestTile(QuestModel quest) {
    return GestureDetector(
      onLongPress: (){
        showDialog(
            context: context,
            builder: (BuildContext context){
              return  AlertDialog(
                title: const Text('Delete Quest?'),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<ApiBloc>().add(deleteQuestModel(quest.quest_id!));
                      context.read<ApiBloc>().add(FetchQuestModel(quest.user_id));
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.black, fontStyle: FontStyle.normal),
                    ),
                  ),
                ],
              );
            }
        );
      },
      onTap: () => _navigateToPage(MilestonePage(quest: quest)),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListTile(
          title: Text(
            quest.quest_name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(quest.quest_description),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("${quest.completion_percent}% done"),
              const SizedBox(height: 4),
              CompletionProgressBar(
                percentage: quest.completion_percent,
                height: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          flex: 0,
          child: CharacterTile(userId: user.user_id),
        ),
        Row(
          children: [
            Text("coin: ${user.coin} XP: ${user.XP} "),
          ],
        ),
        ElevatedButton(
          onPressed: () => _navigateToPage(
            CharacterCustomizationScreen(
              character_id: user.character_id,
              userId: user.user_id,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.tertiary,
          ),
          child: const Text(
            'Customize',
            style: TextStyle(color: Colors.black),
          ),
        ),
        FloatingActionButton(
          onPressed: () => _showAddQuestDialog(),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          child: const Text(
            'Add +\nQuest',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  void _showAddQuestDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Add New Quest"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: "Quest Name",
                      hintText: "I want to Learn..."
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      labelText: "Quest Description",
                      hintText: 'Become the best at...'
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final String description = descriptionController.text.trim();

                if (name.isNotEmpty && description.isNotEmpty) {
                  final newQuest = QuestModel(
                      quest_name: name,
                      quest_description: description,
                      user_id: widget.userId,
                      completion_percent: 0
                  );

                  context.read<ApiBloc>().add(PostQuestModel(newQuest));
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please fill out all fields."),
                    ),
                  );
                }
              },
              child: const Text("Add", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }
}