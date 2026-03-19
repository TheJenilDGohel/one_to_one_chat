import '../domain/entities/user_entity.dart';

class SetUserAction {
  final UserEntity? user;
  
  SetUserAction(this.user);
}

class ClearUserAction {}
