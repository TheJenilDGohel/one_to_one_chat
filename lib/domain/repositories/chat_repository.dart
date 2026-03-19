import '../entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<MessageEntity>> getMessagesStream(String currentUserId, String otherUserId);
  Future<void> sendMessage(String currentUserId, String otherUserId, String text);
  Stream<int> getUnreadCountStream(String currentUserId, String otherUserId);
  Future<void> markMessagesAsRead(String currentUserId, String otherUserId);
}
