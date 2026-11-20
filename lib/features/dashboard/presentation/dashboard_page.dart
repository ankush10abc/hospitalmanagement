import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// TODO: Replace all mock data with API calls once backend endpoints are wired.

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // ── Palette ────────────────────────────────────────────────────────────────
  static const Color _titleColor = Color(0xFF1A2E3D);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Page Header ───────────────────────────────────────────────
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _titleColor,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Platform health at a glance',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 28),

              // ── Section 1: Stat Cards ─────────────────────────────────────
              _sectionTitle('Key Metrics'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: const [
                  // TODO: values come from API
                  _StatCard(
                    label: 'Total Users',
                    value: '48',
                    icon: Icons.people_rounded,
                    color: Color(0xFF167D8D),
                  ),
                  _StatCard(
                    label: 'Total Organizations',
                    value: '12',
                    icon: Icons.business_rounded,
                    color: Colors.indigo,
                  ),
                  _StatCard(
                    label: 'Total Projects',
                    value: '127',
                    icon: Icons.folder_open_rounded,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    label: 'Awaiting Review',
                    value: '8',
                    icon: Icons.pending_actions_rounded,
                    color: Colors.red,
                  ),
                  _StatCard(
                    label: 'Published Catalog',
                    value: '34',
                    icon: Icons.verified_rounded,
                    color: Colors.green,
                  ),
                  _StatCard(
                    label: 'Import Jobs',
                    value: '5',
                    icon: Icons.upload_file_rounded,
                    color: Colors.purple,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Section 2: Pie Chart ──────────────────────────────────────
              _sectionTitle('Project Status Distribution'),
              const SizedBox(height: 12),
              _cardWrapper(
                height: 320,
                child: isWide
                    ? const Row(
                        children: [
                          Expanded(child: _ProjectPieChart()),
                          SizedBox(width: 24),
                          _PieLegend(),
                        ],
                      )
                    : const Column(
                        children: [
                          SizedBox(height: 240, child: _ProjectPieChart()),
                          SizedBox(height: 16),
                          _PieLegend(),
                        ],
                      ),
              ),
              const SizedBox(height: 32),

              // ── Section 3: Bar Chart ──────────────────────────────────────
              _sectionTitle('Projects by Hospital Type'),
              const SizedBox(height: 12),
              _cardWrapper(
                height: 280,
                child: const _HospitalTypeBarChart(),
              ),
              const SizedBox(height: 32),

              // ── Section 4: Recent Activity Table ──────────────────────────
              _sectionTitle('Recent Admin Activity'),
              const SizedBox(height: 12),
              _cardWrapper(child: const _RecentActivityTable()),
              const SizedBox(height: 32),

              // ── Section 5: Data Quality Warnings ─────────────────────────
              _sectionTitle('Data Quality Warnings'),
              const SizedBox(height: 12),
              _cardWrapper(child: const _DataQualityWarnings()),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  static Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _titleColor,
      ),
    );
  }

  static Widget _cardWrapper({required Widget child, double? height}) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _StatCard
// ════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          // Icon top-right
          Positioned(
            top: 0,
            right: 0,
            child: Icon(icon, color: color.withValues(alpha: 0.18), size: 36),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// _ProjectPieChart
// ════════════════════════════════════════════════════════════════════════════

class _ProjectPieChart extends StatelessWidget {
  const _ProjectPieChart();

  // TODO: replace with API data
  static const List<_PieEntry> _entries = [
    _PieEntry('Draft', 42, Colors.grey),
    _PieEntry('Submitted', 28, Colors.blue),
    _PieEntry('Under Review', 15, Colors.orange),
    _PieEntry('Approved', 31, Colors.green),
    _PieEntry('Completed', 11, Color(0xFF167D8D)),
  ];

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 48,
        sections: _entries
            .map(
              (e) => PieChartSectionData(
                value: e.value.toDouble(),
                color: e.color,
                title: '${e.value}',
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                radius: 72,
              ),
            )
            .toList(),
      ),
    );
  }
}

// ── Pie legend ───────────────────────────────────────────────────────────────

class _PieLegend extends StatelessWidget {
  const _PieLegend();

