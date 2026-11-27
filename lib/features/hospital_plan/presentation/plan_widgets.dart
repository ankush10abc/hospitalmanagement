import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Formatters ────────────────────────────────────────────────────────────────
String fL(double v, {int d = 2}) {
  if (!v.isFinite) return '–';
  final parts = v.toStringAsFixed(d).split('.');
  final intPart = parts[0].replaceFirst('-', '');
  final neg = v < 0 ? '-' : '';
  final buf = StringBuffer();
  for (int i = 0; i < intPart.length; i++) {
    final pos = intPart.length - i;
    if (i > 0 && pos % 2 == 0 && pos != intPart.length) buf.write(',');
    buf.write(intPart[i]);
  }
  return d > 0 ? '$neg$buf.${parts[1]}' : '$neg$buf';
}

String fCr(double v) => '₹${fL(v / 100)} Cr';
String fPct(double v) => v.isFinite ? '${fL(v * 100, d: 1)}%' : 'n/a';

// ── KPI card ──────────────────────────────────────────────────────────────────
class KpiCard extends StatelessWidget {
  const KpiCard({required this.label, required this.value, super.key});
  final String label, value;

  @override
  Widget build(BuildContext context) => Container(
    width: 148,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFE3F3F1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B7A75),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF5D7078)),
          maxLines: 2,
        ),
      ],
    ),
  );
}

// ── Section heading ───────────────────────────────────────────────────────────
class SecHead extends StatelessWidget {
  const SecHead(this.text, {this.apiDriven = false, super.key});
  final String text;
  final bool apiDriven;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B7A75),
            ),
          ),
        ),
        if (apiDriven) const _ApiDrivenBadge(),
      ],
    ),
  );
}

// ── API-driven badge ──────────────────────────────────────────────────────────
class _ApiDrivenBadge extends StatelessWidget {
  const _ApiDrivenBadge();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFE3F3F1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF0B7A75), width: 0.8),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.cloud_sync_outlined, size: 11, color: Color(0xFF0B7A75)),
        SizedBox(width: 3),
        Text(
          'Admin-managed',
          style: TextStyle(fontSize: 10, color: Color(0xFF0B7A75), fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

// ── Tip banner ────────────────────────────────────────────────────────────────
class TipBanner extends StatelessWidget {
  const TipBanner(this.text, {this.warn = false, super.key});
  final String text;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final c = warn ? const Color(0xFFB45309) : const Color(0xFF0B7A75);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: c, width: 4)),
      ),
      child: Text(text, style: TextStyle(fontSize: 13, color: c)),
    );
  }
}

// ── Read-only financial table ─────────────────────────────────────────────────
class FinTable extends StatelessWidget {
  const FinTable({
    required this.headers,
    required this.rows,
    this.totals,
    super.key,
  });
  final List<String> headers;
  final List<List<String>> rows;
  final List<String>? totals;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder(
          horizontalInside: BorderSide(color: Colors.grey.shade200),
        ),
        children: [
          _hdr(headers),
          ...rows.map(_row),
          if (totals != null) _totRow(totals!),
        ],
      ),
    );
  }

  TableRow _hdr(List<String> h) => TableRow(
    decoration: const BoxDecoration(color: Color(0xFFF4F7FA)),
    children: h.map((t) => _cell(t, bold: true, isHeader: true)).toList(),
  );

  TableRow _row(List<String> r) =>
      TableRow(children: r.map((t) => _cell(t)).toList());

  TableRow _totRow(List<String> r) => TableRow(
    decoration: const BoxDecoration(color: Color(0xFFE3F3F1)),
    children: r.map((t) => _cell(t, bold: true)).toList(),
  );

  Widget _cell(String t, {bool bold = false, bool isHeader = false}) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    child: Text(
      t,
      style: TextStyle(
        fontSize: 12,
        fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
        color: isHeader ? const Color(0xFF5D7078) : const Color(0xFF17262B),
      ),
    ),
  );
}

