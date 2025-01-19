import 'package:Gamify/bloc/api_bloc.dart';
import 'package:Gamify/bloc/milestone_bloc.dart';
import 'package:Gamify/models/milestone_model.dart';
import 'package:Gamify/models/quest_model.dart';
import 'package:Gamify/pages/task_page.dart';
import 'package:Gamify/ui_elements/progressBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MilestonePage extends StatefulWidget {
  final QuestModel quest;
  const MilestonePage({super.key, required this.quest});


  @override
  State<MilestonePage> createState() => _MilestonePageState();
}

class _MilestonePageState extends State<MilestonePage> {

  @override
  void initState() {

    super.initState();
    // Load initial quest data when the page opens
    context.read<MilestoneBloc>().add(MilestoneLoad(widget.quest.quest_id));
  }

  @override
  Widget build(BuildContext context) {
    final quest = widget.quest.quest_id;
    return BlocListener<ApiBloc, ApiState>(
      listener: (context, state){
        if(state is ApiLoaded){
          context.read<MilestoneBloc>().add(MilestoneLoad(widget.quest));
        }
      },
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        title: Text('Milestones for "${widget.quest.quest_name}"'),
        centerTitle: true,
        actions: [],
      ),
      body: BlocBuilder<MilestoneBloc, MilestoneState>(
        builder: (context, state) {
          if (state is MilestoneInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MilestonesLoaded) {
            if (state.milestones.isEmpty){
              return const Center(child: Text("No Milestones Added Yet"),);
            }
            return ListView.builder(
              itemCount: state.milestones.length,
              itemBuilder: (context, index) {
                final milestone = state.milestones[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskPage(milestoneId: milestone.milestone_id),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0, 
                      vertical: 8.0
                    ),
                    child: ListTile(
                      leading: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Start Milestone!   Not reversable', style: TextStyle(fontSize: 15, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold),),
                                  content: ElevatedButton(
                                    onPressed: (){
                                      context.read<MilestoneBloc>().add(
                                          UpdateMilestone(milestone)
                                      );

                                      Navigator.of(context).pop();

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Milestone started successfully!'),
                                        ),
                                      );
                                    },
                                    child: Text('start'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                      , icon: const Icon(Icons.play_arrow)),
                      title: Text(
                        milestone.title,
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                      subtitle: Text(milestone.description),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                        CompletionProgressBar(percentage: milestone.completionPercent, ),
                        Text("${milestone.completionPercent}%"),
                        Text((milestone.days>0)?"${milestone.days} days left":"Late will only get half the points"),
                        Text((milestone.startTime != null)?'Started':'Not Started')
                      ],),
                    ),
                  ),
                );
              },
            );

          } else {
            return const Center(child: Text('Failed to load Milestones.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showAddQuestDialog(context);

        },
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Text('Milestone\n         +', style: TextStyle(color: Colors.black, fontSize: 12),),
        ),
    ),
    );
  }
void _showAddQuestDialog(BuildContext context) {
  final questId = widget.quest.quest_id;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final dueDateController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Add New Milestone"),
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
                  decoration: const InputDecoration(
                    labelText: "Milestone Name",
                    hintText: "Enter milestone name...",
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Milestone Description",
                    hintText: "e.g., Lose X amount of weight",
                  ),
                ),
                TextField(
                  controller: dueDateController,
                  decoration: const InputDecoration(
                    labelText: "Milestone Duration (in days)",
                    hintText: "Only enter days",
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Dismiss the keyboard
              FocusScope.of(context).unfocus();

              final String name = nameController.text.trim();
              final String description = descriptionController.text.trim();
              final String dueDateText = dueDateController.text.trim();

              // Validate inputs
              if (name.isEmpty || description.isEmpty || dueDateText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill out all fields."),
                  ),
                );
                return;
              }

              int days;
              try {
                days = int.parse(dueDateText);
                if (days <= 0) throw Exception(); // Validate positive days
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a valid positive number for days."),
                  ),
                );
                return;
              }

              // Create a new Milestone
              final newMilestone = Milestone(
                questId: questId,
                title: name,
                description: description,
                days: days,
                completionPercent: 0,
              );

              // Dispatch the PostMilestone event to MilestoneBloc
              context.read<MilestoneBloc>().add(postMilestone(newMilestone));

              // Close the dialog
              Navigator.of(context).pop();

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Milestone added successfully!"),
                ),
              );
            },
            child: const Text(
              "Add",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      );
    },
  );
}



}