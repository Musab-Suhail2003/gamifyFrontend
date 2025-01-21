import 'package:equatable/equatable.dart';
import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/models/quest_model.dart';
import 'package:Gamify/models/milestone_model.dart';
import 'package:Gamify/models/task_model.dart';
import 'package:Gamify/models/user_model.dart';
import 'package:bloc/bloc.dart';

abstract class ApiEvent extends Equatable {
  const ApiEvent();

  @override
  List<Object> get props => [];
}


class FetchQuestModel extends ApiEvent {
  final dynamic questId;

  const FetchQuestModel(this.questId);

  @override
  List<Object> get props => [questId];
}

class FetchMilestone extends ApiEvent {
  final dynamic milestoneId;

  const FetchMilestone(this.milestoneId);

  @override
  List<Object> get props => [milestoneId];
}

class FetchTask extends ApiEvent {
  final dynamic taskId;

  const FetchTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class FetchUserModel extends ApiEvent {
  final dynamic userId;

  const FetchUserModel(this.userId);

  @override
  List<Object> get props => [userId];
}

class PostUserModel extends ApiEvent {
  final UserModel userModel;

  const PostUserModel(this.userModel);

  @override
  List<Object> get props => [userModel];
}

class PostQuestModel extends ApiEvent {
  final QuestModel questModel;

  const PostQuestModel(this.questModel);

  @override
  List<Object> get props => [questModel];
}

class deleteQuestModel extends ApiEvent {
  final String questId;

  const deleteQuestModel(this.questId);

  @override
  List<Object> get props => [questId];
}

class deleteMilestoneModel extends ApiEvent {
  final String milestoneId;

  const deleteMilestoneModel(this.milestoneId);

  @override
  List<Object> get props => [milestoneId];
}


class deleteTaskModel extends ApiEvent {
  final String taskId;

  const deleteTaskModel(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class PostMilestone extends ApiEvent {
  final Milestone milestone;

  const PostMilestone(this.milestone);

  @override
  List<Object> get props => [milestone];
}

class PostTask extends ApiEvent {
  final Task task;

  const PostTask(this.task);

  @override
  List<Object> get props => [task];
}


abstract class ApiState extends Equatable {
  const ApiState();

  @override
  List<Object> get props => [];
}

class ApiInitial extends ApiState {}

class ApiLoading extends ApiState {}

class ApiLoaded<T> extends ApiState {
  final dynamic data;

  const ApiLoaded(this.data);

  @override
  List<Object> get props => [data];
}

class ApiError extends ApiState {
  final String message;

  const ApiError(this.message);

  @override
  List<Object> get props => [message];
}



class ApiBloc extends Bloc<ApiEvent, ApiState> {
  final ApiRepository apiRepository;

  ApiBloc({required this.apiRepository}) : super(ApiInitial()) {
    on<FetchQuestModel>(_onFetchQuestModel);
    on<FetchMilestone>(_onFetchMilestone);
    on<FetchTask>(_onFetchTask);
    on<FetchUserModel>(_onFetchUserModel);
    on<PostUserModel>(_onPostUserModel);
    on<PostQuestModel>(_onPostQuestModel);
    on<PostMilestone>(_onPostMilestone);
    on<PostTask>(_onPostTask);
    on<deleteTaskModel>(_ondeleteTaskModel);
    on<deleteMilestoneModel>(_ondeleteMilestoneModel);
    on<deleteQuestModel>(_ondeleteQuestModel);
  }

  Future<void> _ondeleteTaskModel(deleteTaskModel event, Emitter<ApiState> emit) async {
    try {
      await apiRepository.deleteTask(event.taskId);
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }
  Future<void> _ondeleteMilestoneModel(deleteMilestoneModel event, Emitter<ApiState> emit) async {
    try {
      await apiRepository.deleteMileStone(event.milestoneId);
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }
  Future<void> _ondeleteQuestModel(deleteQuestModel event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      await apiRepository.deleteQuest(event.questId);
      emit(ApiLoaded<void>(null));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> _onFetchQuestModel(FetchQuestModel event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      final questModel = await apiRepository.fetchQuestModel(event.questId);
      emit(ApiLoaded<QuestModel>(questModel));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> _onFetchMilestone(FetchMilestone event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      final milestone = await apiRepository.fetchMilestone(event.milestoneId);
      emit(ApiLoaded<Milestone>(milestone));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> _onFetchTask(FetchTask event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      final task = await apiRepository.fetchTask(event.taskId);
      emit(ApiLoaded<Task>(task));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> _onFetchUserModel(FetchUserModel event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      final userModel = await apiRepository.fetchUserModel(event.userId);
      emit(ApiLoaded<UserModel>(userModel));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> _onPostUserModel(PostUserModel event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      await apiRepository.postUserModel(event.userModel);
      emit(ApiLoaded<void>(null));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> _onPostQuestModel(PostQuestModel event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      await apiRepository.postQuestModelbyUser(event.questModel);
      emit(ApiLoaded<void>(null));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> _onPostMilestone(PostMilestone event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      await apiRepository.postMilestone(event.milestone);
      emit(ApiLoaded<void>(null));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }

  Future<void> _onPostTask(PostTask event, Emitter<ApiState> emit) async {
    emit(ApiLoading());
    try {
      await apiRepository.postTask(event.task);
      emit(ApiLoaded<void>(null));
    } catch (e) {
      emit(ApiError(e.toString()));
    }
  }
}

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

class GoogleSignInRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthLoaded<T> extends AuthState {
  final T data;
  
  const AuthLoaded(this.data);
  
  @override
  List<Object> get props => [data as Object];
}

class AuthSuccess extends AuthState {
  final Map<String, dynamic> userData;
  
  const AuthSuccess(this.userData);
  
  @override
  List<Object> get props => [userData];
}

class AuthError extends AuthState {
  final String message;
  
  const AuthError(this.message);
  
  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GoogleSignInProvider _googleSignInProvider;

  AuthBloc({
    required GoogleSignInProvider googleSignInProvider,
  })  : _googleSignInProvider = googleSignInProvider,
        super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      
      final result = await _googleSignInProvider.signInWithGoogle();
      
      if (result == null) {
        emit(const AuthError('Sign in cancelled by user'));
        return;
      }
      
      if (result is Map<String, dynamic> && result.containsKey('error')) {
        emit(AuthError(result['error'].toString()));
        return;
      }
      
      emit(AuthSuccess(result as Map<String, dynamic>));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignOutRequested(
      GoogleSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      emit(AuthLoading());

      final result = await _googleSignInProvider.signOut();

      emit(AuthSuccess(result as Map<String, dynamic>));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}