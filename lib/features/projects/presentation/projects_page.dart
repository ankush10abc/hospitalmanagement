import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/project_providers.dart';
import '../domain/project_entities.dart';
import '../../users/presentation/user_widgets.dart';
import 'project_status_badge.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(projectsFilterProvider);
    final projectsAsync = ref.watch(projectsProvider);

    return AdminListPage(
      title: 'Hospital Projects',
      subtitle: 'Oversee all hospital and clinic estimation projects',
      actions: [
        FilledButton.icon(
          onPressed: () => _showCreateDialog(context, ref),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('New Project'),
        ),
      ],
      filters: SearchFilterBar(
        onSearch: (q) => ref.read(projectsFilterProvider.notifier).state =
            filter.copyWith(search: q.isEmpty ? null : q),
        filters: [
          FilterDropdown<ProjectStatus>(
            label: 'Status',
            value: filter.status,
            items: ProjectStatus.values
                .map((s) => DropdownMenuItem(
                    value: s, child: Text(s.label)))
                .toList(),
            onChanged: (v) => ref
                .read(projectsFilterProvider.notifier)
                .state = filter.copyWith(status: v),
          ),
          FilterDropdown<HospitalType>(
            label: 'Type',
            value: filter.type,
            items: HospitalType.values
                .map((t) => DropdownMenuItem(
                    value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) => ref
                .read(projectsFilterProvider.notifier)
                .state = filter.copyWith(type: v),
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (projects) => projects.isEmpty
            ? const EmptyState(
                message: 'No projects match the current filters.')
            : TableCard(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFF4F7FA)),
                    columnSpacing: 16,
                    columns: const [
                      DataColumn(label: Text('Project')),
                      DataColumn(label: Text('Hospital Type')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Beds')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Last Updated')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: projects
                        .map((p) => _projectRow(context, ref, p))
                        .toList(),
                  ),
                ),
              ),
      ),
    );
  }

  DataRow _projectRow(
      BuildContext context, WidgetRef ref, HospitalProject p) {
    return DataRow(cells: [
      DataCell(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(p.projectName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(p.hospitalName,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF667786))),
          ],
        ),
      ),
      DataCell(Text(p.hospitalType.label,
          style: const TextStyle(fontSize: 13))),
      DataCell(Text('${p.city}, ${p.state}',
          style: const TextStyle(fontSize: 13))),
      DataCell(Text('${p.totalBeds}')),
      DataCell(ProjectStatusBadge(p.status)),
      DataCell(Text(
        p.lastUpdatedAt != null
            ? DateFormat('dd MMM yyyy').format(p.lastUpdatedAt!)
            : '—',
        style: const TextStyle(fontSize: 13, color: Color(0xFF667786)),
      )),
      DataCell(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility_outlined, size: 18),
            tooltip: 'View details',
            onPressed: () => context.go('/projects/${p.id}'),
          ),
          _StatusActionButton(project: p),
        ],
      )),
    ]);
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => _CreateProjectDialog(
        onCreated: () => ref.invalidate(projectsProvider),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────

// ── Status action button ──────────────────────────────────────────────────────

class _StatusActionButton extends ConsumerWidget {
  const _StatusActionButton({required this.project});
  final HospitalProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = _nextStatus(project.status);
    if (next == null) return const SizedBox.shrink();

    return IconButton(
      icon: Icon(_nextIcon(next), size: 18, color: const Color(0xFF167D8D)),
      tooltip: 'Mark as ${next.label}',
      onPressed: () async {
        await ref
            .read(projectRepositoryProvider)
            .updateProjectStatus(project.id, next);
        ref.invalidate(projectsProvider);
      },
    );
  }

  ProjectStatus? _nextStatus(ProjectStatus s) => switch (s) {
        ProjectStatus.draft => ProjectStatus.submitted,
        ProjectStatus.submitted => ProjectStatus.underReview,
        ProjectStatus.underReview => ProjectStatus.approved,
        ProjectStatus.approved => ProjectStatus.completed,
        ProjectStatus.completed => null,
      };

  IconData _nextIcon(ProjectStatus s) => switch (s) {
        ProjectStatus.submitted => Icons.send_rounded,
        ProjectStatus.underReview => Icons.rate_review_rounded,
        ProjectStatus.approved => Icons.check_circle_outline_rounded,
        ProjectStatus.completed => Icons.done_all_rounded,
        _ => Icons.arrow_forward_rounded,
      };
}

// ── Create project dialog ─────────────────────────────────────────────────────

class _CreateProjectDialog extends ConsumerStatefulWidget {
  const _CreateProjectDialog({required this.onCreated});
  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateProjectDialog> createState() =>
      _CreateProjectDialogState();
}

class _CreateProjectDialogState
    extends ConsumerState<_CreateProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _projectNameCtrl = TextEditingController();
  final _hospitalNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _ownerEmailCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _bedsCtrl = TextEditingController();
  HospitalType _type = HospitalType.general;
  bool _saving = false;

  @override
  void dispose() {
    _projectNameCtrl.dispose();
    _hospitalNameCtrl.dispose();
    _ownerNameCtrl.dispose();
    _ownerEmailCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _bedsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(projectRepositoryProvider).createProject({
        'projectName': _projectNameCtrl.text.trim(),
        'hospitalName': _hospitalNameCtrl.text.trim(),
        'hospitalType': _type.name,
        'ownerName': _ownerNameCtrl.text.trim(),
        'ownerEmail': _ownerEmailCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'totalBeds': int.tryParse(_bedsCtrl.text.trim()) ?? 0,
      });
      widget.onCreated();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Hospital Project'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _tf(_projectNameCtrl, 'Project Name'),
                const SizedBox(height: 12),
                _tf(_hospitalNameCtrl, 'Hospital Name'),
                const SizedBox(height: 12),
                DropdownButtonFormField<HospitalType>(
                  initialValue: _type,
                  decoration:
                      const InputDecoration(labelText: 'Hospital Type'),
                  items: HospitalType.values
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.label)))
                      .toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 12),
                _tf(_ownerNameCtrl, 'Owner Name'),
                const SizedBox(height: 12),
                _tf(_ownerEmailCtrl, 'Owner Email',
                    type: TextInputType.emailAddress),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _tf(_stateCtrl, 'State')),
                  const SizedBox(width: 12),
                  Expanded(child: _tf(_cityCtrl, 'City')),
                ]),
                const SizedBox(height: 12),
                _tf(_bedsCtrl, 'Total Beds',
                    type: TextInputType.number),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text('Create'),
        ),
      ],
    );
  }

  Widget _tf(TextEditingController c, String label,
      {TextInputType? type}) {
    return TextFormField(
      controller: c,
      keyboardType: type,
      decoration: InputDecoration(labelText: label),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}
