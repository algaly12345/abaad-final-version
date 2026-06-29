import 'dart:async';

// import 'package:abaad_chatbot_ui/abaad_chatbot_ui.dart';
//import 'package:abaad_chatbot_ui/abaad_chatbot_ui.dart';
import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/banner_controller.dart';
import 'package:abaad_flutter/controller/category_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/controller/zone_controller.dart';
import 'package:abaad_flutter/helper/responsive_helper.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/base/custom_text_field.dart';
import 'package:abaad_flutter/view/base/drawer_menu.dart';
import 'package:abaad_flutter/view/base/not_logged_in_screen.dart';
import 'package:abaad_flutter/view/base/view_image_dilog.dart';
import 'package:abaad_flutter/view/base/web_menu_bar.dart';

import 'package:abaad_flutter/view/screen/dashboard/widget/bottom_nav_item.dart';
import 'package:abaad_flutter/view/screen/draw.dart';
import 'package:abaad_flutter/view/screen/favourite/favourite_screen.dart';
import 'package:abaad_flutter/view/screen/home/home_screen.dart'
    hide CategoryController;
import 'package:abaad_flutter/view/screen/map/map_view_screen.dart';
import 'package:abaad_flutter/view/screen/qr.dart';
import 'package:abaad_flutter/view/screen/zones/zones_screen.dart';
// import 'package:abaad_flutter/view/screen/map/map_view_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

//import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'widget/bottom_sheet_guide.dart';

class DashboardScreen extends StatefulWidget {
  final bool fromSignUp;
  final bool fromHome;
  final String route;
  final int pageIndex;

  const DashboardScreen({
    super.key,
    this.fromSignUp = false,
    this.fromHome = false,
    this.route = "",
    this.pageIndex = 0,
  });

