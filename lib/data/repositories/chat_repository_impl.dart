import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../utils/app_constants.dart';
import '../models/message_model.dart';
import 'package:snug_logger/snug_logger.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _getChatId(String user1, String user2) {
    final users = [user1, user2]..sort();
    return users.join('_');
  }

  @override
  Stream<List<MessageEntity>> getMessagesStream(
      String currentUserId, String otherUserId) {
    final chatId = _getChatId(currentUserId, otherUserId);
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy(AppConstants.fieldTimestamp, descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromJson(doc.data(), doc.id)).toList());
  }

  @override
  Future<void> sendMessage(
      String currentUserId, String otherUserId, String text) async {
    snugLog('Sending message from $currentUserId to $otherUserId', logType: LogType.debug);
    final chatId = _getChatId(currentUserId, otherUserId);
    final message = MessageModel(
      id: '',
      senderId: currentUserId,
      receiverId: otherUserId,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    );
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .add(message.toJson());
  }

  @override
  Stream<int> getUnreadCountStream(
      String currentUserId, String otherUserId) {
    final chatId = _getChatId(currentUserId, otherUserId);
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .where(AppConstants.fieldReceiverId, isEqualTo: currentUserId)
        .where(AppConstants.fieldIsRead, isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  @override
  Future<void> markMessagesAsRead(
      String currentUserId, String otherUserId) async {
    snugLog('Marking messages as read in chat $currentUserId <-> $otherUserId', logType: LogType.debug);
    final chatId = _getChatId(currentUserId, otherUserId);

    final unreadMessages = await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .where(AppConstants.fieldReceiverId, isEqualTo: currentUserId)
        .where(AppConstants.fieldIsRead, isEqualTo: false)
        .get();

    if (unreadMessages.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {AppConstants.fieldIsRead: true});
    }
    await batch.commit();
  }
}
