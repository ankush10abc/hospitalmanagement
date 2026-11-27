import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/plan_provider.dart';
import '../domain/plan_engine.dart';
import '../domain/plan_data.dart';
import '../domain/plan_state.dart';
import 'plan_widgets.dart';
import 'tabs/tab_pl.dart';
import 'tabs/tab_project_cost.dart';
import 'tabs/tab_revenue.dart';
import 'tabs/tab_setup.dart';
import 'tabs/tab_staff_equip.dart';

/// Dynamic Flutter version of the planning workflow in Platform.html.
class CreateHospitalPlanPage extends ConsumerStatefulWidget {
  const CreateHospitalPlanPage({super.key});

  @override
  ConsumerState<CreateHospitalPlanPage> createState() =>
      _CreateHospitalPlanPageState();
}

class _CreateHospitalPlanPageState
    extends ConsumerState<CreateHospitalPlanPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    'Setup',
    'Revenue drivers',
    'Staff & equipment',
    'Project cost',
    'P&L',
    'Loan & WC',
    'Dep, BS & CF',
    'Ratios & DSCR',
    'DPR draft',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    Future.microtask(() => ref.read(planProvider.notifier).load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(planProvider);
    final model = ref.watch(planResultProvider);
    final syncStatus = ref.watch(planSyncStatusProvider);

    final dashboardMetrics = <(String, String)>[
      ('Total project cost', fCr(model.total)),
      ('Cost per bed', fCr(_safeDivide(model.total, state.beds))),
      ('Cost per sq ft', '₹${fL(_safeDivide(model.total * 1e5, model.area), d: 0)}'),
      ('Built-up area', '${fL(model.area, d: 0)} sq ft'),
      ('Land required', '${fL(model.ldPlot, d: 0)} sq ft (${fL(model.ldPlot / 43560, d: 2)} ac)'),
      ('Floors required', '${model.ldFn} of ${model.ldFl} allowed'),
      ('Equipment share', fPct(_safeDivide(model.med, model.total))),
      ('Year 5 revenue', fCr(model.R[4]['T']!)),
      ('Year 5 EBITDA margin', fPct(_safeDivide(model.eb[4], model.R[4]['T']!))),
      ('Project IRR (10y)', fPct(model.pIrr)),
      ('Equity IRR (10y)', fPct(model.eIrr)),
      ('Average DSCR', model.avgDs.isFinite ? model.avgDs.toStringAsFixed(2) : 'n/a'),
      ('Payback', model.pb == null ? '>10 years' : 'Year ${model.pb}'),
      ('Year 5 BEP', fPct(model.bep[4])),
    ];

    final dashboardTips = <Widget>[
      for (final eq in model.eqAll.where((r) => r[0] == 'Imaging / oncology'))
        TipBanner(
          'Removing ${eq[1]} could reduce project cost by about ${fCr(_num(eq[4]))} (${fL(_safeDivide(_num(eq[4]), model.total) * 100, d: 1)}%). Review the service mix before changing it.',
        ),
      if (model.pIrr.isFinite && model.pIrr < 0.12)
        const TipBanner('Project IRR is below 12%. Review occupancy ramp-up, bed mix, tariffs, or capital costs.', warn: true),
      if (model.avgDs.isFinite && model.avgDs < 1.5)
        const TipBanner('Average DSCR is below 1.5. Consider the financing assumptions and debt capacity.', warn: true),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: _PageHeader(state: state, syncStatus: syncStatus, ref: ref),
          ),
          SliverToBoxAdapter(
            child: _DashboardSection(
              metrics: dashboardMetrics,
              tips: dashboardTips,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabHeaderDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: const Color(0xFF0B7A75),
                unselectedLabelColor: const Color(0xFF5D7078),
                indicatorColor: const Color(0xFF0B7A75),
                indicatorWeight: 2.5,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 13),
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            const TabSetup(),
            const TabRevenue(),
            const TabStaffEquip(),
            const TabProjectCost(),
            const TabPL(),
            _LoanWorkingCapitalTab(model: model, state: state),
            _DepreciationBalanceSheetTab(model: model),
            _RatiosTab(model: model, state: state),
            _DprTab(state: state, model: model),
          ],
        ),
      ),
    );
  }
}

