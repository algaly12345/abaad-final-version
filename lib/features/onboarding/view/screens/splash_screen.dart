// import 'dart:async';
//
// import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
// import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
// import 'package:abaad_flutter/features/map/controller/location_controller.dart';
// import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
// import 'package:abaad_flutter/features/notification/data/models/notification_body.dart';
// import 'package:abaad_flutter/shared/data/models/estate_model.dart';
// import 'package:abaad_flutter/core/routes/route_helper.dart';
// import 'package:abaad_flutter/shared/utils/app_constants.dart';
// import 'package:abaad_flutter/shared/utils/dimensions.dart';
// import 'package:abaad_flutter/shared/utils/images.dart';
// import 'package:abaad_flutter/shared/utils/styles.dart';
// import 'package:abaad_flutter/shared/widgets/no_internet_screen.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// // import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../controller/wishlist_controller.dart';
//
// class SplashScreen extends StatefulWidget {
//   final NotificationBody body;
//   const SplashScreen({super.key, required this.body});
//
//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
//   late StreamSubscription<ConnectivityResult> _onConnectivityChanged;
//   late Timer _timer;
//
//   @override
//   void initState() {
//     super.initState();
//
//     bool firstTime = true;
//     // _onConnectivityChanged = Connectivity()
//     //     .onConnectivityChanged
//     //     .listen((ConnectivityResult result) {
//     //   if (!firstTime) {
//     //     bool isNotConnected = result != ConnectivityResult.wifi &&
//     //         result != ConnectivityResult.mobile;
//     //     isNotConnected
//     //         ? SizedBox()
//     //         : ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//     //       backgroundColor: isNotConnected ? Colors.red : Colors.green,
//     //       duration: Duration(seconds: isNotConnected ? 6000 : 3),
//     //       content: Text(
//     //         isNotConnected ? 'no_connection'.tr : 'connected'.tr,
//     //         textAlign: TextAlign.center,
//     //       ),
//     //     ));
//     //     if (!isNotConnected) {
//     //       _route();
//     //     }
//     //   }
//     //   firstTime = false;
//     // });
//
//     Get.find<SplashController>().initSharedData();
//     if ((Get.find<LocationController>().getUserAddress()?.zoneData == null)) {
//       Get.find<AuthController>().clearSharedAddress();
//     }
//     // Get.find<CartController>().getCartData();
//     _route();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//
//     _onConnectivityChanged.cancel();
//   }
//
//
//   void _route() {
//     Get.find<SplashController>().getConfigData().then((isSuccess) {
//       if(isSuccess) {
//         Timer(const Duration(seconds: 1), () async {
//           int ? minimumVersion = 0;
//           if(GetPlatform.isAndroid) {
//             minimumVersion = Get.find<SplashController>().configModel!.appMinimumVersionAndroid;
//           }else if(GetPlatform.isIOS) {
//             minimumVersion = Get.find<SplashController>().configModel!.appMinimumVersionIos;
//           }
//           if(AppConstants.APP_VERSION < minimumVersion! || Get.find<SplashController>().configModel!.maintenanceMode!) {
//             Get.offNamed(RouteHelper.getUpdateRoute(AppConstants.APP_VERSION < minimumVersion));
//           }else {
//             if (Get.find<AuthController>().isLoggedIn()) {
//               //  Get.find<AuthController>().updateToken();
//               await Get.find<WishListController>().getWishList();
//               if (Get.find<LocationController>().getUserAddress() != null) {
//                 Get.offNamed(RouteHelper.getInitialRoute( ));
//               } else {
//                 Get.offNamed(RouteHelper.getInitialRoute( ));
//               }
//             } else {
//               if (Get.find<SplashController>().showIntro()!) {
//                 if(AppConstants.languages.length > 1) {
//                   Get.offNamed(RouteHelper.getLanguageRoute('splash'));
//                 }else {
//                   Get.offNamed(RouteHelper.getOnBoardingRoute());
//                 }
//               } else {
//                 Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
//               }
//             }
//           }
//         });
//       }
//     });
//   }
//
//   open_app(){
//     if (Get.find<AuthController>().isLoggedIn()) {
//       //Get.find<AuthController>().updateToken();
//       //   await Get.find<WishListController>().getWishList();
//       if (Get.find<LocationController>().getUserAddress() != null) {
//         Get.offNamed(RouteHelper.getInitialRoute());
//       } else {
//         Get.offNamed(RouteHelper.getAccessLocationRoute('splash'));
//       }
//     } else {
//       if (Get.find<SplashController>().showIntro() ?? false) {
//         if(AppConstants.languages.length > 1) {
//           Get.offNamed(RouteHelper.getLanguageRoute('splash'));
//         }else {
//           Get.offNamed(RouteHelper.getOnBoardingRoute());
//         }
//       } else {
//         Get.offNamed(RouteHelper.getInitialRoute());
//         // Get.offNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _globalKey,
//       backgroundColor: Image.asset(Images.background).color,
//       body: GetBuilder<SplashController>(builder: (splashController) {
//         return Container(
//           decoration: BoxDecoration(
//               image: DecorationImage(
//             image: AssetImage(Images.background),
//             fit: BoxFit.fill,
//           )),
//           child: Center(
//             child: splashController.hasConnection
//                 ? Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Image.asset(Images.logo_an, width: 150),
//                       SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
//
//                       Text("abaad".tr,
//                           style: robotoMedium.copyWith(
//                               fontSize: 25,
//                               color: Theme.of(context).primaryColor)),
//                       Text("optimal_real_estate_marketing".tr,
//                           style: robotoMedium.copyWith(
//                               fontSize: 25,
//                               color: Theme.of(context).primaryColor)),
//                       // Container(
//                       //
//                       //   child: ColorizeAnimatedTextKit(
//                       //     onTap: () {
//                       //       //print("Tap Event");
//                       //     },
//                       //     text:  [
//                       //       "abaad".tr,
//                       //       'optimal_real_estate_marketing'.tr,
//                       //     ],
//                       //     textStyle: const TextStyle(
//                       //         fontSize: 40.0,
//                       //         fontFamily: "Horizon",
//                       //     ),
//                       //     alignment: Alignment.center,
//                       //     colors: const [
//                       //       Colors.blueGrey,
//                       //       Colors.blue,
//                       //     ],
//                       //   ),
//                       // ),
//
//                       /*SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
//               Text(AppConstants.APP_NAME, style: robotoMedium.copyWith(fontSize: 25)),*/
//                     ],
//                   )
//                 : NoInternetScreen(child: SplashScreen(body: widget.body)),
//           ),
//         );
//       }),
//     );
//   }
//
//   // void initDynamicLinks() async{
//   //   FirebaseDynamicLinks.instance.onLink(
//   //       onSuccess: (PendingDynamicLinkData dynamicLink)async{
//   //         final Uri deeplink = dynamicLink.link;
//   //
//   //         handleMyLink(deeplink);
//   //               },
//   //       onError: (OnLinkErrorException e)async{
//   //         //print("We got error $e");
//   //
//   //       }
//   //
//   //   );
//   // }
//
//   // void initDynamicLinks() {
//   //   FirebaseDynamicLinks.instance.onLink
//   //       .listen((PendingDynamicLinkData dynamicLink) {
//   //     final Uri deepLink = dynamicLink.link;
//   //     handleMyLink(deepLink);
//   //   }).onError((error) {
//   //     //print('We got error $error');
//   //   });
//   // }
//
//   void handleMyLink(Uri url) {
//     List<String> sepeatedLink = [];
//
//     /// osama.link.page/Hellow --> osama.link.page and Hellow
//     sepeatedLink.addAll(url.path.split('/'));
//
//     //print("The Token that i'm interesed in is ${sepeatedLink[1]}");
//     Get.find<EstateController>()
//         .getEstateDetails(Estate(id: int.parse(sepeatedLink[1])));
//     Get.toNamed(RouteHelper.getDetailsRoute(int.parse(sepeatedLink[1])));
//   }
// }










