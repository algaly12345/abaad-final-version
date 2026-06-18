import 'dart:convert';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/data/model/body/signup_body.dart';
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: isDesktop
          ? WebMenuBar()
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
          Positioned.fill(
            child: Image.asset(
              Images.background,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.78),
                    Colors.white.withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxCardWidth =
                constraints.maxWidth > 900 ? 560 : 480;
                final double horizontalPadding =
                constraints.maxWidth > 600 ? 24 : 16;

                return Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 20,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxCardWidth),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth > 600 ? 28 : 18,
                          vertical: constraints.maxWidth > 600 ? 30 : 22,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.96),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        child: GetBuilder<AuthController>(
                          builder: (authController) {
                            return Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Container(
                                      width: constraints.maxWidth > 600 ? 94 : 84,
                                      height: constraints.maxWidth > 600 ? 94 : 84,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F8FC),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          Images.logo,
                                          width: constraints.maxWidth > 600 ? 58 : 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'إنشاء حساب',
                                    textAlign: TextAlign.center,
                                    style: robotoBlack.copyWith(
                                      fontSize:
                                      constraints.maxWidth > 600 ? 28 : 24,
                                      color: const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'أكمل البيانات التالية لإنشاء حسابك',
                                    textAlign: TextAlign.center,
                                    style: robotoRegular.copyWith(
                                      fontSize: 14,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  _buildLabel('الاسم الكامل'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _fullNameController,
                                    focusNode: _firstNameFocus,
                                    nextFocus: _emailFocus,
                                    hintText: 'أدخل الاسم الكامل',
                                    icon: Icons.person_outline_rounded,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                  ),

                                  const SizedBox(height: 16),

                                  _buildLabel('البريد الإلكتروني'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    nextFocus: _phoneFocus,
                                    hintText: 'example@email.com (اختياري)',
                                    icon: Icons.mail_outline_rounded,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                  ),

                                  const SizedBox(height: 16),

                                  _buildLabel('رقم الجوال'),
                                  const SizedBox(height: 8),
                                  _buildPhoneField(),

                                  const SizedBox(height: 16),

                                  _buildLabel('نوع المستخدم'),
                                  const SizedBox(height: 8),
                                  _buildDropdownField<String>(
                                    value: _selectedUserType,
                                    hint: 'اختر نوع المستخدم',
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'باحث عن عقار',
                                        child: Text('باحث عن عقار'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'مسوق عقاري',
                                        child: Text('مسوق عقاري'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedUserType = value;
                                      });
                                    },
                                  ),

                                  const SizedBox(height: 16),

                                  _buildLabel('نوع التسجيل'),
                                  const SizedBox(height: 8),
                                  _buildDropdownField<String>(
                                    value: _registrationType,
                                    hint: 'اختر نوع التسجيل',
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'individual',
                                        child: Text('فرد'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'organization',
                                        child: Text('منشأة'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _registrationType = value;
                                      });
                                    },
                                  ),

                                  if (_registrationType == 'organization') ...[
                                    const SizedBox(height: 16),
                                    _buildLabel('الرقم الموحد'),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _unifiedNumberController,
                                      focusNode: _unifiedNumberFocus,
                                      hintText: 'أدخل الرقم الموحد',
                                      icon: Icons.badge_outlined,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.done,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                    ),
                                  ],

                                  const SizedBox(height: 18),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: ConditionCheckBox(
                                      authController: authController,
                                    ),
                                  ),

                                  const SizedBox(height: 22),

                                  !authController.isLoading
                                      ? SizedBox(
                                    height: 54,
                                    child: CustomButton(
                                      buttonText: 'إنشاء حساب',
                                      onPressed: authController.acceptTerms
                                          ? () => _register(authController)
                                          : null,
                                    ),
                                  )
                                      : const Center(
                                    child: CircularProgressIndicator(),
                                  ),

                                  const SizedBox(height: 12),

                                  SizedBox(
                                    height: 52,
                                    child: OutlinedButton(
                                      onPressed: () => Get.toNamed(
                                        RouteHelper.getSignInRoute(
                                          RouteHelper.signUp,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Color(0xFFE5E7EB),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        'لديك حساب بالفعل؟ تسجيل الدخول',
                                        style: robotoMedium.copyWith(
                                          fontSize: 15,
                                          color: const Color(0xFF111827),
                                        ),
                                      ),
                                    ),
                                  ),
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
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: robotoMedium.copyWith(
        fontSize: 14,
        color: const Color(0xFF111827),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      style: robotoMedium.copyWith(
        fontSize: 15,
        color: const Color(0xFF111827),
      ),
      onFieldSubmitted: (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: robotoRegular.copyWith(
          fontSize: 14,
          color: const Color(0xFF9CA3AF),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF16A34A),
          size: 20,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF16A34A),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Images.saudi_flag,
                    width: 36,
                    height: 36,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+966',
                    style: robotoBold.copyWith(
                      fontSize: 15,
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
      
                // يبدأ من اليمين
                textAlign: TextAlign.left,
                textDirection: TextDirection.ltr,
      
                style: robotoMedium.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF111827),
                ),
                cursorColor: const Color(0xFF16A34A),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text;
      
                    if (text.isEmpty) {
                      return newValue;
                    }
      
                    if (!text.startsWith('5')) {
                      showCustomSnackBar('يجب أن يبدأ رقم الجوال بـ 5');
                      return oldValue;
                    }
      
                    return newValue;
                  }),
                ],
                decoration: InputDecoration(
                  hintText: '5XXXXXXXX',
                  hintStyle: robotoRegular.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5E7EB),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF16A34A),
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.red,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          hint: Text(
            hint,
            style: robotoRegular.copyWith(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _register(AuthController authController) async {
    FocusScope.of(context).unfocus();

    String fullName = _fullNameController.text.trim();
    String email = _emailController.text.trim();
    String number = _phoneController.text.trim();
    String referCode = _referCodeController.text.trim();

    if (fullName.isEmpty) {
      showCustomSnackBar('الرجاء إدخال الاسم الكامل');
      return;
    }

    if (number.isEmpty) {
      showCustomSnackBar('الرجاء إدخال رقم الجوال');
      return;
    }

    if (!number.startsWith('5')) {
      showCustomSnackBar('يجب أن يبدأ رقم الجوال بـ 5');
      return;
    }

    if (number.length != 9) {
      showCustomSnackBar('رقم الجوال يجب أن يكون 9 أرقام');
      return;
    }

    if ((_selectedUserType?.isEmpty ?? true)) {
      showCustomSnackBar('يرجى اختيار نوع المستخدم');
      return;
    }

    if (_registrationType == 'organization' &&
        _unifiedNumberController.text.trim().isEmpty) {
      showCustomSnackBar('الرجاء إدخال الرقم الموحد');
      return;
    }

    if (referCode.isNotEmpty && referCode.length != 10) {
      showCustomSnackBar('كود الإحالة غير صحيح');
      return;
    }

    final String numberWithCountryCode = '+966$number';

    SignUpBody signUpBody = SignUpBody(
      fName: fullName,
      email: email,
      phone: numberWithCountryCode,
      password: "1234567",
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
        if ((Get.find<SplashController>().configModel?.customerVerification ??
            false)) {
          List<int> encoded = utf8.encode("1234567");
          String data = base64Encode(encoded);

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