// ── Page header (teal banner) ─────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.state, required this.syncStatus, required this.ref});
  final PlanState state;
  final PlanSyncStatus syncStatus;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B7A75),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🏥', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    'HospiPlan',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              const Text(
                'Hospital DPR + bank-style CMA model (P&L, loan, working capital, balance sheet, cash flow, DSCR, IRR, BEP)',
                style: TextStyle(fontSize: 12, color: Color(0xFFE3F3F1)),
              ),
            ],
          );
          final actions = Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                backgroundColor: const Color(0xFF0D9488),
                side: BorderSide.none,
                avatar: const Icon(Icons.bed_outlined, size: 15, color: Colors.white),
                label: Text(
                  '${state.beds.toStringAsFixed(0)} beds · ${state.cityName}',
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
              _SaveButton(syncStatus: syncStatus, ref: ref),
            ],
          );
          return constraints.maxWidth < 700
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, const SizedBox(height: 12), actions],
                )
              : Row(
                  children: [Expanded(child: title), actions],
                );
        },
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.syncStatus, required this.ref});
  final PlanSyncStatus syncStatus;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final isSaving = syncStatus == PlanSyncStatus.saving;
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.18),
        foregroundColor: Colors.white,
      ),
      onPressed: isSaving
          ? null
          : () async {
              try {
                await ref.read(planProvider.notifier).saveNow();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan saved to Firestore')),
                  );
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not save. Check connection.')),
                  );
                }
              }
            },
      icon: Icon(switch (syncStatus) {
        PlanSyncStatus.saved => Icons.cloud_done,
        PlanSyncStatus.error => Icons.cloud_off,
        _ => Icons.cloud_upload,
      }, size: 16),
      label: Text(switch (syncStatus) {
        PlanSyncStatus.loading => 'Loading...',
        PlanSyncStatus.saving => 'Saving...',
        PlanSyncStatus.error => 'Save failed',
        PlanSyncStatus.saved => 'Saved',
      }, style: const TextStyle(fontSize: 12)),
    );
  }
}

// ── Dashboard KPI section ─────────────────────────────────────────────────────
class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.metrics, required this.tips});
  final List<(String, String)> metrics;
  final List<Widget> tips;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard (₹ lakh unless stated)',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF17262B)),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: metrics
                .map((m) => KpiCard(label: m.$1, value: m.$2))
                .toList(),
          ),
          if (tips.isNotEmpty) ...[  
            const SizedBox(height: 8),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              dense: true,
              expandedAlignment: Alignment.centerLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                'Planning insights (${tips.length})',
                style: const TextStyle(fontSize: 13, color: Color(0xFF0B7A75), fontWeight: FontWeight.w600),
              ),
              children: tips,
            ),
          ],
          const SizedBox(height: 6),
          const Text(
            'Planning-grade estimates. Validate local rates, tariffs, staffing and land norms before bank submission.',
            style: TextStyle(fontSize: 11, color: Color(0xFF5D7078)),
          ),
        ],
      ),
    );
  }
}

// ── Sticky tab bar delegate ───────────────────────────────────────────────────
class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabHeaderDelegate(this.tabBar);
  final TabBar tabBar;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      Material(
        color: Colors.white,
        elevation: overlapsContent ? 2 : 0,
        child: tabBar,
      );
  @override
  bool shouldRebuild(covariant _TabHeaderDelegate old) => old.tabBar != tabBar;
}

class _LoanWorkingCapitalTab extends StatelessWidget {
  const _LoanWorkingCapitalTab({required this.model, required this.state});
  final M model;
  final PlanState state;

