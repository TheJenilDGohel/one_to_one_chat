import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class ChatUseCases {
  final ChatRepository repository;

  ChatUseCases(this.repository);

  Stream<List<MessageEntity>> getMessagesStream(String currentUserId, String otherUserId) {
    return repository.getMessagesStream(currentUserId, otherUserId);
  }

  Future<void> sendMessage(String currentUserId, String otherUserId, String text) {
    return repository.sendMessage(currentUserId, otherUserId, text);
  }

  Stream<int> getUnreadCountStream(String currentUserId, String otherUserId) {
    return repository.getUnreadCountStream(currentUserId, otherUserId);
  }

  Future<void> markMessagesAsRead(String currentUserId, String otherUserId) {
    return repository.markMessagesAsRead(currentUserId, otherUserId);
  }
}
