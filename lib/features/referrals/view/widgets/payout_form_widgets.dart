import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:flutter/material.dart';

/// يُخفي وسط الآيبان عند العرض: "SA00 •••• 1234".
String maskIban(String iban) {
  if (iban.length <= 8) return iban;
  return '${iban.substring(0, 4)} •••• ${iban.substring(iban.length - 4)}';
}

/// تلميح صيغة لحظي: نص محايد رمادي لو الحقل فارغ، صح أخضر لو الصيغة صحيحة،
/// خطأ أحمر لو غير صحيحة — نفس نمط _FormatHint في ProviderIdentityForm.
class PayoutLiveHint extends StatelessWidget {
  final bool isEmpty;
  final bool isValid;
  final String neutralText;
  final String errorText;
  final String validText;

  const PayoutLiveHint({
    super.key,
    required this.isEmpty,
    required this.isValid,
    required this.neutralText,
    required this.errorText,
    required this.validText,
  });

  @override
  Widget build(BuildContext context) {
    if (isEmpty) {
      final dark = Theme.of(context).brightness == Brightness.dark;
      return Text(
        neutralText,
        style: AppTypography.caption.copyWith(
          color: dark ? Colors.white.withValues(alpha: 0.45) : Colors.grey.shade500,
        ),
      );
    }

    final color = isValid ? AppColors.success : AppColors.danger;
    return Row(
      children: [
        Icon(isValid ? Icons.check_circle : Icons.error_outline, size: 14, color: color),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Text(
            isValid ? validText : errorText,
            style: AppTypography.caption.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
