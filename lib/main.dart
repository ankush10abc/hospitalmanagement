import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/admin_auth/data/firebase_admin_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    HospitalAdminApp(
      authService: FirebaseAdminAuthService(FirebaseAuth.instance),
    ),
  );
}
