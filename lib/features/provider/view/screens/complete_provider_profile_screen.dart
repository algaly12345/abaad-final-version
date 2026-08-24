import 'dart:io';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/profile/data/models/userinfo_model.dart';
import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/features/provider/view/screens/add_property_service_offer_screen.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:abaad_flutter/shared/widgets/root_fallback_scope.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// نفس مقاييس زرّ الرجوع الدائري بشاشة provider_upgrade_screen.dart كي يتطابق
// الشكل حرفيًا رغم عدم القدرة على استيراد الودجت الخاص (private) من هناك.
const double _topBarButtonSize = 48;

/// شاشة استكمال بيانات "عمل" مزوّد الخدمة (الشعار/العنوان/الجوال) — تظهر فقط
/// عند نقص أي منها (UserInfoModel.missingProviderProfileFields) وتعرض القسم
/// الناقص فعليًا دون غيره، عند محاولة مزوّد معتمد إضافة أول عرض له (راجع
/// نقطة التفعيل في AddPropertyServiceOfferScreen.initState). لا علاقة لها
/// ببيانات الهوية (فرد/منشأة) التي تجمعها ProviderUpgradeScreen قبلها في
/// التسلسل، ولا تجمع المنطقة أو الموقع الجغرافي (استُبعدا من هذه الشاشة بناءً
/// على طلب صريح). حقل الجوال محقَّق عبر OTP مضمّن بنفس البطاقة (لا شاشة
/// منفصلة) لأنه يُستخدَم للتواصل المباشر مع العميل — راجع _PhoneSection.
class CompleteProviderProfileScreen extends StatefulWidget {
  const CompleteProviderProfileScreen({super.key});

  @override
  State<CompleteProviderProfileScreen> createState() =>
      _CompleteProviderProfileScreenState();
}

