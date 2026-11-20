import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../features/admin_auth/domain/admin_auth_service.dart';
import '../../features/admin_auth/presentation/admin_login_page.dart';
import '../../features/admin_auth/presentation/admin_shell_page.dart';
import '../../features/dashboard/presentation/dashboard_placeholder.dart';

// ---------------------------------------------------------------------------
// Placeholder pages for unimplemented routes
// ---------------------------------------------------------------------------

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title\n(coming soon)',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, color: Color(0xFF667786)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(adminAuthServiceProvider);
  final authNotifier = ref.read(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Sync auth notifier with actual service state on every navigation.
      authNotifier.refresh();

      final isLoggedIn = authService.currentAdmin != null;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isGoingToLogin) return '/login';
      if (isLoggedIn && isGoingToLogin) return '/dashboard';
      return null;
    },
    routes: [
      // ---- Unauthenticated ----
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            AdminLoginPage(authService: authService),
      ),

      // ---- Authenticated shell ----
      ShellRoute(
        builder: (context, state, child) =>
            AdminShellPage(child: child),
        routes: [
          GoRoute(
            path: '/',
            redirect: (_, __) => '/dashboard',
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPlaceholder(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Users & Organisations'),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Hospital Projects'),
          ),
          GoRoute(
            path: '/master-data',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Master Data'),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Settings'),
          ),
        ],
      ),
    ],
  );
});
