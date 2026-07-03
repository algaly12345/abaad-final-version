import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/helper/responsive_helper.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'widget/condition_check_box.dart';

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
                leading: widget.exitFromApp
                    ? null
                    : IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
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
                          constraints.maxWidth > 700 ? 460.0 : double.infinity;

                      return Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // ── Logo ───────────────────────────────
                                  Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.18),
                                          blurRadius: 22,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Image.asset(Images.logo, width: 52),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // ── Title ──────────────────────────────
                                  Text(
                                    'sign_in'.tr,
                                    style: robotoBold.copyWith(
                                      fontSize: 24,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'enter_phone_subtitle'.tr,
                                    textAlign: TextAlign.center,
                                    style: robotoRegular.copyWith(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.82),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // ── Form Card ──────────────────────────
                                  Container(
                                    padding: const EdgeInsets.all(22),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 24,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        // Label
                                        Text(
                                          'phone'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: 13,
                                            color: const Color(0xFF374151),
                                          ),
                                        ),
                                        const SizedBox(height: 8),

                                        // Phone input
                                        _buildPhoneField(primary),
                                        const SizedBox(height: 18),

                                        // Terms
                                        ConditionCheckBox(authController: authController),
                                        const SizedBox(height: 20),

                                        // Login button
                                        CustomButton(
                                          margin: EdgeInsets.zero,
                                          height: 52,
                                          radius: 14,
                                          buttonText: 'login_btn'.tr,
                                          isLoading: authController.isLoading,
                                          onPressed: authController.acceptTerms
                                              ? () => _login(authController)
                                              : null,
                                        ),
                                        const SizedBox(height: 10),

                                        // Sign up button
                                        SizedBox(
                                          height: 52,
                                          child: OutlinedButton(
                                            onPressed: () => Get.toNamed(
                                              RouteHelper.getSignUpRoute(),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: primary,
                                              side: BorderSide(
                                                color: primary.withValues(alpha: 0.45),
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Text(
                                              'sign_up'.tr,
                                              style: robotoMedium.copyWith(
                                                fontSize: 15,
                                                color: primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // ── Guest button ───────────────────────
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(1, 44),
                                    ),
                                    onPressed: () => Navigator.pushReplacementNamed(
                                      context,
                                      RouteHelper.getInitialRoute(),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_outline_rounded,
                                          size: 18,
                                          color: primary.withValues(alpha: 0.75),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'continue_as_guest'.tr,
                                          style: robotoMedium.copyWith(
                                            fontSize: 14,
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
            height: 54,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(Images.saudi_flag, width: 26, height: 26),
                const SizedBox(width: 6),
                Text(
                  '+966',
                  style: robotoBold.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF1A2340),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.left,
              style: robotoMedium.copyWith(
                fontSize: 16,
                color: const Color(0xFF1A2340),
              ),
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
    return InputDecoration(
      hintText: hint,
      hintStyle: robotoRegular.copyWith(
        fontSize: 14,
        color: Colors.grey.shade400,
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.3),
      ),
    );
  }

  // ── Login logic ──────────────────────────────────────────────────────────────

  void _login(AuthController authController) {
    if (!_formKey.currentState!.validate()) return;

    final String phone = _phoneController.text.trim();
    final String fullPhone = '+966$phone';

    authController.login(fullPhone, '556769800').then((status) {
      if (status.isSuccess) {
        final String token = status.token ?? status.message;

        if (status.isPhoneVerified == true) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
          return;
        }

        final List<int> encoded = utf8.encode('556769800');
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
