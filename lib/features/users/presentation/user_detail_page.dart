import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/user_providers.dart';
import '../domain/user_entities.dart';
import 'user_widgets.dart';

class UserDetailPage extends ConsumerWidget {
  const UserDetailPage({required this.userId, super.key});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDetailProvider(userId));

    return userAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (user) => _UserDetailView(user: user),
    );
  }
}

class _UserDetailView extends ConsumerWidget {
  const _UserDetailView({required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breadcrumb
          Row(
            children: [
              TextButton.icon(
                onPressed: () => context.go('/users'),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Users'),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: const Color(0xFF667786)),
              ),
              const Text(' / ',
                  style: TextStyle(color: Color(0xFF667786))),
              Text(user.name,
                  style: const TextStyle(color: Color(0xFF1A2E3D))),
            ],
          ),
          const SizedBox(height: 20),

          // Header card
          TableCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor:
                        const Color(0xFF167D8D).withValues(alpha: 0.12),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: Color(0xFF167D8D),
                          fontSize: 24,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2E3D))),
                        const SizedBox(height: 4),
                        Text(user.email,
                            style: const TextStyle(
                                color: Color(0xFF667786), fontSize: 14)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            RoleBadge(user.role),
                            const SizedBox(width: 8),
                            StatusBadge(user.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _RoleChangeButton(user: user),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Details card
          TableCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Account Details',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2E3D))),
                  const Divider(height: 24),
                  DetailRow(label: 'Email', value: user.email),
                  if (user.mobile != null)
                    DetailRow(label: 'Mobile', value: user.mobile!),
                  DetailRow(
                      label: 'Organization',
                      value: user.organizationName ?? '—'),
                  DetailRow(
                      label: 'Created',
                      value: DateFormat('dd MMM yyyy').format(user.createdAt)),
                  DetailRow(
                      label: 'Last Login',
                      value: user.lastLoginAt != null
                          ? DateFormat('dd MMM yyyy, HH:mm')
                              .format(user.lastLoginAt!)
                          : 'Never'),
                  DetailRow(label: 'Status', value: user.status.name),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleChangeButton extends ConsumerStatefulWidget {
  const _RoleChangeButton({required this.user});
  final AdminUser user;

  @override
  ConsumerState<_RoleChangeButton> createState() => _RoleChangeButtonState();
}

class _RoleChangeButtonState extends ConsumerState<_RoleChangeButton> {
  AdminRole? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showRoleDialog(context),
      icon: const Icon(Icons.manage_accounts_rounded, size: 18),
      label: const Text('Change Role'),
    );
  }

  Future<void> _showRoleDialog(BuildContext context) async {
    AdminRole? picked = _selected;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Assign Role'),
          content: StatefulBuilder(
            builder: (ctx2, setInner) => Column(
              mainAxisSize: MainAxisSize.min,
              children: AdminRole.values
                  .map((r) => InkWell(
                        onTap: () => setInner(() => picked = r),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              Radio<AdminRole>(
                                value: r,
                                groupValue: picked,
                                onChanged: (_) => setInner(() => picked = r),
                              ),
                              Text(r.label),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Save')),
          ],
        ),
      ),
    );
    if (confirmed == true && picked != null && picked != widget.user.role) {
      await ref
          .read(userRepositoryProvider)
          .updateUserRole(widget.user.id, picked!);
      setState(() => _selected = picked);
      ref.invalidate(userDetailProvider(widget.user.id));
      ref.invalidate(usersProvider);
    }
  }
}