class _CompleteProviderProfileScreenState
    extends State<CompleteProviderProfileScreen> {
  late final ServiceOfferController _offerController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _offerController = Get.find<ServiceOfferController>();
  }

  UserInfoModel? get _userInfo => Get.find<UserController>().userInfoModel;
  ProviderIdentity? get _provider => _userInfo?.provider;

  // الشعار والعنوان بيانات ضرورية يُطلب من المزوّد استكمالها، لكنها لا تُحجب
  // المتابعة هنا — تُستكمل/تُراجَع يدويًا لاحقًا (لوحة الأدمن). الجوال وحده
  // يبقى إلزاميًا لإكمال هذه الخطوة: شرط الاستمرار هو التحقق الفعلي عبر OTP
  // لا مجرّد إدخال نص — راجع _PhoneSection.
  bool get _canContinue {
    final userInfo = _userInfo;
    final provider = _provider;
    if (userInfo == null || provider == null) return false;
    if (!userInfo.hasPhone && !_offerController.isPhoneVerified) {
      return false;
    }
    return true;
  }

  Future<void> _continue() async {
    final provider = _provider;
    if (provider == null || !_canContinue) return;

    setState(() => _isSubmitting = true);

    if (!provider.hasLogo && _offerController.pickedLogo != null) {
      final ok = await _offerController.uploadLogo();
      if (!ok) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }
    }

    if (!provider.hasAddress) {
      final ok = await _offerController.saveBusinessInfoNow();
      if (!ok) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }
    }

    // لا استدعاء إضافي هنا لحفظ الجوال: verifyBusinessPhoneOtp() بـ
    // _PhoneSection حفظته فورًا بالباكند لحظة نجاح التحقق.

    await Get.find<UserController>().getUserInfo();

    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Get.off(() => const AddPropertyServiceOfferScreen());
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return NotLoggedInScreen(
        redirectAfterLogin: () => const CompleteProviderProfileScreen(),
      );
    }

    final userInfo = _userInfo;
    final provider = _provider;
    if (userInfo == null || provider == null || userInfo.isProviderProfileComplete) {
      // احتياط: لو اكتملت البيانات فعليًا (مثلاً رجوع بالخلف بعد نجاح سابق)
      // لا تُعرض شاشة فارغة بلا أي قسم — تابع مباشرة لمعالج إنشاء العرض.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Get.off(() => const AddPropertyServiceOfferScreen());
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return GetBuilder<ServiceOfferController>(
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: _buildScrollableContent(
                    context, userInfo, provider, controller),
              ),
              _buildBottomBar(context, controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface(context),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _TopBarBackButton(
                onTap: () => RootFallbackScope.handleBackTap(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'complete_profile_title'.tr,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.smallBold.copyWith(
                  fontSize: 17,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            const SizedBox(width: _topBarButtonSize),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(
    BuildContext context,
    UserInfoModel userInfo,
    ProviderIdentity provider,
    ServiceOfferController controller,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'complete_profile_heading'.tr,
            style: AppTypography.title.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'complete_profile_subtitle'.tr,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          if (!provider.hasLogo) ...[
            _LogoSection(controller: controller),
            const SizedBox(height: Spacing.lg),
          ],
          if (!provider.hasAddress) ...[
            _AddressSection(controller: controller),
            const SizedBox(height: Spacing.lg),
          ],
          if (!userInfo.hasPhone) ...[
            _PhoneSection(controller: controller),
            const SizedBox(height: Spacing.lg),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ServiceOfferController controller) {
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
            loading: _isSubmitting ||
                controller.isUploadingLogo ||
                controller.isSavingBusinessInfo,
            // ملاحظة: لا نُدرج isSendingPhoneOtp/isVerifyingPhoneOtp هنا عمدًا —
            // لهما مؤشّرا تحميل خاصّان داخل _PhoneSection نفسها، وزر "متابعة"
            // يبقى مفعّلاً/معطّلاً حسب _canContinue فقط أثناء تلك اللحظة.
            onPressed: _canContinue ? _continue : null,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SHARED LOCAL WIDGETS (نسخ مصغّرة من نمط ProviderUpgradeScreen/
// AddPropertyServiceOfferScreen — مكرَّرة محليًا لأن أصولها private بملفاتها)
// ─────────────────────────────────────────────────────────────────────────

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

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CardSpec.padding),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.soft(blur: 10, opacity: 0.04),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: IconSpec.small, color: Theme.of(context).primaryColor),
        const SizedBox(width: Spacing.xs),
        Text(
          text,
          style: AppTypography.small.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SECTION: الشعار — تغلّف pickLogo()/uploadLogo() الموجودتين مسبقًا في
// ServiceOfferController (مبنيتان سلفًا، لم تُستخدما بأي شاشة قبل هذه).
// ─────────────────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  final ServiceOfferController controller;
  const _LogoSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final logo = controller.pickedLogo;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.storefront_outlined, text: 'business_logo_label'.tr),
          const SizedBox(height: Spacing.md),
          InkWell(
            onTap: controller.pickLogo,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background(context),
                border: Border.all(
                  color: logo != null ? primary : AppColors.border(context),
                  width: logo != null ? 1.6 : 1,
                ),
              ),
              child: logo != null
                  ? ClipOval(
                      child: Image.file(File(logo.path), fit: BoxFit.cover),
                    )
                  : Icon(Icons.add_a_photo_outlined,
                      color: AppColors.textSecondary(context), size: IconSpec.large),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'business_logo_hint'.tr,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SECTION: العنوان
// ─────────────────────────────────────────────────────────────────────────

class _AddressSection extends StatelessWidget {
  final ServiceOfferController controller;
  const _AddressSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.home_work_outlined, text: 'business_address_label'.tr),
          const SizedBox(height: Spacing.md),
          TextFormField(
            controller: controller.businessAddressController,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary(context)),
            decoration: dsInputDecoration(context, hint: 'business_address_hint'.tr),
            // controller.update() (لا setState محلي) — يُعيد بناء
            // GetBuilder<ServiceOfferController> بالشاشة الأم كي يُعاد تقييم
            // _canContinue فور الكتابة، فيتفعّل زرّ "متابعة" فورًا بلا انتظار
            // أي حدث آخر (كان معطّلاً باستمرار قبل هذا الإصلاح رغم إدخال
            // العنوان، لأن setState محلي هنا لا يصل لزرّ "متابعة" بالشاشة الأم).
            onChanged: (_) => controller.update(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// SECTION: الجوال — تحقق OTP مضمّن بنفس البطاقة (بلا تنقّل لشاشة منفصلة).
// ثلاث حالات: إدخال الرقم → إدخال الرمز (مع عدّاد إعادة إرسال، نفس منطق
// verification_screen.dart:_startTimer/_buildResendRow) → نجاح التحقق.
// ─────────────────────────────────────────────────────────────────────────

class _PhoneSection extends StatefulWidget {
  final ServiceOfferController controller;
  const _PhoneSection({required this.controller});

  @override
  State<_PhoneSection> createState() => _PhoneSectionState();
}

class _PhoneSectionState extends State<_PhoneSection> {
  Timer? _timer;
  int _seconds = 0;
  String _otp = '';

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _seconds--;
        if (_seconds <= 0) timer.cancel();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _send() async {
    final ok = await widget.controller.sendBusinessPhoneOtp();
    if (ok) _startTimer();
  }

  Future<void> _resend() async {
    final ok = await widget.controller.resendBusinessPhoneOtp();
    if (ok) _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final primary = Theme.of(context).primaryColor;

    if (controller.isPhoneVerified) {
      return _SectionCard(
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success, size: IconSpec.defaultSize),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                '${controller.businessPhoneController.text.trim()} — ${'phone_verified_label'.tr}',
                style: AppTypography.smallMedium.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.phone_iphone_outlined, text: 'business_phone_label'.tr),
          const SizedBox(height: Spacing.md),
          TextFormField(
            controller: controller.businessPhoneController,
            enabled: !controller.isPhoneOtpSent,
            keyboardType: TextInputType.phone,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary(context)),
            decoration: dsInputDecoration(context, hint: 'business_phone_hint'.tr),
            onChanged: (_) => setState(() {}),
          ),
          if (!controller.isPhoneOtpSent) ...[
            const SizedBox(height: Spacing.md),
            DSPrimaryButton(
              label: 'send_verification_code'.tr,
              loading: controller.isSendingPhoneOtp,
              onPressed: controller.businessPhoneController.text.trim().isEmpty
                  ? null
                  : _send,
            ),
          ],
          if (controller.isPhoneOtpSent) ...[
            const SizedBox(height: Spacing.lg),
            Text(
              'enter_verification_code'.tr,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Directionality(
              textDirection: TextDirection.ltr,
              child: PinCodeTextField(
                length: 4,
                appContext: context,
                keyboardType: TextInputType.number,
                animationType: AnimationType.slide,
                animationDuration: const Duration(milliseconds: 250),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  fieldHeight: 48,
                  fieldWidth: 48,
                  borderWidth: 1.5,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  selectedColor: primary,
                  selectedFillColor: primary.withValues(alpha: 0.06),
                  inactiveFillColor: AppColors.background(context),
                  inactiveColor: AppColors.border(context),
                  activeColor: primary.withValues(alpha: 0.5),
                  activeFillColor: primary.withValues(alpha: 0.06),
                ),
                textStyle: AppTypography.smallBold.copyWith(
                  color: AppColors.textPrimary(context),
                ),
                onChanged: (value) => setState(() => _otp = value),
                beforeTextPaste: (text) => true,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ResendRow(
                  seconds: _seconds,
                  primary: primary,
                  onResend: _resend,
                ),
                if (_otp.length == 4)
                  TextButton(
                    onPressed: controller.isVerifyingPhoneOtp
                        ? null
                        : () => controller.verifyBusinessPhoneOtp(_otp),
                    child: controller.isVerifyingPhoneOtp
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: primary),
                          )
                        : Text('verify'.tr,
                            style: AppTypography.smallBold.copyWith(color: primary)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// صفّ "لم تستلم الرمز؟ إعادة الإرسال" — نسخة مصغّرة من
/// verification_screen.dart:_buildResendRow، بعدّاد يُدار من الودجت الأب
/// (_PhoneSectionState) بدل حالة داخلية خاصة به.
class _ResendRow extends StatelessWidget {
  final int seconds;
  final Color primary;
  final VoidCallback onResend;

  const _ResendRow({
    required this.seconds,
    required this.primary,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final canResend = seconds < 1;
    return Row(
      children: [
        Text(
          'did_not_receive_the_code'.tr,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const SizedBox(width: 4),
        canResend
            ? TextButton(
                onPressed: onResend,
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
                child: Text('resend'.tr,
                    style: AppTypography.smallBold.copyWith(fontSize: 12, color: primary)),
              )
            : Text(
                '${'resend_in'.tr} $seconds',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
      ],
    );
  }
}
