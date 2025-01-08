import 'package:Gamify/api/api_repo.dart';
import 'package:equatable/equatable.dart';
import 'package:Gamify/models/milestone_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MilestoneEvent extends Equatable {
  const MilestoneEvent();

  @override
  List<Object> get props => [];
}

class FetchMilestones extends MilestoneEvent {
  final dynamic questId;

  const FetchMilestones(this.questId);

  @override
  List<Object> get props => [questId];
}

class FetchMilestone extends MilestoneEvent {
  final int milestoneId;

  const FetchMilestone(this.milestoneId);

  @override
  List<Object> get props => [milestoneId];
}

class postMilestone extends MilestoneEvent {
  final Milestone milestone;

  const postMilestone(this.milestone);

  @override
  List<Object> get props => [milestone];
}

class UpdateMilestone extends MilestoneEvent {
  final Milestone milestone;

  const UpdateMilestone(this.milestone);

  @override
  List<Object> get props => [milestone];
}

class DeleteMilestone extends MilestoneEvent {
  final int milestoneId;

  const DeleteMilestone(this.milestoneId);

  @override
  List<Object> get props => [milestoneId];
}

class MilestoneLoad extends MilestoneEvent{
  final dynamic questId;

  const MilestoneLoad(this.questId);

    @override
  List<Object> get props => [questId];
}

abstract class MilestoneState extends Equatable {
  const MilestoneState();

  @override
  List<Object> get props => [];
}

class MilestoneInitial extends MilestoneState {}

class MilestonesLoading extends MilestoneState {}

class MilestonesLoaded extends MilestoneState {
  final List<Milestone> milestones;

  const MilestonesLoaded(this.milestones);

  @override
  List<Object> get props => [milestones];
}


class MilestoneLoaded extends MilestoneState {
  final Milestone milestones;

  const MilestoneLoaded(this.milestones);

  @override
  List<Object> get props => [milestones];
}

class MilestoneError extends MilestoneState {
  final String message;

  const MilestoneError(this.message);

  @override
  List<Object> get props => [message];
}


class MilestoneBloc extends Bloc<MilestoneEvent, MilestoneState> {
  final apirepo = ApiRepository();

  MilestoneBloc() : super(MilestoneInitial()) {
    on<FetchMilestones>(_onFetchMilestones);
    on<postMilestone>(_onPostMilestone);
    on<MilestoneLoad>(_onMilestoneLoad);  // Add the handler for MilestoneLoad
  }

  Future<void> _onFetchMilestones(FetchMilestones event, Emitter<MilestoneState> emit) async {
    emit(MilestonesLoading());
    try {
      final milestones = await apirepo.fetchMilestonesbyQuest(event.questId);
      emit(MilestonesLoaded(milestones));
    } catch (e) {
      emit(MilestoneError("Failed to fetch milestones: ${e.toString()}"));
    }
  }

  

  Future<void> _onPostMilestone(postMilestone event, Emitter<MilestoneState> emit) async {
    emit(MilestonesLoading());
    try {
      await apirepo.postMilestone(event.milestone);
      emit(MilestonesLoaded([event.milestone]));  // Optionally, reload the milestones
    } catch (e) {
      emit(MilestoneError("Failed to post milestone: ${e.toString()}"));
    }
  }

  // Event handler for MilestoneLoad
  Future<void> _onMilestoneLoad(MilestoneLoad event, Emitter<MilestoneState> emit) async {
    emit(MilestonesLoading());
    try {
      final milestones = await apirepo.fetchMilestonesbyQuest(event.questId);
      emit(MilestonesLoaded(milestones)); // Emit the loaded milestones
    } catch (e) {
      print(e.toString());
      emit(MilestoneError("Failed to load milestones: ${e.toString()}"));
    }
  }

}
