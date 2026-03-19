import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../blocs/chat_bloc.dart';
import '../../injection.dart';
import 'package:snug_logger/snug_logger.dart';

class ChatScreen extends StatefulWidget {
  final UserEntity currentUser;
  final UserEntity otherUser;

  const ChatScreen({
    super.key,
    required this.currentUser,
    required this.otherUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatBloc _bloc;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasText = false;
  StreamSubscription<String>? _errorSub;

  @override
  void initState() {
    super.initState();
    snugLog('Entering chat with ${widget.otherUser.name}', logType: LogType.info);
    _bloc = ChatBloc(
      chatUseCases: sl(),
      currentUser: widget.currentUser,
      otherUser: widget.otherUser,
    );

    _messageController.addListener(() {
      _bloc.changeText(_messageController.text);
      final nowHasText = _messageController.text.trim().isNotEmpty;
      if (nowHasText != _hasText) {
        setState(() => _hasText = nowHasText);
      }
    });

    _bloc.clearInput.listen((_) {
      _messageController.clear();
      _scrollToBottom();
    });

    // ── Error surface ──────────────────────────────────────────────────────
    _errorSub = _bloc.error.listen((msg) {
      if (!mounted || msg.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  @override
  void dispose() {
    _errorSub?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    snugLog('User clicked send button', logType: LogType.debug);
    HapticFeedback.lightImpact();
    _bloc.sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom AppBar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 8),
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: AppTheme.onSurface),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    // Recipient avatar
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Center(
                        child: Text(
                          widget.otherUser.name
                              .substring(0, 1)
                              .toUpperCase(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StreamBuilder<UserEntity?>(
                        stream: sl<AuthUseCases>()
                            .getUserStream(widget.otherUser.id),
                        builder: (context, snap) {
                          final other = snap.data;
                          final online = other?.isOnline ?? false;
                          final lastSeen = other?.lastSeen;
                          final subtitle = online
                              ? 'Online'
                              : lastSeen != null
                                  ? 'Last seen ${_formatLastSeen(lastSeen)}'
                                  : 'Offline';
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.otherUser.name,
                                style: GoogleFonts.inter(
                                  color: AppTheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: online
                                          ? AppTheme.accent
                                          : AppTheme.subtle,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    subtitle,
                                    style: GoogleFonts.inter(
                                      color: online
                                          ? AppTheme.accent
                                          : AppTheme.subtle,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: AppTheme.subtle, size: 22),
                      color: AppTheme.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      onSelected: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('$value coming soon!')),
                        );
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'View Profile',
                          child: Text('View Profile',
                              style:
                                  GoogleFonts.inter(color: AppTheme.onSurface)),
                        ),
                        PopupMenuItem(
                          value: 'Clear Chat',
                          child: Text('Clear Chat',
                              style:
                                  GoogleFonts.inter(color: AppTheme.onSurface)),
                        ),
                        PopupMenuItem(
                          value: 'Delete Conversation',
                          child: Text('Delete Conversation',
                              style: GoogleFonts.inter(color: AppTheme.error)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.05)),

              // ── Messages ──────────────────────────────────────────────
              Expanded(
                child: StreamBuilder<List<MessageEntity>>(
                  stream: _bloc.messagesStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                            ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary));
                    }

                    final messages = snapshot.data ?? [];

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('👋', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text(
                              'Say hello!',
                              style: GoogleFonts.inter(
                                  color: AppTheme.onSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Start a conversation with ${widget.otherUser.name}',
                              style: GoogleFonts.inter(
                                  color: AppTheme.subtle, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe =
                            message.senderId == widget.currentUser.id;
                        return _MessageBubble(
                            message: message, isMe: isMe);
                      },
                    );
                  },
                ),
              ),

              // ── Input bar ─────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    // Text field
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TextField(
                          controller: _messageController,
                          style: GoogleFonts.inter(
                              color: AppTheme.onSurface, fontSize: 14),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                          maxLines: 4,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'Type a message…',
                            hintStyle: GoogleFonts.inter(
                                color: AppTheme.subtle, fontSize: 14),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Send button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: _hasText
                            ? AppTheme.primaryGradient
                            : null,
                        color: _hasText
                            ? null
                            : AppTheme.surfaceVariant,
                        shape: BoxShape.circle,
                        boxShadow: _hasText
                            ? [
                                BoxShadow(
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                )
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: _hasText
                              ? Colors.white
                              : AppTheme.subtle,
                        ),
                        onPressed: _hasText ? _sendMessage : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // ── Bubble ──────────────────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                gradient: isMe ? AppTheme.primaryGradient : null,
                color: isMe ? null : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe
                      ? const Radius.circular(18)
                      : const Radius.circular(4),
                  bottomRight: isMe
                      ? const Radius.circular(4)
                      : const Radius.circular(18),
                ),
                boxShadow: isMe
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Text(
                message.text,
                style: GoogleFonts.inter(
                  color: isMe ? Colors.white : AppTheme.onSurface,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

            // ── Timestamp + read receipt (sent messages only) ────────────
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Timestamp
                Text(
                  _formatTime(message.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.subtle,
                  ),
                ),
                // Tick marks only on sent messages
                if (isMe) ...[
                  const SizedBox(width: 4),
                  _ReadReceipt(isRead: message.isRead),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

String _formatLastSeen(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

/// Single grey tick = sent (unread). Double accent ticks = read.
class _ReadReceipt extends StatelessWidget {
  final bool isRead;
  const _ReadReceipt({required this.isRead});

  @override
  Widget build(BuildContext context) {
    if (isRead) {
      // Double tick — accent colour (read)
      return Icon(Icons.done_all_rounded, size: 14, color: AppTheme.accent);
    } else {
      // Single tick — grey (sent, not yet read)
      return Icon(Icons.done_rounded, size: 13, color: AppTheme.subtle);
    }
  }
}
