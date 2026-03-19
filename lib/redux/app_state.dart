import '../domain/entities/user_entity.dart';
import 'package:flutter/foundation.dart';

@immutable
class AppState {
  final UserEntity? currentUser;

  const AppState({
    this.currentUser,
  });

  factory AppState.initial() {
    return const AppState(
      currentUser: null,
    );
  }

  AppState copyWith({
    UserEntity? currentUser,
    bool clearUser = false,
  }) {
    return AppState(
      currentUser: clearUser ? null : (currentUser ?? this.currentUser),
    );
  }
}
