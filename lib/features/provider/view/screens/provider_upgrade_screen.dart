import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/gradient_module_app_bar.dart';
import 'package:abaad_flutter/shared/widgets/my_text_field.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// خطوة "صير مزود خدمة" السابقة لمعالج إنشاء أول عرض
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

  @override
  void initState() {
    super.initState();
    _offerController = Get.find<ServiceOfferController>();
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
          appBar: GradientModuleAppBar(title: 'become_provider_title'.tr),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'choose_account_type'.tr,
                    style: robotoBold.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'provider_upgrade_subtitle'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      const SizedBox(width: 12),
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
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: controller.entityType == 'individual'
                          ? _buildIndividualForm()
                          : controller.entityType == 'organization'
                          ? _buildOrganizationForm()
                          : const SizedBox(),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canContinue ? _continue : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text('continue_label'.tr),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIndividualForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('national_id_number'.tr, style: robotoMedium.copyWith(fontSize: 13)),
        const SizedBox(height: 8),
        MyTextField(
          hintText: 'enter_id_number'.tr,
          controller: _offerController.identityNumberController,
          inputType: TextInputType.number,
          onChanged: (_) => setState(() {}),
          showBorder: true,
        ),
        const SizedBox(height: 4),
        _FormatHint(
          text: _offerController.identityNumberController.text.trim(),
          regex: RegExp(r'^[12]\d{9}$'),
          hintText: 'national_id_hint'.tr,
          errorText: 'national_id_error'.tr,
          validText: 'valid_format'.tr,
        ),
        const SizedBox(height: 16),
        Text(
          'freelance_document_number'.tr,
          style: robotoMedium.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        MyTextField(
          hintText: 'freelance_document_example'.tr,
          controller: _offerController.freelanceMembershipController,
          onChanged: (_) => setState(() {}),
          showBorder: true,
        ),
        const SizedBox(height: 4),
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
        Text(
          'choose_organization_id_type'.tr,
          style: robotoMedium.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _IdTypeChip(
                label: 'commercial_registration_option'.tr,
                selected: idType == 'commercial',
                onTap: () => _selectOrganizationIdType('commercial'),
              ),
            ),
            const SizedBox(width: 10),
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
          const SizedBox(height: 16),
          Text(
            isUnified
                ? 'unified_number_option'.tr
                : 'commercial_registration_option'.tr,
            style: robotoMedium.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 8),
          MyTextField(
            hintText: isUnified
                ? 'unified_number_example'.tr
                : 'commercial_registration_example'.tr,
            controller: _offerController.commercialRegistrationController,
            inputType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            showBorder: true,
          ),
          const SizedBox(height: 4),
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? primary : Colors.black12,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: robotoMedium.copyWith(
            fontSize: 12.5,
            color: selected ? primary : Colors.black87,
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
      return Text(
        hintText,
        style: robotoRegular.copyWith(fontSize: 11, color: Colors.black45),
      );
    }

    final isValid = regex.hasMatch(text);
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.error_outline,
          size: 14,
          color: isValid ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            isValid ? validText : errorText,
            style: robotoRegular.copyWith(
              fontSize: 11,
              color: isValid ? Colors.green : Colors.red,
            ),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : Colors.black12,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? primary : Colors.black54, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: robotoMedium.copyWith(
                fontSize: 14,
                color: selected ? primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
