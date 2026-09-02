import 'package:abaad_flutter/shared/helpers/price_converter.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// يُخفي وسط الآيبان عند العرض: "SA00 •••• 1234".
String maskIban(String iban) {
  if (iban.length <= 8) return iban;
  return '${iban.substring(0, 4)} •••• ${iban.substring(iban.length - 4)}';
}

/// شريط تقدّم نحو الحد الأدنى للسحب + سطر حالة واحد أسفله.
///
/// ثلاث حالات صريحة بدل الرسالة المضلِّلة السابقة (التي كانت تقول "بقي X للحد
/// الأدنى" حتى عندما يكون الرصيد صفرًا لأن كل شيء مسحوب أصلًا):
///   • لا رصيد موجب        → سطر محايد "لا يوجد رصيد متاح للسحب حاليًا".
///   • رصيد موجب دون الحد   → "بقي X للوصول إلى الحد الأدنى".
///   • بلغ الحد (أو بلا حد) → "يمكنك تقديم طلب سحب".
///
/// [minimum] = 0 يعني بلا حد أدنى: يُخفى الشريط ويكتفى بسطر الحالة.
/// [showHeader] يعرض صفّ "متاح للسحب + المبلغ" أعلى الشريط — يُطفأ عندما يكون
/// المبلغ معروضًا فوق الودجت أصلًا (بطاقة الرصيد في شاشة الإحالة) منعًا للتكرار.
class WithdrawalMinimumProgress extends StatelessWidget {
  final double available;
  final double minimum;
  final bool showHeader;

  const WithdrawalMinimumProgress({
    super.key,
    required this.available,
    required this.minimum,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasMin = minimum > 0;
    final bool hasBalance = available > 0;
    final bool reached = hasBalance && (!hasMin || available >= minimum);
    final double ratio = !hasBalance
        ? 0.0
        : (!hasMin ? 1.0 : (available / minimum).clamp(0.0, 1.0));
    final double remaining =
        hasMin ? (minimum - available).clamp(0.0, double.infinity) : 0.0;
    final Color fill = reached
        ? AppColors.success
        : (hasBalance ? AppColors.primary(context) : AppColors.textSecondary(context));

    final IconData hintIcon;
    final Color hintColor;
    final String hintText;
    if (!hasBalance) {
      hintIcon = Icons.info_outline_rounded;
      hintColor = AppColors.textSecondary(context);
      hintText = 'withdrawal_no_balance_yet'.tr;
    } else if (reached) {
      hintIcon = Icons.check_circle;
      hintColor = AppColors.success;
      hintText = hasMin ? 'withdrawal_minimum_reached'.tr : 'withdrawal_ready'.tr;
    } else {
      hintIcon = Icons.savings_outlined;
      hintColor = AppColors.textSecondary(context);
      hintText = 'withdrawal_minimum_remaining'.trParams({
        'amount': PriceConverter.convertPrice(remaining, decimalDigits: 2),
        'min': PriceConverter.convertPrice(minimum, decimalDigits: 2),
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeader) ...[
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: IconSpec.small, color: fill),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  'available_for_withdrawal'.tr,
                  style: AppTypography.small
                      .copyWith(color: AppColors.textSecondary(context)),
                ),
              ),
              Text(
                PriceConverter.convertPrice(available, decimalDigits: 2),
                style: AppTypography.bodyBold.copyWith(color: fill),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
        ],
        if (hasMin) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: AppColors.divider(context),
              valueColor: AlwaysStoppedAnimation<Color>(fill),
            ),
          ),
          const SizedBox(height: Spacing.xs),
        ],
        Row(
          children: [
            Icon(hintIcon, size: 13, color: hintColor),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: Text(
                hintText,
                style: AppTypography.caption.copyWith(color: hintColor),
              ),
            ),
          ],
        ),
      ],
    );
  }
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
