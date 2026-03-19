class UserEntity {
  final String id;
  final String name;
  final String email;
  final bool isOnline;
  final DateTime? lastSeen;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.isOnline = false,
    this.lastSeen,
  });
}
