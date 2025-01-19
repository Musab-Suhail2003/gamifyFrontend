import 'package:Gamify/bloc/task_bloc.dart';
import 'package:Gamify/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskPage extends StatefulWidget {
  final dynamic milestoneId;
  const TaskPage({super.key, required this.milestoneId});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  @override
  void initState() {
    super.initState();
    // Load tasks when the page is initialized
    context.read<TaskBloc>().add(LoadTasksByMilestone(widget.milestoneId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tasks"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            // Show error message in a Snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskLoaded) {
              if (state.tasks.isEmpty) {
                return const Center(child: Text("No Tasks Added Yet"));
              }
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.completed ? "Completed" : '',
                            style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                          ),
                          Text(task.description),
                          Text("Level: ${task.level.toString().split('.').last}"),
                          Text("XP: ${Task.levelXpMap[task.level]}"),
                        ],
                      ),
                      trailing: Checkbox(
                        value: task.completed,
                        onChanged: (value) {
                          context.read<TaskBloc>().add(CompleteTask(task.task_id, task.milestone_id));
                        },
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(
              child: Text('Remember to start the milestone\n      before completing a quest!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        child: const Text(
          'Task\n   +',
          style: TextStyle(color: Colors.black, fontSize: 12),
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    TaskLevel selectedLevel = TaskLevel.EASY; // Initialize with an enum value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New Task"),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Task Name",
                      hintText: "Enter task name...",
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Task Description",
                      hintText: "Enter task description...",
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<TaskLevel>(
                    value: selectedLevel,
                    decoration: const InputDecoration(
                      labelText: "Select Task Level",
                    ),
                    items: TaskLevel.values.map((level) {
                      return DropdownMenuItem<TaskLevel>(
                        value: level,
                        child: Text(level.toString().split('.').last.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (level) {
                      setState(() {
                        selectedLevel = level!;
                      });
                    },
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
                // Validate inputs
                final String title = titleController.text.trim();
                final String description = descriptionController.text.trim();

                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill out all fields.")),
                  );
                  return;
                }

                // Create new task
                final newTask = Task(
                  milestone_id: widget.milestoneId,
                  title: title,
                  description: description,
                  level: selectedLevel.toString().split('.').last, // Convert enum to string
                );

                // Dispatch the event to add the task
                context.read<TaskBloc>().add(CreateTask(newTask));

                // Close the dialog
                Navigator.of(context).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Task added successfully!")),
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
