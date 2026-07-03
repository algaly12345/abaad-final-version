import 'dart:async';
import 'dart:convert';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_dialog.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerificationScreen extends StatefulWidget {
  final String number;
  final bool fromSignUp;
  final String token;
  final String password;

  const VerificationScreen({
    super.key,
    required this.number,
    required this.password,
    required this.fromSignUp,
    required this.token,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late String _number;
  Timer _timer = Timer(const Duration(seconds: 0), () {});
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _number = widget.number.startsWith('+')
        ? widget.number
        : '+${widget.number.substring(1)}';
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds--;
      if (_seconds == 0) timer.cancel();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<AuthController>(
        builder: (authController) {
          return Column(
            children: [
              // ── Gradient header ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 32,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary, primary.withValues(alpha: 0.72)],
                  ),
                ),
                child: Column(
                  children: [
                    // Back button row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Shield icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'otp_verification'.tr,
                      style: robotoBold.copyWith(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ───────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  child: Column(
                    children: [
                      // Subtitle
                      Get.find<SplashController>().configModel?.demo ?? false
                          ? _demoBadge()
                          : _subtitleText(primary),

                      const SizedBox(height: 32),

                      // OTP hint label
                      Text(
                        'enter_verification_code'.tr,
                        style: robotoMedium.copyWith(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── PIN boxes ─────────────────────────────────────────
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
                            fieldHeight: 62,
                            fieldWidth: 62,
                            borderWidth: 1.5,
                            borderRadius: BorderRadius.circular(16),
                            selectedColor: primary,
                            selectedFillColor: primary.withValues(alpha: 0.06),
                            inactiveFillColor: const Color(0xFFF9FAFB),
                            inactiveColor: const Color(0xFFE5E7EB),
                            activeColor: primary.withValues(alpha: 0.5),
                            activeFillColor: primary.withValues(alpha: 0.06),
                          ),
                          textStyle: robotoBold.copyWith(
                            fontSize: 22,
                            color: const Color(0xFF1A2340),
                          ),
                          onChanged: authController.updateVerificationCode,
                          beforeTextPaste: (text) => true,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Resend row ────────────────────────────────────────
                      if (widget.password.isNotEmpty)
                        _buildResendRow(authController, primary),

                      const SizedBox(height: 32),

                      // ── Verify button ─────────────────────────────────────
                      authController.verificationCode.length == 4
                          ? authController.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : CustomButton(
                                  margin: EdgeInsets.zero,
                                  height: 54,
                                  radius: 16,
                                  buttonText: 'verify'.tr,
                                  onPressed: () => _verify(authController),
                                )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: SizedBox(
                                height: 54,
                                child: OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 54),
                                    disabledForegroundColor:
                                        Colors.grey.shade400,
                                    side: BorderSide(
                                        color: Colors.grey.shade200),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'verify'.tr,
                                    style: robotoMedium.copyWith(
                                      fontSize: 15,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Sub-widgets ──────────────────────────────────────────────────────────────

  Widget _subtitleText(Color primary) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '${'otp_sent_to'.tr} ',
            style: robotoRegular.copyWith(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          TextSpan(
            text: _number,
            style: robotoBold.copyWith(
              fontSize: 14,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _demoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Text(
            'for_demo_purpose'.tr,
            style: robotoMedium.copyWith(
              fontSize: 13,
              color: Colors.orange.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendRow(AuthController authController, Color primary) {
    final bool canResend = _seconds < 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'did_not_receive_the_code'.tr,
          style: robotoRegular.copyWith(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 4),
        canResend
            ? TextButton(
                onPressed: () => _resendCode(authController),
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
                child: Text(
                  'resend'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: 13,
                    color: primary,
                  ),
                ),
              )
            : Row(
                children: [
                  Text(
                    '${'resend_in'.tr} ',
                    style: robotoRegular.copyWith(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    '$_seconds',
                    style: robotoBold.copyWith(
                      fontSize: 13,
                      color: primary,
                    ),
                  ),
                  Text(
                    ' s',
                    style: robotoRegular.copyWith(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ],
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  void _resendCode(AuthController authController) {
    if (widget.fromSignUp) {
      authController.login(_number, widget.password).then((value) {
        if (value.isSuccess) {
          _startTimer();
          showCustomSnackBar('resend_code_successful'.tr, isError: false);
        } else {
          showCustomSnackBar(value.message);
        }
      });
    } else {
      authController.forgetPassword(_number).then((value) {
        if (value?.isSuccess ?? false) {
          _startTimer();
          showCustomSnackBar('resend_code_successful'.tr, isError: false);
        } else {
          showCustomSnackBar(value?.message ?? '');
        }
      });
    }
  }

  void _verify(AuthController authController) {
    if (widget.fromSignUp) {
      authController.verifyPhone(_number, widget.token).then((value) {
        if (value.isSuccess) {
          _showSuccessDialog();
          Future.delayed(const Duration(seconds: 2), () {
            Get.offNamed(
              RouteHelper.getAccessLocationRoute('verification'),
            );
          });
        } else {
          showCustomSnackBar(value.message);
        }
      });
    } else {
      authController.verifyToken(_number).then((value) {
        if (!value.isSuccess) {
          showCustomSnackBar(value.message);
        }
      });
    }
  }

  void _showSuccessDialog() {
    showAnimatedDialog(
      context,
      Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(Dimensions.RADIUS_EXTRA_LARGE),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(Images.checked, width: 90, height: 90),
              const SizedBox(height: 16),
              Text(
                'verified'.tr,
                style: robotoBold.copyWith(
                  fontSize: 22,
                  color: const Color(0xFF1A2340),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
      dismissible: false,
    );
  }
}
