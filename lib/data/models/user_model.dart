import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.isOnline,
    super.lastSeen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime? lastSeen;
    final rawLastSeen = json['lastSeen'];
    if (rawLastSeen is Timestamp) {
      lastSeen = rawLastSeen.toDate();
    }
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: lastSeen,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }
}

