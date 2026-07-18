import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// ارتفاع/نصف قطر زرّ الرجوع الدائري — مطابقان حرفيًا لثوابت الشريط العلوي في
// صفحة قائمة الخدمات (services_catalog_screen.dart: _topBarHeight/_BackHomeButton)
// كي يتطابق الشكل تمامًا رغم أن هذه الشاشة لا يمكنها استيراد ذلك الودجت
// الخاص (private) من الملف الآخر مباشرة.
const double _topBarButtonSize = 48;

/// خطوة "إنشاء حساب مزود خدمة" السابقة لمعالج إنشاء أول عرض
/// (AddPropertyServiceOfferScreen). تجمع نوع الحساب (فرد/منشأة) وبيانات
/// التحقق المطلوبة قبل المتابعة لإنشاء العرض نفسه:
/// - فرد: رقم الهوية الوطنية + رقم عضوية العمل الحر (بدون توثيق نفاذ في هذه
///   الشاشة — يتحقق الأدمن من البيانات لاحقاً).
/// - منشأة: رقم السجل التجاري أو الرقم الموحد فقط.
class ProviderUpgradeScreen extends StatefulWidget {
  const ProviderUpgradeScreen({super.key});

  @override
  State<ProviderUpgradeScreen> createState() => _ProviderUpgradeScreenState();
}

class _ProviderUpgradeScreenState extends State<ProviderUpgradeScreen> {
  late final ServiceOfferController _offerController;

  static const String _freelancePrefix = 'FL-';

