import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/user_providers.dart';
import '../domain/user_entities.dart';
import 'user_widgets.dart';

class OrganizationsPage extends ConsumerWidget {
  const OrganizationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(orgsFilterProvider);
    final orgsAsync = ref.watch(organizationsProvider);

    return AdminListPage(
      title: 'Organizations',
      subtitle: 'Hospital owners, consultant firms, and diagnostic centres',
      actions: [
        FilledButton.icon(
          onPressed: () {}, // TODO: create org dialog
          icon: const Icon(Icons.add_business_rounded, size: 18),
          label: const Text('Add Organization'),
        ),
      ],
      filters: SearchFilterBar(
        onSearch: (q) => ref.read(orgsFilterProvider.notifier).state =
            filter.copyWith(search: q.isEmpty ? null : q),
        filters: [
          FilterDropdown<OrgType>(
            label: 'Type',
            value: filter.type,
            items: OrgType.values
                .map((t) => DropdownMenuItem(
                    value: t, child: Text(_orgTypeLabel(t))))
                .toList(),
            onChanged: (v) => ref.read(orgsFilterProvider.notifier).state =
                filter.copyWith(type: v),
          ),
          FilterDropdown<AccountStatus>(
            label: 'Status',
            value: filter.status,
            items: AccountStatus.values
                .map((s) => DropdownMenuItem(
                    value: s, child: Text(s.name.toUpperCase())))
                .toList(),
            onChanged: (v) => ref.read(orgsFilterProvider.notifier).state =
                filter.copyWith(status: v),
          ),
        ],
      ),
      body: orgsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (orgs) => orgs.isEmpty
            ? const EmptyState(
                message: 'No organizations match the current filters.')
            : TableCard(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      const Color(0xFFF4F7FA),
                    ),
                    columnSpacing: 20,
                    columns: const [
                      DataColumn(label: Text('Organization')),
                      DataColumn(label: Text('Type')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Members')),
                      DataColumn(label: Text('Projects')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Created')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: orgs.map((o) => _orgRow(context, ref, o)).toList(),
                  ),
                ),
              ),
      ),
    );
  }

  DataRow _orgRow(BuildContext context, WidgetRef ref, Organization o) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF167D8D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.business_rounded,
                    size: 16, color: Color(0xFF167D8D)),
              ),
              const SizedBox(width: 10),
              Text(o.name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        DataCell(Text(_orgTypeLabel(o.type),
            style: const TextStyle(fontSize: 13))),
        DataCell(Text(
          [o.city, o.state].whereType<String>().join(', '),
          style: const TextStyle(fontSize: 13, color: Color(0xFF667786)),
        )),
        DataCell(Text('${o.memberCount}')),
        DataCell(Text('${o.projectCount}')),
        DataCell(StatusBadge(o.status)),
        DataCell(Text(
          DateFormat('dd MMM yyyy').format(o.createdAt),
          style: const TextStyle(fontSize: 13, color: Color(0xFF667786)),
        )),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                tooltip: 'View details',
                onPressed: () => context.go('/organizations/${o.id}'),
              ),
              IconButton(
                icon: Icon(
                  o.status == AccountStatus.suspended
                      ? Icons.lock_open_rounded
                      : Icons.block_rounded,
                  size: 18,
                  color: o.status == AccountStatus.suspended
                      ? Colors.green
                      : Colors.red,
                ),
                tooltip: o.status == AccountStatus.suspended
                    ? 'Activate'
                    : 'Suspend',
                onPressed: () async {
                  final newStatus = o.status == AccountStatus.suspended
                      ? AccountStatus.active
                      : AccountStatus.suspended;
                  await ref
                      .read(userRepositoryProvider)
                      .updateOrganizationStatus(o.id, newStatus);
                  ref.invalidate(organizationsProvider);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _orgTypeLabel(OrgType t) => switch (t) {
        OrgType.hospitalOwner => 'Hospital Owner',
        OrgType.consultantFirm => 'Consultant Firm',
        OrgType.diagnosticCentre => 'Diagnostic Centre',
        OrgType.other => 'Other',
      };
}