  static Future<void> loadData(bool reload) async {
    //   Get.find<UserController>().getUserInfo();
    Get.find<AuthController>().getZoneList();
    Get.find<CategoryController>().getSubCategoryList("0");
    // Get.find<ZoneController>().getCategoryList();

    // Get.find<AuthController>().getZoneList();
    Get.find<BannerController>().getBannerList(true, 1);

    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;

  int _pageIndex = 0;

  List<Widget> _screens = [];
  final ScrollController scrollController = ScrollController();

  final ScrollController _scrollController = ScrollController();

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  @override
  void initState() {
    super.initState();
    DashboardScreen.loadData(true);
    int offset = 1;
    @override
    void initState() {
      super.initState();
      DashboardScreen.loadData(true);

      // scrollController.addListener(() {
      //   final categoryController = Get.find<CategoryController>();
      //
      //   if (scrollController.position.pixels >=
      //       scrollController.position.maxScrollExtent - 200 &&
      //       !categoryController.isPaginating &&
      //       !categoryController.isLastPage) {
      //     categoryController.getCategoryProductList(
      //       0,
      //       categoryController.subCategoryList != null &&
      //           categoryController.subCategoryList!.isNotEmpty
      //           ? categoryController
      //           .subCategoryList![categoryController.subCategoryIndex].id
      //           .toString()
      //           : "0",
      //       0,
      //       '0',
      //       '0',
      //       '0',
      //       '0',
      //       arPath: 0,
      //       sv: 0,
      //       type: '',
      //     );
      //   }
      // });
    }

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    _screens = [
      //HomeScreen(zoneId: 1,),
      MapViewScreen(),
      ZonesScreen(),
      // HomeScreen(),
      // AbaadChatbotScreen(),
      FavouriteScreen(),

      // CartScreen(fromNav: true),
      // OrderScreen(),
    ];

    Future.delayed(Duration(seconds: 5), () async {
      //_initDynamicLinks(context);

      //setState(() {});
    });

    /*if(GetPlatform.isMobile) {
      NetworkInfo.checkConnectivity(_scaffoldKey.currentContext);
    }*/
  }

  final bool _show = true;
  // @override
  // void dispose() {
  //   super.dispose();
  //   scrollController.dispose();
  // }

  bool checkingFlight = false;
  bool success = false;
  @override
  Widget build(BuildContext context) {
    // Get.find<UserController>().getUserInfo();
    // bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    return GetBuilder<UserController>(
      builder: (userController) {
        return WillPopScope(
          onWillPop: () async {
            if (_pageIndex != 0) {
              _setPage(0);
              return false;
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'back_press_again_to_exit'.tr,
                    style: TextStyle(color: Colors.white),
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                  margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                ),
              );

              // Timer(Duration(seconds: 2), () {
              //
              // });
              return false;
            }
          },

          child: Scaffold(
            key: _key,
            appBar: WebMenuBar(
              ontop: () => _key.currentState?.openDrawer(),
              fromPage: '',
            ),
            drawer: DrawerMenu(),

            floatingActionButton: _pageIndex == 2
                ? null
                : SizedBox(
                    height: 62,
                    width: 62,
                    child: FloatingActionButton(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      onPressed: () {
                        final userController = Get.find<UserController>();
                        if (userController.userInfoModel?.accountVerification != "0") {
                          Get.toNamed(RouteHelper.getAddLicenseRoute());
                        } else {
                          showBottomSheet(context);
                        }
                      },
                      child: Container(
                        height: 62,
                        width: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2E6DA4), Color(0xFF1A3C5E)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1A3C5E).withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

            floatingActionButtonLocation: _pageIndex == 2
                ? null
                : FloatingActionButtonLocation.centerDocked,

            // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: ResponsiveHelper.isDesktop(context)
                ? const SizedBox()
                : GetBuilder<AuthController>(
                    builder: (orderController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: BottomAppBar(
                            elevation: 0,
                            notchMargin: 8,
                            clipBehavior: Clip.antiAlias,
                            color: Colors.transparent,
                            shape: const CircularNotchedRectangle(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  BottomNavItem(
                                    iconData: Images.home,
                                    name: "home".tr,
                                    isSelected: _pageIndex == 0,
                                    onTap: () => _setPage(0),
                                  ),
                                  BottomNavItem(
                                    iconData: Images.menu,
                                    name: "menu".tr,
                                    isSelected: _pageIndex == 1,
                                    onTap: () => _setPage(1),
                                  ),
                                  const Expanded(child: SizedBox()),
                                  BottomNavItem(
                                    iconData: Images.request,
                                    name: "request".tr,
                                    isSelected: _pageIndex == 2,
                                    onTap: () => _setPage(2),
                                  ),
                                  BottomNavItem(
                                    iconData: Images.heart,
                                    name: "favorite".tr,
                                    isSelected: _pageIndex == 3,
                                    onTap: () => _setPage(3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            body: PageView.builder(
              controller: _pageController,
              itemCount: _screens.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return _screens[index];
              },
            ),
          ),
        );
      },
    );
  }

  // void _initDynamicLinks(context) async {
  //   FirebaseDynamicLinks.instance.onLink;
  //
  //   final PendingDynamicLinkData? data =
  //   await FirebaseDynamicLinks.instance.getInitialLink();
  //   final Uri? deepLink = data?.link;
  //
  //     // final code = deepLink.path.split('/')[1];
  //     if(deepLink != null) {
  //       handleMyLink(deepLink);
  //     }
  //   }

  void showBottomSheet(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    Get.dialog(
      GetBuilder<UserController>(
        builder: (userController) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Material(
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            // عنوان الصفحة
                            Text(
                              "توثيق الحساب بالنفاذ الوطني",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),

                            // وصف العملية
                            Text(
                              "your_account_is_not_verified_verify_the_account_through_nafath"
                                  .tr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // نص توضيحي لحقل الهوية
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "ادخل رقم الهوية الوطنية لتوثيق حسابك",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),

                            // حقل الإدخال مع تصميم
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10,
                                    color: Colors.grey[300]!,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: <Widget>[
                                  CustomTextField(
                                    hintText: '1000000000', // توضيح داخل الحقل
                                    controller: phoneController,
                                    inputType: TextInputType.phone,
                                    textAlign: TextAlign.center,
                                    divider: false,
                                  ),

                                  const SizedBox(height: 15),

                                  !userController.isLoading
                                      ? CustomButton(
                                          onPressed: () {
                                            userController.validateNafath(
                                              phoneController.text.trim(),
                                              context,
                                            );
                                          },
                                          margin: EdgeInsets.all(
                                            Dimensions.PADDING_SIZE_SMALL,
                                          ),
                                          buttonText: 'verification'.tr,
                                        )
                                      : const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void handleMyLink(Uri url) {
    List<String> sepeatedLink = [];

    /// osama.link.page/Hellow --> osama.link.page and Hellow
    sepeatedLink.addAll(url.path.split('/'));

    ////print("The Token that i'm interesed in is ${sepeatedLink[1]}");
    // Get.to(()=>EstateDetails(estate: ,));

    // Get.dialog(DettailsDilog(estate:_products[index]));
    Get.toNamed(RouteHelper.getDetailsRoute(int.parse(sepeatedLink[1])));
  }

  // buildDynamicLinks(String title,String image,String docId) async {
  //   String url = "https://abaad.page.link";
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: url,
  //     link: Uri.parse('$url/$docId'),
  //     androidParameters: AndroidParameters(
  //       packageName: "sa.pdm.abaad.abaad",
  //       minimumVersion: 0,
  //     ),
  //       iosParameters: IOSParameters(
  //           bundleId: "sa.pdm.abaad.abaad" ,
  //           minimumVersion: "2.0.6"
  //       ),
  //     socialMetaTagParameters: SocialMetaTagParameters(
  //         description: '',
  //         imageUrl:
  //         Uri.parse(image),
  //         title: title),
  //   );
  //
  //   //final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
  //
  //   // 1. Get FirebaseDynamicLinks instance
  //   final dynamicLinks = FirebaseDynamicLinks.instance;
  //
  //   // 2. Build short link
  //   final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(
  //     parameters,  // Your DynamicLinkParameters object
  //   );
  //
  //   // 3. Get the URL
  //   final dynamicUrl = shortLink.shortUrl;
  //
  //   String desc = dynamicUrl.toString();
  //
  //   await Share.share(desc, subject: title,);
  //
  // }
  void _setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
    });
  }
}

// Future<String> createDynamicLink() async {
//   final dynamicLinks = FirebaseDynamicLinks.instance;
//
//   final parameters = DynamicLinkParameters(
//     uriPrefix: 'https://yourdomain.page.link',
//     link: Uri.parse('https://yourdomain.com/?id=123'),
//     androidParameters: const AndroidParameters(
//       packageName: 'com.your.package',
//     ),
//     iosParameters: const IOSParameters(
//       bundleId: 'com.your.bundle',
//     ),
//   );
//
//   final shortLink = await dynamicLinks.buildShortLink(parameters);
//   return shortLink.shortUrl.toString();
// }

Widget listItem(int index, IconData icon, String label, Color color, onTop) {
  return InkWell(
    onTap: onTop,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 34,
                width: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color,
                ),
                child: Center(child: Icon(icon, size: 20, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
