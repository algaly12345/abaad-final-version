// import 'dart:io';
//
// import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
// import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
// import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
// import 'package:abaad_flutter/core/routes/route_helper.dart';
// import 'package:abaad_flutter/shared/utils/dimensions.dart';
// import 'package:abaad_flutter/shared/utils/images.dart';
// import 'package:abaad_flutter/shared/utils/styles.dart';
// import 'package:abaad_flutter/shared/widgets/confirmation_dialog.dart';
// import 'package:abaad_flutter/shared/widgets/custom_image.dart';
// import 'package:abaad_flutter/features/dashboard/view/screens/dashboard_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:share_plus/share_plus.dart';
//
// class DrawerMenu extends StatelessWidget {
//
//   const DrawerMenu({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
//
//     return GetBuilder<UserController>(builder: (userController) {
//       return (isLoggedIn && userController.userInfoModel == null) ? Center(child: CircularProgressIndicator()) :Drawer(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child:  ListView(
//             children: <Widget>[
//
//               UserAccountsDrawerHeader(
//                 accountName:  Text(
//                   isLoggedIn ? (userController.userInfoModel?.name ?? "") : 'guest'.tr,
//                   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge,color:  Colors.grey), ),
//
//                 accountEmail:   Row(
//                   children: [
//                     // Text(
//                     //   _isLoggedIn ? 'advertiser_no'.tr : 'guest'.tr,
//                     //   style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.grey),
//                     // ),
//                     Text(
//                       isLoggedIn ? userController.userInfoModel?.phone ?? '' : 'guest'.tr,
//                       style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.grey),
//                     ),
//                   ],
//                 ),
//                 onDetailsPressed: (){
//                   Get.toNamed(RouteHelper.getProfileRoute());
//                 },
//                 decoration:  const BoxDecoration(
//                     color: Colors.white
//
//                   // image:  DecorationImage(
//                   //   image: ExactAssetImage(Images.placeholder),
//                   //   fit: BoxFit.cover,
//                   // ),
//                 ),
//                 currentAccountPicture:  ClipOval(child: CustomImage(
//                   image: '${Get.find<SplashController>().configModel?.baseUrls?.customerImageUrl ?? ""}'
//                       '/${(isLoggedIn) ? userController.userInfoModel?.image ?? "" : ''}',
//                   height: 100, width: 100, fit: BoxFit.cover,
//                 )),
//               ),
//               listItem(1,Icons.manage_accounts_outlined, 'my_account'.tr, Colors.blueAccent,(){
//                 Get.find<UserController>().getUserInfoByID(userController.userInfoModel?.id ?? 0 );
//                 Get.find<UserController>().getEstateByUser(1, false,userController.userInfoModel?.id ?? 0 );
//                 Get.toNamed(RouteHelper.getProfileRoute());
//
//               }),
//               listItem(1,Icons.language, 'language'.tr, Colors.green,(){
//                 Get.toNamed(RouteHelper.getLanguageRoute("menu"));
//               }),
//               Divider(height: 1),
//
//               listItem(2,Icons.support_agent_outlined, 'help_support'.tr, Colors.orange,(){
//                 Get.toNamed( RouteHelper.getSupportRoute());
//               }),
//               Divider(height: 1),
//
//               listItem(3,Icons.policy, 'privacy_policy'.tr, Colors.pink,(){
//                  Get.toNamed(RouteHelper.getHtmlRoute("privacy-policy"));
//               }),
//               Divider(height: 1),
//
//               listItem(4,Icons.info, 'about_us'.tr, Colors.deepPurple,(){
//                   Get.toNamed(RouteHelper.getHtmlRoute("about-us"));
//               }),
//               Divider(height: 1),
//
//               listItem(5,Icons.list_alt, 'terms_conditions'.tr, Colors.grey,(){
//
//                      Get.toNamed(RouteHelper.getHtmlRoute("terms-and-condition"));
//               }),
//               Divider(height: 1),
//
//               listItem(6,Icons.account_balance_wallet_outlined, 'wallet'.tr, Colors.green,(){
//                 Get.toNamed(RouteHelper.getWalletRoute(true));
//               }),
//
//               Divider(height: 1),
//               Divider(height: 1),
//
//               listItem(4,Icons.share, 'share_app'.tr, Colors.deepOrangeAccent,(){
//
//                 if (Platform.isIOS) {
//                   // //print('is a IOS');
//                   Share.share('https://play.google.com/store/apps/details?id=sa.pdm.abaad.abaad', subject: 'Look what I made!');
//
//                 } else if (Platform.isAndroid) {
//                   Share.share('https://play.google.com/store/apps/details?id=sa.pdm.abaad.abaad', subject: 'Look what I made!');
//                 } else {
//                 }
//               }),
//
//               listItem(8,Icons.logout,  isLoggedIn ? 'logout'.tr : 'sign_in'.tr, Colors.orange,(){
//
//
//                 if(Get.find<AuthController>().isLoggedIn()) {
//                   Get.dialog(ConfirmationDialog(icon: Images.support, description: 'are_you_sure_to_logout'.tr, isLogOut: true, onYesPressed: () {
//                     Get.find<AuthController>().clearSharedData();
//                     // Get.find<WishListController>().removeWishes();
//                     Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
//                   }), useSafeArea: false);
//                 }
//                 else {
//                 //  Get.find<AuthController>().clearSharedData();
//                   //   Get.find<WishListController>().removeWishes();
//                   Get.toNamed(RouteHelper.getSignInRoute(RouteHelper.main));
//                 }
//               }),
//             ],
//           ),
//         ),
//       );
//
//     });
//   }
// }

