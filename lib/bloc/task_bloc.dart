import 'package:Gamify/api/api_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:Gamify/models/task_model.dart';

// States
sealed class TaskState extends Equatable {
  const TaskState();
  
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;

  TaskLoaded(this.tasks);
  
  @override
  List<Object> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  
  @override
  List<Object> get props => [message];
}

// Events
sealed class TaskEvent extends Equatable {
  const TaskEvent();
  
  @override
  List<Object> get props => [];
}

class LoadTasksByMilestone extends TaskEvent {
  final dynamic milestoneId;
  const LoadTasksByMilestone(this.milestoneId);
  
  @override
  List<Object> get props => [milestoneId];
}

class CreateTask extends TaskEvent {
  final Task task;
  const CreateTask(this.task);
  
  @override
  List<Object> get props => [task];
}

class CompleteTask extends TaskEvent {
  final dynamic taskId;
  final dynamic milestoneId; // Added to refresh milestone tasks after completion
  const CompleteTask(this.taskId, this.milestoneId);
  
  @override
  List<Object> get props => [taskId];
}

// Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final apiRepository = ApiRepository();

  TaskBloc() : super(TaskInitial()) {
    on<LoadTasksByMilestone>(_onLoadTasksByMilestone);
    on<CreateTask>(_onCreateTask);
    on<CompleteTask>(_onCompleteTask);
  }

  Future<void> _onLoadTasksByMilestone(
  LoadTasksByMilestone event,
  Emitter<TaskState> emit,
) async {
  emit(TaskLoading());
  try {
    // Fetch tasks from the API
    final tasks = await apiRepository.fetchTaskbyMilestone(event.milestoneId);

    // Debugging logs
    print('Fetched tasks: $tasks');
    print('Number of tasks: ${tasks.length}');

    if (tasks.isEmpty) {
      print('No tasks found, emitting empty TaskLoaded state.');
      emit(TaskLoaded([])); // Emit empty list if no tasks are returned
    } else {
      print('Tasks found, emitting TaskLoaded with tasks.');
      emit(TaskLoaded(tasks)); // Emit loaded tasks
    }
  } catch (e) {
    // Print error details and emit TaskError state
    print('Error while loading tasks: ${e.toString()}');
    emit(TaskError(e.toString()));
  }
}


  Future<void> _onCreateTask(
    CreateTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      if (event.task.milestone_id != null) {
        await apiRepository.postTask(event.task);
        final tasks = await apiRepository.fetchTaskbyMilestone(event.task.milestone_id);
        emit(TaskLoaded(tasks));
      } else {
        emit(TaskInitial());
      }
    } catch (e) {
      print(e.toString());
      emit(TaskError(e.toString()));
    }
  }

Future<void> _onCompleteTask(
  CompleteTask event,
  Emitter<TaskState> emit,
) async {
  emit(TaskLoading());
  try {
    await apiRepository.updateTask(event.taskId);

    // Fetch tasks by milestone
    if (event.milestoneId != null) {
      final tasks = await apiRepository.fetchTaskbyMilestone(event.milestoneId);
      emit(TaskLoaded(tasks));
    } else {
      emit(TaskInitial()); // Fallback if no milestone ID
    }
  } catch (e) {
    print('Error in _onCompleteTask: ${e.toString()}');
    emit(TaskError('${e.toString()}'));
  }
}


}
