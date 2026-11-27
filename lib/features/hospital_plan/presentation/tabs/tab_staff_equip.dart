import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/plan_provider.dart';
import '../../domain/plan_data.dart';
import '../plan_widgets.dart';

class TabStaffEquip extends ConsumerWidget {
  const TabStaffEquip({super.key});

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
            'Admin-managed catalogs: add, rename, and update values here. All changes sync to Firestore automatically.',
          ),

          const SecHead('Staff & salary (per month)', apiDriven: true),
          EditTable(
            headers: const ['Designation', 'Qty @100 beds', 'Salary ₹/month'],
            rows: s.staff.map((r) => [r[0], r[1], r[2]]).toList(),
            editCols: const {1, 2},
            onChanged: (r, c, v) => n.setCell('staff', r, c, v),
            table: 'staff',
            onAdd: () => n.addRow('staff'),
            onRemove: (r) => n.removeRow('staff', r),
            onTextChanged: (r, c, v) => n.setTextCell('staff', r, c, v),
            textCols: const {0},
            removableFrom: PD.staff.length,
          ),

          const SecHead('Medical equipment catalogue (₹ lakh)', apiDriven: true),
          EditTable(
            headers: const ['Dept', 'Item', 'Unit ₹ lakh', 'Basis', 'Factor'],
            rows: s.eq,
            editCols: const {2},
            onChanged: (r, c, v) => n.setCell('eq', r, c, v),
            table: 'eq',
            onAdd: () => n.addRow('eq'),
            onRemove: (r) => n.removeRow('eq', r),
            onTextChanged: (r, c, v) => n.setTextCell('eq', r, c, v),
            textCols: const {0, 1},
            removableFrom: PD.eq.length,
          ),

          const SecHead('Advanced equipment prices (₹ lakh)', apiDriven: true),
          EditTable(
            headers: const ['Item', '₹ lakh'],
            rows: s.ad,
            editCols: const {1},
            onChanged: (r, c, v) => n.setCell('ad', r, c, v),
            table: 'ad',
            onAdd: () => n.addRow('ad'),
            onRemove: (r) => n.removeRow('ad', r),
            onTextChanged: (r, c, v) => n.setTextCell('ad', r, c, v),
            textCols: const {0},
            removableFrom: PD.ad.length,
          ),

          const SecHead('Non-medical equipment', apiDriven: true),
          EditTable(
            headers: const ['Item', 'Fixed ₹ lakh', 'Per bed ₹ lakh'],
            rows: s.nm,
            editCols: const {1, 2},
            onChanged: (r, c, v) => n.setCell('nm', r, c, v),
            table: 'nm',
            onAdd: () => n.addRow('nm'),
            onRemove: (r) => n.removeRow('nm', r),
            onTextChanged: (r, c, v) => n.setTextCell('nm', r, c, v),
            textCols: const {0},
            removableFrom: PD.nm.length,
          ),

          const SecHead('Furniture unit rates (₹)', apiDriven: true),
          EditTable(
            headers: const ['Item', 'Unit rate ₹'],
            rows: s.fr,
            editCols: const {1},
            onChanged: (r, c, v) => n.setCell('fr', r, c, v),
            table: 'fr',
            onAdd: () => n.addRow('fr'),
            onRemove: (r) => n.removeRow('fr', r),
            onTextChanged: (r, c, v) => n.setTextCell('fr', r, c, v),
            textCols: const {0},
            removableFrom: PD.fr.length,
          ),

          const SecHead('Lump-sum furniture (₹ lakh @100 beds)', apiDriven: true),
          EditTable(
            headers: const ['Section', '₹ lakh @100 beds'],
            rows: s.lump,
            editCols: const {1},
            onChanged: (r, c, v) => n.setCell('lump', r, c, v),
            table: 'lump',
            onAdd: () => n.addRow('lump'),
            onRemove: (r) => n.removeRow('lump', r),
            onTextChanged: (r, c, v) => n.setTextCell('lump', r, c, v),
            textCols: const {0},
            removableFrom: PD.lump.length,
          ),

          const SecHead('Pre-operative expenses', apiDriven: true),
          EditTable(
            headers: const ['Item', '₹ lakh'],
            rows: s.pre,
            editCols: const {1},
            onChanged: (r, c, v) => n.setCell('pre', r, c, v),
            table: 'pre',
            onAdd: () => n.addRow('pre'),
            onRemove: (r) => n.removeRow('pre', r),
            onTextChanged: (r, c, v) => n.setTextCell('pre', r, c, v),
            textCols: const {0},
            removableFrom: PD.pre.length,
          ),
        ],
      ),
    );
  }
}
