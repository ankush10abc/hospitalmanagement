import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../domain/admin_auth_service.dart';

class CreateUserResult {
  const CreateUserResult({required this.uid, required this.email});
  final String uid;
  final String email;
}

class FirebaseUserService {
  FirebaseUserService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Creates a Firebase Auth user WITHOUT signing out the current admin.
  /// Uses a temporary secondary FirebaseApp instance that is deleted after use.
  Future<CreateUserResult> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? mobile,
    String? organizationId,
  }) async {
    // Record the admin UID before any auth operation
    final adminUid = FirebaseAuth.instance.currentUser?.uid ?? 'system';

    FirebaseApp? secondaryApp;
    try {
      // Create a secondary app so we don't touch the primary auth session
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      await credential.user!.updateDisplayName(name);
      // Sign out of secondary app immediately
      await secondaryAuth.signOut();

      // Write profile to Firestore using primary app's Firestore
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'mobile': mobile ?? '',
        'role': role,
        'organizationId': organizationId ?? '',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': adminUid,
      });

      return CreateUserResult(uid: uid, email: email);
    } on FirebaseAuthException catch (e) {
      throw AdminAuthException(_friendlyMessage(e.code));
    } finally {
      await secondaryApp?.delete();
    }
  }

  /// Updates a user's role in Firestore.
  Future<void> updateUserRole(String uid, String role) async {
    await _db.collection('users').doc(uid).update({'role': role});
  }

  /// Updates a user's status in Firestore.
  Future<void> updateUserStatus(String uid, String status) async {
    await _db.collection('users').doc(uid).update({'status': status});
  }

  String _friendlyMessage(String code) => switch (code) {
        'email-already-in-use' => 'An account with this email already exists.',
        'invalid-email' => 'Enter a valid email address.',
        'weak-password' => 'Password must be at least 6 characters.',
        'operation-not-allowed' =>
          'Email/password sign-up is not enabled in Firebase Console.',
        _ => 'Could not create user. Please try again.',
      };
}
