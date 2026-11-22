import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/plan_state.dart';
import '../domain/plan_engine.dart';
import '../domain/plan_data.dart';

class PlanNotifier extends StateNotifier<PlanState> {
  PlanNotifier() : super(PlanState());

  void setParam(String key, double v) {
    final next = _apply(state, key, v);
    state = key == 'beds' ? _clearUnavailableServices(next) : next;
  }

  void setCity(int idx) {
    final n = PD.cityNorms[idx];
    state = state.copyWith(
      cityIdx: idx,
      fsi: n[0],
      gc: n[1],
      hgt: n[2],
      lrate: n[3],
    );
  }

  void setHospitalType(String t) =>
      state = _clearUnavailableServices(state.copyWith(hospitalType: t));
  void setProjectName(String v) => state = state.copyWith(projectName: v);

  void setService(String k, bool v) {
    if (v &&
        PD.serviceRestriction(
              k,
              hospitalType: state.hospitalType,
              beds: state.beds,
            ) !=
            null) {
      return;
    }
    final s = Map<String, bool>.from(state.sel)..[k] = v;
    state = state.copyWith(sel: s);
  }

  PlanState _clearUnavailableServices(PlanState plan) {
    final selections = Map<String, bool>.from(plan.sel);
    for (final key in selections.keys) {
      if (PD.serviceRestriction(
            key,
            hospitalType: plan.hospitalType,
            beds: plan.beds,
          ) !=
          null) {
        selections[key] = false;
      }
    }
    return plan.copyWith(sel: selections);
  }

  void setUtil(int y, double v) {
    final u = List<double>.from(state.util)..[y] = v;
    state = state.copyWith(util: u);
  }

  void setCell(String table, int row, int col, double v) {
    List<List<dynamic>> copy(List<List<dynamic>> src) =>
        src.map((r) => List<dynamic>.from(r)).toList();
    switch (table) {
      case 'opd':
        final t = copy(state.opd);
        t[row][col] = v;
        state = state.copyWith(opd: t);
        return;
      case 'room':
        final t = copy(state.room);
        t[row][col] = v;
        state = state.copyWith(room: t);
        return;
      case 'diag':
        final t = copy(state.diag);
        t[row][col] = v;
        state = state.copyWith(diag: t);
        return;
      case 'otc':
        final t = copy(state.otc);
        t[row][col] = v;
        state = state.copyWith(otc: t);
        return;
      case 'staff':
        final t = copy(state.staff);
        t[row][col] = v;
        state = state.copyWith(staff: t);
        return;
      case 'eq':
        final t = copy(state.eq);
        t[row][col] = v;
        state = state.copyWith(eq: t);
        return;
      case 'ad':
        final t = copy(state.ad);
        t[row][col] = v;
        state = state.copyWith(ad: t);
        return;
      case 'nm':
        final t = copy(state.nm);
        t[row][col] = v;
        state = state.copyWith(nm: t);
        return;
      case 'fr':
        final t = copy(state.fr);
        t[row][col] = v;
        state = state.copyWith(fr: t);
        return;
      case 'lump':
        final t = copy(state.lump);
        t[row][col] = v;
        state = state.copyWith(lump: t);
        return;
      case 'pre':
        final t = copy(state.pre);
        t[row][col] = v;
        state = state.copyWith(pre: t);
        return;
      case 'ott':
        final t = copy(state.ott);
        t[row][col] = v;
        state = state.copyWith(ott: t);
        return;
      default:
        return;
    }
  }

  PlanState _apply(PlanState s, String k, double v) => switch (k) {
    'beds' => s.copyWith(beds: v),
    'icu' => s.copyWith(icu: v),
    'apb' => s.copyWith(apb: v),
    'gest' => s.copyWith(gest: v),
    'opdd' => s.copyWith(opdd: v),
    'surgd' => s.copyWith(surgd: v),
    'bedd' => s.copyWith(bedd: v),
    'fsi' => s.copyWith(fsi: v),
    'gc' => s.copyWith(gc: v),
    'hgt' => s.copyWith(hgt: v),
    'fh' => s.copyWith(fh: v),
    'lrate' => s.copyWith(lrate: v),
    'landov' => s.copyWith(landov: v),
    'prom' => s.copyWith(prom: v),
    'irc' => s.copyWith(irc: v),
    'irw' => s.copyWith(irw: v),
    'ten' => s.copyWith(ten: v),
    'mor' => s.copyWith(mor: v),
    'tax' => s.copyWith(tax: v),
    'infl' => s.copyWith(infl: v),
    'sinfl' => s.copyWith(sinfl: v),
    'dMed' => s.copyWith(dMed: v),
    'dNm' => s.copyWith(dNm: v),
    'dVeh' => s.copyWith(dVeh: v),
    'dBld' => s.copyWith(dBld: v),
    'dFur' => s.copyWith(dFur: v),
    'r1' => s.copyWith(r1: v),
    'r2' => s.copyWith(r2: v),
    'r3' => s.copyWith(r3: v),
    'r4' => s.copyWith(r4: v),
    'sqtr' => s.copyWith(sqtr: v),
    'trr' => s.copyWith(trr: v),
    'lift' => s.copyWith(lift: v),
    'lsr' => s.copyWith(lsr: v),
    'contp' => s.copyWith(contp: v),
    'consp' => s.copyWith(consp: v),
    'phin' => s.copyWith(phin: v),
    'phop' => s.copyWith(phop: v),
    'phor' => s.copyWith(phor: v),
    'cant' => s.copyWith(cant: v),
    'trips' => s.copyWith(trips: v),
    'trate' => s.copyWith(trate: v),
    'v1' => s.copyWith(v1: v),
    'v2' => s.copyWith(v2: v),
    'v3' => s.copyWith(v3: v),
    'gst' => s.copyWith(gst: v),
    'fcont' => s.copyWith(fcont: v),
    'cPh' => s.copyWith(cPh: v),
    'cOpd' => s.copyWith(cOpd: v),
    'cOt' => s.copyWith(cOt: v),
    'cDg' => s.copyWith(cDg: v),
    'cOth' => s.copyWith(cOth: v),
    'cBed' => s.copyWith(cBed: v),
    'pwr' => s.copyWith(pwr: v),
    'rm' => s.copyWith(rm: v),
    'it' => s.copyWith(it: v),
    'pr' => s.copyWith(pr: v),
    'tr' => s.copyWith(tr: v),
    'mk' => s.copyWith(mk: v),
    'fd' => s.copyWith(fd: v),
    'ins' => s.copyWith(ins: v),
    'cont' => s.copyWith(cont: v),
    'stf' => s.copyWith(stf: v),
    'wfp' => s.copyWith(wfp: v),
    'stk' => s.copyWith(stk: v),
    _ => s,
  };
}

final planProvider = StateNotifierProvider<PlanNotifier, PlanState>(
  (_) => PlanNotifier(),
);

final planResultProvider = Provider<M>((ref) => M(ref.watch(planProvider)));
