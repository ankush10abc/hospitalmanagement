import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'features/admin_auth/data/supabase_admin_auth_service.dart';
import 'features/admin_auth/domain/admin_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    runApp(
      const HospitalAdminApp(authService: UnconfiguredAdminAuthService()),
    );
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );
  runApp(
    HospitalAdminApp(
      authService: SupabaseAdminAuthService(Supabase.instance.client),
    ),
  );
}
