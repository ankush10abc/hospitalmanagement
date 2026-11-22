import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/plan_provider.dart';
import '../plan_widgets.dart';

class TabStaffEquip extends ConsumerWidget {
  const TabStaffEquip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(planProvider);
    final n = ref.read(planProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SecHead('Staff & salary (per month)'),
        EditTable(
          headers: const ['Designation', 'Qty @100 beds', 'Salary ₹/month'],
          rows: s.staff.map((r) => [r[0], r[1], r[2]]).toList(),
          editCols: const {1, 2},
          onChanged: (r, c, v) => n.setCell('staff', r, c, v),
        ),

        const SecHead('Medical equipment catalogue (₹ lakh)'),
        EditTable(
          headers: const ['Dept', 'Item', 'Unit ₹ lakh', 'Basis', 'Factor'],
          rows: s.eq, editCols: const {2},
          onChanged: (r, c, v) => n.setCell('eq', r, c, v),
        ),

        const SecHead('Advanced equipment prices (₹ lakh)'),
        EditTable(
          headers: const ['Item', '₹ lakh'],
          rows: s.ad, editCols: const {1},
          onChanged: (r, c, v) => n.setCell('ad', r, c, v),
        ),

        const SecHead('Non-medical equipment'),
        EditTable(
          headers: const ['Item', 'Fixed ₹ lakh', 'Per bed ₹ lakh'],
          rows: s.nm, editCols: const {1, 2},
          onChanged: (r, c, v) => n.setCell('nm', r, c, v),
        ),

        const SecHead('Furniture unit rates (₹)'),
        EditTable(
          headers: const ['Item', 'Unit rate ₹'],
          rows: s.fr, editCols: const {1},
          onChanged: (r, c, v) => n.setCell('fr', r, c, v),
        ),

        const SecHead('Lump-sum furniture (₹ lakh @100 beds)'),
        EditTable(
          headers: const ['Section', '₹ lakh @100 beds'],
          rows: s.lump, editCols: const {1},
          onChanged: (r, c, v) => n.setCell('lump', r, c, v),
        ),

        const SecHead('Pre-operative expenses'),
        EditTable(
          headers: const ['Item', '₹ lakh'],
          rows: s.pre, editCols: const {1},
          onChanged: (r, c, v) => n.setCell('pre', r, c, v),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
