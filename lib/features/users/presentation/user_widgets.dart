import 'package:flutter/material.dart';

import '../domain/user_entities.dart';

// ── Status badge ──────────────────────────────────────────────────────────────

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key});
  final AccountStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AccountStatus.active => ('Active', const Color(0xFF1A7F4B)),
      AccountStatus.suspended => ('Suspended', const Color(0xFFB91C1C)),
      AccountStatus.pendingVerification => ('Pending', const Color(0xFFB45309)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Role badge ────────────────────────────────────────────────────────────────

class RoleBadge extends StatelessWidget {
  const RoleBadge(this.role, {super.key});
  final AdminRole role;

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF167D8D);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        role.label,
        style: const TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Page scaffold shared by list pages ───────────────────────────────────────

class AdminListPage extends StatelessWidget {
  const AdminListPage({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.filters,
    required this.body,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget filters;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2E3D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF667786)),
                    ),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
          const SizedBox(height: 20),
          filters,
          const SizedBox(height: 16),
          body,
        ],
      ),
    );
  }
}

// ── Search + filter bar ───────────────────────────────────────────────────────

class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    required this.onSearch,
    this.filters = const [],
    super.key,
  });

  final ValueChanged<String> onSearch;
  final List<Widget> filters;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 42,
          child: TextField(
            onChanged: onSearch,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE1E8EF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE1E8EF)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        ...filters,
      ],
    );
  }
}

// ── Dropdown filter chip ──────────────────────────────────────────────────────

class FilterDropdown<T> extends StatelessWidget {
  const FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E8EF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF667786))),
          items: [
            DropdownMenuItem<T>(
              value: null,
              child: Text('All $label',
                  style: const TextStyle(fontSize: 13)),
            ),
            ...items,
          ],
          onChanged: onChanged,
          style: const TextStyle(fontSize: 13, color: Color(0xFF1A2E3D)),
          icon: const Icon(Icons.expand_more_rounded, size: 18),
        ),
      ),
    );
  }
}

// ── Card table wrapper ────────────────────────────────────────────────────────

class TableCard extends StatelessWidget {
  const TableCard({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class EmptyState extends StatelessWidget {
  const EmptyState({required this.message, super.key});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(color: Color(0xFF667786), fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ── Detail info row ───────────────────────────────────────────────────────────

class DetailRow extends StatelessWidget {
  const DetailRow({required this.label, required this.value, super.key});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF667786),
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF1A2E3D)),
            ),
          ),
        ],
      ),
    );
  }
}