import 'dart:io';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/confirmation_dialog.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/features/services/view/screens/services_hub_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({super.key});

  /// يجلب بيانات المستخدم إن كانت ناقصة — يُستدعى من initState() (أول بناء)
  /// ومن onDrawerChanged() في كل Scaffold يحتضن هذه القائمة (كل فتح للقائمة).
  /// السبب: الـ Drawer widget يُبنى مرة واحدة فقط طوال عمر الـ Scaffold ولا
  /// يُعاد بناؤه عند كل فتح/إغلاق، فإن فشل الجلب الأول (مثلاً بسبب سباق مع
  /// حفظ التوكن مباشرة بعد تسجيل الدخول) يبقى عالقاً بلا بيانات حتى إعادة
  /// تشغيل التطبيق بالكامل — بدون إعادة محاولة عند كل فتح للقائمة.
  static void ensureUserDataLoaded() {
    final userController = Get.find<UserController>();
    if (Get.find<AuthController>().isLoggedIn() &&
        userController.userInfoModel == null &&
        !userController.isLoading) {
      userController.getUserInfo();
    }
  }

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) DrawerMenu.ensureUserDataLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    final Color primaryColor = Theme.of(context).primaryColor;

    return GetBuilder<UserController>(
      builder: (userController) {
        final bool isLoadingUser =
            isLoggedIn &&
            userController.isLoading &&
            userController.userInfoModel == null;

        final String userName = isLoggedIn
            ? (userController.userInfoModel?.name ?? "")
            : 'guest'.tr;

        final String phone = isLoggedIn
            ? (userController.userInfoModel?.phone ?? '')
            : 'guest'.tr;

        final String imageUrl =
            '${Get.find<SplashController>().configModel?.baseUrls?.customerImageUrl ?? ""}'
            '/${isLoggedIn ? userController.userInfoModel?.image ?? "" : ""}';

        return Drawer(
          backgroundColor: const Color(0xFFF8F9FB),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    children: [
                      _buildHeader(
                        context: context,
                        primaryColor: primaryColor,
                        isLoggedIn: isLoggedIn,
                        isLoading: isLoadingUser,
                        userName: userName,
                        phone: phone,
                        imageUrl: imageUrl,
                      ),

                      const SizedBox(height: 18),

                      _sectionTitle('menu'.tr.isEmpty ? 'Menu' : 'menu'.tr),

                      const SizedBox(height: 10),

                      _drawerTile(
                        context: context,
                        icon: Icons.manage_accounts_outlined,
                        title: 'my_account'.tr,
                        color: Colors.blueAccent,
                        onTap: () {
                          final int userId = userController.userInfoModel?.id ?? 0;
                          if (userId > 0) {
                            Get.find<UserController>().getUserInfoByID(userId);
                            Get.find<UserController>().getEstateByUser(1, false, userId);
                          }
                          Get.toNamed(RouteHelper.getProfileRoute());
                        },
                      ),

                      _drawerTile(
                        context: context,
                        icon: Icons.language,
                        title: 'language'.tr,
                        color: Colors.green,
                        onTap: () {
                          Get.toNamed(RouteHelper.getLanguageRoute("menu"));
                        },
                      ),

                      _drawerTile(
                        context: context,
                        icon: Icons.storefront_outlined,
                        title: 'service'.tr,
                        color: Colors.indigo,
                        onTap: () {
                          Get.to(() => const ServicesHubScreen());
                        },
                      ),

                      _drawerTile(
                        context: context,
                        icon: Icons.support_agent_outlined,
                        title: 'help_support'.tr,
                        color: Colors.orange,
                        onTap: () {
                          Get.toNamed(RouteHelper.getSupportRoute());
                        },
                      ),

                      _drawerTile(
                        context: context,
                        icon: Icons.policy_outlined,
                        title: 'privacy_policy'.tr,
                        color: Colors.pink,
                        onTap: () {
                          Get.toNamed(
                            RouteHelper.getHtmlRoute("privacy-policy"),
                          );
                        },
                      ),

                      _drawerTile(
                        context: context,
                        icon: Icons.info_outline,
                        title: 'about_us'.tr,
                        color: Colors.deepPurple,
                        onTap: () {
                          Get.toNamed(RouteHelper.getHtmlRoute("about-us"));
                        },
                      ),

                      _drawerTile(
                        context: context,
                        icon: Icons.list_alt_outlined,
                        title: 'terms_conditions'.tr,
                        color: Colors.grey,
                        onTap: () {
                          Get.toNamed(
                            RouteHelper.getHtmlRoute("terms-and-condition"),
                          );
                        },
                      ),

                      _drawerTile(
                        context: context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'wallet'.tr,
                        color: Colors.teal,
                        onTap: () {
                          Get.toNamed(RouteHelper.getWalletRoute(true));
                        },
                      ),

                      _drawerTile(
                        context: context,
                        icon: Icons.share_outlined,
                        title: 'share_app'.tr,
                        color: Colors.deepOrangeAccent,
                        onTap: () {
                          Share.share(
                            'https://play.google.com/store/apps/details?id=sa.pdm.abaad.abaad',
                            subject: 'Abaad App',
                          );
                        },
                      ),

                      _drawerTile(
                        context: context,
                        icon: Icons.logout,
                        title: isLoggedIn ? 'logout'.tr : 'sign_in'.tr,
                        color: Colors.redAccent,
                        onTap: () {
                          if (Get.find<AuthController>().isLoggedIn()) {
                            Get.dialog(
                              ConfirmationDialog(
                                icon: Images.support,
                                description: 'are_you_sure_to_logout'.tr,
                                isLogOut: true,
                                onYesPressed: () {
                                  Get.find<AuthController>().clearSharedData();
                                  Get.offAllNamed(
                                    RouteHelper.getSignInRoute(
                                      RouteHelper.splash,
                                    ),
                                  );
                                },
                              ),
                              useSafeArea: false,
                            );
                          } else {
                            Get.toNamed(
                              RouteHelper.getSignInRoute(RouteHelper.main),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),

                _buildContactSection(context, primaryColor),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader({
    required BuildContext context,
    required Color primaryColor,
    required bool isLoggedIn,
    required bool isLoading,
    required String userName,
    required String phone,
    required String imageUrl,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (isLoggedIn) {
          Get.toNamed(RouteHelper.getProfileRoute());
        }
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withValues(alpha: 0.82)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.7),
                  width: 2,
                ),
                color: Colors.white,
              ),
              child: ClipOval(
                child: isLoggedIn && imageUrl.isNotEmpty
                    ? CustomImage(
                        image: imageUrl,
                        fit: BoxFit.cover,
                        height: 68,
                        width: 68,
                      )
                    : Icon(Icons.person, size: 34, color: primaryColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoRegular.copyWith(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      isLoggedIn ? 'View profile' : 'Welcome',
                      style: robotoMedium.copyWith(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey.shade700),
      ),
    );
  }

  Widget _drawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: Colors.grey.shade900,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Abaad',
            style: robotoBold.copyWith(fontSize: 16, color: primaryColor),
          ),
          const SizedBox(height: 4),
          Text(
            'تواصل مع شركة أبعاد',
            style: robotoRegular.copyWith(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _socialButton(
                icon: Icons.language,
                label: 'Website',
                color: Colors.blue,
                onTap: () => _launchUrl('https://abaadapp.sa/'),
              ),
              _socialButton(
                icon: Icons.email_outlined,
                label: 'Email',
                color: Colors.redAccent,
                onTap: () => _launchUrl('mailto:info@abaadapp.sa'),
              ),
              _socialButton(
                icon: Icons.phone_outlined,
                label: 'Call',
                color: Colors.green,
                onTap: () => _launchUrl('tel:+966503731637'),
              ),
              _socialButton(
                icon: Icons.chat_outlined,
                label: 'WhatsApp',
                color: Colors.teal,
                onTap: () => _launchUrl('https://wa.me/966503731637'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