  @override
  void initState() {
    super.initState();
    _offerController = Get.find<ServiceOfferController>();
    // "FL-" ثابتة دومًا في الحقل من أول ظهور له — لا تنتظر أول كتابة من
    // المستخدم كي لا يبدأ من حقل فارغ فينسى الصيغة المطلوبة.
    if (!_offerController.freelanceMembershipController.text
        .startsWith(_freelancePrefix)) {
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

  void _continue() {
    Get.toNamed(RouteHelper.getAddServiceOfferRoute());
  }

  bool get _canContinue {
    final type = _offerController.entityType;
    if (type == 'individual') {
      return RegExp(
            r'^[12]\d{9}$',
          ).hasMatch(_offerController.identityNumberController.text.trim()) &&
          RegExp(r'^FL-\d+$').hasMatch(
            _offerController.freelanceMembershipController.text.trim(),
          );
    }
    if (type == 'organization') {
      final idType = _offerController.organizationIdType;
      if (idType == null) return false;
      final regex =
          idType == 'unified' ? RegExp(r'^70\d{8}$') : RegExp(r'^\d{10}$');
      return regex.hasMatch(
        _offerController.commercialRegistrationController.text.trim(),
      );
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return const NotLoggedInScreen();
    }

    return GetBuilder<ServiceOfferController>(
      builder: (controller) {
        return Scaffold(
          // لا Scaffold.appBar هنا: الشريط العلوي جزء من body مباشرة، بنفس
          // بنية صفحة قائمة الخدمات (_buildTopBar) بدل AppBar/PreferredSizeWidget
          // منفصل — Column + Expanded(ScrollView) + زرّ سفلي مثبّت خارج
          // التمرير داخل SafeArea خاصة به (_buildBottomBar).
          body: Column(
            children: [
              _buildTopBar(context),
              Expanded(child: _buildScrollableContent(context, controller)),
              _buildBottomBar(),
            ],
          ),
        );
      },
    );
  }

  // ─── شريط علوي مطابق حرفيًا لتصميم صفحة قائمة الخدمات: خلفية cardColor
  // مسطّحة بلا تدرّج/ظل، زرّ رجوع دائري بحدّ رمادي وأيقونة primary — إضافة
  // عنوان في المنتصف (غير موجود بالمرجع أصلاً) لأن هذه شاشة نموذج تحتاج
  // عنوانًا واضحًا خلافًا لشريط بحث/فلاتر قائمة الخدمات.
  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface(context),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _TopBarBackButton(onTap: () => Get.back()),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'become_provider_title'.tr,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.smallBold.copyWith(
                  fontSize: 17,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            // موازن بصري بعرض زرّ الرجوع نفسه كي يبقى العنوان في المنتصف
            // الحقيقي للصفّ، بدل الانزياح نحو الطرف المقابل للزرّ.
            const SizedBox(width: _topBarButtonSize),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(
      BuildContext context, ServiceOfferController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'choose_account_type'.tr,
            style: AppTypography.title.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'provider_upgrade_subtitle'.tr,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Row(
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
          const SizedBox(height: Spacing.xl),
          controller.entityType == 'individual'
              ? _buildIndividualForm()
              : controller.entityType == 'organization'
                  ? _buildOrganizationForm()
                  : const SizedBox(),
        ],
      ),
    );
  }

  // ─── زرّ "متابعة" مثبّت أسفل الشاشة خارج منطقة التمرير — حالته/لونه (فعّال
  // بلون primary أو معطّل بشفافية أقل) مربوطان مباشرة بـ _canContinue عبر
  // onPressed، دون أي منطق إضافي هنا.
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: AppShadows.soft(blur: 16, opacity: 0.06),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          child: DSPrimaryButton(
            label: 'continue_label'.tr,
            onPressed: _canContinue ? _continue : null,
          ),
        ),
      ),
    );
  }

  Widget _buildIndividualForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('national_id_number'.tr),
        const SizedBox(height: Spacing.sm),
        _dsTextField(
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
        _fieldLabel('freelance_document_number'.tr),
        const SizedBox(height: Spacing.sm),
        _dsTextField(
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

  void _selectOrganizationIdType(String type) {
    // نفس ملاحظة _selectEntityType: setOrganizationIdType() تستدعي update()
    // الخاص بـ GetX داخلياً، فلا تُغلَّف بـ setState() هنا إطلاقاً.
    _offerController.setOrganizationIdType(type);
  }

  Widget _buildOrganizationForm() {
    final idType = _offerController.organizationIdType;
    final isUnified = idType == 'unified';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('choose_organization_id_type'.tr),
        const SizedBox(height: Spacing.sm),
        Row(
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
        if (idType != null) ...[
          const SizedBox(height: Spacing.lg),
          _fieldLabel(
            isUnified
                ? 'unified_number_option'.tr
                : 'commercial_registration_option'.tr,
          ),
          const SizedBox(height: Spacing.sm),
          _dsTextField(
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

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppTypography.small.copyWith(color: AppColors.textPrimary(context)),
    );
  }

  /// حقل نصي محلي بمقاييس النظام (Height 56 / Radius 12) بدل MyTextField
  /// المشترك (Radius 8) — يبقى استبداله محصوراً بهذه الشاشة فقط دون التأثير
  /// على بقية شاشات التطبيق التي تستخدم MyTextField الأصلي. كل استخدامات هذا
  /// الحقل بالشاشة أرقام/رموز إنجليزية (هوية/سجل تجاري/عضوية عمل حر مثل
  /// FL-240629681):
  /// - textDirection: ltr كي يكتب المستخدم الأرقام/الحروف الإنجليزية بتدفّق
  ///   طبيعي دون أن يقفز المؤشر يمينًا مع كل رقم جديد.
  /// - textAlign: right كي يبقى النص (والتلميح المبني عليه داخل
  ///   InputDecorator، فهو يتبع نفس textAlign) محاذيًا للحافة اليمنى بصريًا،
  ///   مطابقًا لبقية الحقول العربية في الشاشة بدل الانزلاق يسارًا فقط لأن
  ///   الكتابة الداخلية LTR.
  /// التسمية أعلى الحقل (_fieldLabel) والتلميح التحقّقي أسفله (_FormatHint)
  /// عنصران منفصلان خارج هذا الحقل فيبقيان RTL دون أي تأثّر بهذا الضبط.
  Widget _dsTextField({
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

/// زرّ رجوع دائري — نسخة طبق الأصل من _BackHomeButton في
/// services_catalog_screen.dart (حدّ رمادي رفيع، أيقونة primary، 48×48)، معاد
/// تعريفها محليًا لأن الأصل ودجت خاص (private) بذلك الملف ولا يمكن استيرادها.
class _TopBarBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TopBarBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_topBarButtonSize / 2),
      child: Container(
        width: _topBarButtonSize,
        height: _topBarButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Theme.of(context).primaryColor),
      ),
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
            vertical: Spacing.md, horizontal: Spacing.sm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // تعبئة أساسية شفافة جدًا (0.05) عند التحديد + حدّ primary، بدل
          // حدّ ملوّن فقط بلا خلفية — تمييز بصري أوضح للحالة المختارة.
          color: selected ? primary.withValues(alpha: 0.05) : AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: selected ? primary : AppColors.border(context),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.smallMedium.copyWith(
            color: selected ? primary : AppColors.textPrimary(context),
          ),
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
          color: dark ? Colors.white.withValues(alpha: 0.45) : Colors.grey.shade500,
        ),
      );
    }

    final isValid = regex.hasMatch(text);
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
          color: selected ? primary.withValues(alpha: 0.05) : AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
            color: selected ? primary : AppColors.border(context),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? primary : AppColors.textSecondary(context),
                size: IconSpec.large),
            const SizedBox(height: Spacing.sm),
            Text(
              label,
              style: AppTypography.smallMedium.copyWith(
                color: selected ? primary : AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
