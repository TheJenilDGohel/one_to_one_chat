import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'data/models/user_model.dart';
import 'firebase_options.dart';
import 'injection.dart' as di;
import 'redux/app_state.dart';
import 'redux/actions.dart';
import 'redux/reducers.dart';
import 'utils/app_constants.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  di.init();

  final store = createStore();

  // Session restoration moved to SplashScreen to avoid blocking UI

  runApp(MyApp(store: store));
}

class MyApp extends StatefulWidget {
  final Store<AppState> store;

  const MyApp({super.key, required this.store});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called when the app transitions between foreground and background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = widget.store.state.currentUser?.id;
    if (uid == null) return;

    final isOnline =
        state == AppLifecycleState.resumed;

    FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

