import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:flutter/material.dart';

/// Unified dropdown widget used consistently across the entire app.
/// Wraps [DropdownButton] with the app's design system styling.
class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;
  final IconData? leadingIcon;
  final bool enabled;

  const AppDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.hintText,
    this.leadingIcon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final hasValue = value != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        right: leadingIcon != null ? 10 : 14,
        left: 6,
        top: 2,
        bottom: 2,
      ),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFF8FAFC) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasValue
              ? primary.withValues(alpha: 0.35)
              : Colors.grey.withValues(alpha: 0.22),
          width: hasValue ? 1.2 : 1,
        ),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 4, left: 8),
              child: Icon(
                leadingIcon,
                size: 17,
                color: hasValue ? primary : Colors.grey.shade400,
              ),
            ),
          ],
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                hint: hintText != null
                    ? Text(
                        hintText!,
                        style: robotoRegular.copyWith(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                items: items,
                onChanged: enabled ? onChanged : null,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(14),
                menuMaxHeight: 320,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: hasValue ? primary : Colors.grey.shade400,
                  size: 22,
                ),
                style: robotoMedium.copyWith(
                  fontSize: 13,
                  color: const Color(0xFF1A2340),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
