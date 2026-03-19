import 'package:rxdart/rxdart.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/chat_usecases.dart';
import 'package:snug_logger/snug_logger.dart';

class ChatBloc {
  final ChatUseCases chatUseCases;
  final UserEntity currentUser;
  final UserEntity otherUser;

  ChatBloc({
    required this.chatUseCases,
    required this.currentUser,
    required this.otherUser,
  }) {
    // Mark as read initially
    chatUseCases.markMessagesAsRead(currentUser.id, otherUser.id);
  }

  final _textSubject = BehaviorSubject<String>.seeded('');
  final _clearInputSubject = PublishSubject<void>();
  final _errorSubject = PublishSubject<String>();

  // Inputs
  Function(String) get changeText => _textSubject.sink.add;

  // Outputs
  Stream<List<MessageEntity>> get messagesStream {
    snugLog('Loading messages for chat: ${currentUser.id} <-> ${otherUser.id}', logType: LogType.debug);
    return chatUseCases.getMessagesStream(currentUser.id, otherUser.id).doOnData(
          (messages) {
        if (messages.any(
            (m) => m.receiverId == currentUser.id && !m.isRead)) {
          chatUseCases.markMessagesAsRead(currentUser.id, otherUser.id);
        }
      });
  }

  Stream<void> get clearInput => _clearInputSubject.stream;

  /// Emits a human-readable error message when [sendMessage] fails.
  Stream<String> get error => _errorSubject.stream;

  void sendMessage() async {
    final text = _textSubject.value.trim();
    if (text.isEmpty) return;

    // Clear the input immediately for better UX
    _clearInputSubject.add(null);
    _textSubject.add('');

    try {
      await chatUseCases.sendMessage(currentUser.id, otherUser.id, text);
    } catch (e) {
      _errorSubject.add('Failed to send message. Please try again.');
    }
  }

  void dispose() {
    _textSubject.close();
    _clearInputSubject.close();
    _errorSubject.close();
  }
}
