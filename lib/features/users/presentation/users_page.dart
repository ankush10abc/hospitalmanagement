import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/user_providers.dart';
import '../domain/user_entities.dart';
import 'user_widgets.dart';

class UsersPage extends ConsumerWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(usersFilterProvider);
    final usersAsync = ref.watch(usersProvider);

    return AdminListPage(
      title: 'Users',
      subtitle: 'Manage administrator and consultant accounts',
      actions: [
        FilledButton.icon(
          onPressed: () => context.go('/users/create'),
          icon: const Icon(Icons.person_add_rounded, size: 18),
          label: const Text('Create User'),
        ),
      ],
      filters: SearchFilterBar(
        onSearch: (q) => ref
            .read(usersFilterProvider.notifier)
            .state = filter.copyWith(search: q.isEmpty ? null : q),
        filters: [
          FilterDropdown<AdminRole>(
            label: 'Role',
            value: filter.role,
            items: AdminRole.values
                .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
                .toList(),
            onChanged: (v) => ref.read(usersFilterProvider.notifier).state =
                filter.copyWith(role: v),
          ),
          FilterDropdown<AccountStatus>(
            label: 'Status',
            value: filter.status,
            items: AccountStatus.values
                .map((s) => DropdownMenuItem(
                    value: s, child: Text(s.name.toUpperCase())))
                .toList(),
            onChanged: (v) => ref.read(usersFilterProvider.notifier).state =
                filter.copyWith(status: v),
          ),
        ],
      ),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (users) => users.isEmpty
            ? const EmptyState(message: 'No users match the current filters.')
            : TableCard(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF4F7FA),
                    ),
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Role')),
                      DataColumn(label: Text('Organization')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Last Login')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: users.map((u) => _userRow(context, ref, u)).toList(),
                  ),
                ),
              ),
      ),
    );
  }

  DataRow _userRow(BuildContext context, WidgetRef ref, AdminUser u) {
    final lastLogin = u.lastLoginAt != null
        ? DateFormat('dd MMM yyyy').format(u.lastLoginAt!)
        : '—';

    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor:
                    const Color(0xFF167D8D).withValues(alpha: 0.12),
                child: Text(
                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: Color(0xFF167D8D),
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Text(u.name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        DataCell(Text(u.email)),
        DataCell(RoleBadge(u.role)),
        DataCell(Text(u.organizationName ?? '—')),
        DataCell(StatusBadge(u.status)),
        DataCell(Text(lastLogin,
            style: const TextStyle(color: Color(0xFF667786), fontSize: 13))),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                tooltip: 'View details',
                onPressed: () => context.go('/users/${u.id}'),
              ),
              _StatusToggleButton(user: u),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusToggleButton extends ConsumerWidget {
  const _StatusToggleButton({required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuspended = user.status == AccountStatus.suspended;
    return IconButton(
      icon: Icon(
        isSuspended ? Icons.lock_open_rounded : Icons.block_rounded,
        size: 18,
        color: isSuspended ? Colors.green : Colors.red,
      ),
      tooltip: isSuspended ? 'Activate account' : 'Suspend account',
      onPressed: () async {
        final confirm = await _confirmDialog(
          context,
          isSuspended ? 'Activate account?' : 'Suspend account?',
          isSuspended
              ? 'This will restore access for ${user.name}.'
              : 'This will block access for ${user.name}.',
        );
        if (confirm != true) return;
        final newStatus = isSuspended
            ? AccountStatus.active
            : AccountStatus.suspended;
        await ref
            .read(userRepositoryProvider)
            .updateUserStatus(user.id, newStatus);
        ref.invalidate(usersProvider);
      },
    );
  }

  Future<bool?> _confirmDialog(
      BuildContext context, String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Confirm')),
        ],
      ),
    );
  }
}
