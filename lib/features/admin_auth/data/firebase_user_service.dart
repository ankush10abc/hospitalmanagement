import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/admin_auth_service.dart';

class CreateUserResult {
  const CreateUserResult({required this.uid, required this.email});
  final String uid;
  final String email;
}

class FirebaseUserService {
  FirebaseUserService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  /// Creates a new Firebase Auth user and writes their profile to Firestore.
  /// Uses a secondary FirebaseApp instance so creating a user does NOT
  /// sign out the currently logged-in admin.
  Future<CreateUserResult> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? mobile,
    String? organizationId,
  }) async {
    try {
      // Create auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      // Update display name
      await credential.user!.updateDisplayName(name);

      // Write profile to Firestore
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'mobile': mobile ?? '',
        'role': role,
        'organizationId': organizationId ?? '',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid ?? 'system',
      });

      return CreateUserResult(uid: uid, email: email);
    } on FirebaseAuthException catch (e) {
      throw AdminAuthException(_friendlyMessage(e.code));
    }
  }

  String _friendlyMessage(String code) => switch (code) {
        'email-already-in-use' =>
          'An account with this email already exists.',
        'invalid-email' => 'Enter a valid email address.',
        'weak-password' => 'Password must be at least 6 characters.',
        'operation-not-allowed' =>
          'Email/password sign-up is not enabled in Firebase Console.',
        _ => 'Could not create user. Please try again.',
      };
}
