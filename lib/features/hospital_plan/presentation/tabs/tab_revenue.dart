import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/plan_provider.dart';
import '../../domain/plan_data.dart';
import '../plan_widgets.dart';

class TabRevenue extends ConsumerWidget {
  const TabRevenue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(planProvider);
    final n = ref.read(planProvider.notifier);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      child: PlanCard(
        children: [
          const TipBanner(
            'Revenue drivers mirror the CMA "revenue model" sheet. Quantities are per day at 100 beds and scale with bed count. These are admin-managed values — edits save to Firestore automatically.',
          ),

          const SecHead('OPD revenue', apiDriven: true),
          EditTable(
            headers: const ['Specialty', 'Patients/day @100 beds', 'Fee ₹'],
            rows: s.opd,
            editCols: const {1, 2},
            onChanged: (r, c, v) => n.setCell('opd', r, c, v),
            table: 'opd',
            onAdd: () => n.addRow('opd'),
            onRemove: (r) => n.removeRow('opd', r),
            onTextChanged: (r, c, v) => n.setTextCell('opd', r, c, v),
            textCols: const {0},
            removableFrom: PD.opd.length,
          ),

          const SecHead('Room revenue (bed mix)', apiDriven: true),
          EditTable(
            headers: const ['Category', 'Bed share', 'Rate ₹/day'],
            rows: s.room,
            editCols: const {1, 2},
            onChanged: (r, c, v) => n.setCell('room', r, c, v),
            table: 'room',
            onAdd: () => n.addRow('room'),
            onRemove: (r) => n.removeRow('room', r),
            onTextChanged: (r, c, v) => n.setTextCell('room', r, c, v),
            textCols: const {0},
            removableFrom: PD.room.length,
          ),

          const SecHead(
            'Diagnostics revenue (CT/MRI rows count only if selected)',
            apiDriven: true,
          ),
          EditTable(
            headers: const [
              'Test', 'OPD share', 'IPD share', 'Rate IPD ₹', 'Rate OPD ₹',
            ],
            rows: s.diag,
            editCols: const {1, 2, 3, 4},
            onChanged: (r, c, v) => n.setCell('diag', r, c, v),
            table: 'diag',
            onAdd: () => n.addRow('diag'),
            onRemove: (r) => n.removeRow('diag', r),
            onTextChanged: (r, c, v) => n.setTextCell('diag', r, c, v),
            textCols: const {0},
            removableFrom: PD.diag.length,
          ),

          const SecHead('OT revenue (cases per day)', apiDriven: true),
          EditTable(
            headers: const ['Case type', 'Cases/day @100 beds', 'Avg ₹/case'],
            rows: s.otc,
            editCols: const {1, 2},
            onChanged: (r, c, v) => n.setCell('otc', r, c, v),
            table: 'otc',
            onAdd: () => n.addRow('otc'),
            onRemove: (r) => n.removeRow('otc', r),
            onTextChanged: (r, c, v) => n.setTextCell('otc', r, c, v),
            textCols: const {0},
            removableFrom: PD.otc.length,
          ),
        ],
      ),
    );
  }
}
