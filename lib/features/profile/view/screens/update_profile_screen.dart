import 'dart:io';

import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/profile/data/models/userinfo_model.dart';
import 'package:abaad_flutter/features/provider/data/repositories/service_offer_repo.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/data/models/response_model.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// شاشة تعديل الملف الشخصي — بنظام التصميم نفسه المستخدم في شاشات المزوّد
/// (شريط علوي مسطّح، بطاقات DSCard، حقول dsInputDecoration، زر DSPrimaryButton
/// سفلي مثبّت) وبنصوص مترجمة بالكامل عبر مفاتيح اللغة. منطق الحفظ دون تغيير:
/// البريد اختياري (تُفحص الصيغة فقط إن كُتب)، والجوال ونوع العضوية للقراءة فقط.
class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();

  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _snapchatController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();

  // بيانات التوثيق (الرقم الموحّد + السجل التجاري) — تظهر لمزوّد الخدمة فقط،
  // وتُحفظ عبر update-identity لا عبر updateUserInfo (حقول مختلفة بالباكند).
  final TextEditingController _unifiedController = TextEditingController();
  final TextEditingController _crController = TextEditingController();
  bool _verificationFilled = false;
  bool _savingVerification = false;
  // يأتي من زر "أكمل ملفك" في إحصائيات المزوّد: تُرفع بطاقة التوثيق لأعلى
  // الشاشة لأنها الناقص غالبًا.
  late final bool _verificationFirst =
      Get.arguments is Map && Get.arguments['focus_verification'] == true;
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if (_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
    Get.find<UserController>().initData();
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _userTypeController,
      _youtubeController,
      _snapchatController,
      _instagramController,
      _websiteController,
      _tiktokController,
      _twitterController,
      _unifiedController,
      _crController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _fillControllers(UserController userController) {
    final user = userController.userInfoModel;
    if (_phoneController.text.isEmpty) {
      _nameController.text = user?.name ?? '';
      _phoneController.text = user?.phone ?? '';
      _emailController.text = user?.email ?? '';
      _userTypeController.text = user?.agent?.membershipType ?? '';
      _youtubeController.text = user?.youtube ?? '';
      _snapchatController.text = user?.snapchat ?? '';
      _tiktokController.text = user?.tiktok ?? '';
      _twitterController.text = user?.twitter ?? '';
      _websiteController.text = user?.website ?? '';
      _instagramController.text = user?.instagram ?? '';
    }
    if (!_verificationFilled && user != null) {
      _verificationFilled = true;
      _unifiedController.text = user.unified_number ?? '';
      final cr = user.provider?.commercialRegistrationNo;
      // 'pending' قيمة وهمية من مسارات تسجيل قديمة — لا تُعرَض كبيانات.
      _crController.text =
          (cr == null || cr == 'pending' || cr == 'commercial_registration_no')
              ? ''
              : cr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: GetBuilder<UserController>(builder: (userController) {
              if (!_isLoggedIn) return const NotLoggedInScreen();
              if (userController.userInfoModel == null) {
                return const Center(child: CircularProgressIndicator());
              }
              _fillControllers(userController);
              final showVerification =
                  userController.userInfoModel?.provider != null;

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(Spacing.pagePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(child: _buildAvatar(context, userController)),
                          const SizedBox(height: Spacing.xl),
                          if (showVerification && _verificationFirst) ...[
                            _verificationCard(context),
                            const SizedBox(height: Spacing.lg),
                          ],
                          _personalCard(context),
                          const SizedBox(height: Spacing.lg),
                          _socialCard(context),
                          if (showVerification && !_verificationFirst) ...[
                            const SizedBox(height: Spacing.lg),
                            _verificationCard(context),
                          ],
                          const SizedBox(height: Spacing.sm),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(context, userController),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── شريط علوي مطابق لشاشات المزوّد: خلفية مسطّحة + زرّ رجوع دائري + عنوان
  // في المنتصف الحقيقي.
  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface(context),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              onTap: Get.back,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: AppColors.primary(context)),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: Text(
                'profile'.tr,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.smallBold.copyWith(
                    fontSize: 17, color: AppColors.textPrimary(context)),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, UserController userController) {
    const size = 96.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface(context),
            boxShadow: AppShadows.card(context),
          ),
          child: ClipOval(
            child: userController.pickedFile != null
                ? (GetPlatform.isWeb
                    ? Image.network(userController.pickedFile!.path,
                        width: size, height: size, fit: BoxFit.cover)
                    : Image.file(File(userController.pickedFile!.path),
                        width: size, height: size, fit: BoxFit.cover))
                : CustomImage(
                    image:
                        '${Get.find<SplashController>().configModel?.baseUrls?.customerImageUrl ?? ""}/${userController.userInfoModel?.image}',
                    height: size,
                    width: size,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        PositionedDirectional(
          bottom: -2,
          end: -2,
          child: GestureDetector(
            onTap: userController.pickImage,
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primary(context),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface(context), width: 2.5),
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ─── البطاقات ─────────────────────────────────────────────────────────

  Widget _personalCard(BuildContext context) {
    return _section(
      context,
      icon: Icons.person_outline_rounded,
      title: 'personal_information'.tr,
      children: [
        _field(context,
            label: 'full_name'.tr,
            controller: _nameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words),
        _field(context,
            label: 'email'.tr,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            optional: true,
            ltr: true),
        _field(context,
            label: 'phone'.tr,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            readOnly: true,
            ltr: true),
        _field(context,
            label: 'membership_type'.tr,
            controller: _userTypeController,
            readOnly: true),
      ],
    );
  }

  Widget _socialCard(BuildContext context) {
    return _section(
      context,
      icon: Icons.public_rounded,
      title: 'social_links'.tr,
      children: [
        _field(context,
            label: 'youtube_label'.tr,
            controller: _youtubeController,
            optional: true,
            ltr: true),
        _field(context,
            label: 'snapchat_username'.tr,
            controller: _snapchatController,
            optional: true,
            ltr: true),
        _field(context,
            label: 'instagram_label'.tr,
            controller: _instagramController,
            optional: true,
            ltr: true),
        _field(context,
            label: 'website_label'.tr,
            controller: _websiteController,
            keyboardType: TextInputType.url,
            optional: true,
            ltr: true),
        _field(context,
            label: 'tiktok_username'.tr,
            controller: _tiktokController,
            optional: true,
            ltr: true),
        _field(context,
            label: 'twitter_x_label'.tr,
            controller: _twitterController,
            optional: true,
            ltr: true),
      ],
    );
  }

  /// بطاقة "بيانات التوثيق" لمزوّد الخدمة: الرقم الموحّد + السجل التجاري، بحفظ
  /// مستقل عبر update-identity (زر الحفظ الرئيسي أسفل الشاشة لا يمسّهما).
  Widget _verificationCard(BuildContext context) {
    final unified = _unifiedController.text.trim();
    final cr = _crController.text.trim();
    final unifiedBad =
        unified.isNotEmpty && !RegExp(r'^70\d{8}$').hasMatch(unified);
    final crBad = cr.isNotEmpty && !RegExp(r'^\d{10}$').hasMatch(cr);

    return _section(
      context,
      icon: Icons.verified_outlined,
      title: 'verification_data_title'.tr,
      children: [
        _field(context,
            label: 'unified_number_option'.tr,
            hint: 'unified_number_example'.tr,
            controller: _unifiedController,
            keyboardType: TextInputType.number,
            ltr: true,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
            errorText: unifiedBad ? 'unified_number_error'.tr : null,
            onChanged: (_) => setState(() {})),
        _field(context,
            label: 'commercial_registration_option'.tr,
            hint: 'commercial_registration_example'.tr,
            controller: _crController,
            keyboardType: TextInputType.number,
            ltr: true,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 10,
            errorText: crBad ? 'commercial_registration_error'.tr : null,
            onChanged: (_) => setState(() {})),
        DSPrimaryButton(
          label: 'save_verification_data'.tr,
          loading: _savingVerification,
          onPressed: (unifiedBad || crBad || (unified.isEmpty && cr.isEmpty))
              ? null
              : _saveVerification,
        ),
      ],
    );
  }

  Widget _section(
    BuildContext context, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return DSCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                  child: Icon(icon,
                      size: IconSpec.small, color: AppColors.primary(context)),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(title,
                      style: AppTypography.bodyBold
                          .copyWith(color: AppColors.textPrimary(context))),
                ),
              ],
            ),
            const SizedBox(height: Spacing.lg),
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: Spacing.lg),
              children[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool optional = false,
    bool readOnly = false,
    bool ltr = false,
    List<TextInputFormatter>? formatters,
    int? maxLength,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    final secondary = AppColors.textSecondary(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(label,
                  style: AppTypography.small
                      .copyWith(color: AppColors.textPrimary(context))),
            ),
            if (optional) ...[
              const SizedBox(width: Spacing.xs),
              Text('(${'optional_label'.tr})',
                  style: AppTypography.caption.copyWith(color: secondary)),
            ],
            if (readOnly) ...[
              const SizedBox(width: Spacing.xs),
              Text('(${'non_changeable'.tr})',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.danger)),
            ],
          ],
        ),
        const SizedBox(height: Spacing.sm),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          enabled: !readOnly,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: formatters,
          maxLength: maxLength,
          onChanged: onChanged,
          textDirection: ltr ? TextDirection.ltr : null,
          textAlign: ltr ? TextAlign.right : TextAlign.start,
          style: AppTypography.body.copyWith(
              color: readOnly ? secondary : AppColors.textPrimary(context)),
          decoration: dsInputDecoration(context, hint: hint, errorText: errorText)
              .copyWith(counterText: ''),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, UserController userController) {
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
            label: 'update'.tr,
            loading: userController.isLoading,
            onPressed: () => _updateProfile(userController),
          ),
        ),
      ),
    );
  }

  // ─── حفظ بيانات التوثيق ──────────────────────────────────────────────

  Future<void> _saveVerification() async {
    final userController = Get.find<UserController>();
    final provider = userController.userInfoModel?.provider;
    setState(() => _savingVerification = true);
    // repo محلي (لا Get.find) لأن ServiceOfferRepo lazyPut ويُتلف بين المسارات.
    final response = await ServiceOfferRepo(apiClient: Get.find<ApiClient>())
        .updateIdentity(
      entityType: provider?.identityType == 'company'
          ? 'organization'
          : (provider?.identityType ?? 'individual'),
      commercialRegistrationNo:
          _crController.text.trim().isEmpty ? null : _crController.text.trim(),
      unifiedNumber: _unifiedController.text.trim().isEmpty
          ? null
          : _unifiedController.text.trim(),
    );
    if (response.statusCode == 200 && response.body['status'] == 'success') {
      await userController.getUserInfo();
      showCustomSnackBar('verification_data_saved'.tr, isError: false);
    } else {
      final body = response.body;
      showCustomSnackBar((body is Map ? body['message'] : null)?.toString() ??
          'something_went_wrong'.tr);
    }
    if (mounted) setState(() => _savingVerification = false);
  }

  // ─── حفظ الملف الشخصي — نفس المنطق الأصلي ────────────────────────────

  void _updateProfile(UserController userController) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final snapchat = _snapchatController.text.trim();
    final youtube = _youtubeController.text.trim();
    final instagram = _instagramController.text.trim();
    final tiktok = _tiktokController.text.trim();
    final twitter = _twitterController.text.trim();
    final website = _websiteController.text.trim();
    final current = userController.userInfoModel;

    if (current?.name == name &&
        current?.phone == phone &&
        current?.email == email &&
        userController.pickedFile == null &&
        current?.snapchat == snapchat &&
        current?.youtube == youtube &&
        current?.instagram == instagram &&
        current?.tiktok == tiktok &&
        current?.twitter == twitter &&
        current?.website == website) {
      showCustomSnackBar('change_something_to_update'.tr);
    } else if (name.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    } else if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      // البريد اختياري: نتحقق من الصيغة فقط لو كتب المستخدم قيمة.
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    } else if (phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (phone.length < 6) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      final updatedUser = UserInfoModel(
        name: name,
        email: email,
        phone: phone,
        snapchat: snapchat,
        youtube: youtube,
        tiktok: tiktok,
        instagram: instagram,
        website: website,
        twitter: twitter,
      );
      final ResponseModel responseModel = await userController.updateUserInfo(
          updatedUser, Get.find<AuthController>().getUserToken());
      if (responseModel.isSuccess) {
        showCustomSnackBar('profile_updated_successfully'.tr, isError: false);
      } else {
        showCustomSnackBar(responseModel.message);
      }
    }
  }
}
