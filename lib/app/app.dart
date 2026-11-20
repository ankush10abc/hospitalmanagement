import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/admin_auth/domain/admin_auth_service.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import '../core/providers/auth_provider.dart';

class HospitalAdminApp extends StatelessWidget {
  const HospitalAdminApp({required this.authService, super.key});

  final AdminAuthService authService;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        adminAuthServiceProvider.overrideWithValue(authService),
      ],
      child: const _AppRouter(),
    );
  }
}

/// Separated into its own ConsumerWidget so it can read providers from the
/// ProviderScope above.
class _AppRouter extends ConsumerWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Hospital Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
