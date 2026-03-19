import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Register a new user with name, email, and password.
  Future<UserEntity> register(String name, String email, String password);

  /// Sign in an existing user with email and password.
  Future<UserEntity> login(String email, String password);

  /// Sign out the current user.
  Future<void> logout();

  /// Returns the currently signed-in user, or null if not signed in.
  Future<UserEntity?> getCurrentUser();

  /// Stream of all other users in Firestore.
  Stream<List<UserEntity>> getUsers();

  /// Update the online/offline presence of the current user.
  Future<void> updatePresence(String userId, bool isOnline);

  /// Real-time stream of a single user document (for presence in chat header).
  Stream<UserEntity?> getUserStream(String userId);
}
