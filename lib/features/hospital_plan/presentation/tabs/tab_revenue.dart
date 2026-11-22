import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/plan_provider.dart';
import '../plan_widgets.dart';

class TabRevenue extends ConsumerWidget {
  const TabRevenue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(planProvider);
    final n = ref.read(planProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Revenue drivers mirror the CMA "revenue model" sheet. Quantities are per day at 100 beds and scale with bed count. All cells are editable.',
            style: TextStyle(fontSize: 12, color: Color(0xFF5D7078))),

        const SecHead('OPD revenue'),
        EditTable(
          headers: const ['Specialty', 'Patients/day @100 beds', 'Fee ₹'],
          rows: s.opd, editCols: const {1, 2},
          onChanged: (r, c, v) => n.setCell('opd', r, c, v),
        ),

        const SecHead('Room revenue (bed mix)'),
        EditTable(
          headers: const ['Category', 'Bed share', 'Rate ₹/day'],
          rows: s.room, editCols: const {1, 2},
          onChanged: (r, c, v) => n.setCell('room', r, c, v),
        ),

        const SecHead('Diagnostics revenue (CT/MRI rows count only if selected)'),
        EditTable(
          headers: const ['Test', 'OPD share', 'IPD share', 'Rate IPD ₹', 'Rate OPD ₹'],
          rows: s.diag, editCols: const {1, 2, 3, 4},
          onChanged: (r, c, v) => n.setCell('diag', r, c, v),
        ),

        const SecHead('OT revenue (cases per day)'),
        EditTable(
          headers: const ['Case type', 'Cases/day @100 beds', 'Avg ₹/case'],
          rows: s.otc, editCols: const {1, 2},
          onChanged: (r, c, v) => n.setCell('otc', r, c, v),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
