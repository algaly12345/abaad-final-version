import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// نموذج "اختر نوع الحساب" (فرد/منشأة) وحقول بيانات الهوية التابعة له —
/// مستخرَج من ProviderUpgradeScreen ليُعاد استخدامه أيضاً داخل SignUpScreen
/// لمن يسجّل عبر رابط إحالة (تُجمع بيانات الهوية مع التسجيل الأساسي مباشرة
/// بدل شاشة "إنشاء حساب مزود خدمة" منفصلة لاحقاً، فلا يبدو الأمر تسجيلاً
/// مزدوجاً). يقرأ/يكتب حالته من/إلى ServiceOfferController نفسه (GetX
/// lazySingleton) في الحالتين، فالبيانات المُدخلة هنا هي ذاتها التي يستهلكها
/// ServiceOfferController.saveIdentityNow() لاحقاً أياً كان مصدر النموذج.
class ProviderIdentityForm extends StatefulWidget {
  const ProviderIdentityForm({super.key});

  @override
  State<ProviderIdentityForm> createState() => _ProviderIdentityFormState();
}

class _ProviderIdentityFormState extends State<ProviderIdentityForm> {
  late final ServiceOfferController _offerController;

  static const String _freelancePrefix = 'FL-';

  @override
  void initState() {
    super.initState();
    _offerController = Get.find<ServiceOfferController>();
    // "FL-" ثابتة دومًا في الحقل من أول ظهور له — لا تنتظر أول كتابة من
    // المستخدم كي لا يبدأ من حقل فارغ فينسى الصيغة المطلوبة.
    if (!_offerController.freelanceMembershipController.text.startsWith(
      _freelancePrefix,
    )) {
      _offerController.freelanceMembershipController.text = _freelancePrefix;
    }
  }

  void _selectEntityType(String type) {
    // setEntityType() يستدعي update() الخاص بـ GetX داخلياً بالفعل، فيعيد بناء
    // GetBuilder<ServiceOfferController> من نفسه — تغليفها بـ setState() هنا
    // كان يسبب استدعاء إعادة بناء مزدوج بنفس اللحظة (GetX + Flutter) ويؤدي
    // لخطأ "setState() or markNeedsBuild() called during build".
    _offerController.setEntityType(type);
  }

  void _selectOrganizationIdType(String type) {
    _offerController.setOrganizationIdType(type);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceOfferController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IntrinsicHeight + stretch: both cards take the height of the
            // taller one, so a localized label that wraps to two lines on one
            // card doesn't leave the other card short and vertically centered.
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _EntityTypeCard(
                      label: 'individual'.tr,
                      icon: Icons.person_outline,
                      selected: controller.entityType == 'individual',
                      onTap: () => _selectEntityType('individual'),
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: _EntityTypeCard(
                      label: 'organization'.tr,
                      icon: Icons.apartment_outlined,
                      selected: controller.entityType == 'organization',
                      onTap: () => _selectEntityType('organization'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.xl),
            controller.entityType == 'individual'
                ? _buildIndividualForm(context)
                : controller.entityType == 'organization'
                ? _buildOrganizationForm(context)
                : const SizedBox(),
          ],
        );
      },
    );
  }

  Widget _buildIndividualForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, 'national_id_number'.tr),
        const SizedBox(height: Spacing.sm),
        _dsTextField(
          context,
          hintText: 'enter_id_number'.tr,
          controller: _offerController.identityNumberController,
          keyboardType: TextInputType.number,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: Spacing.xs),
        _FormatHint(
          text: _offerController.identityNumberController.text.trim(),
          regex: RegExp(r'^[12]\d{9}$'),
          hintText: 'national_id_hint'.tr,
          errorText: 'national_id_error'.tr,
          validText: 'valid_format'.tr,
        ),
        const SizedBox(height: Spacing.lg),
        _fieldLabel(context, 'freelance_document_number'.tr),
        const SizedBox(height: Spacing.sm),
        _dsTextField(
          context,
          hintText: 'freelance_document_example'.tr,
          controller: _offerController.freelanceMembershipController,
          keyboardType: TextInputType.number,
          inputFormatters: [_FixedPrefixFormatter(_freelancePrefix)],
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: Spacing.xs),
        _FormatHint(
          text: _offerController.freelanceMembershipController.text.trim(),
          regex: RegExp(r'^FL-\d+$'),
          hintText: 'freelance_document_hint'.tr,
          errorText: 'freelance_document_error'.tr,
          validText: 'valid_format'.tr,
        ),
      ],
    );
  }

  Widget _buildOrganizationForm(BuildContext context) {
    final idType = _offerController.organizationIdType;
    final isUnified = idType == 'unified';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(context, 'choose_organization_id_type'.tr),
        const SizedBox(height: Spacing.sm),
        // IntrinsicHeight + stretch: "Commercial Registration Number" wraps to
        // two lines while "Unified Number" is one — without this the two chips
        // render at different heights with the shorter one floating centered.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _IdTypeChip(
                  label: 'commercial_registration_option'.tr,
                  selected: idType == 'commercial',
                  onTap: () => _selectOrganizationIdType('commercial'),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _IdTypeChip(
                  label: 'unified_number_option'.tr,
                  selected: isUnified,
                  onTap: () => _selectOrganizationIdType('unified'),
                ),
              ),
            ],
          ),
        ),
        if (idType != null) ...[
          const SizedBox(height: Spacing.lg),
          _fieldLabel(
            context,
            isUnified
                ? 'unified_number_option'.tr
                : 'commercial_registration_option'.tr,
          ),
          const SizedBox(height: Spacing.sm),
          _dsTextField(
            context,
            hintText: isUnified
                ? 'unified_number_example'.tr
                : 'commercial_registration_example'.tr,
            controller: _offerController.commercialRegistrationController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: Spacing.xs),
          _FormatHint(
            text: _offerController.commercialRegistrationController.text.trim(),
            regex: isUnified ? RegExp(r'^70\d{8}$') : RegExp(r'^\d{10}$'),
            hintText: isUnified
                ? 'unified_number_hint'.tr
                : 'commercial_registration_hint'.tr,
            errorText: isUnified
                ? 'unified_number_error'.tr
                : 'commercial_registration_error'.tr,
            validText: 'valid_format'.tr,
          ),
        ],
      ],
    );
  }

  Widget _fieldLabel(BuildContext context, String text) {
    return Text(
      text,
      style: AppTypography.small.copyWith(
        color: AppColors.textPrimary(context),
      ),
    );
  }

  /// حقل نصي محلي بمقاييس النظام (Height 56 / Radius 12) بدل MyTextField
  /// المشترك (Radius 8) — راجع نفس الملاحظة بالمصدر الأصلي
  /// (provider_upgrade_screen.dart) قبل استخراج هذا الودجت: كل استخدامات هذا
  /// الحقل هنا أرقام/رموز إنجليزية (هوية/سجل تجاري/عضوية عمل حر)، لذا
  /// textDirection: ltr مع textAlign: right للمحاذاة البصرية مع بقية الحقول
  /// العربية رغم الكتابة الداخلية LTR.
  Widget _dsTextField(
    BuildContext context, {
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      style: AppTypography.body.copyWith(color: AppColors.textPrimary(context)),
      decoration: dsInputDecoration(context, hint: hintText),
    );
  }
}

