import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospitalmanagement/features/hospital_plan/data/plan_provider.dart';
import 'package:hospitalmanagement/features/hospital_plan/domain/plan_engine.dart';
import 'package:hospitalmanagement/features/hospital_plan/domain/plan_state.dart';
import 'package:hospitalmanagement/features/hospital_plan/presentation/create_hospital_plan_page.dart';

void main() {
  group('hospital plan calculations', () {
    test('defaults produce complete ten-year financial projections', () {
      final model = M(PlanState());

      expect(model.area, 50000);
      expect(model.R, hasLength(10));
      expect(model.C, hasLength(10));
      expect(model.ds, hasLength(10));
      expect(model.bep, hasLength(10));
      expect(model.total, greaterThan(0));
      expect(model.WC.first, greaterThan(0));
      expect(model.Q, isNotEmpty);
    });

    test('bed count and utilization changes recalculate areas and revenue', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planProvider.notifier);
      final initial = container.read(planResultProvider);

      notifier.setParam('beds', 200);
      final larger = container.read(planResultProvider);
      expect(larger.area, 100000);
      expect(larger.total, greaterThan(initial.total));

      final revenueAtCurrentUtilization = larger.R[0]['T']!;
      notifier.setUtil(0, 50);
      expect(
        container.read(planResultProvider).R[0]['T']!,
        greaterThan(revenueAtCurrentUtilization),
      );
    });

    test('editable table values recalculate the relevant financial model', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planProvider.notifier);
      final initialRevenue = container.read(planResultProvider).R[0]['OPD']!;

      notifier.setCell('opd', 0, 2, 900);
      expect(
        container.read(planResultProvider).R[0]['OPD']!,
        greaterThan(initialRevenue),
      );

      final initialCapex = container.read(planResultProvider).total;
      notifier.setCell('fr', 0, 1, 200000);
      expect(
        container.read(planResultProvider).total,
        greaterThan(initialCapex),
      );
    });

    test('city and financing assumptions flow into project cost and debt', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planProvider.notifier);
      final initial = container.read(planResultProvider);

      notifier.setCity(6);
      final mumbai = container.read(planResultProvider);
      expect(container.read(planProvider).cityName, 'Mumbai');
      expect(mumbai.bld, greaterThan(initial.bld));
      expect(mumbai.land, greaterThan(initial.land));

      notifier.setParam('prom', 30);
      final moreEquity = container.read(planResultProvider);
      expect(moreEquity.prom2, greaterThan(mumbai.prom2));
      expect(moreEquity.debt, lessThan(mumbai.debt));
      notifier.setParam('irc', 18);
      expect(
        container.read(planResultProvider).iT.first,
        greaterThan(moreEquity.iT.first),
      );
    });

    test('service eligibility is enforced after capacity or type changes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planProvider.notifier);

      notifier.setParam('beds', 200);
      notifier.setService('pet', true);
      expect(container.read(planProvider).sel['pet'], isTrue);
      expect(
        container
            .read(planResultProvider)
            .eqAll
            .any((row) => row[1] == 'PET CT'),
        isTrue,
      );

      notifier.setHospitalType('ivf');
      expect(container.read(planProvider).sel['mri'], isFalse);
      expect(container.read(planProvider).sel['ct'], isFalse);
      expect(container.read(planProvider).sel['pet'], isFalse);
      expect(
        container
            .read(planResultProvider)
            .eqAll
            .any((row) => row[1] == 'PET CT'),
        isFalse,
      );

      notifier.setService('mri', true);
      expect(container.read(planProvider).sel['mri'], isFalse);
    });

    test('every editable catalogue table accepts updates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planProvider.notifier);
      const edits = <(String, int, int)>[
        ('opd', 0, 2),
        ('room', 0, 2),
        ('diag', 0, 3),
        ('otc', 0, 2),
        ('staff', 0, 2),
        ('eq', 0, 2),
        ('ad', 0, 1),
        ('nm', 0, 1),
        ('fr', 0, 1),
        ('lump', 0, 1),
        ('pre', 0, 1),
        ('ott', 0, 2),
      ];

      for (final (table, row, column) in edits) {
        notifier.setCell(table, row, column, 123.45);
        expect(container.read(planProvider), isNotNull, reason: table);
        expect(
          container.read(planResultProvider).total.isFinite,
          isTrue,
          reason: table,
        );
      }
    });

    test(
      'capex, revenue, and utilization sensitivity scenarios are dynamic',
      () {
        final state = PlanState();
        final base = M.withSens(state, 1, 1, 1);
        final lowerOccupancy = M.withSens(state, 0.8, 1, 1);
        final higherCapex = M.withSens(state, 1, 1, 1.2);
        final higherTariff = M.withSens(state, 1, 1.1, 1);

        expect(lowerOccupancy.R[4]['T']!, lessThan(base.R[4]['T']!));
        expect(higherCapex.total, greaterThan(base.total));
        expect(higherTariff.R[4]['T']!, greaterThan(base.R[4]['T']!));
        expect(higherTariff.C[4]['T']!, greaterThan(base.C[4]['T']!));
      },
    );

    test('zero bed and zero floor-area edge cases do not crash', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(planProvider.notifier);
      notifier.setParam('beds', 0);
      notifier.setParam('apb', 0);
      notifier.setParam('gc', 0);
      notifier.setParam('sqtr', 0);

      final model = container.read(planResultProvider);
      expect(model.area, 0);
      expect(model.ldPlot, 0);
      expect(model.ldFn, greaterThanOrEqualTo(1));
      expect(model.total.isFinite, isTrue);
    });
  });

  testWidgets('all nine plan tabs render their feature sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: CreateHospitalPlanPage())),
      ),
    );
    await tester.pumpAndSettle();

    const sections = [
      'Project configuration',
      'OPD revenue',
      'Staff & salary (per month)',
      'Cost of project',
      'Projected profit & loss',
      'Term loan assumptions',
      'Depreciation by asset class',
      'Debt service coverage',
      'Auto-generated DPR draft',
    ];

    for (var index = 0; index < sections.length; index++) {
      final tab = find.byKey(ValueKey('hospital-plan-tab-$index'));
      await tester.ensureVisible(tab);
      await tester.tap(tab);
      await tester.pumpAndSettle();
      expect(
        find.textContaining(sections[index]),
        findsWidgets,
        reason: 'Plan tab $index should render its section',
      );
    }
  });
}
