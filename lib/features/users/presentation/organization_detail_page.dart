import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/user_providers.dart';
import '../domain/user_entities.dart';
import 'user_widgets.dart';

class OrganizationDetailPage extends ConsumerWidget {
  const OrganizationDetailPage({required this.orgId, super.key});
  final String orgId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgAsync = ref.watch(orgDetailProvider(orgId));
    final membersAsync = ref.watch(orgMembersProvider(orgId));

    return orgAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (org) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumb
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => context.go('/organizations'),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Organizations'),
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: const Color(0xFF667786)),
                ),
                const Text(' / ',
                    style: TextStyle(color: Color(0xFF667786))),
                Text(org.name,
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
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF167D8D).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.business_rounded,
                          size: 28, color: Color(0xFF167D8D)),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(org.name,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A2E3D))),
                          const SizedBox(height: 4),
                          Text(
                            _orgTypeLabel(org.type),
                            style: const TextStyle(
                                color: Color(0xFF667786), fontSize: 14),
                          ),
                          const SizedBox(height: 10),
                          StatusBadge(org.status),
                        ],
                      ),
                    ),
                    // Stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _StatChip(
                            icon: Icons.people_rounded,
                            label: '${org.memberCount} Members'),
                        const SizedBox(height: 8),
                        _StatChip(
                            icon: Icons.folder_open_rounded,
                            label: '${org.projectCount} Projects'),
                      ],
                    ),
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
                    const Text('Organization Details',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A2E3D))),
                    const Divider(height: 24),
                    if (org.contactEmail != null)
                      DetailRow(label: 'Contact Email', value: org.contactEmail!),
                    if (org.contactMobile != null)
                      DetailRow(label: 'Mobile', value: org.contactMobile!),
                    if (org.city != null || org.state != null)
                      DetailRow(
                          label: 'Location',
                          value: [org.city, org.state]
                              .whereType<String>()
                              .join(', ')),
                    DetailRow(
                        label: 'Created',
                        value: DateFormat('dd MMM yyyy').format(org.createdAt)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Members card
            TableCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Members',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A2E3D))),
                        TextButton.icon(
                          onPressed: () => context.go('/users'),
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: const Text('View all users'),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    membersAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                      data: (members) => members.isEmpty
                          ? const EmptyState(
                              message: 'No members in this organization.')
                          : Column(
                              children: members
                                  .map((m) => _MemberTile(user: m))
                                  .toList(),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _orgTypeLabel(OrgType t) => switch (t) {
        OrgType.hospitalOwner => 'Hospital Owner',
        OrgType.consultantFirm => 'Consultant Firm',
        OrgType.diagnosticCentre => 'Diagnostic Centre',
        OrgType.other => 'Other',
      };
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF667786)),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A2E3D),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.user});
  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFF167D8D).withValues(alpha: 0.12),
        child: Text(
          user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Color(0xFF167D8D),
              fontSize: 12,
              fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(user.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(user.email,
          style: const TextStyle(fontSize: 12, color: Color(0xFF667786))),
      trailing: RoleBadge(user.role),
    );
  }
}
