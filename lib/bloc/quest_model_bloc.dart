import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Gamify/api/api_repo.dart';
import 'package:Gamify/models/quest_model.dart';

class QuestModelBloc extends Bloc<QuestModelEvent, QuestModelState> {
  final apirepo = ApiRepository();
  
  QuestModelBloc() : super(QuestModelInitial()) {
    on<LoadedQuestModel>((event, emit) {
      final List<dynamic> questsJson = event.json;
      final List<QuestModel> quests = questsJson
          .map((json) => QuestModel.fromJson(json))
          .toList();
      emit(QuestModelLoaded(quests));
    });

    on<LoadQuestModel>((event, emit) async {
      try {
        final List<QuestModel> quests = await apirepo.fetchUsersQuests();
        emit(QuestModelLoaded(quests));
      } catch (e) {
        emit(QuestModelError('Failed to load quests: ${e.toString()}'));
      }
    });
  }
}

// Update the states to handle a list
sealed class QuestModelState extends Equatable {
  const QuestModelState();
  
  @override
  List<Object> get props => [];
}

final class QuestModelInitial extends QuestModelState {}

final class QuestModelLoaded extends QuestModelState {
  final List<QuestModel> quests;

  const QuestModelLoaded(this.quests);

  @override
  List<Object> get props => [quests];
}

final class QuestModelError extends QuestModelState {
  final String message;

  const QuestModelError(this.message);

  @override
  List<Object> get props => [message];
}

// Update the events to use userId
sealed class QuestModelEvent extends Equatable {
  const QuestModelEvent();

  @override
  List<Object> get props => [];
}

class LoadedQuestModel extends QuestModelEvent {
  final List<dynamic> json;

  const LoadedQuestModel(this.json);

  @override
  List<Object> get props => [json];
}

class LoadQuestModel extends QuestModelEvent {
  final dynamic userId;

  const LoadQuestModel(this.userId);

  @override
  List<Object> get props => [userId];
}