/// يمنع حذف/تعديل بادئة ثابتة (هنا "FL-") من حقل نصي — أي محاولة كتابة لا
/// تبدأ بالبادئة (حذفها جزئيًا أو كليًا، أو لصق نص فوقها) تُعاد صياغتها
/// لتُبقيها في مكانها دومًا، مع الاحتفاظ بالأرقام فقط لما بعدها (يطابق صيغة
/// عضوية العمل الحر: FL- متبوعة بأرقام فقط).
class _FixedPrefixFormatter extends TextInputFormatter {
  final String prefix;

  const _FixedPrefixFormatter(this.prefix);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text;
    if (raw.startsWith(prefix)) {
      raw = raw.substring(prefix.length);
    }
    final digitsOnly = raw.replaceAll(RegExp(r'[^0-9]'), '');
    final text = '$prefix$digitsOnly';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _IdTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _IdTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: AnimatedContainer(
        duration: AnimSpec.button,
        padding: const EdgeInsets.symmetric(
          vertical: Spacing.md,
          horizontal: Spacing.sm,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // حالة "مختار" واضحة: تعبئة primary بشفافية 0.12 + حدّ 2px + ظل خفيف
          // + علامة ✓ بجانب النص — بدل حدّ رفيع وتعبئة شبه معدومة كان الفرق
          // فيها يكاد لا يُرى.
          color: selected
              ? primary.withValues(alpha: 0.12)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: selected ? primary : AppColors.border(context),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? AppShadows.soft(blur: 10, opacity: 0.10) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected) ...[
              Icon(Icons.check_circle, size: 14, color: primary),
              const SizedBox(width: Spacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTypography.smallMedium.copyWith(
                  color: selected ? primary : AppColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// يعرض حالة الحقل لحظياً أثناء الكتابة: تلميح محايد لو فارغ، خطأ أحمر لو
/// الصيغة غلط، أو علامة صح خضراء لو الصيغة صحيحة — بدل انتظار الضغط على متابعة.
class _FormatHint extends StatelessWidget {
  final String text;
  final RegExp regex;
  final String hintText;
  final String errorText;
  final String validText;

  const _FormatHint({
    required this.text,
    required this.regex,
    required this.hintText,
    required this.errorText,
    required this.validText,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      // رمادي أفتح من AppColors.textSecondary المستخدَم في بقية الشاشة —
      // يرسّخ أن هذا نص مساعد ثانوي لا نص محتوى أساسي.
      final dark = Theme.of(context).brightness == Brightness.dark;
      return Text(
        hintText,
        style: AppTypography.caption.copyWith(
          fontSize: 12,
          color: dark
              ? Colors.white.withValues(alpha: 0.45)
              : Colors.grey.shade500,
        ),
      );
    }

    final isValid = regex.hasMatch(text);
    final color = isValid ? AppColors.success : AppColors.danger;
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.error_outline,
          size: 14,
          color: color,
        ),
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

class _EntityTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _EntityTypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: AnimatedContainer(
        duration: AnimSpec.button,
        padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.12)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: selected ? primary : AppColors.border(context),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? AppShadows.soft(blur: 10, opacity: 0.10) : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? primary : AppColors.textSecondary(context),
              size: IconSpec.large,
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  Icon(Icons.check_circle, size: 14, color: primary),
                  const SizedBox(width: Spacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: AppTypography.smallMedium.copyWith(
                      color: selected
                          ? primary
                          : AppColors.textPrimary(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
