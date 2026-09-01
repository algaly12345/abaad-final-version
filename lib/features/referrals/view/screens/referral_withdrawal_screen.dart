import 'package:abaad_flutter/features/referrals/controller/referral_controller.dart';
import 'package:abaad_flutter/features/referrals/data/models/referral_model.dart';
import 'package:abaad_flutter/features/referrals/view/screens/referral_payout_method_screen.dart';
import 'package:abaad_flutter/features/referrals/view/widgets/payout_form_widgets.dart';
import 'package:abaad_flutter/shared/helpers/price_converter.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// شاشة طلب سحب عمولات الإحالة — المبلغ فقط. بيانات الحساب البنكي تُدار في شاشة
/// مستقلة (ReferralPayoutMethodScreen)؛ هنا نكتفي بعرض ملخّص الحساب المحفوظ
/// وزرّ تعديله، ونمنع الإرسال إن لم يكن هناك حساب محفوظ بعد.
class ReferralWithdrawalScreen extends StatefulWidget {
  final double availableBalance;
  const ReferralWithdrawalScreen({super.key, required this.availableBalance});

  @override
  State<ReferralWithdrawalScreen> createState() => _ReferralWithdrawalScreenState();
}

class _ReferralWithdrawalScreenState extends State<ReferralWithdrawalScreen> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ─── حالة حقل المبلغ لحظياً (لتلميح الصيغة والتحقق قبل الإرسال) ────────────
  double? get _amount => double.tryParse(_amountController.text.trim());
  bool get _amountValid => _amount != null && _amount! > 0 && _amount! <= widget.availableBalance;
  bool get _amountExceeds => _amount != null && _amount! > widget.availableBalance;

  Future<void> _submit() async {
    final ReferralController controller = Get.find<ReferralController>();

    if (_amount == null || _amount! <= 0) {
      showCustomSnackBar('input_field_is_empty'.tr);
      return;
    }
    if (_amountExceeds) {
      showCustomSnackBar('amount_exceeds_available_balance'.tr);
      return;
    }

    final PayoutMethodModel? payout = controller.payoutMethod;
    if (payout == null) {
      showCustomSnackBar('payout_account_required'.tr);
      return;
    }

    final bool success = await controller.requestWithdrawal(
      amount: _amount!,
      accountHolderName: payout.accountHolderName,
      iban: payout.iban,
      bankName: payout.bankName,
      nationalId: payout.nationalId,
    );
    if (success) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _balanceStrip(context),
                    const SizedBox(height: Spacing.lg),

                    _fieldLabel(context, 'withdrawal_amount'.tr),
                    const SizedBox(height: Spacing.xs),
                    _dsField(
                      context,
                      controller: _amountController,
                      hint: 'enter_amount'.tr,
                      ltr: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    ),
                    const SizedBox(height: Spacing.xs),
                    PayoutLiveHint(
                      isEmpty: _amountController.text.trim().isEmpty,
                      isValid: _amountValid,
                      neutralText: 'withdrawal_amount_hint'.tr,
                      errorText: 'amount_exceeds_available_balance'.tr,
                      validText: 'valid_format'.tr,
                    ),
                    const SizedBox(height: Spacing.xl),

                    _sectionTitle(
                      context,
                      icon: Icons.account_balance_outlined,
                      title: 'payout_account'.tr,
                      subtitle: 'payout_account_subtitle'.tr,
                    ),
                    const SizedBox(height: Spacing.md),
                    _savedAccountCard(context),
                  ],
                ),
              ),
            ),
            _footer(context),
          ],
        ),
      ),
    );
  }

  // ─── الشريط العلوي: مسطّح + زرّ رجوع دائري بحدّ (نفس my_services_screen) ────
  Widget _topBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(bottom: BorderSide(color: AppColors.divider(context))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider(context)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppColors.primary(context)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'request_withdrawal'.tr,
              style: robotoBold.copyWith(fontSize: 17, color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── شريط الرصيد المتاح (سطر واحد مضغوط) ─────────────────────────────────
  Widget _balanceStrip(BuildContext context) {
    final primary = AppColors.primary(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm + 2),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_outlined, color: primary, size: IconSpec.small),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              'available_for_withdrawal'.tr,
              style: AppTypography.small.copyWith(color: AppColors.textSecondary(context)),
            ),
          ),
          Text(
            PriceConverter.convertPrice(widget.availableBalance, decimalDigits: 2),
            style: AppTypography.bodyBold.copyWith(color: primary),
          ),
        ],
      ),
    );
  }

  // ─── عنوان قسم بأيقونة داخل شارة مصبوغة ─────────────────────────────────
  Widget _sectionTitle(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Icon(icon, size: 14, color: AppColors.primary(context)),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.smallBold
                    .copyWith(fontSize: 15.5, color: AppColors.textPrimary(context)),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─── ملخّص الحساب البنكي المحفوظ + زرّ تعديله/إضافته ────────────────────
  Widget _savedAccountCard(BuildContext context) {
    return GetBuilder<ReferralController>(
      builder: (controller) {
        final PayoutMethodModel? m = controller.payoutMethod;
        return Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: AppColors.divider(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: m == null
                    ? Text(
                        'payout_account_not_set'.tr,
                        style: AppTypography.small.copyWith(color: AppColors.warning),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.accountHolderName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.smallBold
                                .copyWith(color: AppColors.textPrimary(context)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${m.bankName} · ${maskIban(m.iban)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary(context)),
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: Spacing.sm),
              TextButton(
                onPressed: () => Get.to(() => const ReferralPayoutMethodScreen()),
                child: Text(
                  m == null ? 'add_payout_account'.tr : 'edit_payout_account'.tr,
                  style: AppTypography.smallBold.copyWith(color: AppColors.primary(context)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    return Text(
      text,
      style: AppTypography.small.copyWith(color: AppColors.textPrimary(context)),
    );
  }

  /// حقل نصي بمقاييس النظام (Height 56 / Radius 12) عبر dsInputDecoration.
  Widget _dsField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    bool ltr = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      inputFormatters: formatters,
      textDirection: ltr ? TextDirection.ltr : null,
      textAlign: ltr ? TextAlign.right : TextAlign.start,
      style: AppTypography.body.copyWith(color: AppColors.textPrimary(context)),
      cursorColor: AppColors.primary(context),
      decoration: dsInputDecoration(context, hint: hint),
    );
  }

  // ─── التذييل الثابت: زرّ أساسي بعرض كامل فوق الكيبورد ───────────────────
  Widget _footer(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(top: BorderSide(color: AppColors.divider(context))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.md),
          child: GetBuilder<ReferralController>(
            builder: (controller) => DSPrimaryButton(
              label: 'request_withdrawal'.tr,
              loading: controller.isRequestingWithdrawal,
              onPressed: _submit,
            ),
          ),
        ),
      ),
    );
  }
}
