import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'package:snug_logger/snug_logger.dart';

class UserListBloc {
  final AuthUseCases authUseCases;
  final ChatUseCases chatUseCases;

  UserListBloc({
    required this.authUseCases,
    required this.chatUseCases,
  });

  Stream<List<UserEntity>> getUsersStream(String currentUserId) {
    snugLog('Fetching user list stream...', logType: LogType.debug);
    return authUseCases.getUsers().map((users) => users.where((u) => u.id != currentUserId).toList());
  }

  Stream<int> getUnreadCountStream(String currentUserId, String otherUserId) {
    return chatUseCases.getUnreadCountStream(currentUserId, otherUserId);
  }

  void dispose() {
    // No subjects to close
  }
}
