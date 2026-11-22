import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/project_providers.dart';
import '../domain/project_entities.dart';
import '../../users/presentation/user_widgets.dart';

class ProjectDetailPage extends ConsumerWidget {
  const ProjectDetailPage({required this.projectId, super.key});
  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));
    return projectAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (project) => _ProjectDetailView(project: project),
    );
  }
}

// ── Inline status badge ───────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);
  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      ProjectStatus.draft => (const Color(0xFF667786), const Color(0xFFF0F4F8)),
      ProjectStatus.submitted => (Colors.blue, const Color(0xFFEFF6FF)),
      ProjectStatus.underReview => (Colors.orange, const Color(0xFFFFF7ED)),
      ProjectStatus.approved => (const Color(0xFF1A7F4B), const Color(0xFFECFDF5)),
      ProjectStatus.completed => (const Color(0xFF167D8D), const Color(0xFFECFEFF)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(status.label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _ProjectDetailView extends ConsumerWidget {
  const _ProjectDetailView({required this.project});
  final HospitalProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat('#,##,##0', 'en_IN');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            TextButton.icon(
              onPressed: () => context.go('/projects'),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Projects'),
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, foregroundColor: const Color(0xFF667786)),
            ),
            const Text(' / ', style: TextStyle(color: Color(0xFF667786))),
            Flexible(
                child: Text(project.projectName,
                    style: const TextStyle(color: Color(0xFF1A2E3D)))),
          ]),
          const SizedBox(height: 20),

          TableCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF167D8D).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.local_hospital_rounded,
                        size: 26, color: Color(0xFF167D8D)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.projectName,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2E3D))),
                        const SizedBox(height: 2),
                        Text(project.hospitalName,
                            style: const TextStyle(color: Color(0xFF667786), fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(children: [
                          _StatusBadge(project.status),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F7FA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(project.hospitalType.label,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF667786))),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  _StatusWorkflowButton(project: project),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          TableCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Project Details',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A2E3D))),
                  const Divider(height: 24),
                  DetailRow(label: 'Owner', value: project.ownerName),
                  DetailRow(label: 'Owner Email', value: project.ownerEmail),
                  DetailRow(label: 'Location', value: '${project.city}, ${project.state}'),
                  if (project.address != null)
                    DetailRow(label: 'Address', value: project.address!),
                  DetailRow(label: 'Total Beds', value: '${project.totalBeds}'),
                  if (project.projectStartYear != null)
                    DetailRow(label: 'Start Year', value: '${project.projectStartYear}'),
                  if (project.totalProjectCost != null)
                    DetailRow(
                        label: 'Total Project Cost',
                        value: '₹${fmt.format(project.totalProjectCost)}'),
                  DetailRow(
                      label: 'Created',
                      value: DateFormat('dd MMM yyyy').format(project.createdAt)),
                  if (project.lastUpdatedAt != null)
                    DetailRow(
                        label: 'Last Updated',
                        value: DateFormat('dd MMM yyyy').format(project.lastUpdatedAt!)),
                  if (project.reviewComment != null && project.reviewComment!.isNotEmpty)
                    DetailRow(label: 'Review Comment', value: project.reviewComment!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusWorkflowButton extends ConsumerWidget {
  const _StatusWorkflowButton({required this.project});
  final HospitalProject project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = _nextStatus(project.status);
    if (next == null) return const SizedBox.shrink();
    return OutlinedButton.icon(
      onPressed: () => _advance(ref, next),
      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
      label: Text('Mark ${next.label}'),
    );
  }

  ProjectStatus? _nextStatus(ProjectStatus s) => switch (s) {
        ProjectStatus.draft => ProjectStatus.submitted,
        ProjectStatus.submitted => ProjectStatus.underReview,
        ProjectStatus.underReview => ProjectStatus.approved,
        ProjectStatus.approved => ProjectStatus.completed,
        ProjectStatus.completed => null,
      };

  Future<void> _advance(WidgetRef ref, ProjectStatus next) async {
    await ref.read(projectRepositoryProvider).updateProjectStatus(project.id, next);
    ref.invalidate(projectDetailProvider(project.id));
    ref.invalidate(projectsProvider);
  }
}
