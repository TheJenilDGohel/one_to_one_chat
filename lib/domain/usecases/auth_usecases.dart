import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AuthUseCases {
  final AuthRepository repository;

  AuthUseCases(this.repository);

  Future<UserEntity> register(String name, String email, String password) {
    return repository.register(name, email, password);
  }

  Future<UserEntity> login(String email, String password) {
    return repository.login(email, password);
  }

  Future<void> logout() {
    return repository.logout();
  }

  Future<UserEntity?> getCurrentUser() {
    return repository.getCurrentUser();
  }

  Stream<List<UserEntity>> getUsers() {
    return repository.getUsers();
  }

  /// Marks the user as online or offline in Firestore.
  Future<void> updatePresence(String userId, bool isOnline) {
    return repository.updatePresence(userId, isOnline);
  }

  /// Real-time stream for a single user's presence data.
  Stream<UserEntity?> getUserStream(String userId) {
    return repository.getUserStream(userId);
  }
}
