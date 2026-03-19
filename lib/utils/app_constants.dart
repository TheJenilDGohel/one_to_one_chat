/// App-wide constants following the Single Responsibility Principle.
/// All magic strings, field names, and collection names live here.
class AppConstants {
  AppConstants._(); // Prevent instantiation

  // ── Firestore Collection Names ───────────────────────────────────────────
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // ── Firestore Field Names — Users ────────────────────────────────────────
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';

  // ── Firestore Field Names — Messages ─────────────────────────────────────
  static const String fieldSenderId = 'senderId';
  static const String fieldReceiverId = 'receiverId';
  static const String fieldText = 'text';
  static const String fieldTimestamp = 'timestamp';
  static const String fieldIsRead = 'isRead';

  // ── App Meta ──────────────────────────────────────────────────────────────
  static const String appName = 'One Chat';
}
