import 'package:flutter/material.dart';

import '../domain/project_entities.dart';

class ProjectStatusBadge extends StatelessWidget {
  const ProjectStatusBadge(this.status, {super.key});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, backgroundColor) = switch (status) {
      ProjectStatus.draft => (
          const Color(0xFF667786),
          const Color(0xFFF0F4F8),
        ),
      ProjectStatus.submitted => (Colors.blue, const Color(0xFFEFF6FF)),
      ProjectStatus.underReview => (Colors.orange, const Color(0xFFFFF7ED)),
      ProjectStatus.approved => (
          const Color(0xFF1A7F4B),
          const Color(0xFFECFDF5),
        ),
      ProjectStatus.completed => (
          const Color(0xFF167D8D),
          const Color(0xFFECFEFF),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