  @override
  Widget build(BuildContext context) => _PlanScroll(
    children: [
      const SecHead('Term loan assumptions'),
      FinTable(
        headers: const ['Parameter', 'Value'],
        rows: [
          ['Principal', '${fL(model.debt)} lakh'],
          ['Interest rate', '${fL(state.irc, d: 2)}%'],
          [
            'Tenure / moratorium',
            '${state.ten.toStringAsFixed(1)} / ${state.mor.toStringAsFixed(1)} years',
          ],
          ['Repayment', 'Quarterly, equal principal after moratorium'],
          ['Quarterly principal instalment', '${fL(model.inst)} lakh'],
        ],
      ),
      const SecHead('Yearly loan summary (₹ lakh)'),
      FinTable(
        headers: const ['Particulars', ..._years],
        rows: [
          _row('Interest on term loan', model.iT),
          _row('Principal repayment', model.rp),
          _row('Closing balance', model.cl),
        ],
      ),
      const SecHead('Term loan schedule (₹ lakh)'),
      FinTable(
        headers: const [
          'Period',
          'Opening balance',
          'Interest',
          'Principal',
          'Closing balance',
        ],
        rows: model.Q
            .map(
              (r) => [
                r[0].toString(),
                fL(_num(r[1])),
                fL(_num(r[2])),
                fL(_num(r[3])),
                fL(_num(r[4])),
              ],
            )
            .toList(),
      ),
      const SecHead('Working capital requirement (₹ lakh)'),
      FinTable(
        headers: const ['Particulars', ..._years],
        rows: [
          _row(
            'Cash operating expenses',
            model.C.map((cost) => cost['T']!).toList(),
          ),
          _row('Working funds (${fL(state.wfp, d: 1)}%)', model.WF),
          _row('Stock of consumables', model.stock),
          _row('Working capital requirement', model.WC),
          _row(
            'Less: long-term margin',
            List<double>.filled(10, model.WC.first),
          ),
          _row('Bank working capital borrowing', model.bB),
          _row('Interest on working capital', model.iW),
        ],
      ),
    ],
  );
}

class _DepreciationBalanceSheetTab extends StatelessWidget {
  const _DepreciationBalanceSheetTab({required this.model});

  final M model;

  @override
  Widget build(BuildContext context) {
    final liabilities = List.generate(
      10,
      (year) => model.prom2 + model.cum[year] + model.cl[year] + model.bB[year],
    );
    final cashFlowHeaders = ['Particulars', 'Yr 0', ..._years];
    List<String> openingOnly(String label, double value) => [
      label,
      fL(value),
      ...List<String>.filled(10, '–'),
    ];
    List<String> yearlyCashFlow(String label, List<double> values) => [
      label,
      '–',
      ...values.map((value) => value.isFinite ? fL(value) : 'n/a'),
    ];

    return _PlanScroll(
      children: [
        const SecHead('Depreciation by asset class (₹ lakh)'),
        FinTable(
          headers: const ['Asset class', ..._years],
          rows: [
            for (var i = 0; i < model.blk.length; i++)
              _row(
                '${model.blk[i][0]} @ ${model.blk[i][2]}%',
                model.dp[i].map((v) => v[1]).toList(),
              ),
            _row('Total depreciation', model.dep),
          ],
        ),
        const SecHead('Projected balance sheet (₹ lakh)'),
        FinTable(
          headers: const ['Particulars', ..._years],
          rows: [
            _row('Promoter capital', List<double>.filled(10, model.prom2)),
            _row('Reserves (cumulative profit)', model.cum),
            _row(
              'Net worth',
              List.generate(10, (year) => model.prom2 + model.cum[year]),
            ),
            _row('Term loan', model.cl),
            _row('Bank working capital', model.bB),
            _row('Total liabilities', liabilities),
            _row(
              'Gross block (including land)',
              List<double>.filled(10, model.gross),
            ),
            _row('Less: accumulated depreciation', model.cd),
            _row('Net fixed assets', model.nfa),
            _row('Stock of consumables', model.stock),
            _row('Cash and bank', model.cf.map((row) => row['c']!).toList()),
            _row('Preliminary expenses', List<double>.filled(10, model.pre)),
            _row('Total assets', model.ta),
            _row(
              'Check: assets less liabilities',
              List.generate(10, (year) => model.ta[year] - liabilities[year]),
            ),
          ],
        ),
        const SecHead('Projected cash flow (₹ lakh)'),
        FinTable(
          headers: cashFlowHeaders,
          rows: [
            openingOnly('Promoter capital', model.prom2),
            openingOnly('Term loan', model.debt),
            yearlyCashFlow('Increase in WC borrowing', model.dB),
            yearlyCashFlow(
              'Revenue from operations',
              model.R.map((row) => row['T']!).toList(),
            ),
            openingOnly(
              'Capital expenditure including pre-operative',
              model.gross + model.pre,
            ),
            yearlyCashFlow(
              'Operating expenses',
              model.C.map((row) => row['T']!).toList(),
            ),
            yearlyCashFlow('Interest on term loan', model.iT),
            yearlyCashFlow('Repayment of term loan', model.rp),
            yearlyCashFlow('Increase in stock', model.dS),
            yearlyCashFlow('Interest on working capital', model.iW),
            yearlyCashFlow('Income tax', model.tx),
            ['Opening cash', '0.00', ...model.cf.map((row) => fL(row['o']!))],
            [
              'Net surplus / (deficit)',
              fL(model.WC[0]),
              ...List.generate(
                10,
                (year) => fL(model.cf[year]['inn']! - model.cf[year]['out']!),
              ),
            ],
            [
              'Closing cash',
              fL(model.WC[0]),
              ...model.cf.map((row) => fL(row['c']!)),
            ],
          ],
        ),
        const TipBanner(
          'Opening working capital margin is held as cash. Additional bank borrowing funds working capital above that initial margin.',
        ),
      ],
    );
  }
}

