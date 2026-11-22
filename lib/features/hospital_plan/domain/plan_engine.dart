// ignore_for_file: non_constant_identifier_names
import 'dart:math';

import 'plan_data.dart';
import 'plan_state.dart';

class M {
  M(PlanState s) {
    final b = s.beds, icu = s.icu, f = s.cityIndex, sc = b / 100;
    final ir = s.irc / 100,
        iw = s.irw / 100,
        g = s.infl / 100,
        sg = s.sinfl / 100;

    // OT totals
    final OT = s.ott;
    otTot = _S(OT, (o) => _n(o[1]));
    final otFu = _S(OT, (o) => _n(o[1]) * _n(o[3]));
    final otFit = _S(OT, (o) => _n(o[1]) * _n(o[4])) * f;

    // Staff
    st = s.staff.map((r) {
      final q = _n(r[3]) == 1 ? (_n(r[1]) * sc).ceil().toDouble() : _n(r[1]);
      return [r[0], q, _n(r[2])];
    }).toList();
    staffN = _S(st, (r) => _n(r[1]));
    staffAnn = _S(st, (r) => _n(r[1]) * _n(r[2]) * 12 / 1e5);

    // OPD day
    final opdDay =
        _S(s.opd.sublist(0, min(10, s.opd.length)), (r) => _n(r[1])) * sc;

    bool serviceSelected(String key) =>
        s.sel[key] == true &&
        PD.serviceRestriction(key, hospitalType: s.hospitalType, beds: b) ==
            null;

    bool act(String name) {
      if (name == 'CT Scan') return serviceSelected('ct');
      if (name == 'MRI') return serviceSelected('mri');
      return true;
    }

    // Theoretical revenue
    th = {
      'Room': _S(s.room, (r) => b * _n(r[1]) * _n(r[2]) * s.bedd / 1e5),
      'OPD': _S(s.opd, (r) => _n(r[1]) * sc * _n(r[2]) * s.opdd / 1e5),
      'Diag': _S(
        s.diag,
        (r) => act(r[0] as String)
            ? (b * _n(r[2]) * _n(r[3]) + opdDay * _n(r[1]) * _n(r[4])) *
                  s.bedd /
                  1e5
            : 0.0,
      ),
      'OT': _S(s.otc, (r) => _n(r[1]) * sc * _n(r[2]) * s.surgd / 1e5),
      'Pharm': (b * s.phin + opdDay * s.phop / 100 * s.phor) * s.bedd / 1e5,
      'Other':
          ((opdDay * 0.35 + b * 2 + staffN * 0.3) * s.cant +
              s.trips * s.trate) *
          s.bedd /
          1e5,
    };

    final keys = ['Room', 'OPD', 'Diag', 'OT', 'Pharm', 'Other'];
    U = List.generate(10, (y) => s.util[y] / 100);

    R = List.generate(10, (y) {
      final m = <String, double>{};
      for (final k in keys) m[k] = th[k]! * U[y] * pow(1 + g, y).toDouble();
      m['T'] = keys.fold(0.0, (a, k) => a + m[k]!);
      return m;
    });

    C = List.generate(10, (y) {
      final r = R[y];
      final c = <String, double>{
        'Staff': staffAnn * s.stf / 100 * pow(1 + sg, y),
        'Ph': r['Pharm']! * s.cPh / 100,
        'Opd': r['OPD']! * s.cOpd / 100,
        'Ot': r['OT']! * s.cOt / 100,
        'Dg': r['Diag']! * s.cDg / 100,
        'Oth': r['Other']! * s.cOth / 100,
        'Bed': r['Room']! * s.cBed / 100,
      };
      for (final k in [
        'pwr',
        'rm',
        'it',
        'pr',
        'tr',
        'mk',
        'fd',
        'ins',
        'cont',
      ]) {
        c[k] = r['T']! * _sp(s, k);
      }
      c['T'] = c.values.fold(0.0, (a, v) => a + v);
      return c;
    });

    // Land & building
    area = b * s.apb;
    final fsi2 = s.fsi > 0 ? s.fsi : 1.0;
    final gc2 = (s.gc > 0 ? s.gc : 50) / 100;
    final fl2 = max(1, (s.hgt / (s.fh > 0 ? s.fh : 3.6)).floor());
    ldByGC = area / (fl2 * gc2);
    ldByFAR = area / fsi2;
    ldPlot = max(ldByGC, ldByFAR);
    ldFn = max(1, ldPlot > 0 ? (area / (ldPlot * gc2)).ceil() : 1);
    ldFoot = area / ldFn;
    ldFl = fl2;
    ldGov = ldByFAR > ldByGC ? 'FSI / FAR limit' : 'Ground coverage + height';

    land = s.landov > 0 ? s.landov : ldPlot * s.lrate / 1e5;
    final lifts = (b / 50).ceil() + 1;

    final sqftPerTr = s.sqtr > 0 ? s.sqtr : 250;
    bl = [
      [
        'RCC works incl. masonry & waterproofing',
        area,
        s.r1,
        area * s.r1 * f / 1e5,
      ],
      ['Interiors, façade & other civil', area, s.r2, area * s.r2 * f / 1e5],
      [
        'Electrical (substation, DG, cabling, ELV)',
        area,
        s.r3,
        area * s.r3 * f / 1e5,
      ],
      [
        'HVAC (${(area / sqftPerTr).toStringAsFixed(0)} TR)',
        area / sqftPerTr,
        s.trr,
        area / sqftPerTr * s.trr * f / 1e5,
      ],
      [
        'Plumbing & firefighting (WTP, STP, pumps)',
        area,
        s.r4,
        area * s.r4 * f / 1e5,
      ],
      ['Elevators ($lifts)', lifts.toDouble(), s.lift * 1e5, lifts * s.lift],
      [
        'Landscaping & site development',
        max(0.0, ldPlot - ldFoot),
        s.lsr,
        max(0.0, ldPlot - ldFoot) * s.lsr / 1e5,
      ],
      ['OT fit-out (laminar flow, panels, pendants)', otTot, 0.0, otFit],
    ];
    final sub = _S(bl, (r) => _n(r[3]));
    bCont = sub * s.contp / 100;
    bCons = sub * s.consp / 100;
    bld = sub + bCont + bCons;

    // Equipment
    final cat = s.eq.map((r) {
      final basis = r[3] as String;
      final factor = _n(r[4]);
      final qty = basis == 'f'
          ? factor
          : basis == 'bed'
          ? (b * factor).ceil().toDouble()
          : basis == 'icu'
          ? (icu * factor).ceil().toDouble()
          : factor * otTot;
      return [r[0], r[1], qty, _n(r[2]), qty * _n(r[2])];
    }).toList();

    final adv = <List<dynamic>>[];
    if (serviceSelected('mri'))
      adv.add([
        'Imaging / oncology',
        b >= 200 ? s.ad[1][0] : s.ad[0][0],
        1.0,
        b >= 200 ? _n(s.ad[1][1]) : _n(s.ad[0][1]),
        b >= 200 ? _n(s.ad[1][1]) : _n(s.ad[0][1]),
      ]);
    if (serviceSelected('ct'))
      adv.add([
        'Imaging / oncology',
        b >= 150 ? s.ad[3][0] : s.ad[2][0],
        1.0,
        b >= 150 ? _n(s.ad[3][1]) : _n(s.ad[2][1]),
        b >= 150 ? _n(s.ad[3][1]) : _n(s.ad[2][1]),
      ]);
    if (serviceSelected('cath'))
      adv.add([
        'Imaging / oncology',
        s.ad[4][0],
        1.0,
        _n(s.ad[4][1]),
        _n(s.ad[4][1]),
      ]);
    if (serviceSelected('pet'))
      adv.add([
        'Imaging / oncology',
        s.ad[5][0],
        1.0,
        _n(s.ad[5][1]),
        _n(s.ad[5][1]),
      ]);
    if (serviceSelected('linac'))
      adv.add([
        'Imaging / oncology',
        s.ad[6][0],
        1.0,
        _n(s.ad[6][1]),
        _n(s.ad[6][1]),
      ]);

    final otE = OT
        .where((o) => _n(o[1]) > 0)
        .map(
          (o) => [
            'OT',
            '${o[0]} equipment',
            _n(o[1]),
            _n(o[2]),
            _n(o[1]) * _n(o[2]),
          ],
        )
        .toList();
    eqAll = [...otE, ...cat, ...adv];
    med = _S(eqAll, (r) => _n(r[4]));

    // Non-medical
    nmRows = s.nm.map((r) => [r[0], _n(r[1]) + _n(r[2]) * b]).toList();
    nmT = _S(nmRows, (r) => _n(r[1]));

    // Vehicles
    veh = s.v1 * 12 + s.v2 * 28 + s.v3 * 1.25;

    // Furniture
    double mix(int i) => _n(s.room[i][1]) * b;
    final frR = s.fr.map((r) => _n(r[1])).toList();
    fu = [
      [
        'ICU hi-lo beds',
        (mix(0) + mix(1) + mix(2)).ceil().toDouble(),
        frR[0],
        (mix(0) + mix(1) + mix(2)).ceil() * frR[0] / 1e5,
      ],
      [
        'Fowler beds',
        (mix(3) + mix(4) + mix(5)).ceil().toDouble(),
        frR[1],
        (mix(3) + mix(4) + mix(5)).ceil() * frR[1] / 1e5,
      ],
      [
        'Ward beds',
        (mix(6) + mix(7) + mix(9)).ceil().toDouble(),
        frR[2],
        (mix(6) + mix(7) + mix(9)).ceil() * frR[2] / 1e5,
      ],
      [
        'Casualty beds',
        mix(8).ceil().toDouble(),
        frR[3],
        mix(8).ceil() * frR[3] / 1e5,
      ],
      [
        'Dialysis chairs',
        mix(10).ceil().toDouble(),
        frR[4],
        mix(10).ceil() * frR[4] / 1e5,
      ],
      ['Overbed tables', b, frR[5], b * frR[5] / 1e5],
      [
        'Relatives couches',
        (b * 0.7).ceil().toDouble(),
        frR[6],
        (b * 0.7).ceil() * frR[6] / 1e5,
      ],
      [
        'Examination tables',
        (6 * sc).ceil().toDouble(),
        frR[7],
        (6 * sc).ceil() * frR[7] / 1e5,
      ],
    ];
    fBase = _S(fu, (r) => _n(r[3])) + _S(s.lump, (r) => _n(r[1]) * sc) + otFu;
    fGst = fBase * s.gst / 100;
    fCont = (fBase + fGst) * s.fcont / 100;
    furn = fBase + fGst + fCont;

    // Pre-operative
    pre =
        _n(s.pre[0][1]) +
        _n(s.pre[1][1]) +
        _n(s.pre[2][1]) +
        _n(s.pre[3][1]) * s.gest;

    // Working capital
    stock = List.generate(
      10,
      (y) => (C[y]['Ph']! + C[y]['Ot']! + C[y]['Dg']!) * s.stk / 100,
    );
    WF = C.map((c) => c['T']! * s.wfp / 100).toList();
    WC = List.generate(10, (y) => WF[y] + stock[y]);
    bB = List.generate(10, (y) => max(0.0, WC[y] - WC[0]));
    iW = bB.map((x) => x * iw).toList();

    // Totals
    total = land + bld + med + nmT + veh + furn + pre + WC[0];
    prom2 = total * s.prom / 100;
    debt = total - prom2;

    // Loan schedule
    final nq = max(1, ((s.ten - s.mor) * 4).round());
    inst = debt / nq;
    iT = List.filled(10, 0.0);
    rp = List.filled(10, 0.0);
    cl = List.filled(10, 0.0);
    Q = [];
    double bal = debt;
    for (int q = 0; q < s.ten.round() * 4; q++) {
      final y = (q / 4).floor();
      final op = bal,
          itQ = op * ir / 4,
          prQ = q >= s.mor.round() * 4 ? inst : 0.0;
      bal -= prQ;
      if (y < 10) {
        iT[y] += itQ;
        rp[y] += prQ;
        cl[y] = bal;
      }
      Q.add(['Yr ${y + 1} Q${q % 4 + 1}', op, itQ, prQ, bal]);
    }

    // Depreciation
    blk = [
      ['Medical', med, s.dMed],
      ['Non-medical', nmT, s.dNm],
      ['Vehicles', veh, s.dVeh],
      ['Building', bld, s.dBld],
      ['Furniture & fittings', furn, s.dFur],
    ];
    dp = blk.map((b2) {
      double w = _n(b2[1]);
      return List.generate(10, (_) {
        final d = w * _n(b2[2]) / 100;
        w -= d;
        return [w, d];
      });
    }).toList();
    dep = List.generate(10, (y) => _S(dp, (a) => _n(a[y][1])));

    // P&L
    eb = List.generate(10, (y) => R[y]['T']! - C[y]['T']!);
    pbit = List.generate(10, (y) => eb[y] - dep[y]);
    pbt = List.generate(10, (y) => pbit[y] - iW[y] - iT[y]);
    tx = pbt.map((v) => max(0.0, v) * s.tax / 100).toList();
    pat = List.generate(10, (y) => pbt[y] - tx[y]);
    cum = <double>[];
    for (int i = 0; i < 10; i++) cum.add((i > 0 ? cum[i - 1] : 0.0) + pat[i]);

    // Balance sheet
    gross = land + bld + med + nmT + veh + furn;
    cd = <double>[];
    for (int i = 0; i < 10; i++) cd.add((i > 0 ? cd[i - 1] : 0.0) + dep[i]);
    nfa = List.generate(10, (y) => gross - cd[y]);

    // Cash flow
    dS = List.generate(10, (y) => stock[y] - (y > 0 ? stock[y - 1] : 0.0));
    dB = List.generate(10, (y) => bB[y] - (y > 0 ? bB[y - 1] : 0.0));
    double cb = WC[0];
    cf = List.generate(10, (y) {
      final inn = dB[y] + R[y]['T']!;
      final out = C[y]['T']! + iT[y] + rp[y] + dS[y] + iW[y] + tx[y];
      final o = cb;
      cb = o + inn - out;
      return {'inn': inn, 'out': out, 'o': o, 'c': cb};
    });

    ta = List.generate(10, (y) => nfa[y] + stock[y] + cf[y]['c']! + pre);

    // DSCR
    ds = List.generate(10, (y) {
      final d = iT[y] + rp[y] + iW[y];
      return d > 0 ? (pat[y] + dep[y] + iT[y] + iW[y]) / d : double.nan;
    });
    final dsv = ds.where((v) => v.isFinite).toList();
    avgDs = dsv.isNotEmpty
        ? dsv.fold(0.0, (a, v) => a + v) / dsv.length
        : double.nan;

    // IRR
    pc = List.generate(10, (y) => eb[y] - tx[y]);
    pIrr = _irr([-total, ...pc]);
    eIrr = _irr([
      -prom2,
      ...List.generate(10, (y) => pat[y] + dep[y] - rp[y] - dS[y] + dB[y]),
    ]);

    // Payback
    double cu = -total;
    int? paybackYear;
    for (int i = 0; i < 10; i++) {
      cu += pc[i];
      if (paybackYear == null && cu >= 0) paybackYear = i + 1;
    }
    pb = paybackYear;

    // BEP
    vc = List.generate(10, (y) {
      final c = C[y];
      return c['Ph']! +
          c['Opd']! +
          c['Ot']! +
          c['Dg']! +
          c['Oth']! +
          c['Bed']! +
          c['it']! +
          c['pr']! +
          c['cont']! +
          iW[y];
    });
    fc = List.generate(10, (y) {
      final c = C[y];
      return c['Staff']! +
          c['pwr']! +
          c['rm']! +
          c['tr']! +
          c['fd']! +
          c['ins']! +
          c['mk']! +
          iT[y] +
          dep[y];
    });
    ct = List.generate(10, (y) => R[y]['T']! - vc[y]);
    bep = List.generate(10, (y) => ct[y] > 0 ? fc[y] / ct[y] : double.nan);
    cbep = List.generate(
      10,
      (y) => ct[y] > 0 ? (fc[y] - dep[y]) / ct[y] : double.nan,
    );
  }

