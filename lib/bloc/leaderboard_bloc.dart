// leaderboard_bloc.dart
import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/models/character_model.dart';
import 'package:Gamify/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeaderboardEntry {
  final UserModel user;
  final Character character;
  final int rank;

  LeaderboardEntry({
    required this.user,
    required this.character,
    required this.rank,
  });

  // Helper method to get user's total XP
  int get totalXP => user.XP;
  int get totalCoin => user.coin;
}


// Events
abstract class LeaderboardEvent {}

class LoadLeaderboard extends LeaderboardEvent {}
class RefreshLeaderboard extends LeaderboardEvent {}

class SelectLeaderboardUser extends LeaderboardEvent {
  final String? userId;
  SelectLeaderboardUser(this.userId);
}

// States
abstract class LeaderboardState {}

class LeaderboardInitial extends LeaderboardState {}
class LeaderboardLoading extends LeaderboardState {}
class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntry> entries;
  String? selectedUserId;

  LeaderboardLoaded(this.entries, {this.selectedUserId});

  List<Object?> get props => [entries, selectedUserId];
}
class LeaderboardError extends LeaderboardState {
  final String message;
  LeaderboardError(this.message);
}

// BLoC
class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final repository = ApiRepository();

  LeaderboardBloc() : super(LeaderboardInitial()) {
    on<LoadLeaderboard>(_onLoadLeaderboard);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
    on<SelectLeaderboardUser>((event, emit) {
      if (state is LeaderboardLoaded) {
        final currentState = state as LeaderboardLoaded;
        emit(LeaderboardLoaded(currentState.entries, selectedUserId: event.userId));
      }
    });
  }

  

  Future<void> _onLoadLeaderboard(
    LoadLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    try {
      final entries = await repository.getLeaderboard();
      emit(LeaderboardLoaded(entries));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    try {
      final entries = await repository.getLeaderboard();
      emit(LeaderboardLoaded(entries));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}