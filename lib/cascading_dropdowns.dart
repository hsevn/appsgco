import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CascadingDropdowns extends StatefulWidget {
  const CascadingDropdowns({
    super.key,
    this.width,
    this.height,
    this.gap = 12,
    this.outerPadding = 0,
    this.borderRadius = 12,
    this.collection = 'location_hierarchy',
    this.l1CodeField = 'L1_CODE',
    this.l1NameField = 'L1_NAME',
    this.l2CodeField = 'L2_CODE',
    this.l2NameField = 'L2_NAME',
    this.l3CodeField = 'L3_CODE',
    this.l3NameField = 'L3_NAME',
    this.autosave = true,
    this.saveDocPath,
    this.saveL1Field = 'L1',
    this.saveL2Field = 'L2',
    this.saveL3Field = 'L3',
    this.onChanged,
  });

  final double? width;
  final double? height;
  final double gap;
  final double outerPadding;
  final double borderRadius;

  final String collection;
  final String l1CodeField;
  final String l1NameField;
  final String l2CodeField;
  final String l2NameField;
  final String l3CodeField;
  final String l3NameField;

  final bool autosave;
  final String? saveDocPath;
  final String saveL1Field;
  final String saveL2Field;
  final String saveL3Field;

  /// Callback trả về MÃ đã chọn (không trả tên)
  final void Function({String? l1Code, String? l2Code, String? l3Code})?
  onChanged;

  @override
  State<CascadingDropdowns> createState() => _CascadingDropdownsState();
}

class _CascadingDropdownsState extends State<CascadingDropdowns> {
  String? _l1;
  String? _l2;
  String? _l3;

  Future<void> _saveIfNeeded() async {
    if (!widget.autosave) return;
    final path = widget.saveDocPath;
    if (path == null || path.trim().isEmpty) return;
    await FirebaseFirestore.instance.doc(path).set({
      widget.saveL1Field: _l1,
      widget.saveL2Field: _l2,
      widget.saveL3Field: _l3,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          padding: EdgeInsets.all(widget.outerPadding),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(widget.collection)
                .snapshots(),
            builder: (context, snap) {
              if (snap.hasError) {
                return Text('Lỗi tải dữ liệu: ${snap.error}');
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snap.data!.docs;

              // L1 unique theo L1_CODE
              final l1Pairs = _uniquePairs(
                docs,
                codeField: widget.l1CodeField,
                nameField: widget.l1NameField,
              );
              // L2 lọc theo L1
              final l2Pairs = _uniquePairs(
                docs.where((d) {
                  final m = d.data();
                  return _l1 == null ? true : m[widget.l1CodeField] == _l1;
                }),
                codeField: widget.l2CodeField,
                nameField: widget.l2NameField,
              );
              // L3 lọc theo L1 + L2
              final l3Pairs = _uniquePairs(
                docs.where((d) {
                  final m = d.data();
                  final okL1 =
                  _l1 == null ? true : m[widget.l1CodeField] == _l1;
                  final okL2 =
                  _l2 == null ? true : m[widget.l2CodeField] == _l2;
                  return okL1 && okL2;
                }),
                codeField: widget.l3CodeField,
                nameField: widget.l3NameField,
              );

              // Giữ hợp lệ sau khi lọc
              if (_l1 != null && !l1Pairs.any((e) => e.key == _l1)) _l1 = null;
              if (_l2 != null && !l2Pairs.any((e) => e.key == _l2)) _l2 = null;
              if (_l3 != null && !l3Pairs.any((e) => e.key == _l3)) _l3 = null;

              final r = BorderRadius.circular(widget.borderRadius);

              final l1Widget = _dropdown(
                hint: '1._ Khu vực chung trong nhà',
                value: _l1,
                items: l1Pairs,
                borderRadius: r,
                enabled: true,
                onChanged: (v) async {
                  setState(() {
                    _l1 = v;
                    _l2 = null;
                    _l3 = null;
                  });
                  widget.onChanged?.call(l1Code: _l1, l2Code: _l2, l3Code: _l3);
                  await _saveIfNeeded();
                },
              );
              final l2Widget = _dropdown(
                hint: '2._ Chọn nhóm (L2)',
                value: _l2,
                items: l2Pairs,
                borderRadius: r,
                enabled: _l1 != null,
                onChanged: (v) async {
                  setState(() {
                    _l2 = v;
                    _l3 = null;
                  });
                  widget.onChanged?.call(l1Code: _l1, l2Code: _l2, l3Code: _l3);
                  await _saveIfNeeded();
                },
              );
              final l3Widget = _dropdown(
                hint: '3._ Chọn mục (L3)',
                value: _l3,
                items: l3Pairs,
                borderRadius: r,
                enabled: _l1 != null && _l2 != null,
                onChanged: (v) async {
                  setState(() {
                    _l3 = v;
                  });
                  widget.onChanged?.call(l1Code: _l1, l2Code: _l2, l3Code: _l3);
                  await _saveIfNeeded();
                },
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  l1Widget,
                  SizedBox(height: widget.gap),
                  l2Widget,
                  SizedBox(height: widget.gap),
                  l3Widget,
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Tạo list (code, name) duy nhất, bỏ rỗng và bỏ chữ "string".
  List<MapEntry<String, String>> _uniquePairs(
      Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
        required String codeField,
        required String nameField,
      }) {
    final map = <String, String>{};
    for (final d in docs) {
      final m = d.data();
      var code = (m[codeField]?.toString() ?? '').trim();
      var name = (m[nameField]?.toString() ?? '').trim();
      if (code.isEmpty) continue;
      if (code.toLowerCase() == 'string') continue;
      if (name.toLowerCase() == 'string') name = '';
      if (name.isEmpty) name = code;
      map.putIfAbsent(code, () => name);
    }
    final list = map.entries.toList();
    list.sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    return list;
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<MapEntry<String, String>> items,
    required BorderRadius borderRadius,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    if (items.isEmpty) {
      return TextFormField(
        enabled: false,
        decoration: InputDecoration(
          isDense: true,
          hintText: '$hint (không có dữ liệu)',
          border: OutlineInputBorder(borderRadius: borderRadius),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      value: (value == null || value.isEmpty) ? null : value,
      isExpanded: true,
      items: items
          .map(
            (e) => DropdownMenuItem<String>(
          value: e.key, // LƯU MÃ
          child: Text(
            e.value, // HIỂN THỊ TÊN
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          .toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: borderRadius),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
      selectedItemBuilder: (_) => items
          .map(
            (e) => Align(
          alignment: Alignment.centerLeft,
          child: Text(
            e.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          .toList(),
    );
  }
}
