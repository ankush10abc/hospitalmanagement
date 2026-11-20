import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../features/admin_auth/presentation/admin_login_page.dart';
import '../../features/admin_auth/presentation/admin_shell_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/users/presentation/users_page.dart';
import '../../features/users/presentation/user_detail_page.dart';
import '../../features/users/presentation/organizations_page.dart';
import '../../features/users/presentation/organization_detail_page.dart';

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

final appRouterProvider = Provider<GoRouter>((ref) {
  final authService = ref.read(adminAuthServiceProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authService.currentAdmin != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      if (!isLoggedIn && !isGoingToLogin) return '/login';
      if (isLoggedIn && isGoingToLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => AdminLoginPage(authService: authService),
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShellPage(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          // Module 3 — Users & Organizations
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    UserDetailPage(userId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/organizations',
            builder: (context, state) => const OrganizationsPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => OrganizationDetailPage(
                  orgId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          // Placeholders for future modules
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
            path: '/catalogs',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Estimation Catalogs'),
          ),
          GoRoute(
            path: '/assumption-templates',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Assumption Templates'),
          ),
          GoRoute(
            path: '/calculation-rules',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Calculation Rules'),
          ),
          GoRoute(
            path: '/financial-models',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Financial Models'),
          ),
          GoRoute(
            path: '/workbook-import',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Workbook Import & Reconciliation'),
          ),
          GoRoute(
            path: '/validation',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Validation Centre'),
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Reports & Templates'),
          ),
          GoRoute(
            path: '/audit-logs',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'Audit Logs'),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const _PlaceholderPage(title: 'System Settings'),
          ),
        ],
      ),
    ],
  );
});