class _RatiosTab extends StatelessWidget {
  const _RatiosTab({required this.model, required this.state});
  final M model;
  final PlanState state;
  @override
  Widget build(BuildContext context) => _PlanScroll(
    children: [
      const SecHead('Feasibility indicators'),
      FinTable(
        headers: const ['Metric', ..._years],
        rows: [
          _row(
            'EBITDA margin',
            List.generate(10, (i) => model.eb[i] / model.R[i]['T']! * 100),
            suffix: '%',
          ),
          _row(
            'Break-even revenue',
            model.bep.map((v) => v * 100).toList(),
            suffix: '%',
          ),
          _row(
            'Cash break-even revenue',
            model.cbep.map((v) => v * 100).toList(),
            suffix: '%',
          ),
          _row('DSCR', model.ds),
        ],
      ),
      const SecHead('Debt service coverage'),
      FinTable(
        headers: const ['Particulars', ..._years],
        rows: [
          _row('Profit after tax', model.pat),
          _row('Add: depreciation', model.dep),
          _row('Add: term loan interest', model.iT),
          _row('Add: working capital interest', model.iW),
          _row(
            'Total available',
            List.generate(
              10,
              (i) => model.pat[i] + model.dep[i] + model.iT[i] + model.iW[i],
            ),
          ),
          _row('Term loan interest', model.iT),
          _row('Term loan repayment', model.rp),
          _row('Working capital interest', model.iW),
          _row(
            'Total obligation',
            List.generate(10, (i) => model.iT[i] + model.rp[i] + model.iW[i]),
          ),
          _row('DSCR', model.ds),
        ],
      ),
      const SecHead('Returns'),
      FinTable(
        headers: const ['Measure', 'Value'],
        rows: [
          ['Project IRR (10 years, after tax)', fPct(model.pIrr)],
          ['Equity IRR', fPct(model.eIrr)],
          [
            'Payback period',
            model.pb == null ? 'Beyond 10 years' : '${model.pb} years',
          ],
        ],
      ),
      const SecHead('Break-even analysis (₹ lakh)'),
      FinTable(
        headers: const ['Particulars', ..._years],
        rows: [
          _row('Revenue', model.R.map((row) => row['T']!).toList()),
          _row('Variable cost', model.vc),
          _row('Contribution', model.ct),
          _row('Fixed cost including interest and depreciation', model.fc),
          _row(
            'Break-even point (% of revenue)',
            model.bep.map((value) => value * 100).toList(),
            suffix: '%',
          ),
          _row(
            'Break-even revenue',
            List.generate(10, (i) => model.bep[i] * model.R[i]['T']!),
          ),
          _row(
            'Cash break-even point (% of revenue)',
            model.cbep.map((value) => value * 100).toList(),
            suffix: '%',
          ),
          _row(
            'Cash break-even revenue',
            List.generate(10, (i) => model.cbep[i] * model.R[i]['T']!),
          ),
        ],
      ),
      const SecHead('Financial ratios'),
      FinTable(
        headers: const ['Ratio', ..._years],
        rows: [
          _row(
            'Fixed asset turnover',
            List.generate(
              10,
              (i) => _safeDivide(model.R[i]['T']!, model.nfa[i]),
            ),
          ),
          _row(
            'Net profit ratio',
            List.generate(
              10,
              (i) => _safeDivide(model.pat[i], model.R[i]['T']!) * 100,
            ),
            suffix: '%',
          ),
          _row(
            'Return on investment (PBIT / total assets)',
            List.generate(
              10,
              (i) => _safeDivide(model.pbit[i], model.ta[i]) * 100,
            ),
            suffix: '%',
          ),
          _row(
            'EBITDA margin',
            List.generate(
              10,
              (i) => _safeDivide(model.eb[i], model.R[i]['T']!) * 100,
            ),
            suffix: '%',
          ),
          _row(
            'Debt / equity',
            List.generate(
              10,
              (i) => _safeDivide(model.cl[i], model.prom2 + model.cum[i]),
            ),
          ),
        ],
      ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          KpiCard(label: 'Project IRR', value: fPct(model.pIrr)),
          KpiCard(label: 'Equity IRR', value: fPct(model.eIrr)),
          KpiCard(
            label: 'Average DSCR',
            value: model.avgDs.isFinite
                ? model.avgDs.toStringAsFixed(2)
                : 'n/a',
          ),
          KpiCard(
            label: 'Payback period',
            value: model.pb == null ? 'Beyond 10 years' : 'Year ${model.pb}',
          ),
        ],
      ),
      const SecHead('Utilisation vs revenue per unit'),
      _SensitivityMatrix(state: state, capexByUtilisation: false),
      const SecHead('Capex vs utilisation'),
      _SensitivityMatrix(state: state, capexByUtilisation: true),
      const SecHead('Scenario sensitivity'),
      FinTable(
        headers: const [
          'Scenario',
          'Project IRR',
          'Equity IRR',
          'Avg DSCR',
          'Payback',
          'Year 5 EBITDA',
          'Year 5 BEP',
        ],
        rows: [
          for (final scenario in _scenarios)
            _scenarioRow(
              scenario.$1,
              M.withSens(state, scenario.$2, scenario.$3, scenario.$4),
            ),
        ],
      ),
    ],
  );
}

