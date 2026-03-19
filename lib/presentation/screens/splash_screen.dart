import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_redux/flutter_redux.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/user_model.dart';
import '../../redux/app_state.dart';
import '../../redux/actions.dart';
import '../../utils/app_constants.dart';
import 'login_screen.dart';
import 'user_list_screen.dart';
import 'package:snug_logger/snug_logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Give the animation a tiny bit of time to start before doing heavy async work
    Future.delayed(const Duration(milliseconds: 500), _restoreSession);
  }

  Future<void> _restoreSession() async {
    snugLog('Restoring session...', logType: LogType.info);
    final store = StoreProvider.of<AppState>(context, listen: false);
    final firebaseUser = FirebaseAuth.instance.currentUser;
    bool isLoggedIn = false;

    if (firebaseUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();
        if (doc.exists) {
          final user = UserModel.fromJson(doc.data()!, firebaseUser.uid);
          store.dispatch(SetUserAction(user));
          // Mark online on session restore
          await FirebaseFirestore.instance
              .collection(AppConstants.usersCollection)
              .doc(firebaseUser.uid)
              .update({
                'isOnline': true,
                'lastSeen': FieldValue.serverTimestamp(),
              });
          snugLog('Session restored for: ${user.email}', logType: LogType.info);
          isLoggedIn = true;
        } else {
          snugLog('User document not found for UID: ${firebaseUser.uid}', logType: LogType.info);
        }
      } catch (e) {
        snugLog('Session restore failed', logType: LogType.error);
      }
    } else {
      snugLog('No active Firebase user found', logType: LogType.info);
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isLoggedIn ? const UserListScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: Image.asset(
                'assets/logo.png',
                width: 160,
                height: 160,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
