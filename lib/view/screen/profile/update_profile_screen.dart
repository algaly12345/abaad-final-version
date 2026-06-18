import 'dart:io';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/data/model/response/response_model.dart';
import 'package:abaad_flutter/data/model/response/userinfo_model.dart';
import 'package:abaad_flutter/helper/responsive_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/base/my_text_field.dart';
import 'package:abaad_flutter/view/base/not_logged_in_screen.dart';
import 'package:abaad_flutter/view/base/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/custom_app_bar.dart';
import 'widget/profile_bg_widget_update.dart';

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
    if(_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
    Get.find<UserController>().initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar:  CustomAppBar(title: 'profile'.tr),
      body: GetBuilder<UserController>(builder: (userController) {
        if(_phoneController.text.isEmpty) {
          _firstNameController.text = userController.userInfoModel?.name ?? '';
          _phoneController.text = userController.userInfoModel?.phone ?? '';
          _emailController.text = userController.userInfoModel?.email ?? '';
          _userTypeController.text = userController.userInfoModel?.agent?.membershipType ?? '';


          _youtubeController.text = userController.userInfoModel?.youtube ?? '';
          _snapchatController.text = userController.userInfoModel?.snapchat ?? '';
          _tiktokController.text = userController.userInfoModel?.tiktok ?? '';
          _twitterController.text = userController.userInfoModel?.twitter?? '';
          _websiteController.text = userController.userInfoModel?.website ?? '';
          _instagramController.text = userController.userInfoModel?.instagram?? '';

        }

        return _isLoggedIn ? userController.userInfoModel != null ? ProfileBgUpdateWidget(
          backButton: true,
          circularImage: Center(child: Stack(children: [
            ClipOval(child: userController.pickedFile != null ? GetPlatform.isWeb ? Image.network(
              userController.pickedFile?.path ?? "", width: 100, height: 100, fit: BoxFit.cover,
            ) : Image.file(
              File(userController.pickedFile?.path ?? ""), width: 100, height: 100, fit: BoxFit.cover,
            ) : CustomImage(
              image: '${Get.find<SplashController>().configModel?.baseUrls?.customerImageUrl ?? ""}/${userController.userInfoModel?.image}',
              height: 100, width: 100, fit: BoxFit.cover,
            )),
            Positioned(
              bottom: 0, right: 0, top: 0, left: 0,
              child: InkWell(
                onTap: () => userController.pickImage(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3), shape: BoxShape.circle,
                    border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.white),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.white),
                  ),
                ),
              ),
            ),
          ])),
          mainWidget: Column(children: [

            Expanded(child: Scrollbar(child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                Text(
                  'full_name'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'full_name'.tr,
                  controller: _firstNameController,
                  focusNode: _firstNameFocus,
                  nextFocus: _lastNameFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  showBorder: true,
                ),

                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Text(
                  'email'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'email'.tr,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  inputAction: TextInputAction.done,
                  inputType: TextInputType.emailAddress,
                  showBorder: true,
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Row(children: [
                  Text(
                    'phone'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text('(${'non_changeable'.tr})', style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error,
                  )),
                ]),


                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'phone'.tr,
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  inputType: TextInputType.phone,
                  showBorder: true,
                  isEnabled: false,
                ),



                SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

                Row(children: [
                  Text(
                    'membership_type'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                  ),
                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  Text('(${'non_changeable'.tr})', style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).colorScheme.error,
                  )),
                ]),


                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'membership_type'.tr,
                  controller: _userTypeController,
                  focusNode: _userTypeFocus,
                  inputType: TextInputType.phone,
                  isEnabled: false,
                  showBorder: true,
                ),





                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Text(
                  'youtube'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'youtube'.tr,
                  controller: _youtubeController,
                  focusNode: _youtubeFocus,
                  nextFocus: _snapchatFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  showBorder: true,
                ),


                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Text(
                  'اسم المستخدم سناب شات'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'snapchat'.tr,
                  controller: _snapchatController,
                  focusNode: _snapchatFocus,
                  nextFocus: _instagramFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  showBorder: true,
                ),



                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Text(
                  'instagram'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'instagram'.tr,
                  controller: _instagramController,
                  focusNode: _instagramFocus,
                  nextFocus: _websiteFocus,
                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                  showBorder: true,
                ),



                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Text(
                  'website'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'website'.tr,
                  controller: _websiteController,
                  focusNode: _websiteFocus,
                  nextFocus: _tiktokFocus,
                  inputType: TextInputType.name,
                  showBorder: true,
                  capitalization: TextCapitalization.words,
                ),



                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Text(
                  'اسم المستخدم في tiktok'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'ادخل المستخدم'.tr,
                  controller: _tiktokController,
                  focusNode: _tiktokFocus,
                  nextFocus: _twitterFocus,
                  inputType: TextInputType.name,
                  showBorder: true,
                  capitalization: TextCapitalization.words,
                ),



                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Text(
                  'twitter'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                MyTextField(
                  hintText: 'twitter'.tr,
                  controller: _twitterController,
                  focusNode: _twitterFocus,
                  nextFocus: _twitterFocus,
                  showBorder: true,

                  inputType: TextInputType.name,
                  capitalization: TextCapitalization.words,
                ),


              ]))),
            ))),

            !userController.isLoading ? CustomButton(
              onPressed: () => _updateProfile(userController),
              margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              buttonText: 'update'.tr,
            ) : Center(child: CircularProgressIndicator()),

          ]),
        ) : Center(child: CircularProgressIndicator()) : NotLoggedInScreen();
      }),
    );
  }

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

    if (userController.userInfoModel?.name == firstName && userController.userInfoModel?.phone == phoneNumber &&
        userController.userInfoModel?.email == _emailController.text && userController.pickedFile == null
        && userController.userInfoModel?.snapchat == snapchat && userController.userInfoModel?.youtube == youtube
        && userController.userInfoModel?.instagram == instagram&& userController.userInfoModel?.tiktok == tiktok
        && userController.userInfoModel?.twitter == twitter && userController.userInfoModel?.website == website) {
      showCustomSnackBar('change_something_to_update'.tr);
    }else if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    }else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    }else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    }else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    }else if (phoneNumber.length < 6) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else {
      UserInfoModel updatedUser = UserInfoModel(name: firstName, email: email,
          phone: phoneNumber,
          snapchat: _snapchatController.text.trim(),
        youtube: _youtubeController.text.trim(),
        tiktok: _tiktokController.text.trim(),
        instagram: _instagramController.text.trim(),
        website: _websiteController.text.trim(),
          twitter: _twitterController.text.trim()
      );
      ResponseModel responseModel = await userController.updateUserInfo(updatedUser, Get.find<AuthController>().getUserToken());
      if(responseModel.isSuccess) {
        showCustomSnackBar('profile_updated_successfully'.tr, isError: false);
      }else {
        showCustomSnackBar(responseModel.message);
      }
    }
  }
}