  @override
  Widget build(BuildContext context) {
    const entries = _ProjectPieChart._entries;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: e.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.label} (${e.value})',
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _PieEntry {
  const _PieEntry(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}

// ════════════════════════════════════════════════════════════════════════════
// _HospitalTypeBarChart
// ════════════════════════════════════════════════════════════════════════════

class _HospitalTypeBarChart extends StatelessWidget {
  const _HospitalTypeBarChart();

  // TODO: replace with API data
  static const List<_BarEntry> _entries = [
    _BarEntry('Multi-Specialty', 45),
    _BarEntry('Single-Specialty', 32),
    _BarEntry('Clinic', 28),
    _BarEntry('Diagnostic Centre', 18),
    _BarEntry('Day-care', 12),
  ];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 50,
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _entries.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _entries[index].label,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: _entries.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: e.value.toDouble(),
                color: const Color(0xFF167D8D),
                width: 28,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _BarEntry {
  const _BarEntry(this.label, this.value);
  final String label;
  final int value;
}

// ════════════════════════════════════════════════════════════════════════════
// _RecentActivityTable
// ════════════════════════════════════════════════════════════════════════════

class _RecentActivityTable extends StatelessWidget {
  const _RecentActivityTable();

  // TODO: replace with API data
  static const List<_ActivityRow> _rows = [
    _ActivityRow(
      action: 'Published rule version',
      entity: 'Depreciation Rule v3',
      actor: 'admin@hospital.com',
      date: 'Today 09:12',
    ),
    _ActivityRow(
      action: 'Imported workbook',
      entity: 'City Hospital Project',
      actor: 'data@hospital.com',
      date: 'Today 08:45',
    ),
    _ActivityRow(
      action: 'Updated catalog item',
      entity: 'ICU Ventilator',
      actor: 'data@hospital.com',
      date: 'Yesterday',
    ),
    _ActivityRow(
      action: 'Suspended user',
      entity: 'john.doe@clinic.com',
      actor: 'admin@hospital.com',
      date: 'Yesterday',
    ),
    _ActivityRow(
      action: 'Generated CMA report',
      entity: 'Metro Hospital',
      actor: 'finance@hospital.com',
      date: '2 days ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Admin Activity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2E3D),
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: navigate to full activity log
              },
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              const Color(0xFFF4F7FA),
            ),
            columnSpacing: 24,
            columns: const [
              DataColumn(label: Text('Action')),
              DataColumn(label: Text('Entity')),
              DataColumn(label: Text('Actor')),
              DataColumn(label: Text('Date')),
            ],
            rows: _rows
                .map(
                  (r) => DataRow(
                    cells: [
                      DataCell(Text(r.action)),
                      DataCell(Text(r.entity)),
                      DataCell(Text(r.actor)),
                      DataCell(Text(r.date)),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow {
  const _ActivityRow({
    required this.action,
    required this.entity,
    required this.actor,
    required this.date,
  });
  final String action;
  final String entity;
  final String actor;
  final String date;
}

// ════════════════════════════════════════════════════════════════════════════
// _DataQualityWarnings
// ════════════════════════════════════════════════════════════════════════════

class _DataQualityWarnings extends StatelessWidget {
  const _DataQualityWarnings();

  // TODO: replace with API data
  static const List<_Warning> _warnings = [
    _Warning(
      message: '3 catalog items missing price — Medical Equipment',
      severity: _WarningSeverity.orange,
    ),
    _Warning(
      message: '2 workbook imports with unresolved conflicts',
      severity: _WarningSeverity.red,
    ),
    _Warning(
      message: 'Assumption template v2 approaching expiry',
      severity: _WarningSeverity.yellow,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Quality Warnings',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A2E3D),
          ),
        ),
        const SizedBox(height: 12),
        ..._warnings.map((w) => _WarningTile(warning: w)),
      ],
    );
  }
}

enum _WarningSeverity { orange, red, yellow }

class _Warning {
  const _Warning({required this.message, required this.severity});
  final String message;
  final _WarningSeverity severity;
}

class _WarningTile extends StatelessWidget {
  const _WarningTile({required this.warning});
  final _Warning warning;

  Color get _color {
    switch (warning.severity) {
      case _WarningSeverity.orange:
        return Colors.orange;
      case _WarningSeverity.red:
        return Colors.red;
      case _WarningSeverity.yellow:
        return const Color(0xFFF5A623);
    }
  }

  IconData get _icon {
    switch (warning.severity) {
      case _WarningSeverity.red:
        return Icons.error_rounded;
      case _WarningSeverity.orange:
        return Icons.warning_amber_rounded;
      case _WarningSeverity.yellow:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: c, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              warning.message,
              style: TextStyle(
                fontSize: 13,
                color: c.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
