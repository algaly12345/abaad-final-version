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
import 'package:abaad_flutter/view/screen/auth/widget/guest_button.dart';
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
              const SnackBar(content: Text('اضغط مرة أخرى للخروج')),
            );
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
            return Future.value(false);
          }
        } else {
          return true;
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: isDesktop
            ? WebMenuBar(ontop: null, fromPage: '')
            : AppBar(
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_rounded),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),

        body: Stack(
          children: [

            // 🌄 خلفية كاملة
            Positioned.fill(
              child: Image.asset(
                Images.background,
                fit: BoxFit.cover,
              ),
            ),

            // 🌫️ طبقة هادئة
            Positioned.fill(
              child: Container(
                color: Colors.white.withOpacity(0.85),
              ),
            ),

            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth =
                  constraints.maxWidth > 700 ? 450.0 : double.infinity;

                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),

                          child: GetBuilder<AuthController>(
                            builder: (authController) {
                              return Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                                  children: [

                                    const SizedBox(height: 10),

                                    Center(
                                      child: Image.asset(
                                        Images.logo_name,
                                        width: 80,
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    Text(
                                      'تسجيل الدخول',
                                      textAlign: TextAlign.center,
                                      style: robotoBlack.copyWith(fontSize: 24),
                                    ),

                                    const SizedBox(height: 8),

                                    const Text(
                                      'أدخل رقم الجوال',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.grey),
                                    ),

                                    const SizedBox(height: 28),

                                    // 📱 حقل الجوال
                                    Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                          BorderRadius.circular(18),
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                          ),
                                        ),
                                        child: Row(
                                          children: [

                                            // 🇸🇦 علم السعودية
                                            Container(
                                              height: 56,
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                BorderRadius.circular(14),
                                                border: Border.all(
                                                  color:
                                                  const Color(0xFFE5E7EB),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Image.asset(
                                                    Images.saudi_flag,
                                                    width: 34,
                                                    height: 34,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Text(
                                                    '+966',
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 10),

                                            Expanded(
                                              child: TextFormField(
                                                controller: _phoneController,
                                                focusNode: _phoneFocus,
                                                keyboardType:
                                                TextInputType.number,

                                                // 🔥 هذا هو المطلوب
                                                textAlign: TextAlign.left,
                                                textDirection:
                                                TextDirection.ltr,

                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  LengthLimitingTextInputFormatter(
                                                      9),
                                                ],

                                                onChanged: (value) {
                                                  if (value.isNotEmpty &&
                                                      !value.startsWith('5')) {
                                                    if (!_shownWarning) {
                                                      _shownWarning = true;
                                                      showCustomSnackBar(
                                                          'يجب أن يبدأ الرقم بـ 5');
                                                    }
                                                  } else {
                                                    _shownWarning = false;
                                                  }
                                                },

                                                decoration: InputDecoration(
                                                  hintText: '5XXXXXXXX',
                                                  prefixIcon: const Icon(
                                                      Icons.phone),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(14),
                                                  ),
                                                ),

                                                validator: (value) {
                                                  final phone = value ?? '';

                                                  if (phone.isEmpty) {
                                                    return 'أدخل رقم الجوال';
                                                  }
                                                  if (!phone.startsWith('5')) {
                                                    return 'يجب أن يبدأ بـ 5';
                                                  }
                                                  if (phone.length != 9) {
                                                    return '9 أرقام فقط';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    ConditionCheckBox(
                                      authController: authController,
                                    ),

                                    const SizedBox(height: 20),

                                    SizedBox(
                                      height: 50,
                                      child: CustomButton(
                                        buttonText: 'دخول',
                                        onPressed:
                                        authController.acceptTerms
                                            ? () => _login(authController)
                                            : null,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    SizedBox(
                                      height: 52,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Get.toNamed(RouteHelper.getSignUpRoute());
                                        },
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          'إنشاء حساب',
                                          style: robotoMedium.copyWith(
                                            fontSize: 15,
                                            color: const Color(0xFF111827),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const GuestButton(),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login(AuthController authController) {
    if (!_formKey.currentState!.validate()) return;

    String phone = _phoneController.text.trim();

    authController.login("+966$phone", "1234567").then((status) {
      if (status.isSuccess) {
        String token = status.message.substring(1);

        List<int> encoded = utf8.encode("1234567");
        String data = base64Encode(encoded);

        Get.toNamed(
          RouteHelper.getVerificationRoute(
            "+966$phone",
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