import 'dart:async';
import 'dart:ui';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/features/map/controller/location_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/notification/data/models/notification_body.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody body;
  const SplashScreen({super.key, required this.body});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  Timer? _timer;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();

    Get.find<SplashController>().initSharedData();

    if (Get.find<LocationController>().getUserAddress()?.zoneData == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    _route();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((isSuccess) {
      // Always start the timer — even if config failed, proceed after delay
      // so the app never gets stuck on the splash screen forever.
      _timer = Timer(const Duration(seconds: 2), () async {
        if (isSuccess) {
          final splashCtrl = Get.find<SplashController>();
          int minimumVersion = 0;

          if (GetPlatform.isAndroid) {
            minimumVersion =
                splashCtrl.configModel?.appMinimumVersionAndroid ?? 0;
          } else if (GetPlatform.isIOS) {
            minimumVersion =
                splashCtrl.configModel?.appMinimumVersionIos ?? 0;
          }

          final maintenanceMode =
              splashCtrl.configModel?.maintenanceMode ?? false;

          if (AppConstants.APP_VERSION < minimumVersion || maintenanceMode) {
            Get.offNamed(
              RouteHelper.getUpdateRoute(
                AppConstants.APP_VERSION < minimumVersion,
              ),
            );
            return;
          }
        }

        openApp();
      });
    });
  }

  void openApp() async {
    _navigateToApp();
  }

  void _navigateToApp() async {
    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<WishListController>().getWishList();

      if (Get.find<LocationController>().getUserAddress() != null) {
        Get.offNamed(RouteHelper.getInitialRoute());
      } else {
        Get.offNamed(RouteHelper.getAccessLocationRoute('splash'));
      }
    } else {
      if (Get.find<SplashController>().showIntro() ?? false) {
        if (AppConstants.languages.length > 1) {
          Get.offNamed(RouteHelper.getLanguageRoute('splash'));
        } else {
          Get.offNamed(RouteHelper.getOnBoardingRoute());
        }
      } else {
        Get.offNamed(RouteHelper.getInitialRoute());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(
        builder: (splashController) {
          if (!splashController.hasConnection) {
            return NoInternetScreen(
              child: SplashScreen(body: widget.body),
            );
          }

          return Stack(
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
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.45),
                        Theme.of(context).primaryColor.withValues(alpha: 0.20),
                      ],
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 420),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 30,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.18),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(18),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withValues(alpha: 0.18),
                                          blurRadius: 22,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Image.asset(
                                      Images.logo_an,
                                      width: 95,
                                      height: 95,
                                      fit: BoxFit.contain,
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  Text(
                                    "abaad".tr,
                                    textAlign: TextAlign.center,
                                    style: robotoMedium.copyWith(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.1,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    "optimal_real_estate_marketing".tr,
                                    textAlign: TextAlign.center,
                                    style: robotoRegular.copyWith(
                                      fontSize: 16,
                                      height: 1.6,
                                      color: Colors.white.withValues(alpha: 0.92),
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  SizedBox(
                                    width: 160,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: const LinearProgressIndicator(
                                        minHeight: 6,
                                        backgroundColor: Color(0x33FFFFFF),
                                        valueColor:
                                        AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  Text(
                                    "Loading...".tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.82),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "Powered by Abaad",
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
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
    List<String> separatedLink = [];
    separatedLink.addAll(url.path.split('/'));

    Get.find<EstateController>()
        .getEstateDetails(Estate(id: int.parse(separatedLink[1])));
    Get.toNamed(RouteHelper.getDetailsRoute(int.parse(separatedLink[1])));
  }
}