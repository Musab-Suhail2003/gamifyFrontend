import 'package:Gamify/bloc/character_bloc.dart';
import 'package:Gamify/bloc/user_model_bloc.dart';
import 'package:Gamify/pages/characterTile.dart';
import 'package:Gamify/pages/characterpage.dart';
import 'package:Gamify/pages/leaderboard.dart';
import 'package:Gamify/ui_elements/progressBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/bloc/quest_model_bloc.dart';
import 'package:Gamify/models/quest_model.dart';
import 'milestone_page.dart';

class QuestPage extends StatefulWidget {
  final userData;
  const QuestPage({Key? key, required this.userData}) : super(key: key);

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  @override
  @override
  void initState() {
    super.initState();

    // Refresh user data when the page opens
    final userState = context.read<UserModelBloc>().state;
    if (userState is UserModelLoaded) {
      context.read<QuestModelBloc>().add(LoadQuestModel(userState.userModel.user_id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;
    return BlocListener<ApiBloc, ApiState>(
      listener: (context, state) {
        if (state is ApiLoaded) {
          context.read<QuestModelBloc>().add(LoadQuestModel(userData['_id']));
          context.read<UserModelBloc>().add(RefreshUserModel(userData['_id']));
          context.read<CharacterBloc>().add(LoadUserCharacters(userData['_id']));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeaderBoardPage(userData: userData),
                ),
              ).then((_) {
                // Refresh data when returning from LeaderBoardPage
                context.read<QuestModelBloc>().add(LoadQuestModel(userData['_id']));
                context.read<UserModelBloc>().add(RefreshUserModel(userData['_id']));
                context.read<CharacterBloc>().add(LoadUserCharacters(userData['_id']));
              });
            },
            icon: const Icon(Icons.leaderboard, weight: 50),
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          title: const Text('Quests'),
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
          ],
        ),
        body: BlocBuilder<QuestModelBloc, QuestModelState>(
          builder: (context, state) {
            if (state is QuestModelInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is QuestModelLoaded) {
              if (state.quests.isEmpty) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child:  const Center(child: Text("No Quests Added Yet")),),
                    Expanded(
                      flex: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            flex: 0,
                            child: CharacterTile(userId: userData['_id']),
                          ),
                          Row(
                            children: [
                              Text("coin: ${userData['coin']} XP: ${userData['XP']} "),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CharacterCustomizationScreen(
                                    character_id: userData['Character'],
                                    userId: userData['_id'],
                                  ),
                                ),
                              ).then((_) {
                                // Refresh user data after returning
                                context
                                    .read<UserModelBloc>()
                                    .add(RefreshUserModel(userData['_id']));
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                            ),
                            child: const Text(
                              'Customize',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: () {
                              _showAddQuestDialog(context, userData);
                            },
                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                            child: const Text(
                              'Add +\nQuest',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  Expanded(
                    flex: 10,
                    child: ListView.builder(
                      itemCount: state.quests.length,
                      itemBuilder: (context, index) {
                        final quest = state.quests[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MilestonePage(quest: quest),
                              ),
                            ).then((_) {
                              context
                                  .read<QuestModelBloc>()
                                  .add(LoadQuestModel(userData['_id']));
                            });
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                quest.quest_name,
                                style:
                                const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(quest.quest_description),
                              trailing: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Text("${quest.completion_percent}% done"),
                                  CompletionProgressBar(
                                    percentage: quest.completion_percent,
                                    height: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    flex: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 0,
                          child: CharacterTile(userId: userData['_id']),
                        ),
                        Row(
                          children: [
                            Text("coin: ${userData['coin']} XP: ${userData['XP']} "),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CharacterCustomizationScreen(
                                  character_id: userData['Character'],
                                  userId: userData['_id'],
                                ),
                              ),
                            ).then((_) {
                              // Refresh user data after returning
                              context
                                  .read<UserModelBloc>()
                                  .add(RefreshUserModel(userData['_id']));
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Theme.of(context).colorScheme.tertiary,
                          ),
                          child: const Text(
                            'Customize',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            _showAddQuestDialog(context, userData);
                          },
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          child: const Text(
                            'Add +\nQuest',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('Failed to load quests.'));
            }
          },
        ),
      ),
    );
  }


  void _showAddQuestDialog(BuildContext context, userData) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Quest"),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Quest Name",  hintText: "I want to Learn..."),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: "Quest Description", hintText: 'Become the best at...' ),

                  ),
                ],
              ),
              )
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.black),),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                final String description = descriptionController.text.trim();

                if (name.isNotEmpty && description.isNotEmpty) {
                  // Create a new QuestModel
                  final newQuest = QuestModel(
                    quest_name: name,
                    quest_description: description,
                    user_id: userData['_id'],
                    completion_percent: 0
                  );

                  // Dispatch the event to the ApiBloc
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
