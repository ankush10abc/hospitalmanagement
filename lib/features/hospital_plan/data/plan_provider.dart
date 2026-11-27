import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/plan_state.dart';
import '../domain/plan_engine.dart';
import '../domain/plan_data.dart';

enum PlanSyncStatus { loading, saved, saving, error }

final planSyncStatusProvider = StateProvider<PlanSyncStatus>(
  (ref) => PlanSyncStatus.loading,
);

class PlanNotifier extends StateNotifier<PlanState> {
  PlanNotifier(this._ref) : super(PlanState()) {
    addListener((_) => _queueSave());
  }

  final Ref _ref;
  Timer? _saveTimer;
  bool _loaded = false;
  static final _doc = FirebaseFirestore.instance
      .collection('hospitalPlanConfigs')
      .doc('default');

  Future<void> load() async {
    try {
      final snapshot = await _doc.get();
      if (snapshot.exists && snapshot.data() != null) {
        state = PlanState.fromMap(snapshot.data()!);
      }
      _loaded = true;
      _ref.read(planSyncStatusProvider.notifier).state = PlanSyncStatus.saved;
    } catch (_) {
      _loaded = true;
      _ref.read(planSyncStatusProvider.notifier).state = PlanSyncStatus.error;
    }
  }

  Future<void> saveNow() async {
    _saveTimer?.cancel();
    if (!_loaded) _loaded = true;
    _ref.read(planSyncStatusProvider.notifier).state = PlanSyncStatus.saving;
    try {
      await _doc.set({
        ...state.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      _ref.read(planSyncStatusProvider.notifier).state = PlanSyncStatus.saved;
    } catch (_) {
      _ref.read(planSyncStatusProvider.notifier).state = PlanSyncStatus.error;
      rethrow;
    }
  }

  void _queueSave() {
    if (!_loaded) return;
    _saveTimer?.cancel();
    _ref.read(planSyncStatusProvider.notifier).state = PlanSyncStatus.saving;
    _saveTimer = Timer(const Duration(milliseconds: 700), () {
      saveNow().catchError((_) {});
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

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

  List<List<dynamic>> _table(String key) => switch (key) {
    'opd' => state.opd,
    'room' => state.room,
    'diag' => state.diag,
    'otc' => state.otc,
    'staff' => state.staff,
    'eq' => state.eq,
    'ad' => state.ad,
    'nm' => state.nm,
    'fr' => state.fr,
    'lump' => state.lump,
    'pre' => state.pre,
    'ott' => state.ott,
    _ => const [],
  };

  void addRow(String table) {
    final rows = _table(table).map((r) => List<dynamic>.from(r)).toList();
    final templates = {
      'opd': ['New specialty', 0.0, 0.0],
      'room': ['New room category', 0.0, 0.0],
      'diag': ['New diagnostic test', 0.0, 0.0, 0.0, 0.0],
      'otc': ['New case type', 0.0, 0.0],
      'staff': ['New role', 0.0, 0.0, 0.0],
      'eq': ['Other', 'New equipment', 0.0, 'f', 1.0],
      'ad': ['New advanced equipment', 0.0],
      'nm': ['New non-medical item', 0.0, 0.0],
      'fr': ['New furniture item', 0.0],
      'lump': ['New section', 0.0],
      'pre': ['New expense', 0.0],
      'ott': ['New OT type', 0.0, 0.0, 0.0, 0.0],
    };
    if (!templates.containsKey(table)) return;
    rows.add(templates[table]!);
    _replaceTable(table, rows);
  }

  void removeRow(String table, int row) {
    final rows = _table(table).map((r) => List<dynamic>.from(r)).toList();
    final defaults = {
      'opd': PD.opd.length,
      'room': PD.room.length,
      'diag': PD.diag.length,
      'otc': PD.otc.length,
      'staff': PD.staff.length,
      'eq': PD.eq.length,
      'ad': PD.ad.length,
      'nm': PD.nm.length,
      'fr': PD.fr.length,
      'lump': PD.lump.length,
      'pre': PD.pre.length,
      'ott': PD.ott.length,
    };
    if (row < (defaults[table] ?? 0) || row >= rows.length) return;
    rows.removeAt(row);
    _replaceTable(table, rows);
  }

  void setTextCell(String table, int row, int col, String value) {
    final rows = _table(table).map((r) => List<dynamic>.from(r)).toList();
    if (row < rows.length && col < rows[row].length) {
      rows[row][col] = value;
      _replaceTable(table, rows);
    }
  }

  void _replaceTable(String table, List<List<dynamic>> rows) {
    switch (table) {
      case 'opd':
        state = state.copyWith(opd: rows);
        return;
      case 'room':
        state = state.copyWith(room: rows);
        return;
      case 'diag':
        state = state.copyWith(diag: rows);
        return;
      case 'otc':
        state = state.copyWith(otc: rows);
        return;
      case 'staff':
        state = state.copyWith(staff: rows);
        return;
      case 'eq':
        state = state.copyWith(eq: rows);
        return;
      case 'ad':
        state = state.copyWith(ad: rows);
        return;
      case 'nm':
        state = state.copyWith(nm: rows);
        return;
      case 'fr':
        state = state.copyWith(fr: rows);
        return;
      case 'lump':
        state = state.copyWith(lump: rows);
        return;
      case 'pre':
        state = state.copyWith(pre: rows);
        return;
      case 'ott':
        state = state.copyWith(ott: rows);
        return;
    }
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
  (ref) => PlanNotifier(ref),
);

final planResultProvider = Provider<M>((ref) => M(ref.watch(planProvider)));