  late final double area,
      land,
      bld,
      med,
      nmT,
      veh,
      furn,
      pre,
      total,
      prom2,
      debt,
      inst;
  late final double otTot, staffN, staffAnn, gross;
  late final double ldPlot,
      ldFoot,
      ldByGC,
      ldByFAR,
      bCont,
      bCons,
      fBase,
      fGst,
      fCont;
  late final int ldFn, ldFl;
  late final String ldGov;
  late final Map<String, double> th;
  late final List<double> U,
      iT,
      rp,
      cl,
      dep,
      eb,
      pbit,
      pbt,
      tx,
      pat,
      cum,
      cd,
      stock,
      WF,
      WC,
      bB,
      iW,
      dS,
      dB,
      ds,
      pc,
      vc,
      fc,
      ct,
      bep,
      cbep,
      nfa,
      ta;
  late final List<Map<String, double>> R, C, cf;
  late final List<List<dynamic>> bl, eqAll, nmRows, fu, st, Q;
  late final List<List<dynamic>> blk;
  late final List<List<List<double>>> dp;
  late final double avgDs, pIrr, eIrr;
  late final int? pb;

  static double _n(dynamic v) => v is num ? v.toDouble() : 0.0;

  /// Safely reads numeric values from the editable row based model tables.
  /// Kept public so presentation code can format calculated table rows without
  /// reaching into this library's private helpers.
  static double valueOf(dynamic value) => _n(value);
  static double _S<T>(List<T> a, double Function(T) f) =>
      a.fold(0.0, (s, x) => s + f(x));