// ── Editable table cell ───────────────────────────────────────────────────────
class NumCell extends StatefulWidget {
  const NumCell({required this.value, required this.onChanged, super.key});
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<NumCell> createState() => _NumCellState();
}

class _NumCellState extends State<NumCell> {
  late TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _fmt(widget.value));
  }

  @override
  void didUpdateWidget(NumCell old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final cur = double.tryParse(_c.text);
      if (cur != widget.value) _c.text = _fmt(widget.value);
    }
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 88,
    child: TextField(
      controller: _c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
      style: const TextStyle(fontSize: 12),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        border: OutlineInputBorder(),
      ),
      onChanged: (s) {
        final v = double.tryParse(s);
        if (v != null) widget.onChanged(v);
      },
    ),
  );
}

// ── Editable table ────────────────────────────────────────────────────────────
class EditTable extends StatelessWidget {
  const EditTable({
    required this.headers,
    required this.rows,
    required this.editCols,
    required this.onChanged,
    required this.table,
    required this.onAdd,
    required this.onRemove,
    required this.onTextChanged,
    required this.textCols,
    required this.removableFrom,
    super.key,
  });
  final List<String> headers;
  final List<List<dynamic>> rows;
  final Set<int> editCols;
  final void Function(int row, int col, double val) onChanged;
  final String table;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int row, int col, String value) onTextChanged;
  final Set<int> textCols;
  final int removableFrom;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add item'),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const IntrinsicColumnWidth(),
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.shade200),
            ),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF4F7FA)),
                children: [
                  ...headers.map(
                    (h) => Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      child: Text(
                        h,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5D7078),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              ...rows.asMap().entries.map((re) {
                final i = re.key;
                final r = re.value;
                return TableRow(
                  children: [
                    ...r.asMap().entries.map((ce) {
                      final j = ce.key;
                      final v = ce.value;
                      if (editCols.contains(j) && v is num) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          child: NumCell(
                            value: v.toDouble(),
                            onChanged: (nv) => onChanged(i, j, nv),
                          ),
                        );
                      }
                      if (!textCols.contains(j)) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          child: Text(
                            v.toString(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: InkWell(
                          onTap: () async {
                            final controller = TextEditingController(
                              text: v.toString(),
                            );
                            final edited = await showDialog<String>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Edit item name'),
                                content: TextField(
                                  controller: controller,
                                  autofocus: true,
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(
                                      context,
                                      controller.text.trim(),
                                    ),
                                    child: const Text('Save'),
                                  ),
                                ],
                              ),
                            );
                            controller.dispose();
                            if (edited != null && edited.isNotEmpty)
                              onTextChanged(i, j, edited);
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  v.toString(),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.edit_outlined,
                                size: 13,
                                color: Color(0xFF5D7078),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(
                      width: 40,
                      child: i >= removableFrom
                          ? IconButton(
                              tooltip: 'Remove added item',
                              onPressed: () => onRemove(i),
                              icon: const Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Color(0xFFB3261E),
                              ),
                            )
                          : null,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Card wrapper (white card on grey bg, matching Platform.html) ─────────────
class PlanCard extends StatelessWidget {
  const PlanCard({required this.children, super.key});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFDBE4E7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

// ── Parameter input field ─────────────────────────────────────────────────────
class PField extends StatefulWidget {
  const PField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<PField> createState() => _PFieldState();
}

class _PFieldState extends State<PField> {
  late TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _fmt(widget.value));
  }

  @override
  void didUpdateWidget(PField old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      final cur = double.tryParse(_c.text);
      if (cur != widget.value) _c.text = _fmt(widget.value);
    }
  }

  String _fmt(double v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toString();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF5D7078)),
      ),
      const SizedBox(height: 3),
      SizedBox(
        width: 160,
        child: TextField(
          controller: _c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 9,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFDBE4E7)),
            ),
          ),
          onChanged: (s) {
            final v = double.tryParse(s);
            if (v != null) widget.onChanged(v);
          },
        ),
      ),
    ],
  );
}
