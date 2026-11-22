import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/plan_provider.dart';
import '../../domain/plan_engine.dart';
import '../plan_widgets.dart';

class TabProjectCost extends ConsumerWidget {
  const TabProjectCost({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(planResultProvider);
    final s = ref.watch(planProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SecHead('Cost of project'),
          FinTable(
            headers: const ['Head', '₹ lakh', '₹ Cr', '%'],
            rows: [
              _cp('Land', m.land, m.total),
              _cp('Building (civil, MEP, OT fit-out, fees)', m.bld, m.total),
              _cp('Medical equipment', m.med, m.total),
              _cp('Non-medical equipment', m.nmT, m.total),
              _cp('Vehicles', m.veh, m.total),
              _cp('Furniture & fittings', m.furn, m.total),
              _cp('Preliminary & pre-operative', m.pre, m.total),
              _cp('Working capital margin', m.WC[0], m.total),
            ],
            totals: [
              'Total cost of project',
              fL(m.total),
              fL(m.total / 100),
              '100%',
            ],
          ),

          const SecHead('Means of finance'),
          FinTable(
            headers: const ['Source', '₹ lakh', '%'],
            rows: [
              ['Promoter contribution', fL(m.prom2), '${fL(s.prom, d: 0)}%'],
              ['Bank term loan', fL(m.debt), '${fL(100 - s.prom, d: 0)}%'],
            ],
            totals: ['Total', fL(m.total), '100%'],
          ),

          const SecHead('Land requirement'),
          FinTable(
            headers: const ['Parameter', 'Value'],
            rows: [
              ['Built-up area', '${fL(m.area, d: 0)} sq ft'],
              [
                'FSI / coverage / height',
                '${s.fsi} / ${fL(s.gc, d: 0)}% / ${s.hgt} m',
              ],
              ['Floors permitted', '${m.ldFl}'],
              [
                'Land needed – coverage & height',
                '${fL(m.ldByGC, d: 0)} sq ft',
              ],
              ['Land needed – FSI limit', '${fL(m.ldByFAR, d: 0)} sq ft'],
              ['Governing constraint', m.ldGov],
              [
                'Floors used / footprint',
                '${m.ldFn} / ${fL(m.ldFoot, d: 0)} sq ft',
              ],
            ],
            totals: [
              'Land required',
              '${fL(m.ldPlot, d: 0)} sq ft · ${fL(m.ldPlot / 43560, d: 2)} acres',
            ],
          ),

          const SecHead('Land & building development'),
          FinTable(
            headers: const ['Item', 'Qty', 'Rate', '₹ lakh'],
            rows: [
              ...m.bl.map(
                (r) => [
                  r[0].toString(),
                  fL(M.valueOf(r[1]), d: 0),
                  fL(M.valueOf(r[2]), d: 0),
                  fL(M.valueOf(r[3])),
                ],
              ),
              ['Contingency', '', '', fL(m.bCont)],
              ['Consultant fees', '', '', fL(m.bCons)],
            ],
            totals: ['Building total', '', '', fL(m.bld)],
          ),
          Text(
            'Cost per sq ft: ₹${fL(m.area > 0 ? m.bld * 1e5 / m.area : double.nan, d: 0)}. Land: ${fCr(m.land)}.',
            style: const TextStyle(fontSize: 12, color: Color(0xFF5D7078)),
          ),

          const SecHead('Medical equipment'),
          FinTable(
            headers: const ['Dept', 'Item', 'Qty', 'Unit ₹L', '₹ lakh'],
            rows: m.eqAll
                .map(
                  (r) => [
                    r[0].toString(),
                    r[1].toString(),
                    fL(M.valueOf(r[2]), d: 0),
                    fL(M.valueOf(r[3])),
                    fL(M.valueOf(r[4])),
                  ],
                )
                .toList(),
            totals: ['Total', '', '', '', fL(m.med)],
          ),

          const SecHead('Non-medical equipment'),
          FinTable(
            headers: const ['Item', '₹ lakh'],
            rows: m.nmRows
                .map((r) => [r[0].toString(), fL(M.valueOf(r[1]))])
                .toList(),
            totals: ['Total', fL(m.nmT)],
          ),

          const SecHead('Furniture'),
          FinTable(
            headers: const ['Item', 'Qty', 'Rate ₹', '₹ lakh'],
            rows: [
              ...m.fu.map(
                (r) => [
                  r[0].toString(),
                  fL(M.valueOf(r[1]), d: 0),
                  fL(M.valueOf(r[2]), d: 0),
                  fL(M.valueOf(r[3])),
                ],
              ),
              [
                'OT furniture & lump sections',
                '',
                '',
                fL(m.fBase - m.fu.fold(0.0, (a, r) => a + M.valueOf(r[3]))),
              ],
              ['GST', '', '', fL(m.fGst)],
              ['Contingency', '', '', fL(m.fCont)],
            ],
            totals: ['Furniture total', '', '', fL(m.furn)],
          ),

          const SecHead('Pre-operative expenses'),
          FinTable(
            headers: const ['Item', '₹ lakh'],
            rows: [
              ...ref
                  .watch(planProvider)
                  .pre
                  .sublist(0, 3)
                  .map((r) => [r[0].toString(), fL(M.valueOf(r[1]))]),
              [
                'Site office for ${s.gest.toInt()} months',
                fL(M.valueOf(s.pre[3][1]) * s.gest),
              ],
            ],
            totals: ['Total', fL(m.pre)],
          ),

          const SecHead('Manpower'),
          FinTable(
            headers: const ['Designation', 'Qty', 'Salary ₹/mo', '₹ lakh/yr'],
            rows: m.st
                .map(
                  (r) => [
                    r[0].toString(),
                    fL(M.valueOf(r[1]), d: 0),
                    fL(M.valueOf(r[2]), d: 0),
                    fL(M.valueOf(r[1]) * M.valueOf(r[2]) * 12 / 1e5),
                  ],
                )
                .toList(),
            totals: [
              'Total (full strength)',
              fL(m.staffN, d: 0),
              '',
              fL(m.staffAnn),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<String> _cp(String label, double v, double total) => [
    label,
    fL(v),
    fL(v / 100),
    '${fL(v / total * 100, d: 1)}%',
  ];
}
