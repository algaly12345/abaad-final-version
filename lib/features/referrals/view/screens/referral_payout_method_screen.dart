import 'package:abaad_flutter/features/referrals/controller/referral_controller.dart';
import 'package:abaad_flutter/features/referrals/data/models/referral_model.dart';
import 'package:abaad_flutter/features/referrals/view/widgets/payout_form_widgets.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// شاشة إدارة حساب الإيداع البنكي لعمولات الإحالة — تحفظ/تحدّث صفًّا واحدًا لكل
/// مزوّد عبر POST /api/v1/referrals/payout-method. مستقلة عن ورقة طلب السحب:
/// المزوّد يضبط حسابه هنا مرّة واحدة، وورقة السحب تكتفي بالمبلغ.
class ReferralPayoutMethodScreen extends StatefulWidget {
  const ReferralPayoutMethodScreen({super.key});

  @override
  State<ReferralPayoutMethodScreen> createState() => _ReferralPayoutMethodScreenState();
}

class _ReferralPayoutMethodScreenState extends State<ReferralPayoutMethodScreen> {
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تعبئة مسبقة من الحساب المحفوظ إن وُجد (نفس مصدر تعبئة ورقة السحب سابقًا).
    final PayoutMethodModel? saved = Get.find<ReferralController>().payoutMethod;
    if (saved != null) {
      _holderNameController.text = saved.accountHolderName;
      // الحقل يعرض الأرقام فقط بعد بادئة SA الثابتة — نزيل أي أحرف من القيمة المحفوظة.
      _ibanController.text = saved.iban.replaceAll(RegExp(r'[^0-9]'), '');
      _bankNameController.text = saved.bankName;
      _nationalIdController.text = saved.nationalId;
    }
    for (final c in [
      _holderNameController,
      _ibanController,
      _bankNameController,
      _nationalIdController,
    ]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _holderNameController.dispose();
    _ibanController.dispose();
    _bankNameController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  // ─── حالة الحقول لحظياً (لتلميحات الصيغة والتحقق قبل الحفظ) ───────────────
  // العميل يُدخل الأرقام فقط؛ بادئة "SA" ثابتة في الواجهة وتُضاف قبل الإرسال.
  String get _ibanDigits => _ibanController.text.trim();
  String get _fullIban => 'SA$_ibanDigits';
  bool get _ibanValid => RegExp(r'^\d{22}$').hasMatch(_ibanDigits);

  String get _nationalId => _nationalIdController.text.trim();
  bool get _nationalIdValid => RegExp(r'^\d{10}$').hasMatch(_nationalId);

  Future<void> _save() async {
    final ReferralController controller = Get.find<ReferralController>();
    final String holderName = _holderNameController.text.trim();
    final String bankName = _bankNameController.text.trim();

    if (holderName.isEmpty || _ibanDigits.isEmpty || bankName.isEmpty || _nationalId.isEmpty) {
      showCustomSnackBar('payout_details_required'.tr);
      return;
    }
    if (!_ibanValid) {
      showCustomSnackBar('invalid_iban'.tr);
      return;
    }
    if (!_nationalIdValid) {
      showCustomSnackBar('invalid_national_id'.tr);
      return;
    }

    final bool success = await controller.savePayoutMethod(
      accountHolderName: holderName,
      iban: _fullIban,
      bankName: bankName,
      nationalId: _nationalId,
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
                padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _intro(context),
                    const SizedBox(height: Spacing.lg),

                    _fieldLabel(context, 'account_holder_name'.tr),
                    const SizedBox(height: Spacing.xs),
                    _dsField(
                      context,
                      controller: _holderNameController,
                      hint: 'enter_account_holder_name'.tr,
                    ),
                    const SizedBox(height: Spacing.md),

                    _fieldLabel(context, 'iban'.tr),
                    const SizedBox(height: Spacing.xs),
                    _dsField(
                      context,
                      controller: _ibanController,
                      hint: '0000000000000000000000',
                      ltr: true,
                      keyboardType: TextInputType.number,
                      prefixText: 'SA ',
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(22),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    PayoutLiveHint(
                      isEmpty: _ibanDigits.isEmpty,
                      isValid: _ibanValid,
                      neutralText: 'iban_digits_hint'.tr,
                      errorText: 'invalid_iban'.tr,
                      validText: 'valid_format'.tr,
                    ),
                    const SizedBox(height: Spacing.md),

                    _fieldLabel(context, 'bank_name'.tr),
                    const SizedBox(height: Spacing.xs),
                    _dsField(
                      context,
                      controller: _bankNameController,
                      hint: 'enter_bank_name'.tr,
                    ),
                    const SizedBox(height: Spacing.md),

                    _fieldLabel(context, 'national_id_iqama'.tr),
                    const SizedBox(height: Spacing.xs),
                    _dsField(
                      context,
                      controller: _nationalIdController,
                      hint: 'national_id_iqama_hint'.tr,
                      ltr: true,
                      keyboardType: TextInputType.number,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    PayoutLiveHint(
                      isEmpty: _nationalId.isEmpty,
                      isValid: _nationalIdValid,
                      neutralText: 'national_id_iqama_hint'.tr,
                      errorText: 'invalid_national_id'.tr,
                      validText: 'valid_format'.tr,
                    ),
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

  // ─── شريط علوي مسطّح بزرّ رجوع دائري — نفس نمط ReferralScreen ─────────────
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
              'payout_account'.tr,
              style: robotoBold.copyWith(fontSize: 17, color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _intro(BuildContext context) {
    final primary = AppColors.primary(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: IconSpec.small, color: primary),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              'payout_account_subtitle'.tr,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String text) => Text(
        text,
        style: AppTypography.small.copyWith(color: AppColors.textPrimary(context)),
      );

  /// حقل نصي بمقاييس النظام (Height 56 / Radius 12) عبر dsInputDecoration.
  /// عند تمرير [prefixText] تظهر بادئة ثابتة (مثل "SA ") على يسار الحقل ويُغلف
  /// الحقل باتجاه LTR كي تبقى البادئة قبل ما يكتبه المستخدم.
  Widget _dsField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    bool ltr = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    String? prefixText,
  }) {
    final Widget field = TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      inputFormatters: formatters,
      textDirection: ltr ? TextDirection.ltr : null,
      textAlign: prefixText != null
          ? TextAlign.left
          : (ltr ? TextAlign.right : TextAlign.start),
      style: AppTypography.body.copyWith(color: AppColors.textPrimary(context)),
      cursorColor: AppColors.primary(context),
      decoration: prefixText == null
          ? dsInputDecoration(context, hint: hint)
          : dsInputDecoration(context, hint: hint).copyWith(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 6),
                child: Text(
                  prefixText,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            ),
    );

    if (prefixText == null) return field;
    return Directionality(textDirection: TextDirection.ltr, child: field);
  }

  // ─── تذييل ثابت: زر حفظ بعرض كامل (DSPrimaryButton) ──────────────────────
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
              label: 'save_payout_account'.tr,
              loading: controller.isSavingPayoutMethod,
              onPressed: _save,
            ),
          ),
        ),
      ),
    );
  }
}
