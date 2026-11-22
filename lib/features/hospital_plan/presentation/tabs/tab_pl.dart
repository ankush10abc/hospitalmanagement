import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/plan_provider.dart';
import '../plan_widgets.dart';

class TabPL extends ConsumerWidget {
  const TabPL({super.key});

  static const _yh = ['Yr 1','Yr 2','Yr 3','Yr 4','Yr 5','Yr 6','Yr 7','Yr 8','Yr 9','Yr 10'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(planResultProvider);
    final R = m.R; final C = m.C;

    List<String> rw(String label, List<double> vals, {int d = 2}) =>
        [label, ...vals.map((v) => fL(v, d: d))];

    List<String> pctRow(String label, List<double> vals) =>
        [label, ...vals.map(fPct)];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SecHead('Projected profit & loss (₹ lakh)'),
        FinTable(
          headers: const ['Particulars', ..._yh],
          rows: [
            rw('Capacity utilisation %', m.U.map((u) => u * 100).toList(), d: 0),
            rw('Revenue from beds / rooms', R.map((r) => r['Room']!).toList()),
            rw('Revenue from OPD', R.map((r) => r['OPD']!).toList()),
            rw('Revenue from diagnostics', R.map((r) => r['Diag']!).toList()),
            rw('Revenue from OT', R.map((r) => r['OT']!).toList()),
            rw('Revenue from pharmacy', R.map((r) => r['Pharm']!).toList()),
            rw('Other revenue', R.map((r) => r['Other']!).toList()),
            rw('Staff cost', C.map((c) => c['Staff']!).toList()),
            rw('Pharmacy cost', C.map((c) => c['Ph']!).toList()),
            rw('OPD cost', C.map((c) => c['Opd']!).toList()),
            rw('Surgery cost', C.map((c) => c['Ot']!).toList()),
            rw('Diagnostics cost', C.map((c) => c['Dg']!).toList()),
            rw('Other income cost', C.map((c) => c['Oth']!).toList()),
            rw('Bed cost', C.map((c) => c['Bed']!).toList()),
            rw('Power & utilities', C.map((c) => c['pwr']!).toList()),
            rw('Repairs & maintenance', C.map((c) => c['rm']!).toList()),
            rw('IT & communication', C.map((c) => c['it']!).toList()),
            rw('Printing & stationery', C.map((c) => c['pr']!).toList()),
            rw('Travel', C.map((c) => c['tr']!).toList()),
            rw('Marketing', C.map((c) => c['mk']!).toList()),
            rw('Food to staff', C.map((c) => c['fd']!).toList()),
            rw('Insurance', C.map((c) => c['ins']!).toList()),
            rw('Contingency margin', C.map((c) => c['cont']!).toList()),
            rw('Total revenue', R.map((r) => r['T']!).toList()),
            rw('Total operating cost', C.map((c) => c['T']!).toList()),
            rw('EBITDA', m.eb),
            rw('Depreciation', m.dep),
            rw('Operating profit before interest', m.pbit),
            rw('Interest on working capital', m.iW),
            rw('Interest on term loan', m.iT),
            rw('Profit before tax', m.pbt),
            rw('Tax', m.tx),
            rw('Profit after tax', m.pat),
            rw('Cumulative profit', m.cum),
            pctRow('EBITDA margin', List.generate(10, (y) => m.eb[y] / R[y]['T']!)),
          ],
        ),
        const SizedBox(height: 8),
        const Text('Revenue is theoretical 100% revenue × utilisation × inflation (compounded). Tax has no loss carry-forward.',
            style: TextStyle(fontSize: 12, color: Color(0xFF5D7078))),
        const SizedBox(height: 24),
      ]),
    );
  }
}
