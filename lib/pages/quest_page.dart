import 'package:Gamify/pages/characterTile.dart';
import 'package:Gamify/pages/characterpage.dart';
import 'package:Gamify/pages/leaderboard.dart';
import 'package:Gamify/ui_elements/progressBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/bloc/quest_model_bloc.dart';
import 'package:Gamify/models/milestone_model.dart';
import 'package:Gamify/models/quest_model.dart';
import 'milestone_page.dart'; // Import your milestone page here.

class QuestPage extends StatefulWidget {
  final userData;
  const QuestPage({super.key, required this.userData});


  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {

  @override
  void initState() {

    super.initState();
     print(widget.userData);
    // Load initial quest data when the page opens
    context.read<QuestModelBloc>().add(LoadQuestModel(widget.userData['_id']));
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;
    return BlocListener<ApiBloc, ApiState>(
      listener: (context, state){
        if(state is ApiLoaded){
          context.read<QuestModelBloc>().add(LoadQuestModel(widget.userData['_id']));
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: 
           () {
               Navigator.push(
               context,
               MaterialPageRoute(
                     builder: (context) => const LeaderBoardPage(),
                   ),
                 );
               }
        , icon: const Icon(Icons.leaderboard, weight: 50,)),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        title: const Text('Quests'),
        centerTitle: true,
        actions: [IconButton(onPressed:(){} , icon: Icon(Icons.settings))],
      ),
      body: BlocBuilder<QuestModelBloc, QuestModelState>(
        builder: (context, state) {
          if (state is QuestModelInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuestModelLoaded) {
            if (state.quests.length == 0){
              return const Center(child: Text("No Quests Added Yet"),);
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
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16.0, 
                            vertical: 8.0
                          ),
                          child: ListTile(
                            title: Text(
                              quest.quest_name,
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            subtitle: Text(quest.quest_description),

                            trailing: Column(
                              children: [
                                const SizedBox(height: 10,),
                                Text("${quest.completion_percent}% done"),
                                CompletionProgressBar(percentage: quest.completion_percent, height: 4)
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
                      Expanded(flex: 0, child: CharacterTile(userId: userData['_id'])),
                       Row(children: [ Text("coin: ${userData['coin']} XP: ${userData['XP']} ")],),
                      ElevatedButton(onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CharacterCustomizationScreen(character_id: userData['Character'], userId: userData['_id'],)));
                        },
                        style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.tertiary, 
                            ), 
                        child: const Text('Customize'), 
                        ) ,
                    FloatingActionButton(
                      onPressed: (){
                        _showAddQuestDialog(context);
                      },
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      child: const Text('Add +\nQuest', style: TextStyle(color: Colors.black),),
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

  void _showAddQuestDialog(BuildContext context) {
    final userData = widget.userData;
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
                  // Show an error if fields are empty
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