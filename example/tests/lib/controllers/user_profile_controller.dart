import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../usecases/get_user_profile_usecase.dart';

sealed class UserProfileState {
  const UserProfileState();
}

class UserProfileInitialState extends UserProfileState {
  const UserProfileInitialState();
}

class UserProfileLoadingState extends UserProfileState {
  const UserProfileLoadingState();
}

class UserProfileSuccessState extends UserProfileState {
  final UserModel user;
  const UserProfileSuccessState(this.user);
}

class UserProfileErrorState extends UserProfileState {
  final String message;
  const UserProfileErrorState(this.message);
}

class UserProfileController extends ValueNotifier<UserProfileState> {
  final GetUserProfileUseCase _getUserProfile;

  UserProfileController({required GetUserProfileUseCase getUserProfile})
      : _getUserProfile = getUserProfile,
        super(const UserProfileInitialState());

  Future<void> fetchUser(String userId) async {
    value = const UserProfileLoadingState();
    final result = await _getUserProfile(userId);
    result.fold(
      (failure) => value = UserProfileErrorState(failure.message),
      (user) => value = UserProfileSuccessState(user),
    );
  }
}
