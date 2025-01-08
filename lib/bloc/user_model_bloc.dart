import 'package:Gamify/api/api_repo.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';


sealed class UserModelState extends Equatable {

  const UserModelState();
  
  @override
  List<Object> get props => [];
}

final class UserModelInitial extends UserModelState {

}

final class UserModelLoaded extends UserModelState {
  final UserModel userModel;

  const UserModelLoaded(this.userModel);

  @override
  List<Object> get props => [userModel];
}

sealed class UserModelEvent extends Equatable {
  const UserModelEvent();

  @override
  List<Object> get props => [];
}

class LoadedUserModel extends UserModelEvent {
  final Map<String, dynamic> json;

  const LoadedUserModel(this.json);

  @override
  List<Object> get props => [json];
}
// Event to Refresh UserModel
class RefreshUserModel extends UserModelEvent {
  final String userId; // Assuming userId is needed to fetch updated data.

  const RefreshUserModel(this.userId);

  @override
  List<Object> get props => [userId];
}


class UserModelBloc extends Bloc<UserModelEvent, UserModelState> {
  UserModelBloc() : super(UserModelInitial()) {
    on<LoadedUserModel>((event, emit) {
      final userModel = UserModel.fromJson(event.json);
      emit(UserModelLoaded(userModel));
    });
  on<RefreshUserModel>((event, emit) async {
      try {
        // Simulate an API call or database query to fetch updated user data
        final userModel = await ApiRepository().fetchUserModel(event.userId); // Replace with actual API logic

        emit(UserModelLoaded(userModel));
      } catch (e) {
        // Handle errors gracefully (Optional)
        emit(state); // Keep the current state in case of an error
      }
    });
  }

  // Simulate a function to fetch user data (replace with actual logic)
  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    return {
      "_id": userId,
      "username": "UpdatedUser",
      "coin": 500,
      "XP": 1200,
      "Character": "UpdatedCharacter"
    };
  }
}