class _SensitivityMatrix extends StatelessWidget {
  const _SensitivityMatrix({
    required this.state,
    required this.capexByUtilisation,
  });

  final PlanState state;
  final bool capexByUtilisation;

  static const _multipliers = [0.8, 0.9, 1.0, 1.1, 1.2];

  String _change(double multiplier) {
    final percent = ((multiplier - 1) * 100).round();
    return '${percent > 0 ? '+' : ''}$percent%';
  }

  @override
  Widget build(BuildContext context) {
    final rowMultipliers = _multipliers;
    final columnMultipliers = _multipliers;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F7FA)),
        columns: [
          DataColumn(
            label: Text(
              capexByUtilisation
                  ? 'Capex ↓ / utilisation →'
                  : 'Utilisation ↓ / revenue per unit →',
            ),
          ),
          for (final multiplier in columnMultipliers)
            DataColumn(label: Text(_change(multiplier))),
        ],
        rows: [
          for (var rowIndex = 0; rowIndex < rowMultipliers.length; rowIndex++)
            DataRow(
              cells: [
                DataCell(Text(_change(rowMultipliers[rowIndex]))),
                for (
                  var columnIndex = 0;
                  columnIndex < columnMultipliers.length;
                  columnIndex++
                )
                  _cell(
                    rowIndex,
                    columnIndex,
                    capexByUtilisation
                        ? M.withSens(
                            state,
                            columnMultipliers[columnIndex],
                            1,
                            rowMultipliers[rowIndex],
                          )
                        : M.withSens(
                            state,
                            rowMultipliers[rowIndex],
                            columnMultipliers[columnIndex],
                            1,
                          ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  DataCell _cell(int row, int column, M model) {
    final isBase = row == 2 && column == 2;
    final dscrColor = model.avgDs.isFinite && model.avgDs < 1
        ? const Color(0xFFB3261E)
        : const Color(0xFF17262B);
    return DataCell(
      Container(
        width: 94,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        color: isBase ? const Color(0xFFE3F3F1) : null,
        child: Text(
          '${fPct(model.pIrr)} · ${model.avgDs.isFinite ? model.avgDs.toStringAsFixed(2) : 'n/a'}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dscrColor,
            fontWeight: isBase ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _DprTab extends StatelessWidget {
  const _DprTab({required this.state, required this.model});
  final PlanState state;
  final M model;
  @override
  Widget build(BuildContext context) => _PlanScroll(
    children: [
      const Text(
        'Auto-generated DPR draft',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SecHead('1. Executive summary'),
      Text(
        '${state.projectName} is a proposed ${state.beds.toStringAsFixed(0)} bed ${PD.hospitalTypes.firstWhere((type) => type[0] == state.hospitalType)[1]} hospital in ${state.cityName}, with ${fL(model.area, d: 0)} sq ft built-up area and ${state.icu.toStringAsFixed(0)} ICU beds. Total project cost is ${fCr(model.total)}, including promoter contribution of ${fCr(model.prom2)} and term debt of ${fCr(model.debt)}.',
      ),
      const SecHead('2. Site and facility'),
      Text(
        'The model estimates ${fL(model.ldPlot, d: 0)} sq ft of land (${fL(model.ldPlot / 43560, d: 2)} acres), with ${model.ldFn} floors and ${model.ldGov.toLowerCase()} as the governing constraint.',
      ),
      const SecHead('3. Revenue and operating outlook'),
      Text(
        'Revenue is modeled from room, OPD, diagnostics, OT, pharmacy and other income. Year 1 revenue is ${fCr(model.R[0]['T']!)} and Year 10 revenue is ${fCr(model.R[9]['T']!)}. Year 5 EBITDA margin is ${fPct(model.eb[4] / model.R[4]['T']!)}.',
      ),
      const SecHead('4. Project cost and financial viability'),
      Text(
        'Project IRR is ${fPct(model.pIrr)}, equity IRR is ${fPct(model.eIrr)}, average DSCR is ${model.avgDs.isFinite ? model.avgDs.toStringAsFixed(2) : 'n/a'}, and payback is ${model.pb == null ? 'beyond 10 years' : 'Year ${model.pb}'}.',
      ),
      const SecHead('5. Manpower and facility operations'),
      Text(
        'The model includes ${model.staffN.toStringAsFixed(0)} full-strength staff at an annual salary cost of ${fCr(model.staffAnn)}. The facility plan includes ${model.otTot.toStringAsFixed(0)} operating theatres and ${state.icu.toStringAsFixed(0)} ICU beds. Revenue utilization starts at ${fL(state.util.first, d: 0)}% in Year 1 and reaches ${fL(state.util.last, d: 0)}% in Year 10.',
      ),
      const SecHead('6. Planning assumptions and selected services'),
      Text(
        'The plan uses ${state.fsi} FSI, ${fL(state.gc, d: 0)}% ground coverage, and ${fL(state.hgt, d: 0)} m maximum height. Selected advanced services: ${_selectedServices(state)}.',
      ),
      const SecHead('7. Key risks and validation'),
      const Text(
        'Validate occupancy, tariffs, payer mix, staffing, local land norms, equipment quotes and construction rates with local market data and qualified finance professionals before using this draft for lending decisions.',
      ),
    ],
  );
}

const _years = [
  'Yr 1',
  'Yr 2',
  'Yr 3',
  'Yr 4',
  'Yr 5',
  'Yr 6',
  'Yr 7',
  'Yr 8',
  'Yr 9',
  'Yr 10',
];
const _scenarios = <(String, double, double, double)>[
  ('Base case', 1, 1, 1),
  ('Utilisation −10%', .9, 1, 1),
  ('Utilisation +10%', 1.1, 1, 1),
  ('Revenue per unit −10%', 1, .9, 1),
  ('Revenue per unit +10%', 1, 1.1, 1),
  ('Capex +10%', 1, 1, 1.1),
  ('Capex −10%', 1, 1, .9),
  ('Downside: utilisation −10%, revenue −5%, capex +10%', .9, .95, 1.1),
];
List<String> _scenarioRow(String label, M model) => [
  label,
  fPct(model.pIrr),
  fPct(model.eIrr),
  model.avgDs.isFinite ? model.avgDs.toStringAsFixed(2) : 'n/a',
  model.pb == null ? '>10 years' : 'Year ${model.pb}',
  fL(model.eb[4]),
  fPct(model.bep[4]),
];
double _num(dynamic value) => value is num ? value.toDouble() : 0;
double _safeDivide(double numerator, double denominator) =>
    denominator == 0 ? double.nan : numerator / denominator;
String _selectedServices(PlanState state) {
  const labels = {
    'mri': 'MRI',
    'ct': 'CT',
    'cath': 'Cath Lab',
    'pet': 'PET CT',
    'linac': 'LINAC',
  };
  final selected = state.sel.entries
      .where((entry) => entry.value && labels.containsKey(entry.key))
      .map((entry) => labels[entry.key]!)
      .toList();
  return selected.isEmpty ? 'none' : selected.join(', ');
}

List<String> _row(String label, List<double> values, {String suffix = ''}) => [
  label,
  ...values.map((v) => v.isFinite ? '${fL(v)}$suffix' : 'n/a'),
];

class _PlanScroll extends StatelessWidget {
  const _PlanScroll({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    physics: const AlwaysScrollableScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
    child: PlanCard(
      children: [...children, const SizedBox(height: 8)],
    ),
  );
}
