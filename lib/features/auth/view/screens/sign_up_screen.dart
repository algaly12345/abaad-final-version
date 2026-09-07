import 'dart:convert';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/features/provider/view/screens/provider_upgrade_screen.dart';
import 'package:abaad_flutter/features/provider/view/widgets/provider_identity_form.dart';
import 'package:abaad_flutter/features/services/view/screens/my_services_screen.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/auth/data/models/signup_body.dart';
import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/services/referral_link_manager.dart';
import 'package:abaad_flutter/shared/widgets/app_dropdown.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/root_fallback_scope.dart';
import 'package:abaad_flutter/shared/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../widgets/condition_check_box.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _unifiedNumberFocus = FocusNode();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _referCodeController = TextEditingController();
  final TextEditingController _unifiedNumberController =
      TextEditingController();

  String? _registrationType = 'individual';
  String? _selectedUserType;

  /// حارس إعادة الدخول لزرّ الرجوع — نقرة مزدوجة سريعة أو فتح الحوار مرّتين.
  bool _handlingBack = false;

  /// المصدر الوحيد الذي يملأ _referCodeController هو رابط الإحالة (لا يوجد
  /// حقل يدوي له في الواجهة) — فوجود قيمة هنا يعني تحديداً أن هذا التسجيل
  /// جاء عبر رابط إحالة مزوّد خدمة، فنسجّله هو أيضاً كمزوّد خدمة مباشرة بلا
  /// سؤاله عن نوع الحساب (راجع طلب اختصار المسار لمن يُحال عبر الرابط).
  bool get _isReferralSignUp => _referCodeController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _prefillReferralCode();
  }

  /// يعبّي كود الإحالة تلقائيًا من التخزين المحلي (وصل عبر ChottuLink —
  /// مثبَّت/مؤجَّل — أو الرابط الخام أو Play Install Referrer). **peek وليس
  /// حذف**: الكود يبقى محفوظًا حتى نجاح التسجيل (clearAfterRegistration في
  /// _register)، فلا يضيع لو خرج المستخدم أو تنقّل Login↔Register قبل الإكمال.
  Future<void> _prefillReferralCode() async {
    final String? code = await ReferralLinkManager.instance
        .pendingReferralCode();
    if (code != null && code.isNotEmpty && mounted) {
      setState(() {
        _referCodeController.text = code;
        // يخفي حقل "نوع المستخدم" في الواجهة (انظر أدناه) فلا بد من قيمة
        // مسبقة هنا حتى يمر تحقق _register() دون أن يظهر الحقل أصلاً.
        _selectedUserType = 'مسوق عقاري';
      });
    }
  }

  /// معالج زرّ الرجوع (أيقونة الشريط + زرّ النظام/الإيماءة معًا). لا يمسّ منطق
  /// الإحالة إطلاقًا — يقرأ فقط [_isReferralSignUp] القائم:
  ///  • جاء عبر رابط إحالة: هذه الشاشة جذر المكدّس (Get.offAllNamed)، فالرجوع
  ///    "ميت". نعرض تأكيد إلغاء التسجيل، وعند التأكيد ننتقل للصفحة الرئيسية.
  ///    الكود المحفوظ لا يُمسح (يبقى لأي محاولة تسجيل لاحقة كما هو مصمَّم).
  ///  • تسجيل عادي: سلوك RootFallbackScope.handleBackTap القائم بلا تغيير.
  Future<void> _handleBack() async {
    if (_handlingBack) return;
    _handlingBack = true;
    try {
      if (_isReferralSignUp) {
        final bool leave = await _confirmCancelSignUp() ?? false;
        if (!leave || !mounted) return;
        Get.offAllNamed(RouteHelper.getInitialRoute());
        return;
      }
      if (mounted) RootFallbackScope.handleBackTap(context);
    } finally {
      _handlingBack = false;
    }
  }

  Future<bool?> _confirmCancelSignUp() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('cancel_signup_title'.tr),
        content: Text('cancel_signup_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('no'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('yes'.tr),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _unifiedNumberFocus.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _referCodeController.dispose();
    _unifiedNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final primary = Theme.of(context).primaryColor;

    return PopScope(
      // زرّ/إيماءة الرجوع من النظام لا يُغلق التطبيق ولا "يموت" على هذه
      // الشاشة حين تكون جذر المكدّس — نمرّره لنفس معالج أيقونة الرجوع.
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      extendBodyBehindAppBar: true,
      appBar: isDesktop
          ? WebMenuBar()
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: AppBarSpec.height,
              // زرّ الرجوع يمرّ عبر _handleBack: لمن جاء برابط إحالة يعرض تأكيد
              // إلغاء التسجيل ثم ينتقل للرئيسية؛ لغيره سلوك RootFallbackScope
              // القائم. (Get.back() وحدها "ميتة" هنا لأن الشاشة جذر المكدّس
              // بعد Get.offAllNamed من تدفّق الإحالة / السبلاش.)
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.22),
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: _handleBack,
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: GetBuilder<AuthController>(
        builder: (authController) {
          // Single-child Stack kept for structural stability; the gradient
          // header is now an inline sliver of the scroll content (see below)
          // instead of a fixed-height Positioned layer.
          return Stack(
            children: [
              SafeArea(
                top: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth = constraints.maxWidth > 700
                        ? 520.0
                        : double.infinity;

                    return Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: Spacing.xxl),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // ── Gradient header ──────────────────────
                                // Wraps its own content (logo + title +
                                // subtitle) so the text can never bleed past
                                // the gradient onto the light page background.
                                // The old fixed-height Positioned layer
                                // (size.height * 0.30) clipped the subtitle on
                                // shorter screens / larger text scales.
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(
                                    Spacing.pagePadding,
                                    MediaQuery.of(context).padding.top +
                                        AppBarSpec.height +
                                        Spacing.sm,
                                    Spacing.pagePadding,
                                    Spacing.xl,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        primary,
                                        primary.withValues(alpha: 0.72),
                                      ],
                                    ),
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(
                                        AppRadius.extraLarge,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: AvatarSpec.profile,
                                        height: AvatarSpec.profile,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.extraLarge,
                                          ),
                                          boxShadow: AppShadows.soft(
                                            blur: 14,
                                            opacity: 0.1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            Images.logo,
                                            width: 48,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: Spacing.lg),
                                      Text(
                                        'sign_up'.tr,
                                        style: AppTypography.h3.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: Spacing.xs),
                                      Text(
                                        'complete_form_data'.tr,
                                        textAlign: TextAlign.center,
                                        style: AppTypography.small.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.85,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: Spacing.lg),

                                // ── Form card ─────────────────────────────
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: Spacing.pagePadding,
                                  ),
                                  padding: const EdgeInsets.all(
                                    CardSpec.padding,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.large,
                                    ),
                                    boxShadow: AppShadows.soft(
                                      blur: 12,
                                      opacity: 0.08,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Full name
                                      _fieldLabel('full_name'.tr),
                                      const SizedBox(height: Spacing.sm),
                                      _textField(
                                        controller: _fullNameController,
                                        focusNode: _firstNameFocus,
                                        nextFocus: _emailFocus,
                                        hint: 'enter_full_name_hint'.tr,
                                        icon: Icons.person_outline_rounded,
                                        primary: primary,
                                        keyboardType: TextInputType.name,
                                      ),
                                      const SizedBox(height: Spacing.md),

                                      // Email
                                      _fieldLabel('email'.tr),
                                      const SizedBox(height: Spacing.sm),
                                      _textField(
                                        controller: _emailController,
                                        focusNode: _emailFocus,
                                        nextFocus: _phoneFocus,
                                        hint: 'enter_email_optional'.tr,
                                        icon: Icons.mail_outline_rounded,
                                        primary: primary,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: Spacing.md),

                                      // Phone
                                      _fieldLabel('phone'.tr),
                                      const SizedBox(height: Spacing.sm),
                                      _buildPhoneField(primary),
                                      const SizedBox(height: Spacing.md),

                                      // User type / نوع التسجيل / الرقم الموحد —
                                      // تختفي جميعها لمن جاء عبر رابط إحالة (انظر
                                      // _isReferralSignUp)، ويظهر بدلاً منها نموذج
                                      // "اختر نوع الحساب" (بيانات الهوية كمزوّد
                                      // خدمة) في مكانها مباشرة — فيُسجَّل بذلك
                                      // كمزوّد خدمة بتسجيل واحد متصل، لا تسجيل
                                      // كمستخدم ثم "انضمام كمزوّد خدمة" منفصل لاحقاً.
                                      if (!_isReferralSignUp) ...[
                                        _fieldLabel('user_type'.tr),
                                        const SizedBox(height: Spacing.sm),
                                        AppDropdown<String>(
                                          value: _selectedUserType,
                                          hintText:
                                              'please_select_user_type'.tr,
                                          leadingIcon: Icons.groups_outlined,
                                          items: [
                                            DropdownMenuItem(
                                              value: 'باحث عن عقار',
                                              child: Text('property_seeker'.tr),
                                            ),
                                            DropdownMenuItem(
                                              value: 'مسوق عقاري',
                                              child: Text(
                                                'real_estate_marketer'.tr,
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) => setState(
                                            () => _selectedUserType = value,
                                          ),
                                        ),
                                        const SizedBox(height: Spacing.md),

                                        // Registration type
                                        _fieldLabel('registration_type'.tr),
                                        const SizedBox(height: Spacing.sm),
                                        AppDropdown<String>(
                                          value: _registrationType,
                                          hintText: 'registration_type'.tr,
                                          leadingIcon: Icons.badge_outlined,
                                          items: [
                                            DropdownMenuItem(
                                              value: 'individual',
                                              child: Text('individual'.tr),
                                            ),
                                            DropdownMenuItem(
                                              value: 'organization',
                                              child: Text(
                                                'organization_label'.tr,
                                              ),
                                            ),
                                          ],
                                          onChanged: (value) => setState(
                                            () => _registrationType = value,
                                          ),
                                        ),

                                        // Unified number (organization only)
                                        if (_registrationType ==
                                            'organization') ...[
                                          const SizedBox(height: Spacing.md),
                                          _fieldLabel('unified_number'.tr),
                                          const SizedBox(height: Spacing.sm),
                                          _textField(
                                            controller:
                                                _unifiedNumberController,
                                            focusNode: _unifiedNumberFocus,
                                            hint: 'enter_unified_number'.tr,
                                            icon: Icons.pin_outlined,
                                            primary: primary,
                                            keyboardType: TextInputType.number,
                                            textInputAction:
                                                TextInputAction.done,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                            ],
                                          ),
                                        ],
                                      ] else ...[
                                        _fieldLabel('choose_account_type'.tr),
                                        const SizedBox(height: Spacing.xs),
                                        Text(
                                          'provider_upgrade_subtitle'.tr,
                                          style: AppTypography.caption.copyWith(
                                            color: const Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: Spacing.md),
                                        const ProviderIdentityForm(),
                                        const SizedBox(height: Spacing.md),
                                      ],

                                      // Applied referral code (read-only confirmation, only when auto-filled via link)
                                      if (_referCodeController
                                          .text
                                          .isNotEmpty) ...[
                                        const SizedBox(height: Spacing.md),
                                        _fieldLabel('applied_referral_code'.tr),
                                        const SizedBox(height: Spacing.sm),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: FieldSpec.padding,
                                            vertical: FieldSpec.padding,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF0FDF4),
                                            borderRadius: BorderRadius.circular(
                                              FieldSpec.radius,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFF86EFAC),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                color: Color(0xFF16A34A),
                                                size: IconSpec.small,
                                              ),
                                              const SizedBox(width: Spacing.sm),
                                              Expanded(
                                                child: Text(
                                                  _referCodeController.text,
                                                  style: AppTypography.bodyBold
                                                      .copyWith(
                                                        color: const Color(
                                                          0xFF15803D,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: Spacing.lg),

                                      // Terms
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Spacing.md,
                                          vertical: Spacing.md,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9FAFB),
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.medium,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        child: ConditionCheckBox(
                                          authController: authController,
                                        ),
                                      ),
                                      const SizedBox(height: Spacing.lg),

                                      // Register button
                                      DSPrimaryButton(
                                        label: 'sign_up'.tr,
                                        loading: authController.isLoading,
                                        onPressed: authController.acceptTerms
                                            ? () => _register(authController)
                                            : null,
                                      ),
                                      const SizedBox(height: Spacing.md),

                                      // Sign in link — low-emphasis text button
                                      // so it doesn't compete with the primary
                                      // "Sign Up" action directly above it.
                                      Center(
                                        child: TextButton(
                                          onPressed: () => Get.toNamed(
                                            RouteHelper.getSignInRoute(
                                              RouteHelper.signUp,
                                            ),
                                          ),
                                          style: TextButton.styleFrom(
                                            foregroundColor: primary,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: Spacing.md,
                                              vertical: Spacing.sm,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            'already_have_account'.tr,
                                            style: AppTypography.smallBold
                                                .copyWith(color: primary),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: AppTypography.small.copyWith(color: const Color(0xFF374151)),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    required String hint,
    required IconData icon,
    required Color primary,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(FieldSpec.radius),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    );
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      style: AppTypography.body.copyWith(color: const Color(0xFF1A2340)),
      cursorColor: primary,
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.small.copyWith(color: Colors.grey.shade400),
        prefixIcon: Icon(icon, color: primary, size: IconSpec.small),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FieldSpec.padding,
          vertical: FieldSpec.padding,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: border.copyWith(
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
    );
  }

  Widget _buildPhoneField(Color primary) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(FieldSpec.radius),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          Container(
            height: FieldSpec.height,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(FieldSpec.radius),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Images.saudi_flag, width: 26, height: 26),
                const SizedBox(width: Spacing.xs),
                Text(
                  '+966',
                  style: AppTypography.bodyBold.copyWith(
                    color: const Color(0xFF1A2340),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              textInputAction: TextInputAction.next,
              style: AppTypography.body.copyWith(
                color: const Color(0xFF1A2340),
              ),
              cursorColor: primary,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isNotEmpty &&
                      !newValue.text.startsWith('5')) {
                    showCustomSnackBar('phone_start_5_error'.tr);
                    return oldValue;
                  }
                  return newValue;
                }),
              ],
              onFieldSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_unifiedNumberFocus),
              decoration: InputDecoration(
                hintText: '5XXXXXXXX',
                hintStyle: AppTypography.small.copyWith(
                  color: Colors.grey.shade400,
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: FieldSpec.padding,
                  vertical: FieldSpec.padding,
                ),
                border: border,
                enabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide: BorderSide(color: primary, width: 1.6),
                ),
                errorBorder: border.copyWith(
                  borderSide: const BorderSide(color: AppColors.danger),
                ),
                focusedErrorBorder: border.copyWith(
                  borderSide: const BorderSide(
                    color: AppColors.danger,
                    width: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Register logic ───────────────────────────────────────────────────────────

  void _register(AuthController authController) async {
    FocusScope.of(context).unfocus();

    final String fullName = _fullNameController.text.trim();
    final String email = _emailController.text.trim();
    final String number = _phoneController.text.trim();
    final String referCode = _referCodeController.text.trim();

    if (fullName.isEmpty) {
      showCustomSnackBar('please_enter_full_name'.tr);
      return;
    }
    if (number.isEmpty) {
      showCustomSnackBar('please_enter_phone'.tr);
      return;
    }
    if (!number.startsWith('5')) {
      showCustomSnackBar('phone_start_5_error'.tr);
      return;
    }
    if (number.length != 9) {
      showCustomSnackBar('phone_9_digits_error'.tr);
      return;
    }
    if (_selectedUserType?.isEmpty ?? true) {
      showCustomSnackBar('please_select_user_type'.tr);
      return;
    }
    if (_isReferralSignUp) {
      // نفس رسالة/شرط ServiceOfferController._validateEntityIdentity() —
      // نكرره هنا مسبقًا كي لا يُنشأ حساب مصادَق (تسجيل + تحقق OTP) دون بيانات
      // هوية أصلاً، بدل اكتشاف ذلك لاحقًا في _ReferralIdentitySubmitGate.
      if (Get.find<ServiceOfferController>().entityType == null) {
        showCustomSnackBar('اختر فرد أو منشأة');
        return;
      }
    } else if (_registrationType == 'organization' &&
        _unifiedNumberController.text.trim().isEmpty) {
      showCustomSnackBar('please_enter_unified_number'.tr);
      return;
    }
    // لا نفرض طولًا ثابتًا: أكواد قديمة قبل توحيد التوليد (مثل "SP-9361")
    // أقصر من الصيغة الجديدة (10 أحرف بدون شرطة) — السيرفر هو من يتحقق من
    // وجود الكود فعليًا عند التسجيل، هذا فقط تحقق أولي من شكل معقول للقيمة.
    if (referCode.isNotEmpty &&
        (referCode.length < 3 || referCode.length > 20)) {
      showCustomSnackBar('referral_code_invalid'.tr);
      return;
    }

    final String numberWithCountryCode = '+966$number';

    if (_isReferralSignUp) {
      // بيانات الهوية (فرد/منشأة) جُمعت للتوّ أعلاه عبر ProviderIdentityForm
      // ضمن نفس نموذج التسجيل، لكن إرسالها لـ updateIdentity API يتطلب توكن
      // مصادقة — غير متوفر إلا بعد نجاح التحقق من الجوال (verifyPhone تحفظه).
      // لذا تُرسَل فعليًا من _ReferralIdentitySubmitGate بعد ذلك مباشرة، لا من
      // هنا، فيبدو التسجيل بأكمله (بيانات أساسية + هوية) خطوة واحدة متصلة
      // للمستخدم رغم أن الإرسال الفعلي يحدث على دفعتين خلف الكواليس. نفس آلية
      // إعادة التوجيه بعد تسجيل الدخول المستخدمة أصلاً لزائر ضغط "انضم كمزوّد
      // خدمة" (راجع AuthController.setPendingPostAuthRedirect وطريقة
      // استهلاكها في verification_screen.dart)، وتُستهلَك مرة واحدة فتلقائيًا
      // لا تؤثر على أي تسجيل لاحق.
      authController.setPendingPostAuthRedirect(
        () => const _ReferralIdentitySubmitGate(),
      );
    }

    final SignUpBody signUpBody = SignUpBody(
      fName: fullName,
      email: email,
      phone: numberWithCountryCode,
      password: '1234567',
      refCode: referCode,
      zone_id: 0,
      membershipType: _selectedUserType,
      unifiedNumber: _registrationType == 'organization'
          ? _unifiedNumberController.text.trim()
          : null,
      city_id: 0,
    );

    authController.registration(signUpBody).then((status) async {
      if (status.isSuccess) {
        // نجح التسجيل → ref_code وصل للباكند وأُنشئ صف Referral (سواء تلا ذلك
        // تحقق OTP أم لا). الآن فقط يُمسح الكود من التخزين المحلي.
        await ReferralLinkManager.instance.clearAfterRegistration();

        if (Get.find<SplashController>().configModel?.customerVerification ??
            false) {
          final List<int> encoded = utf8.encode('1234567');
          final String data = base64Encode(encoded);

          Get.toNamed(
            RouteHelper.getVerificationRoute(
              numberWithCountryCode,
              status.message,
              RouteHelper.signUp,
              data,
            ),
          );
        } else if (_isReferralSignUp) {
          // لا خطوة تحقق OTP هنا: registration() سجّل الدخول فوراً، فنستهلك
          // إعادة التوجيه المضبوطة أعلاه يدوياً بدل الاعتماد على
          // verification_screen.dart (التي لن تُفتَح إطلاقاً بهذا المسار).
          authController.consumePendingPostAuthRedirect();
          Get.offAll(
            () => const RootFallbackScope(child: _ReferralIdentitySubmitGate()),
          );
        } else {
          Get.toNamed(RouteHelper.getAccessLocationRoute(RouteHelper.signUp));
        }
      } else {
        showCustomSnackBar(status.message);
      }
    });
  }
}

/// شاشة انتقالية موجزة (لا تظهر أي نموذج) تُرسل بيانات الهوية التي جُمعت
/// أثناء التسجيل نفسه (ProviderIdentityForm أعلاه) بمجرد توفر توكن مصادقة
/// صالح بعد نجاح تسجيل الدخول/التحقق — لا يمكن إرسالها قبل ذلك لأن
/// updateIdentity API محمي بـ auth:api. عند النجاح تنتقل مباشرة إلى "خدماتي"،
/// أو تعرض شاشة "إنشاء حساب مزود خدمة" (مسبوقة بنفس البيانات المُدخلة، لأنها
/// تُقرأ من نفس ServiceOfferController) لإتاحة إعادة المحاولة لو فشل الإرسال
/// (مثلاً بسبب انقطاع شبكة لحظي) بدل حجب الوصول لـ"خدماتي" بصمت.
class _ReferralIdentitySubmitGate extends StatefulWidget {
  const _ReferralIdentitySubmitGate();

  @override
  State<_ReferralIdentitySubmitGate> createState() =>
      _ReferralIdentitySubmitGateState();
}

class _ReferralIdentitySubmitGateState
    extends State<_ReferralIdentitySubmitGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
  }

  Future<void> _submit() async {
    final saved = await Get.find<ServiceOfferController>().saveIdentityNow();
    if (saved) {
      await Get.find<UserController>().getUserInfo();
    }
    if (!mounted) return;
    // يُعاد اللف بـ RootFallbackScope هنا مجدداً رغم أن هذه الشاشة نفسها قد
    // تكون أصلاً داخل واحدة (استهلاك pendingPostAuthRedirect): Get.offAll()
    // يمسح المكدّس بالكامل بما فيه أي لفّ سابق، فبلا هذا يصل المستخدم لشاشة
    // بلا حماية زرّ الرجوع (راجع تعليق RootFallbackScope.handleBackTap).
    if (saved) {
      Get.offAll(() => const RootFallbackScope(child: MyServicesScreen()));
    } else {
      Get.offAll(() => const RootFallbackScope(child: ProviderUpgradeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
