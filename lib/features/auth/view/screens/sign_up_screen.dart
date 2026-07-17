import 'dart:convert';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/auth/data/models/signup_body.dart';
import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/widgets/app_dropdown.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
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
  final TextEditingController _unifiedNumberController = TextEditingController();

  String? _registrationType = 'individual';
  String? _selectedUserType;

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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      extendBodyBehindAppBar: true,
      appBar: isDesktop
          ? WebMenuBar()
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: AppBarSpec.height,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              ),
            ),
      body: GetBuilder<AuthController>(
        builder: (authController) {
          return Stack(
            children: [
              // Gradient header background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.30,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primary,
                        primary.withValues(alpha: 0.72),
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxWidth =
                        constraints.maxWidth > 700 ? 520.0 : double.infinity;

                    return Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.pagePadding,
                          Spacing.md,
                          Spacing.pagePadding,
                          Spacing.xxl,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // ── Logo ─────────────────────────────────
                                Container(
                                  width: AvatarSpec.profile,
                                  height: AvatarSpec.profile,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.extraLarge),
                                    boxShadow: AppShadows.soft(blur: 14, opacity: 0.1),
                                  ),
                                  child: Center(
                                    child: Image.asset(Images.logo, width: 48),
                                  ),
                                ),
                                const SizedBox(height: Spacing.lg),

                                Text(
                                  'sign_up'.tr,
                                  style: AppTypography.h3.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: Spacing.xs),
                                Text(
                                  'complete_form_data'.tr,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.small.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: Spacing.xl),

                                // ── Form card ─────────────────────────────
                                Container(
                                  padding: const EdgeInsets.all(CardSpec.padding),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.large),
                                    boxShadow: AppShadows.soft(blur: 12, opacity: 0.08),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                        keyboardType: TextInputType.emailAddress,
                                      ),
                                      const SizedBox(height: Spacing.md),

                                      // Phone
                                      _fieldLabel('phone'.tr),
                                      const SizedBox(height: Spacing.sm),
                                      _buildPhoneField(primary),
                                      const SizedBox(height: Spacing.md),

                                      // User type
                                      _fieldLabel('user_type'.tr),
                                      const SizedBox(height: Spacing.sm),
                                      AppDropdown<String>(
                                        value: _selectedUserType,
                                        hintText: 'please_select_user_type'.tr,
                                        items: [
                                          DropdownMenuItem(
                                            value: 'باحث عن عقار',
                                            child: Text('property_seeker'.tr),
                                          ),
                                          DropdownMenuItem(
                                            value: 'مسوق عقاري',
                                            child: Text('real_estate_marketer'.tr),
                                          ),
                                        ],
                                        onChanged: (value) =>
                                            setState(() => _selectedUserType = value),
                                      ),
                                      const SizedBox(height: Spacing.md),

                                      // Registration type
                                      _fieldLabel('registration_type'.tr),
                                      const SizedBox(height: Spacing.sm),
                                      AppDropdown<String>(
                                        value: _registrationType,
                                        hintText: 'registration_type'.tr,
                                        items: [
                                          DropdownMenuItem(
                                            value: 'individual',
                                            child: Text('individual'.tr),
                                          ),
                                          DropdownMenuItem(
                                            value: 'organization',
                                            child: Text('organization_label'.tr),
                                          ),
                                        ],
                                        onChanged: (value) =>
                                            setState(() => _registrationType = value),
                                      ),

                                      // Unified number (organization only)
                                      if (_registrationType == 'organization') ...[
                                        const SizedBox(height: Spacing.md),
                                        _fieldLabel('unified_number'.tr),
                                        const SizedBox(height: Spacing.sm),
                                        _textField(
                                          controller: _unifiedNumberController,
                                          focusNode: _unifiedNumberFocus,
                                          hint: 'enter_unified_number'.tr,
                                          icon: Icons.badge_outlined,
                                          primary: primary,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.done,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
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
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.medium),
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

                                      // Sign in link
                                      DSSecondaryButton(
                                        label: 'already_have_account'.tr,
                                        onPressed: () => Get.toNamed(
                                          RouteHelper.getSignInRoute(
                                            RouteHelper.signUp,
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
            horizontal: FieldSpec.padding, vertical: FieldSpec.padding),
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
                  style: AppTypography.bodyBold
                      .copyWith(color: const Color(0xFF1A2340)),
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
              style: AppTypography.body.copyWith(color: const Color(0xFF1A2340)),
              cursorColor: primary,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isNotEmpty && !newValue.text.startsWith('5')) {
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
                hintStyle: AppTypography.small.copyWith(color: Colors.grey.shade400),
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
    if (_registrationType == 'organization' &&
        _unifiedNumberController.text.trim().isEmpty) {
      showCustomSnackBar('please_enter_unified_number'.tr);
      return;
    }
    if (referCode.isNotEmpty && referCode.length != 10) {
      showCustomSnackBar('referral_code_invalid'.tr);
      return;
    }

    final String numberWithCountryCode = '+966$number';

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
        if (Get.find<SplashController>().configModel?.customerVerification ?? false) {
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
        } else {
          Get.toNamed(
            RouteHelper.getAccessLocationRoute(RouteHelper.signUp),
          );
        }
      } else {
        showCustomSnackBar(status.message);
      }
    });
  }
}
