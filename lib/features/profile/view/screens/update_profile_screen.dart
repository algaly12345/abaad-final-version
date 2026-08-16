import 'dart:io';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/shared/data/models/response_model.dart';
import 'package:abaad_flutter/features/profile/data/models/userinfo_model.dart';
import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_button.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/my_text_field.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:abaad_flutter/shared/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:abaad_flutter/shared/widgets/custom_app_bar.dart';
import '../widgets/profile_bg_widget_update.dart';

/// ملاحظة: نفس أسماء الكلاسات الأصلية (UpdateProfileScreen،
/// _UpdateProfileScreenState) وكل الـ controllers/focus nodes بلا حذف —
/// التحسينات: تجميع الحقول في بطاقات بعناوين وأيقونات واضحة (معلومات
/// شخصية / روابط التواصل)، صورة بروفايل بشارة تعديل صغيرة أنيقة بدل تعتيم
/// الدائرة بالكامل، والبريد الإلكتروني أصبح اختياريًا وليس إجباريًا (يُتحقق
/// من صحة الصيغة فقط لو المستخدم كتب قيمة).
const Color kUpdateSectionColor = Color(0xFF2252A1);

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _userTypeFocus = FocusNode();

  final FocusNode _youtubeFocus = FocusNode();
  final FocusNode _snapchatFocus = FocusNode();
  final FocusNode _instagramFocus = FocusNode();
  final FocusNode _websiteFocus = FocusNode();
  final FocusNode _tiktokFocus = FocusNode();
  final FocusNode _twitterFocus = FocusNode();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();

  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _snapchatController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: CustomAppBar(title: 'profile'.tr),
      body: GetBuilder<UserController>(builder: (userController) {
        if (_phoneController.text.isEmpty) {
          _firstNameController.text = userController.userInfoModel?.name ?? '';
          _phoneController.text = userController.userInfoModel?.phone ?? '';
          _emailController.text = userController.userInfoModel?.email ?? '';
          _userTypeController.text =
              userController.userInfoModel?.agent?.membershipType ?? '';

          _youtubeController.text = userController.userInfoModel?.youtube ?? '';
          _snapchatController.text =
              userController.userInfoModel?.snapchat ?? '';
          _tiktokController.text = userController.userInfoModel?.tiktok ?? '';
          _twitterController.text = userController.userInfoModel?.twitter ?? '';
          _websiteController.text = userController.userInfoModel?.website ?? '';
          _instagramController.text =
              userController.userInfoModel?.instagram ?? '';
        }

        return _isLoggedIn
            ? userController.userInfoModel != null
            ? ProfileBgUpdateWidget(
          backButton: true,
          circularImage: _buildProfileImage(context, userController),
          mainWidget: Column(
            children: [
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(
                        Dimensions.PADDING_SIZE_SMALL),
                    child: Center(
                      child: SizedBox(
                        width: Dimensions.WEB_MAX_WIDTH,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // ============ بطاقة المعلومات الشخصية ============
                            _sectionCard(
                              context,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  _sectionBanner(
                                    isArabic: true,
                                    title: 'المعلومات الشخصية',
                                    icon: Icons.person_rounded,
                                  ),
                                  const SizedBox(height: 14),
                                  _fieldLabel(
                                    context,
                                    'full_name'.tr,
                                    Icons.badge_outlined,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'full_name'.tr,
                                    controller: _firstNameController,
                                    focusNode: _firstNameFocus,
                                    nextFocus: _lastNameFocus,
                                    inputType: TextInputType.name,
                                    capitalization:
                                    TextCapitalization.words,
                                    showBorder: true,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_LARGE),

                                  Row(
                                    children: [
                                      _fieldLabel(
                                        context,
                                        'email'.tr,
                                        Icons
                                            .alternate_email_rounded,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(اختياري)',
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions
                                              .fontSizeExtraSmall,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'email'.tr,
                                    controller: _emailController,
                                    focusNode: _emailFocus,
                                    inputAction: TextInputAction.done,
                                    inputType:
                                    TextInputType.emailAddress,
                                    showBorder: true,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_LARGE),

                                  Row(
                                    children: [
                                      _fieldLabel(
                                        context,
                                        'phone'.tr,
                                        Icons.phone_iphone_rounded,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(${'non_changeable'.tr})',
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions
                                              .fontSizeExtraSmall,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'phone'.tr,
                                    controller: _phoneController,
                                    focusNode: _phoneFocus,
                                    inputType: TextInputType.phone,
                                    showBorder: true,
                                    isEnabled: false,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_LARGE),

                                  Row(
                                    children: [
                                      _fieldLabel(
                                        context,
                                        'membership_type'.tr,
                                        Icons.verified_user_outlined,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(${'non_changeable'.tr})',
                                        style: robotoRegular.copyWith(
                                          fontSize: Dimensions
                                              .fontSizeExtraSmall,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'membership_type'.tr,
                                    controller: _userTypeController,
                                    focusNode: _userTypeFocus,
                                    inputType: TextInputType.phone,
                                    isEnabled: false,
                                    showBorder: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ============ بطاقة روابط التواصل الاجتماعي ============
                            _sectionCard(
                              context,
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  _sectionBanner(
                                    isArabic: true,
                                    title: 'روابط التواصل الاجتماعي',
                                    icon: Icons.public_rounded,
                                  ),
                                  const SizedBox(height: 14),

                                  _fieldLabel(context, 'youtube'.tr,
                                      Icons.play_circle_outline),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'youtube'.tr,
                                    controller: _youtubeController,
                                    focusNode: _youtubeFocus,
                                    nextFocus: _snapchatFocus,
                                    inputType: TextInputType.name,
                                    capitalization:
                                    TextCapitalization.words,
                                    showBorder: true,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_LARGE),

                                  _fieldLabel(
                                    context,
                                    'اسم المستخدم سناب شات'.tr,
                                    Icons.chat_bubble_outline,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'snapchat'.tr,
                                    controller: _snapchatController,
                                    focusNode: _snapchatFocus,
                                    nextFocus: _instagramFocus,
                                    inputType: TextInputType.name,
                                    capitalization:
                                    TextCapitalization.words,
                                    showBorder: true,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_LARGE),

                                  _fieldLabel(context, 'instagram'.tr,
                                      Icons.camera_alt_outlined),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'instagram'.tr,
                                    controller: _instagramController,
                                    focusNode: _instagramFocus,
                                    nextFocus: _websiteFocus,
                                    inputType: TextInputType.name,
                                    capitalization:
                                    TextCapitalization.words,
                                    showBorder: true,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_LARGE),

                                  _fieldLabel(context, 'website'.tr,
                                      Icons.language_rounded),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'website'.tr,
                                    controller: _websiteController,
                                    focusNode: _websiteFocus,
                                    nextFocus: _tiktokFocus,
                                    inputType: TextInputType.name,
                                    showBorder: true,
                                    capitalization:
                                    TextCapitalization.words,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_LARGE),

                                  _fieldLabel(
                                    context,
                                    'اسم المستخدم في tiktok'.tr,
                                    Icons.music_note_outlined,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'ادخل المستخدم'.tr,
                                    controller: _tiktokController,
                                    focusNode: _tiktokFocus,
                                    nextFocus: _twitterFocus,
                                    inputType: TextInputType.name,
                                    showBorder: true,
                                    capitalization:
                                    TextCapitalization.words,
                                  ),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_LARGE),

                                  _fieldLabel(context, 'twitter'.tr,
                                      Icons.alternate_email),
                                  const SizedBox(
                                      height: Dimensions
                                          .PADDING_SIZE_EXTRA_SMALL),
                                  MyTextField(
                                    hintText: 'twitter'.tr,
                                    controller: _twitterController,
                                    focusNode: _twitterFocus,
                                    nextFocus: _twitterFocus,
                                    showBorder: true,
                                    inputType: TextInputType.name,
                                    capitalization:
                                    TextCapitalization.words,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              !userController.isLoading
                  ? Padding(
                padding: const EdgeInsets.all(
                    Dimensions.PADDING_SIZE_SMALL),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: () =>
                        _updateProfile(userController),
                    buttonText: 'update'.tr,
                  ),
                ),
              )
                  : const Center(child: CircularProgressIndicator()),
            ],
          ),
        )
            : const Center(child: CircularProgressIndicator())
            : const NotLoggedInScreen();
      }),
    );
  }

  // ==========================================================================
  // عناصر تصميم مساعدة
  // ==========================================================================

  /// صورة البروفايل الدائرية بشارة تعديل صغيرة أنيقة في الأسفل، بدل تعتيم
  /// الدائرة بالكامل عند اللمس.
  Widget _buildProfileImage(
      BuildContext context, UserController userController) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: userController.pickedFile != null
                  ? GetPlatform.isWeb
                  ? Image.network(
                userController.pickedFile?.path ?? "",
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
                  : Image.file(
                File(userController.pickedFile?.path ?? ""),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              )
                  : CustomImage(
                image:
                '${Get.find<SplashController>().configModel?.baseUrls?.customerImageUrl ?? ""}/${userController.userInfoModel?.image}',
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: -2,
            right: -2,
            child: GestureDetector(
              onTap: () => userController.pickImage(),
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kUpdateSectionColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بطاقة موحّدة (خلفية بيضاء + حواف دائرية + ظل ناعم) تُستخدم لتجميع كل
  /// قسم من أقسام النموذج بدل عرض الحقول متتالية بلا تجميع.
  Widget _sectionCard(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  /// شريط عنوان القسم الكامل العرض بخلفية كحلية وأيقونة.
  Widget _sectionBanner({
    required bool isArabic,
    required String title,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kUpdateSectionColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// تسمية حقل بأيقونة صغيرة بجانبها بدل نص مجرّد.
  Widget _fieldLabel(BuildContext context, String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: kUpdateSectionColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).disabledColor,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // منطق الحفظ — نفس المنطق الأصلي، فقط البريد الإلكتروني أصبح اختياريًا
  // ==========================================================================

  void _updateProfile(UserController userController) async {
    String firstName = _firstNameController.text.trim();

    String email = _emailController.text.trim();
    String phoneNumber = _phoneController.text.trim();

    String snapchat = _snapchatController.text.trim();
    String youtube = _youtubeController.text.trim();
    String instagram = _instagramController.text.trim();
    String tiktok = _tiktokController.text.trim();
    String twitter = _twitterController.text.trim();
    String website = _websiteController.text.trim();

    if (userController.userInfoModel?.name == firstName &&
        userController.userInfoModel?.phone == phoneNumber &&
        userController.userInfoModel?.email == _emailController.text &&
        userController.pickedFile == null &&
        userController.userInfoModel?.snapchat == snapchat &&
        userController.userInfoModel?.youtube == youtube &&
        userController.userInfoModel?.instagram == instagram &&
        userController.userInfoModel?.tiktok == tiktok &&
        userController.userInfoModel?.twitter == twitter &&
        userController.userInfoModel?.website == website) {
      showCustomSnackBar('change_something_to_update'.tr);
    } else if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    }
    // ملاحظة: تم حذف شرط "email.isEmpty" الإجباري القديم — البريد
    // الإلكتروني أصبح اختياريًا بالكامل. لو المستخدم كتب قيمة فعلًا،
    // نتحقق فقط من أن صيغتها صحيحة (وإلا نتجاهل التحقق تمامًا لو تركه فاضي).
    else if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    } else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (phoneNumber.length < 6) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      UserInfoModel updatedUser = UserInfoModel(
        name: firstName,
        email: email,
        phone: phoneNumber,
        snapchat: _snapchatController.text.trim(),
        youtube: _youtubeController.text.trim(),
        tiktok: _tiktokController.text.trim(),
        instagram: _instagramController.text.trim(),
        website: _websiteController.text.trim(),
        twitter: _twitterController.text.trim(),
      );
      ResponseModel responseModel = await userController.updateUserInfo(
          updatedUser, Get.find<AuthController>().getUserToken());
      if (responseModel.isSuccess) {
        showCustomSnackBar('profile_updated_successfully'.tr, isError: false);
      } else {
        showCustomSnackBar(responseModel.message);
      }
    }
  }
}