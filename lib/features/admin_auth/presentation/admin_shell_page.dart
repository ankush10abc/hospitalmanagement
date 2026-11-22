import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../domain/admin_auth_service.dart';

// ---------------------------------------------------------------------------
// Navigation item model
// ---------------------------------------------------------------------------

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

class _NavGroup {
  const _NavGroup({required this.label, required this.items});
  final String label;
  final List<_NavItem> items;
}

const _navGroups = [
  _NavGroup(
    label: '',
    items: [
      _NavItem(
        label: 'Overview',
        icon: Icons.dashboard_rounded,
        route: '/dashboard',
      ),
    ],
  ),
  _NavGroup(
    label: 'ADMINISTRATION',
    items: [
      _NavItem(label: 'Users', icon: Icons.people_rounded, route: '/users'),
      _NavItem(
        label: 'Create User',
        icon: Icons.person_add_rounded,
        route: '/users/create',
      ),
      _NavItem(
        label: 'Organizations',
        icon: Icons.business_center_rounded,
        route: '/organizations',
      ),
      _NavItem(
        label: 'Hospital Projects',
        icon: Icons.business_rounded,
        route: '/projects',
      ),
      _NavItem(
        label: 'Create Hospital Plan',
        icon: Icons.add_chart_rounded,
        route: '/hospital-plan',
      ),
    ],
  ),
  _NavGroup(
    label: 'CONFIGURATION',
    items: [
      _NavItem(
        label: 'Master Data',
        icon: Icons.storage_rounded,
        route: '/master-data',
      ),
      _NavItem(
        label: 'Catalogs',
        icon: Icons.inventory_2_rounded,
        route: '/catalogs',
      ),
      _NavItem(
        label: 'Assumption Templates',
        icon: Icons.tune_rounded,
        route: '/assumption-templates',
      ),
      _NavItem(
        label: 'Calculation Rules',
        icon: Icons.calculate_rounded,
        route: '/calculation-rules',
      ),
      _NavItem(
        label: 'Financial Models',
        icon: Icons.account_balance_rounded,
        route: '/financial-models',
      ),
    ],
  ),
  _NavGroup(
    label: 'TOOLS',
    items: [
      _NavItem(
        label: 'Workbook Import',
        icon: Icons.upload_file_rounded,
        route: '/workbook-import',
      ),
      _NavItem(
        label: 'Validation Centre',
        icon: Icons.fact_check_rounded,
        route: '/validation',
      ),
      _NavItem(
        label: 'Reports',
        icon: Icons.description_rounded,
        route: '/reports',
      ),
      _NavItem(
        label: 'Audit Logs',
        icon: Icons.history_rounded,
        route: '/audit-logs',
      ),
    ],
  ),
  _NavGroup(
    label: 'SYSTEM',
    items: [
      _NavItem(
        label: 'Settings',
        icon: Icons.settings_rounded,
        route: '/settings',
      ),
    ],
  ),
];

// ---------------------------------------------------------------------------
// AdminShellPage
// ---------------------------------------------------------------------------

class AdminShellPage extends ConsumerStatefulWidget {
  const AdminShellPage({required this.child, super.key});

  /// The active route's page widget, supplied by GoRouter's ShellRoute.
  final Widget child;

  @override
  ConsumerState<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends ConsumerState<AdminShellPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String _activeRoute(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return location;
  }

  bool _isSelected(String route, String active) {
    return active == route || active.startsWith('$route/');
  }

  // -------------------------------------------------------------------------
  // Sign-out
  // -------------------------------------------------------------------------

  Future<void> _signOut() async {
    await ref.read(authNotifierProvider.notifier).signOut();
    if (mounted) context.go('/login');
  }

  // -------------------------------------------------------------------------
  // Sidebar content (shared between drawer and permanent panel)
  // -------------------------------------------------------------------------

  Widget _buildSidebarContent(BuildContext context, String activeRoute) {
    return Container(
      color: AppTheme.sidebarBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand header
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Care & Capital',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Hospital Admin',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                letterSpacing: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Divider(color: Color(0x22FFFFFF), thickness: 1, height: 1),
          const SizedBox(height: 16),

          // Nav items
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final group in _navGroups) ...[
                    if (group.label.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                        child: Text(
                          group.label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.38),
                            fontSize: 10,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    for (final item in group.items)
                      _SidebarItem(
                        item: item,
                        selected: _isSelected(item.route, activeRoute),
                        onTap: () {
                          final scaffold = _scaffoldKey.currentState;
                          if (scaffold?.isDrawerOpen ?? false) {
                            scaffold?.closeDrawer();
                          }
                          context.go(item.route);
                        },
                      ),
                  ],
                ],
              ),
            ),
          ),
          const Divider(color: Color(0x22FFFFFF), thickness: 1, height: 1),
          const SizedBox(height: 8),
          // Sign-out at bottom
          _SidebarItem(
            item: const _NavItem(
              label: 'Sign out',
              icon: Icons.logout_rounded,
              route: '',
            ),
            selected: false,
            onTap: _signOut,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Top app bar
  // -------------------------------------------------------------------------

  PreferredSizeWidget _buildTopBar(
    BuildContext context,
    bool isWide,
    AdminAccount? account,
  ) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: const Color(0x1A000000),
      leading: isWide
          ? null
          : IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              tooltip: 'Open menu',
            ),
      title: isWide
          ? const Text(
              'Care & Capital | Hospital Admin',
              style: TextStyle(
                color: Color(0xFF172B3A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            )
          : const Text(
              'Hospital Admin',
              style: TextStyle(
                color: Color(0xFF172B3A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
      actions: [
        // Notification bell
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded),
          tooltip: 'Notifications',
          color: const Color(0xFF667786),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
        // Admin profile menu
        if (account != null)
          _ProfileMenu(account: account, onSignOut: _signOut),
        const SizedBox(width: 12),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: Color(0xFFE4ECF2)),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(authNotifierProvider);
    final activeRoute = _activeRoute(context);
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    if (isWide) {
      // Desktop: permanent sidebar + content area
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: _buildTopBar(context, true, account),
        body: Row(
          children: [
            SizedBox(
              width: 240,
              child: _buildSidebarContent(context, activeRoute),
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: widget.child),
          ],
        ),
      );
    } else {
      // Mobile: drawer sidebar
      return Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF4F7FA),
        appBar: _buildTopBar(context, false, account),
        drawer: Drawer(
          width: 240,
          shape: const RoundedRectangleBorder(),
          child: _buildSidebarContent(context, activeRoute),
        ),
        body: widget.child,
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Sidebar nav item
// ---------------------------------------------------------------------------

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF167D8D);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: selected ? teal.withValues(alpha: 0.18) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.06),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border(left: BorderSide(color: teal, width: 3)),
                  )
                : null,
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: selected ? teal : Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile menu
// ---------------------------------------------------------------------------

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.account, required this.onSignOut});

  final AdminAccount account;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Admin profile',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                account.email,
                style: const TextStyle(
                  color: Color(0xFF172B3A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                account.role,
                style: const TextStyle(color: Color(0xFF667786), fontSize: 12),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'sign_out',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: Color(0xFF667786)),
              SizedBox(width: 10),
              Text('Sign out'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'sign_out') onSignOut();
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF167D8D).withValues(alpha: 0.12),
            child: Text(
              account.email.isNotEmpty ? account.email[0].toUpperCase() : 'A',
              style: const TextStyle(
                color: Color(0xFF167D8D),
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.expand_more_rounded,
            size: 18,
            color: Colors.grey.shade500,
          ),
        ],
      ),
    );
  }
}
