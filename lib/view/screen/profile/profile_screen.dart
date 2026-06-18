import 'dart:io';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/theme_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/confirmation_dialog.dart';
import 'package:abaad_flutter/view/base/custom_app_bar.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/screen/profile/widget/profile_button.dart';
import 'package:abaad_flutter/view/screen/profile/widget/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:url_launcher/url_launcher.dart';
import '../../../util/images.dart';
import 'widget/profile_bg_widget.dart';
import 'widget/profile_button_mode.dart';
import 'package:share_plus/share_plus.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isLoggedIn;
  final int _rating = 0;
  @override
  void initState() {
    super.initState();
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    if(_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  CustomAppBar(title: 'profile'.tr),
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<UserController>(builder: (userController) {
        return (_isLoggedIn && userController.userInfoModel == null) ? Center(child: CircularProgressIndicator()) :
        ProfileBgWidget(
          backButton: true,
          circularImage: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.topRight,
                  child: ClipOval(child: CustomImage(
                    image: '${Get.find<SplashController>().configModel?.baseUrls?.customerImageUrl}'
                        '/${(_isLoggedIn) ? userController.userInfoModel?.image : ''}',
                    height: 100, width: 100, fit: BoxFit.cover,
                  )),
                ),
              ),

              Container(
                alignment: Alignment.topRight,
                child: Column(
                  children: [

                    Text(
                      _isLoggedIn ?? false ? userController.userInfoModel?.name ?? "" : 'guest'.tr,
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                    ),

                    // Text(
                    //   _isLoggedIn&& userController.userInfoModel.userinfo.membershipType==null? '${userController.userInfoModel.userinfo.membershipType}' : 'guest'.tr,
                    //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          mainWidget: SingleChildScrollView(physics: BouncingScrollPhysics(), child: Center(child: Container(
            width: Dimensions.WEB_MAX_WIDTH, color: Theme.of(context).cardColor,
            padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            child: Column(children: [

              SizedBox(height: 10),
              _isLoggedIn ? Column(children: [

                Row(children: [
                  ProfileCard(title: 'setting_profile'.tr, image: Images.setting_profile,index: 1),
                  SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                  ProfileCard(title: 'wallet'.tr, image: Images.property_profile,index:2),
                ]),
              ]) : SizedBox(),
              SizedBox(height: _isLoggedIn ? 30 : 0),
              ProfileButton(icon: Icons.language, title: 'language'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                Get.toNamed(RouteHelper.getLanguageRoute("menu"));
              }),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              ProfileButtonMode(icon: Icons.dark_mode, title: 'dark_mode'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                Get.find<ThemeController>().toggleTheme();
              }),

              SizedBox(height: _isLoggedIn ? Dimensions.PADDING_SIZE_SMALL : 5),
              ProfileButton(
                icon: Icons.generating_tokens,
                title: 'your_rating'.tr,
                isButtonActive: Get.isDarkMode,
                onTap: () async {
                  const String appId = "sa.pdm.abaad.abaad";

                  final Uri url = Uri.parse(
                    'market://details?id=$appId',
                  );

                  final Uri fallbackUrl = Uri.parse(
                    'https://play.google.com/store/apps/details?id=$appId',
                  );

                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    await launchUrl(
                      fallbackUrl,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
              ),



              //
              // SizedBox(height: _isLoggedIn ? Dimensions.PADDING_SIZE_SMALL : 5),
              // ProfileButton(icon: Icons.supervised_user_circle_outlined, title: 'membership_modification'.tr, isButtonActive: Get.isDarkMode, onTap: () {
              //   Get.toNamed(RouteHelper.getAgentRegister());
              // }),


              _isLoggedIn ? SizedBox(height: _isLoggedIn ? Dimensions.PADDING_SIZE_SMALL : 5):Container(),
              _isLoggedIn ? ProfileButton(icon: Icons.ads_click, title: 'my_ads'.tr, isButtonActive: Get.isDarkMode, onTap: ()async {
                Get.find<UserController>().getUserInfoByID(userController.userInfoModel?.id ?? 0 );
                Get.toNamed(RouteHelper.getProfileAgentRoute(userController.userInfoModel?.id ?? 0 ,1));
                // Get.find<ThemeController>().toggleTheme();
              }):Container(),

              // SizedBox(height: _isLoggedIn ? Dimensions.PADDING_SIZE_SMALL : 5),
              // ProfileButton(icon: Icons.subscriptions_outlined, title: 'subscribe_type'.tr, isButtonActive: Get.isDarkMode, onTap: () {
              //   showCustomSnackBar("الإشتراك غير متاح حاليا");
              //   // Get.find<ThemeController>().toggleTheme();
              // }),
              SizedBox(height: _isLoggedIn ? Dimensions.PADDING_SIZE_SMALL : 5),
              ProfileButton(icon: Icons.share, title: 'share_app'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                if (Platform.isIOS) {
                  // //print('is a IOS');
                  Share.share('https://play.google.com/store/apps/details?id=sa.pdm.abaad.abaad', subject: 'Look what I made!');

                } else if (Platform.isAndroid) {
                  Share.share('https://play.google.com/store/apps/details?id=sa.pdm.abaad.abaad', subject: 'Look what I made!');
                } else {
                }
              }),
              SizedBox(height: _isLoggedIn ? Dimensions.PADDING_SIZE_SMALL : 5),
              _isLoggedIn ? ProfileButton(
                icon: Icons.delete, title: 'delete_account'.tr,
                onTap: () {
                  Get.dialog(ConfirmationDialog(icon: Images.support,
                    title: 'are_you_sure_to_delete_account'.tr,
                    description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
                    onYesPressed: () => userController.removeUser(),
                  ), useSafeArea: false);
                }, isButtonActive: true,
              ) : SizedBox(),
              // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
              // _isLoggedIn ? GetBuilder<AuthController>(builder: (authController) {
              //   return ProfileButton(
              //     icon: Icons.notifications, title: 'notification'.tr,
              //     isButtonActive: authController.notification, onTap: () {
              //     authController.setNotificationActive(!authController.notification);
              //   },
              //   );
              // }) : SizedBox(),
              SizedBox(height: _isLoggedIn ? Dimensions.PADDING_SIZE_SMALL : 5),
              //

              ProfileButton(icon: Icons.edit, title: 'edit_profile'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                Get.toNamed(RouteHelper.getUpdateProfileRoute());
              }),

              SizedBox(height: _isLoggedIn ? Dimensions.PADDING_SIZE_SMALL : Dimensions.PADDING_SIZE_LARGE),

              ProfileButton(icon: Icons.list_alt, title: 'terms_conditions'.tr, isButtonActive: Get.isDarkMode, onTap: () {
                Get.toNamed(RouteHelper.getHtmlRoute("terms_conditions"));
              }),
              // _isLoggedIn ? ProfileButton(
              //   icon: Icons.delete, title: 'delete_account'.tr,
              //   onTap: () {
              //     // Get.dialog(ConfirmationDialog(icon: Images.support,
              //     //   title: 'are_you_sure_to_delete_account'.tr,
              //     //   description: 'it_will_remove_your_all_information'.tr, isLogOut: true,
              //     //   onYesPressed: () => userController.removeUser(),
              //     // ), useSafeArea: false);
              //   },
              // ) : SizedBox(),
              SizedBox(height: _isLoggedIn ? Dimensions.PADDING_SIZE_LARGE : 5),

              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${'version'.tr}:', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                Text(AppConstants.APP_VERSION.toString(), style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
              ]),

            ]),
          ))),
        );
      }),
    );
  }





}

