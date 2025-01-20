import 'package:Gamify/api/api_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';

// Events
sealed class UserModelEvent extends Equatable {
  const UserModelEvent();

  @override
  List<Object> get props => [];
}

class LoadUserModel extends UserModelEvent {
  final String userId;

  const LoadUserModel(this.userId);

  @override
  List<Object> get props => [userId];
}

class LoadedUserModel extends UserModelEvent {
  final Map<String, dynamic> json;

  const LoadedUserModel(this.json);

  @override
  List<Object> get props => [json];
}

class RefreshUserModel extends UserModelEvent {
  final String userId;

  const RefreshUserModel(this.userId);

  @override
  List<Object> get props => [userId];
}

// States
sealed class UserModelState extends Equatable {
  const UserModelState();

  @override
  List<Object> get props => [];
}

class UserModelInitial extends UserModelState {}

class UserModelLoading extends UserModelState {}

class UserModelLoaded extends UserModelState {
  final UserModel userModel;

  const UserModelLoaded(this.userModel);

  @override
  List<Object> get props => [userModel];
}

class UserModelError extends UserModelState {
  final String message;

  const UserModelError(this.message);

  @override
  List<Object> get props => [message];
}

// Bloc
class UserModelBloc extends Bloc<UserModelEvent, UserModelState> {
  final ApiRepository _apiRepository;

  UserModelBloc({ApiRepository? apiRepository})
      : _apiRepository = apiRepository ?? ApiRepository(),
        super(UserModelInitial()) {

    on<LoadUserModel>(_onLoadUserModel);
    on<LoadedUserModel>(_onLoadedUserModel);
    on<RefreshUserModel>(_onRefreshUserModel);
  }

  Future<void> _onLoadUserModel(
      LoadUserModel event,
      Emitter<UserModelState> emit,
      ) async {
    emit(UserModelLoading());
    try {
      final userModel = await _apiRepository.fetchUserModel(event.userId);
      emit(UserModelLoaded(userModel));
    } catch (e) {
      emit(UserModelError('Failed to load user data: ${e.toString()}'));
    }
  }

  void _onLoadedUserModel(
      LoadedUserModel event,
      Emitter<UserModelState> emit,
      ) {
    try {
      final userModel = UserModel.fromJson(event.json);
      emit(UserModelLoaded(userModel));
    } catch (e) {
      emit(UserModelError('Failed to parse user data: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshUserModel(
      RefreshUserModel event,
      Emitter<UserModelState> emit,
      ) async {
    // Only show loading state if there's no current data
    if (state is! UserModelLoaded) {
      emit(UserModelLoading());
    }

    try {
      final userModel = await _apiRepository.fetchUserModel(event.userId);
      emit(UserModelLoaded(userModel));
    } catch (e) {
      // If we have existing data, keep it instead of showing error
      if (state is UserModelLoaded) {
        emit(state);
      } else {
        emit(UserModelError('Failed to refresh user data: ${e.toString()}'));
      }
    }
  }
}