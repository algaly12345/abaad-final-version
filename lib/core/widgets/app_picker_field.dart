import 'package:abaad_flutter/core/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A unified picker field used across the entire app.
/// Tapping opens a bottom-sheet with an optional search bar.
///
/// Usage:
/// ```dart
/// AppPickerField<String>(
///   label: 'نوع المستخدم',
///   hint: 'اختر نوع المستخدم',
///   selectedValue: _type,
///   items: ['باحث عن عقار', 'مسوق عقاري'],
///   itemLabel: (v) => v,
///   onSelected: (v) => setState(() => _type = v),
/// )
/// ```
class AppPickerField<T> extends StatelessWidget {
  final String? label;
  final String hint;
  final T? selectedValue;
  final String Function(T) itemLabel;
  final List<T> items;
  final void Function(T) onSelected;
  final IconData prefixIcon;
  final bool showSearch;
  final String? searchHint;
  /// Title shown at the top of the bottom sheet (defaults to [label]).
  final String? sheetTitle;

  const AppPickerField({
    super.key,
    this.label,
    required this.hint,
    required this.selectedValue,
    required this.itemLabel,
    required this.items,
    required this.onSelected,
    this.prefixIcon = Icons.list_rounded,
    this.showSearch = false,
    this.searchHint,
    this.sheetTitle,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final hasValue = selectedValue != null;
    final displayText = hasValue ? itemLabel(selectedValue as T) : hint;

    Widget field = GestureDetector(
      onTap: () => _openSheet(context, primary),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasValue
                ? primary.withValues(alpha: 0.45)
                : const Color(0xFFE5E7EB),
            width: hasValue ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(prefixIcon,
                size: 20,
                color: hasValue ? primary : const Color(0xFF9CA3AF)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                displayText,
                style: robotoRegular.copyWith(
                  fontSize: 14,
                  color: hasValue
                      ? const Color(0xFF111827)
                      : const Color(0xFF9CA3AF),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: primary,
              size: 20,
            ),
          ],
        ),
      ),
    );

    if (label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Label(label: label!, primary: primary),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  void _openSheet(BuildContext context, Color primary) {
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet<T>(
        title: sheetTitle ?? label ?? hint,
        items: items,
        itemLabel: itemLabel,
        selectedValue: selectedValue,
        primary: primary,
        showSearch: showSearch,
        searchHint: searchHint ?? 'search'.tr,
        onSelected: (v) {
          Navigator.of(context).pop();
          onSelected(v);
        },
      ),
    );
  }
}

// ── Label ──────────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final String label;
  final Color primary;
  const _Label({required this.label, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.label_outline_rounded, size: 13, color: primary),
        const SizedBox(width: 5),
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: 13,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

// ── Bottom-sheet picker ────────────────────────────────────────────────────

class _PickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T) itemLabel;
  final T? selectedValue;
  final Color primary;
  final bool showSearch;
  final String searchHint;
  final void Function(T) onSelected;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.selectedValue,
    required this.primary,
    required this.showSearch,
    required this.searchHint,
    required this.onSelected,
  });

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  late List<T> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List.from(widget.items);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String q) {
    setState(() {
      _filtered = widget.items
          .where((e) =>
              widget.itemLabel(e).toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sheetHeight =
        widget.showSearch || widget.items.length > 5 ? 0.65 : 0.45;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * sheetHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Title
            Text(
              widget.title,
              style: robotoBold.copyWith(fontSize: 17, color: const Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 14),

            // ── Search (optional)
            if (widget.showSearch || widget.items.length > 6) ...[
              _SearchField(
                controller: _searchCtrl,
                hint: widget.searchHint,
                primary: widget.primary,
                onChanged: _onSearch,
              ),
              const SizedBox(height: 10),
            ],

            // ── Items list
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                itemBuilder: (_, i) {
                  final item = _filtered[i];
                  final label = widget.itemLabel(item);
                  final isSelected = item == widget.selectedValue;
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: isSelected
                          ? widget.primary.withValues(alpha: 0.15)
                          : const Color(0xFFF3F4F6),
                      child: isSelected
                          ? Icon(Icons.check_rounded,
                              color: widget.primary, size: 16)
                          : Text(
                              label.isNotEmpty ? label[0] : '',
                              style: TextStyle(
                                color: widget.primary.withValues(alpha: 0.7),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                    ),
                    title: Text(
                      label,
                      style: robotoMedium.copyWith(
                        fontSize: 14,
                        color: isSelected
                            ? widget.primary
                            : const Color(0xFF1F2937),
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? null
                        : const Icon(Icons.arrow_forward_ios_rounded,
                            size: 13, color: Color(0xFFAAAAAA)),
                    onTap: () => widget.onSelected(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color primary;
  final void Function(String) onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.primary,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: robotoRegular.copyWith(
              fontSize: 14, color: const Color(0xFFAAAAAA)),
          prefixIcon: Icon(Icons.search_rounded, color: primary, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }
}
