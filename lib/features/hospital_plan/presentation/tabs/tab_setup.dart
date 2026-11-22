import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/plan_provider.dart';
import '../../domain/plan_data.dart';
import '../plan_widgets.dart';

class TabSetup extends ConsumerWidget {
  const TabSetup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(planProvider);
    final n = ref.read(planProvider.notifier);

    Widget pf(String label, String key, double val) =>
        PField(label: label, value: val, onChanged: (v) => n.setParam(key, v));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project config
          const SecHead('Project configuration'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project name',
                      style: TextStyle(fontSize: 11, color: Color(0xFF5D7078)),
                    ),
                    const SizedBox(height: 3),
                    TextFormField(
                      initialValue: s.projectName,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDBE4E7),
                          ),
                        ),
                      ),
                      onChanged: n.setProjectName,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'City',
                      style: TextStyle(fontSize: 11, color: Color(0xFF5D7078)),
                    ),
                    const SizedBox(height: 3),
                    DropdownButtonFormField<int>(
                      initialValue: s.cityIdx,
                      isDense: true,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDBE4E7),
                          ),
                        ),
                      ),
                      items: PD.cities
                          .asMap()
                          .entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(
                                e.value[0] as String,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (i) {
                        if (i != null) n.setCity(i);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hospital type',
                      style: TextStyle(fontSize: 11, color: Color(0xFF5D7078)),
                    ),
                    const SizedBox(height: 3),
                    DropdownButtonFormField<String>(
                      initialValue: s.hospitalType,
                      isDense: true,
                      isExpanded: true,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFDBE4E7),
                          ),
                        ),
                      ),
                      items: PD.hospitalTypes
                          .map(
                            (t) => DropdownMenuItem(
                              value: t[0],
                              child: Text(
                                t[1],
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) n.setHospitalType(v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SecHead('Project & area'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              pf('Beds', 'beds', s.beds),
              pf('ICU beds', 'icu', s.icu),
              pf('Built-up sq ft / bed', 'apb', s.apb),
              pf('Gestation (months)', 'gest', s.gest),
              pf('OPD days / yr', 'opdd', s.opdd),
              pf('Surgery days / yr', 'surgd', s.surgd),
              pf('Bed days / yr', 'bedd', s.bedd),
            ],
          ),

          const SecHead('Land norms'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              pf('FSI / FAR', 'fsi', s.fsi),
              pf('Ground coverage %', 'gc', s.gc),
              pf('Max height (m)', 'hgt', s.hgt),
              pf('Floor-to-floor (m)', 'fh', s.fh),
              pf('Land rate ₹/sq ft', 'lrate', s.lrate),
              pf('Land override ₹ lakh (0=auto)', 'landov', s.landov),
            ],
          ),

          const SecHead('Finance & tax'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              pf('Promoter %', 'prom', s.prom),
              pf('Term loan interest %', 'irc', s.irc),
              pf('WC interest %', 'irw', s.irw),
              pf('Loan tenure (yrs)', 'ten', s.ten),
              pf('Moratorium (yrs)', 'mor', s.mor),
              pf('Tax rate %', 'tax', s.tax),
              pf('Revenue inflation %/yr', 'infl', s.infl),
              pf('Salary inflation %/yr', 'sinfl', s.sinfl),
            ],
          ),

          const SecHead('Depreciation (WDV %)'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              pf('Medical', 'dMed', s.dMed),
              pf('Non-medical', 'dNm', s.dNm),
              pf('Vehicles', 'dVeh', s.dVeh),
              pf('Building', 'dBld', s.dBld),
              pf('Furniture', 'dFur', s.dFur),
            ],
          ),

          const SecHead('Building rates (× city index)'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              pf('RCC ₹/sq ft', 'r1', s.r1),
              pf('Interiors ₹/sq ft', 'r2', s.r2),
              pf('Electrical ₹/sq ft', 'r3', s.r3),
              pf('Plumbing ₹/sq ft', 'r4', s.r4),
              pf('HVAC sq ft/TR', 'sqtr', s.sqtr),
              pf('HVAC ₹/TR', 'trr', s.trr),
              pf('Lift ₹ lakh/unit', 'lift', s.lift),
              pf('Landscaping ₹/sq ft', 'lsr', s.lsr),
              pf('Contingency %', 'contp', s.contp),
              pf('Consultant fees %', 'consp', s.consp),
            ],
          ),

          const SecHead('Revenue drivers'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              pf('Pharmacy ₹/IPD pt/day', 'phin', s.phin),
              pf('% OPD buying pharmacy', 'phop', s.phop),
              pf('Pharmacy ₹/OPD pt', 'phor', s.phor),
              pf('Canteen ₹/footfall', 'cant', s.cant),
              pf('Ambulance trips/day', 'trips', s.trips),
              pf('₹/ambulance trip', 'trate', s.trate),
              pf('Ambulances (normal)', 'v1', s.v1),
              pf('Ambulances (cardiac)', 'v2', s.v2),
              pf('Two-wheelers', 'v3', s.v3),
              pf('Furniture GST %', 'gst', s.gst),
              pf('Furniture contingency %', 'fcont', s.fcont),
            ],
          ),

          const SecHead('Cost ratios (% of revenue)'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              pf('Pharmacy cost %', 'cPh', s.cPh),
              pf('OPD cost %', 'cOpd', s.cOpd),
              pf('Surgery cost %', 'cOt', s.cOt),
              pf('Diagnostics cost %', 'cDg', s.cDg),
              pf('Other income cost %', 'cOth', s.cOth),
              pf('Bed cost %', 'cBed', s.cBed),
              pf('Power & utilities %', 'pwr', s.pwr),
              pf('Repairs %', 'rm', s.rm),
              pf('IT %', 'it', s.it),
              pf('Printing %', 'pr', s.pr),
              pf('Travel %', 'tr', s.tr),
              pf('Marketing %', 'mk', s.mk),
              pf('Staff food %', 'fd', s.fd),
              pf('Insurance %', 'ins', s.ins),
              pf('Contingency margin %', 'cont', s.cont),
              pf('Staffing % of full strength', 'stf', s.stf),
              pf('Working funds % of cash opex', 'wfp', s.wfp),
              pf('Consumables stock %', 'stk', s.stk),
            ],
          ),

          const SecHead('Capacity utilisation % per year'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (int i = 0; i < 10; i++)
                PField(
                  label: 'Year ${i + 1}',
                  value: s.util[i],
                  onChanged: (v) => n.setUtil(i, v),
                ),
            ],
          ),

          const SecHead('Advanced services & equipment'),
          _ServicesWidget(),

          const SecHead('OT categories'),
          Consumer(
            builder: (_, ref, __) {
              final st = ref.watch(planProvider);
              return EditTable(
                headers: const [
                  'OT type',
                  'Count',
                  'Equip ₹L/OT',
                  'Furn ₹L/OT',
                  'Fit-out ₹L/OT',
                ],
                rows: st.ott,
                editCols: const {1, 2, 3, 4},
                onChanged: (r, c, v) =>
                    ref.read(planProvider.notifier).setCell('ott', r, c, v),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ServicesWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(planProvider);
    final n = ref.read(planProvider.notifier);
    final b = s.beds;
    final t = s.hospitalType;

    const svcs = [
      ['mri', 'MRI'],
      ['ct', 'CT Scan'],
      ['cath', 'Cath Lab (Cardiology)'],
      ['pet', 'PET CT'],
      ['linac', 'LINAC (Oncology)'],
    ];

    return Column(
      children: svcs.map((sv) {
        final k = sv[0];
        final label = sv[1];
        final r = PD.serviceRestriction(k, hospitalType: t, beds: b);
        final allowed = r == null;
        return Opacity(
          opacity: allowed ? 1.0 : 0.55,
          child: CheckboxListTile(
            dense: true,
            value: allowed && (s.sel[k] ?? false),
            onChanged: allowed ? (v) => n.setService(k, v ?? false) : null,
            title: Text(label, style: const TextStyle(fontSize: 13)),
            subtitle: Text(
              allowed ? '✅ Allowed' : '🚫 $r',
              style: TextStyle(
                fontSize: 11,
                color: allowed
                    ? const Color(0xFF1A7F4B)
                    : const Color(0xFFB45309),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
