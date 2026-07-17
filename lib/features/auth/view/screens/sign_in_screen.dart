import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../widgets/condition_check_box.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignInScreen({super.key, required this.exitFromApp});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _canExit = GetPlatform.isWeb ? true : false;
  bool _shownWarning = false;

  @override
  void dispose() {
    _phoneFocus.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final primary = Theme.of(context).primaryColor;

    return WillPopScope(
      onWillPop: () async {
        if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            }
            return Future.value(false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('back_press_again_to_exit'.tr)),
            );
            _canExit = true;
            Timer(const Duration(seconds: 2), () => _canExit = false);
            return Future.value(false);
          }
        } else {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        extendBodyBehindAppBar: true,
        appBar: isDesktop
            ? WebMenuBar(ontop: null, fromPage: '')
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: AppBarSpec.height,
                leading: widget.exitFromApp
                    ? null
                    : IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(
                          Icons.arrow_back_ios_rounded,
                          color: Colors.white,
                        ),
                      ),
              ),
        body: GetBuilder<AuthController>(
          builder: (authController) {
            return Stack(
              children: [
                // Gradient background (top half)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.42,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, primary.withValues(alpha: 0.72)],
                      ),
                    ),
                  ),
                ),

                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth > 700
                          ? 460.0
                          : double.infinity;

                      return Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                            Spacing.pagePadding,
                            Spacing.lg,
                            Spacing.pagePadding,
                            Spacing.xxl,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // ── Logo ───────────────────────────────
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
                                      child: Image.asset(
                                        Images.logo,
                                        width: 52,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.lg),

                                  // ── Title ──────────────────────────────
                                  Text(
                                    'sign_in'.tr,
                                    style: AppTypography.h3
                                        .copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: Spacing.xs),
                                  Text(
                                    'enter_phone_subtitle'.tr,
                                    textAlign: TextAlign.center,
                                    style: AppTypography.small.copyWith(
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                  const SizedBox(height: Spacing.xl),

                                  // ── Form Card ──────────────────────────
                                  Container(
                                    padding: const EdgeInsets.all(CardSpec.padding),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.large),
                                      boxShadow: AppShadows.soft(blur: 12, opacity: 0.08),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Label
                                        Text(
                                          'phone'.tr,
                                          style: AppTypography.small
                                              .copyWith(color: const Color(0xFF374151)),
                                        ),
                                        const SizedBox(height: Spacing.sm),

                                        // Phone input
                                        _buildPhoneField(primary),
                                        const SizedBox(height: Spacing.lg),

                                        // Terms
                                        ConditionCheckBox(
                                          authController: authController,
                                        ),
                                        const SizedBox(height: Spacing.lg),

                                        // Login button
                                        DSPrimaryButton(
                                          label: 'login_btn'.tr,
                                          loading: authController.isLoading,
                                          onPressed: authController.acceptTerms
                                              ? () => _login(authController)
                                              : null,
                                        ),
                                        const SizedBox(height: Spacing.md),

                                        // Sign up button
                                        DSSecondaryButton(
                                          label: 'sign_up'.tr,
                                          onPressed: () => Get.toNamed(
                                            RouteHelper.getSignUpRoute(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: Spacing.lg),

                                  // ── Guest button ───────────────────────
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(1, 48),
                                    ),
                                    onPressed: () =>
                                        Navigator.pushReplacementNamed(
                                          context,
                                          RouteHelper.getInitialRoute(),
                                        ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          size: IconSpec.small,
                                          color: primary.withValues(alpha: 0.75),
                                        ),
                                        const SizedBox(width: Spacing.xs),
                                        Text(
                                          'continue_as_guest'.tr,
                                          style: AppTypography.smallMedium.copyWith(
                                            color: primary.withValues(alpha: 0.9),
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

  // ── Phone field ──────────────────────────────────────────────────────────────

  Widget _buildPhoneField(Color primary) {
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
              style: AppTypography.body.copyWith(color: const Color(0xFF1A2340)),
              cursorColor: primary,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              onChanged: (value) {
                if (value.isNotEmpty && !value.startsWith('5')) {
                  if (!_shownWarning) {
                    _shownWarning = true;
                    showCustomSnackBar('phone_start_5_error'.tr);
                  }
                } else {
                  _shownWarning = false;
                }
              },
              decoration: _phoneInputDecoration(primary, '5XXXXXXXX'),
              validator: (value) {
                final phone = value ?? '';
                if (phone.isEmpty) return 'please_enter_phone'.tr;
                if (!phone.startsWith('5')) return 'phone_start_5_error'.tr;
                if (phone.length != 9) return 'phone_9_digits_error'.tr;
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _phoneInputDecoration(Color primary, String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(FieldSpec.radius),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.small.copyWith(color: Colors.grey.shade400),
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
    );
  }

  // ── Login logic ──────────────────────────────────────────────────────────────

  void _login(AuthController authController) {
    if (!_formKey.currentState!.validate()) return;

    final String phone = _phoneController.text.trim();
    final String fullPhone = '+966$phone';

    authController.login(fullPhone, 'string').then((status) {
      if (status.isSuccess) {
        final String token = status.token ?? status.message;

        if (status.isPhoneVerified == true) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          return;
        }

        final List<int> encoded = utf8.encode('string');
        final String data = base64Encode(encoded);

        Get.toNamed(
          RouteHelper.getVerificationRoute(
            fullPhone,
            token,
            RouteHelper.signUp,
            data,
          ),
        );
      } else {
        showCustomSnackBar(status.message);
      }
    });
  }
}