  static double _irr(List<double> cashflows) {
    double npv(double m) => cashflows.asMap().entries.fold(
      0.0,
      (s, e) => s + e.value / pow(1 + m, e.key),
    );
    double lo = -0.99, hi = 10.0;
    final a = npv(lo);
    if (a * npv(hi) > 0) return double.nan;
    for (int i = 0; i < 100; i++) {
      final m = (lo + hi) / 2;
      (npv(m) > 0) == (a > 0) ? lo = m : hi = m;
    }
    return (lo + hi) / 2;
  }

  static double _sp(PlanState s, String k) => switch (k) {
    'pwr' => s.pwr / 100,
    'rm' => s.rm / 100,
    'it' => s.it / 100,
    'pr' => s.pr / 100,
    'tr' => s.tr / 100,
    'mk' => s.mk / 100,
    'fd' => s.fd / 100,
    'ins' => s.ins / 100,
    'cont' => s.cont / 100,
    _ => 0.0,
  };

  // Sensitivity: run with multipliers
  static M withSens(PlanState s, double u, double r, double c) {
    final util = List.generate(10, (i) => s.util[i] * u);
    // revenue multiplier: scale fees in opd/room/diag/otc
    final opd2 = s.opd.map((row) => [row[0], row[1], _n(row[2]) * r]).toList();
    final room2 = s.room
        .map((row) => [row[0], row[1], _n(row[2]) * r])
        .toList();
    final diag2 = s.diag
        .map((row) => [row[0], row[1], row[2], _n(row[3]) * r, _n(row[4]) * r])
        .toList();
    final otc2 = s.otc.map((row) => [row[0], row[1], _n(row[2]) * r]).toList();
    // Capex excludes land and vehicles, and scales building, equipment and furniture.
    final eq2 = s.eq
        .map((row) => [row[0], row[1], _n(row[2]) * c, row[3], row[4]])
        .toList();
    final ad2 = s.ad.map((row) => [row[0], _n(row[1]) * c]).toList();
    final nm2 = s.nm
        .map((row) => [row[0], _n(row[1]) * c, _n(row[2]) * c])
        .toList();
    final fr2 = s.fr.map((row) => [row[0], _n(row[1]) * c]).toList();
    final lump2 = s.lump.map((row) => [row[0], _n(row[1]) * c]).toList();
    final ott2 = s.ott
        .map(
          (row) => [
            row[0],
            row[1],
            _n(row[2]) * c,
            _n(row[3]) * c,
            _n(row[4]) * c,
          ],
        )
        .toList();
    final s2 = s.copyWith(
      util: util,
      opd: opd2,
      room: room2,
      diag: diag2,
      otc: otc2,
      eq: eq2,
      ad: ad2,
      nm: nm2,
      fr: fr2,
      lump: lump2,
      ott: ott2,
      r1: s.r1 * c,
      r2: s.r2 * c,
      r3: s.r3 * c,
      r4: s.r4 * c,
      trr: s.trr * c,
      lift: s.lift * c,
      lsr: s.lsr * c,
    );
    return M(s2);
  }
}
