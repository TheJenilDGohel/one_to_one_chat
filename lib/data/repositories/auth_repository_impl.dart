import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../utils/app_constants.dart';
import '../models/user_model.dart';
import 'package:snug_logger/snug_logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Register ────────────────────────────────────────────────────────────
  @override
  Future<UserEntity> register(
      String name, String email, String password) async {
    snugLog('Registering user: $email', logType: LogType.info);
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;
    await credential.user!.updateDisplayName(name);

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set({
      AppConstants.fieldName: name,
      AppConstants.fieldEmail: email,
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });

    return UserModel(id: uid, name: name, email: email, isOnline: true);
  }

  // ── Login ────────────────────────────────────────────────────────────────
  @override
  Future<UserEntity> login(String email, String password) async {
    snugLog('Logging in user: $email', logType: LogType.info);
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    final name = doc.data()?[AppConstants.fieldName] ??
        credential.user!.displayName ??
        email;

    // Mark online
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({'isOnline': true, 'lastSeen': FieldValue.serverTimestamp()});

    return UserModel(id: uid, name: name, email: email, isOnline: true);
  }

  // ── Logout ───────────────────────────────────────────────────────────────
  @override
  Future<void> logout() async {
    final uid = _auth.currentUser?.uid;
    snugLog('Logging out user: $uid', logType: LogType.info);
    if (uid != null) {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'isOnline': false, 'lastSeen': FieldValue.serverTimestamp()});
    }
    await _auth.signOut();
  }

  // ── Session restore ──────────────────────────────────────────────────────
  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!, firebaseUser.uid);
    } catch (_) {
      return null;
    }
  }

  // ── All users ─────────────────────────────────────────────────────────────
  @override
  Stream<List<UserEntity>> getUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  // ── Presence ─────────────────────────────────────────────────────────────
  @override
  Future<void> updatePresence(String userId, bool isOnline) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({
      'isOnline': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  // ── Single user stream ───────────────────────────────────────────────────
  @override
  Stream<UserEntity?> getUserStream(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data()!, doc.id);
    });
  }
}
