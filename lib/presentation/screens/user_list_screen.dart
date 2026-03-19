import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../redux/app_state.dart';
import '../../redux/actions.dart';
import '../blocs/user_list_bloc.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import '../../injection.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  late UserListBloc _bloc;
  late AnimationController _listAnimController;

  @override
  void initState() {
    super.initState();
    _bloc = UserListBloc(authUseCases: sl(), chatUseCases: sl());
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _bloc.dispose();
    _listAnimController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) async {
    try {
      await sl<AuthUseCases>().logout();
    } catch (_) {}
    if (!context.mounted) return;
    StoreProvider.of<AppState>(context).dispatch(ClearUserAction());
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _showFindUserDialog() {
    final emailCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Find User by Email',
          style: GoogleFonts.inter(
              color: AppTheme.onSurface, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the email of the person you want to chat with.',
              style: GoogleFonts.inter(color: AppTheme.subtle, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              autofocus: true,
              style: GoogleFonts.inter(color: AppTheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: GoogleFonts.inter(color: AppTheme.subtle),
                hintText: 'user@example.com',
                prefixIcon: const Icon(Icons.email_rounded, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.subtle)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              minimumSize: const Size(80, 40),
            ),
            onPressed: () async {
              if (emailCtrl.text.isEmpty) return;
              try {
                // Find user by email in Firestore
                final store = StoreProvider.of<AppState>(context, listen: false);
                final currentUser = store.state.currentUser!;
                
                final users = await sl<AuthUseCases>().getUsers().first;
                final foundUser = users.firstWhere(
                  (u) => u.email.toLowerCase() == emailCtrl.text.trim().toLowerCase(),
                  orElse: () => throw Exception('User not found'),
                );

                if (foundUser.id == currentUser.id) {
                    throw Exception('You cannot chat with yourself!');
                }

                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  // Navigate to Chat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        currentUser: currentUser,
                        otherUser: foundUser,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              }
            },
            child: const Text('Find'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, UserEntity?>(
      converter: (store) => store.state.currentUser,
      builder: (context, currentUser) {
        if (currentUser == null) {
          return const Scaffold(
              body: Center(child: Text('Not logged in')));
        }

        return Scaffold(
          body: Container(
            decoration:
                const BoxDecoration(gradient: AppTheme.backgroundGradient),
            child: SafeArea(
              child: Column(
                children: [
                  // ── Custom header ──────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.3),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              currentUser.name
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${currentUser.name} 👋',
                                style: GoogleFonts.inter(
                                  color: AppTheme.onSurface,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Who do you want to chat with?',
                                style: GoogleFonts.inter(
                                  color: AppTheme.subtle,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // More Menu (3 Dots)
                        PopupMenuButton<String>(
                          icon: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.more_vert_rounded,
                                color: AppTheme.subtle, size: 20),
                          ),
                          color: AppTheme.surface,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          offset: const Offset(0, 48),
                          onSelected: (value) {
                            if (value == 'logout') {
                              _logout(context);
                            } else if (value == 'find_user') {
                              _showFindUserDialog();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'find_user',
                              child: Row(
                                children: [
                                  const Icon(Icons.person_search_rounded,
                                      size: 18, color: AppTheme.onSurface),
                                  const SizedBox(width: 10),
                                  Text('Find by Email',
                                      style: GoogleFonts.inter(
                                          color: AppTheme.onSurface,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'logout',
                              child: Row(
                                children: [
                                  const Icon(Icons.logout_rounded,
                                      size: 18, color: AppTheme.error),
                                  const SizedBox(width: 10),
                                  Text('Logout',
                                      style: GoogleFonts.inter(
                                          color: AppTheme.error, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Section label ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'Contacts',
                          style: GoogleFonts.inter(
                            color: AppTheme.subtle,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.inter(color: AppTheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search chats...',
                        hintStyle: GoogleFonts.inter(color: AppTheme.subtle, fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.subtle, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // User List
                  Expanded(
                    child: StreamBuilder<List<UserEntity>>(
                      stream: _bloc.getUsersStream(currentUser.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: AppTheme.primary));
                        }

                        final users = snapshot.data!
                              .where((u) => u.id != currentUser.id)
                              .where((u) => u.name.toLowerCase().contains(_searchQuery) || u.email.toLowerCase().contains(_searchQuery))
                              .toList();

                        if (users.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_searchQuery.isEmpty) ...[
                                  Icon(Icons.people_outline_rounded,
                                      size: 56,
                                      color: AppTheme.subtle
                                          .withValues(alpha: 0.5)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No other users yet',
                                    style: GoogleFonts.inter(
                                        color: AppTheme.subtle, fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Invite someone to join you!',
                                    style: GoogleFonts.inter(
                                        color: AppTheme.subtle
                                            .withValues(alpha: 0.6),
                                        fontSize: 13),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 100),
                                  Icon(Icons.search_off_rounded, size: 64, color: AppTheme.subtle.withOpacity(0.2)),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No matches for "$_searchQuery"',
                                    style: GoogleFonts.inter(color: AppTheme.subtle),
                                  ),
                                ]
                              ],
                            ),
                          );
                        }

                        // Re-run the intro animation when new data arrives
                        // only if the list was previously empty.
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            // Stagger using Interval curves on the controller
                            final start = (index * 0.1).clamp(0.0, 0.6);
                            final end = (start + 0.4).clamp(0.0, 1.0);
                            final animation = CurvedAnimation(
                              parent: _listAnimController,
                              curve: Interval(start, end,
                                  curve: Curves.easeOut),
                            );
                            return AnimatedBuilder(
                              animation: animation,
                              builder: (context, child) => Opacity(
                                opacity: animation.value,
                                child: Transform.translate(
                                  offset: Offset(
                                      0, 20 * (1 - animation.value)),
                                  child: child,
                                ),
                              ),
                              child: _UserTile(
                                user: users[index],
                                currentUserId: currentUser.id,
                                bloc: _bloc,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, _, _) => ChatScreen(
                                        currentUser: currentUser,
                                        otherUser: users[index],
                                      ),
                                      transitionsBuilder:
                                          (_, anim, _, child) =>
                                              SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(CurvedAnimation(
                                            parent: anim,
                                            curve: Curves.easeOutCubic)),
                                        child: child,
                                      ),
                                      transitionDuration:
                                          const Duration(milliseconds: 350),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserEntity user;
  final String currentUserId;
  final UserListBloc bloc;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.currentUserId,
    required this.bloc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05), width: 1),
            ),
            child: Row(
              children: [
                // ── Avatar ────────────────────────────────────────────
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // ── Name + online indicator ────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.inter(
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: user.isOnline
                                  ? AppTheme.accent
                                  : AppTheme.subtle,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.isOnline ? 'Online' : 'Offline',
                            style: GoogleFonts.inter(
                              color: user.isOnline
                                  ? AppTheme.accent
                                  : AppTheme.subtle,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Unread badge ──────────────────────────────────────
                StreamBuilder<int>(
                  stream: bloc.getUnreadCountStream(currentUserId, user.id),
                  builder: (context, snap) {
                    final count = snap.data ?? 0;
                    if (count == 0) {
                      return const Icon(Icons.chevron_right_rounded,
                          color: AppTheme.subtle, size: 20);
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        count.toString(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
