import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  MessageModel({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.text,
    required super.timestamp,
    required super.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    return MessageModel(
      id: id,
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      text: json['text'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}
