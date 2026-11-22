import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../features/admin_auth/presentation/admin_login_page.dart';
import '../../features/admin_auth/presentation/admin_shell_page.dart';
import '../../features/admin_auth/presentation/create_user_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/users/presentation/users_page.dart';
import '../../features/users/presentation/user_detail_page.dart';
import '../../features/users/presentation/organizations_page.dart';
import '../../features/users/presentation/organization_detail_page.dart';
import '../../features/hospital_plan/presentation/create_hospital_plan_page.dart';

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.construction_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A2E3D))),
          const SizedBox(height: 8),
          const Text('Coming in next phase',
              style: TextStyle(color: Color(0xFF667786))),
        ],
      ),
    );
  }
}

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen<dynamic>(authNotifierProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/dashboard',
    debugLogDiagnostics: false,
    refreshListenable: listenable,
    redirect: (context, state) {
      final account = ref.read(authNotifierProvider);
      final isLoggedIn = account != null;
      final isGoingToLogin = state.matchedLocation == '/login';
      if (!isLoggedIn && !isGoingToLogin) return '/login';
      if (isLoggedIn && isGoingToLogin) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final authService = ref.read(adminAuthServiceProvider);
          return AdminLoginPage(authService: authService);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShellPage(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
          // /users/create MUST be before /users/:id
          GoRoute(path: '/users/create', builder: (_, __) => const CreateUserPage()),
          GoRoute(
            path: '/users',
            builder: (_, __) => const UsersPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, s) => UserDetailPage(userId: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/organizations',
            builder: (_, __) => const OrganizationsPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, s) =>
                    OrganizationDetailPage(orgId: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/hospital-plan',
            builder: (_, __) => const CreateHospitalPlanPage(),
          ),
          GoRoute(path: '/projects', builder: (_, __) => const _PlaceholderPage(title: 'Hospital Projects')),
          GoRoute(path: '/master-data', builder: (_, __) => const _PlaceholderPage(title: 'Master Data')),
          GoRoute(path: '/catalogs', builder: (_, __) => const _PlaceholderPage(title: 'Estimation Catalogs')),
          GoRoute(path: '/assumption-templates', builder: (_, __) => const _PlaceholderPage(title: 'Assumption Templates')),
          GoRoute(path: '/calculation-rules', builder: (_, __) => const _PlaceholderPage(title: 'Calculation Rules')),
          GoRoute(path: '/financial-models', builder: (_, __) => const _PlaceholderPage(title: 'Financial Models')),
          GoRoute(path: '/workbook-import', builder: (_, __) => const _PlaceholderPage(title: 'Workbook Import')),
          GoRoute(path: '/validation', builder: (_, __) => const _PlaceholderPage(title: 'Validation Centre')),
          GoRoute(path: '/reports', builder: (_, __) => const _PlaceholderPage(title: 'Reports & Templates')),
          GoRoute(path: '/audit-logs', builder: (_, __) => const _PlaceholderPage(title: 'Audit Logs')),
          GoRoute(path: '/settings', builder: (_, __) => const _PlaceholderPage(title: 'System Settings')),
        ],
      ),
    ],
  );
});
