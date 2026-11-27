import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/admin_auth_service.dart';

class FirebaseAdminAuthService implements AdminAuthService {
  FirebaseAdminAuthService(this._auth, {FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  static const _allowedRoles = {
    'super_admin',
    'admin',
    'finance_reviewer',
    'data_manager',
    'support_operator',
    'read_only_auditor',
  };

  @override
  AdminAccount? get currentAdmin {
    final user = _auth.currentUser;
    if (user == null) return null;
    // Return a minimal account; role is resolved fully on sign-in.
    return AdminAccount(email: user.email ?? '', role: 'admin');
  }

  @override
  Future<AdminAccount> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;

      // 1. Try custom claims first (set via Firebase Admin SDK / Cloud Function)
      final idTokenResult = await user.getIdTokenResult(true);
      final claimRole = _roleFromClaims(idTokenResult.claims);

      if (claimRole != null) {
        return AdminAccount(email: user.email ?? '', role: claimRole);
      }

      // 2. Fallback: read role from Firestore users collection
      final doc = await _getUserProfile(user.uid);
      if (doc.exists) {
        final rawRole = doc.data()?['role'];
        final firestoreRole = _normalise(rawRole is String ? rawRole : '');
        if (_allowedRoles.contains(firestoreRole)) {
          return AdminAccount(email: user.email ?? '', role: firestoreRole);
        }
      }

      // Never apply the bootstrap admin fallback from an offline cache. A
      // cached profile without a valid role cannot prove current access.
      if (doc.metadata.isFromCache) {
        throw const AdminAuthException(
          'Your email and password were accepted, but Firebase could not verify your admin role. Check your internet connection and make sure your account has a role in Firestore at users/<your Firebase Auth UID> (or has a Firebase custom claim named role).',
        );
      }

      // 3. If no role found, allow sign-in as default 'admin' for the
      //    first super-admin account (bootstrapping). In production, always
      //    set the role in Firestore or via custom claims.
      return AdminAccount(email: user.email ?? '', role: 'admin');
    } on FirebaseAuthException catch (e) {
      throw AdminAuthException(_friendlyMessage(e.code));
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      throw const AdminAuthException(
        'Could not send reset link. Check the email and try again.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException {
      throw const AdminAuthException('Sign-out failed. Please try again.');
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserProfile(
    String uid,
  ) async {
    final profile = _db.collection('users').doc(uid);
    try {
      // Role authorization must be based on the current server state. An
      // offline cached miss is not evidence that this is the bootstrap admin.
      return await profile.get(const GetOptions(source: Source.server));
    } catch (error) {
      if (!_isFirestoreUnavailable(error)) {
        throw const AdminAuthException(
          'Your email and password were accepted, but Firebase could not read your administrator profile. Check that Firestore is enabled and its security rules allow this signed-in account to read users/<your Firebase Auth UID>.',
        );
      }

      try {
        return await profile.get(const GetOptions(source: Source.cache));
      } catch (_) {
        throw const AdminAuthException(
          'Could not verify your administrator role while offline. Connect to the internet and try again.',
        );
      }
    }
  }

  bool _isFirestoreUnavailable(Object error) {
    if (error is FirebaseException) {
      return error.code == 'unavailable' || error.code == 'deadline-exceeded';
    }
    final message = error.toString();
    return message.contains('[cloud_firestore/unavailable]') ||
        message.contains('[cloud_firestore/deadline-exceeded]');
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String? _roleFromClaims(Map<String, dynamic>? claims) {
    if (claims == null) return null;
    final raw = claims['role'];
    if (raw is! String) return null;
    final role = _normalise(raw);
    return _allowedRoles.contains(role) ? role : null;
  }

  String _normalise(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');

  String _friendlyMessage(String code) => switch (code) {
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'Incorrect email or password. Please try again.',
    'user-disabled' => 'This account has been disabled.',
    'too-many-requests' =>
      'Too many attempts. Please wait a moment and try again.',
    'network-request-failed' =>
      'Network error. Check your connection and try again.',
    _ => 'Sign-in failed. Please try again.',
  };
}
