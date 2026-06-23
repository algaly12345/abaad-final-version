// import 'package:abaad_chatbot_ui/abaad_chatbot_ui.dart';
// import 'package:abaad_flutter/view/base/details_dilog.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:io';
//
// import 'package:abaad_flutter/controller/auth_controller.dart';
// import 'package:abaad_flutter/controller/localization_controller.dart';
// import 'package:abaad_flutter/controller/location_controller.dart';
// import 'package:abaad_flutter/controller/splash_controller.dart';
// import 'package:abaad_flutter/controller/theme_controller.dart';
// import 'package:abaad_flutter/controller/wishlist_controller.dart';
// import 'package:abaad_flutter/data/model/body/notification_body.dart';
// import 'package:abaad_flutter/helper/notification_helper.dart';
// import 'package:abaad_flutter/helper/responsive_helper.dart';
// import 'package:abaad_flutter/helper/route_helper.dart';
// import 'package:abaad_flutter/theme/dark_theme.dart';
// import 'package:abaad_flutter/theme/light_theme.dart';
// import 'package:abaad_flutter/util/app_constants.dart';
// import 'package:abaad_flutter/util/messages.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_strategy/url_strategy.dart';
// import 'package:app_links/app_links.dart';
//
// import 'controller/estate_controller.dart';
// import 'data/model/response/estate_model.dart';
// import 'helper/get_di.dart' as di;
//
// Future<void> main() async {
//
//   WidgetsFlutterBinding.ensureInitialized();
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   if (ResponsiveHelper.isMobilePhone()) {
//     HttpOverrides.global = MyHttpOverrides();
//   }
//
//   setPathUrlStrategy();
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // ✅ لازم di.init() يشتغل أول قبل أي Get.find
//   Map<String, Map<String, String>> languages = await di.init();
//
//   // ✅ الآن نقدر نستخدم Get.find بأمان
//   final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();
//
//
//
//   NotificationBody? body;
//
//   try {
//     if (GetPlatform.isMobile) {
//       // await NotificationHelper.initialize(...)
//     }
//
//     runApp(
//       MyApp(
//         languages: languages,
//         body: body ?? NotificationBody(notificationType: NotificationType.order),
//       ),
//     );
//   } catch (e) {
//     debugPrint('Main error: $e');
//   }
// }
//
// class MyApp extends StatefulWidget {
//   final Map<String, Map<String, String>> languages;
//   final NotificationBody? body;
//
//   const MyApp({
//     super.key,
//     required this.languages,
//     required this.body,
//   });
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   final AppLinks _appLinks = AppLinks();
//   StreamSubscription<Uri>? _linkSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     _initDeepLinks();
//   }
//
//   Future<void> _initDeepLinks() async {
//     if (!GetPlatform.isMobile) return;
//
//     try {
//       final Uri? initialUri = await _appLinks.getInitialAppLink();
//
//       if (initialUri != null) {
//         Future.delayed(const Duration(seconds: 2), () {
//           _handleDeepLink(initialUri);
//         });
//       }
//
//       _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
//         _handleDeepLink(uri);
//       });
//     } catch (e) {
//       debugPrint('Deep link error: $e');
//     }
//   }
//   void _handleDeepLink(Uri uri) async {
//     debugPrint('DEEPLINK: $uri');
//
//     if (uri.host != 'app.abaadapp.sa') return;
//     if (uri.pathSegments.isEmpty) return;
//     if (uri.pathSegments.first != 'details') return;
//
//     final int? estateId = int.tryParse(uri.pathSegments.last);
//     if (estateId == null) return;
//
//     await Future.delayed(const Duration(milliseconds: 500));
//
//
//     int tries = 0;
//     while (Get.context == null && tries < 20) {
//       await Future.delayed(const Duration(milliseconds: 200));
//       tries++;
//     }
//
//     final estateController = Get.find<EstateController>();
//
//     final Estate estate = await estateController.getEstateDetails(
//       Estate(id: estateId),
//     );
//
//
//     if (Get.isDialogOpen == true) {
//       Get.back();
//     }
//
//
//     Get.dialog(
//       DettailsDilog(estate: estate),
//       barrierDismissible: true,
//     );
//   }
//
//
//
//
//
//
//   // void _handleDeepLink(Uri uri) async {
//   //   debugPrint('DEEPLINK: $uri');
//   //
//   //   if (uri.host != 'app.abaadapp.sa') return;
//   //   if (uri.pathSegments.isEmpty) return;
//   //   if (uri.pathSegments.first != 'details') return;
//   //
//   //   final int? estateId = int.tryParse(uri.pathSegments.last);
//   //   if (estateId == null) return;
//   //
//   //   int tries = 0;
//   //   while (Get.context == null && tries < 20) {
//   //     await Future.delayed(const Duration(milliseconds: 300));
//   //     tries++;
//   //   }
//   //
//   //   await Future.delayed(const Duration(milliseconds: 500));
//   //
//   //   final estateController = Get.find<EstateController>();
//   //
//   //   final Estate estate = await estateController.getEstateDetails(
//   //     Estate(id: estateId),
//   //   );
//   //
//   //   if (Get.isDialogOpen == true) {
//   //     Get.back();
//   //   }
//   //
//   //   Get.dialog(
//   //     DettailsDilog(estate: estate),
//   //     barrierDismissible: true,
//   //   );
//   // }
//
//
//
//   Future<void> openEstateDialog(int estateId) async {
//     final estateController = Get.find<EstateController>();
//
//     final Estate estate = await estateController.getEstateDetails(
//       Estate(id: estateId),
//     );
//
//     if (Get.isDialogOpen == true) {
//       Get.back();
//     }
//
//     Get.dialog(
//       DettailsDilog(estate: estate),
//       barrierDismissible: true,
//     );
//   }
//
//   void _route() {
//     Get.find<SplashController>().getConfigData().then((bool isSuccess) async {
//       if (isSuccess) {
//         if (Get.find<AuthController>().isLoggedIn()) {
//           await Get.find<WishListController>().getWishList();
//         }
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _linkSubscription?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (GetPlatform.isWeb) {
//       Get.find<SplashController>().initSharedData();
//       _route();
//     }
//
//     return GetBuilder<ThemeController>(builder: (themeController) {
//       return GetBuilder<LocalizationController>(builder: (localizeController) {
//         return GetBuilder<SplashController>(builder: (splashController) {
//           return (GetPlatform.isWeb && splashController.configModel == null)
//               ? const SizedBox()
//               : GetMaterialApp(
//             title: AppConstants.APP_NAME,
//             debugShowCheckedModeBanner: false,
//             navigatorKey: Get.key,
//             scrollBehavior: MaterialScrollBehavior().copyWith(
//               dragDevices: {
//                 PointerDeviceKind.mouse,
//                 PointerDeviceKind.touch,
//               },
//             ),
//             theme: themeController.darkTheme ? dark : light,
//             locale: localizeController.locale,
//             translations: Messages(languages: widget.languages),
//             fallbackLocale: Locale(
//               AppConstants.languages[0].languageCode,
//               AppConstants.languages[0].countryCode,
//             ),
//             initialRoute: GetPlatform.isWeb
//                 ? RouteHelper.getInitialRoute()
//                 : RouteHelper.getSplashRoute(widget.body),
//             getPages: RouteHelper.routes,
//             defaultTransition: Transition.topLevel,
//             transitionDuration: const Duration(milliseconds: 500),
//           );
//         });
//       });
//     });
//   }
// }
//
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }

//import 'package:abaad_chatbot_ui/abaad_chatbot_ui.dart';
import 'package:abaad_flutter/view/base/details_dilog.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/localization_controller.dart';
import 'package:abaad_flutter/controller/location_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/theme_controller.dart';
import 'package:abaad_flutter/controller/wishlist_controller.dart';
import 'package:abaad_flutter/data/model/body/notification_body.dart';
import 'package:abaad_flutter/helper/notification_helper.dart';
import 'package:abaad_flutter/helper/responsive_helper.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/theme/dark_theme.dart';
import 'package:abaad_flutter/theme/light_theme.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:abaad_flutter/util/messages.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'controller/estate_controller.dart';
import 'data/model/response/estate_model.dart';
import 'helper/get_di.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }

  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ لازم di.init() يشتغل أول قبل أي Get.find
  Map<String, Map<String, String>> languages = await di.init();

  // ✅ الآن نقدر نستخدم Get.find بأمان
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  NotificationBody? body;

  try {
    if (GetPlatform.isMobile) {
      // await NotificationHelper.initialize(...)
    }

    runApp(
      MyApp(
        languages: languages,
        body:
            body ?? NotificationBody(notificationType: NotificationType.order),
      ),
    );
  } catch (e) {
    debugPrint('Main error: $e');
  }
}

class MyApp extends StatefulWidget {
  final Map<String, Map<String, String>> languages;
  final NotificationBody? body;

  const MyApp({super.key, required this.languages, required this.body});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> openEstateDialog(int estateId) async {
    final estateController = Get.find<EstateController>();

    final Estate estate = await estateController.getEstateDetails(
      Estate(id: estateId),
    );

    if (Get.isDialogOpen == true) {
      Get.back();
    }

    Get.dialog(DettailsDilog(estate: estate), barrierDismissible: true);
  }

  void _route() {
    Get.find<SplashController>().getConfigData().then((bool isSuccess) async {
      if (isSuccess) {
        if (Get.find<AuthController>().isLoggedIn()) {
          await Get.find<WishListController>().getWishList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (GetPlatform.isWeb) {
      Get.find<SplashController>().initSharedData();
      _route();
    }

    return GetBuilder<ThemeController>(
      builder: (themeController) {
        return GetBuilder<LocalizationController>(
          builder: (localizeController) {
            return GetBuilder<SplashController>(
              builder: (splashController) {
                return (GetPlatform.isWeb &&
                        splashController.configModel == null)
                    ? const SizedBox()
                    : GetMaterialApp(
                        title: AppConstants.APP_NAME,
                        debugShowCheckedModeBanner: false,
                        navigatorKey: Get.key,
                        scrollBehavior: MaterialScrollBehavior().copyWith(
                          dragDevices: {
                            PointerDeviceKind.mouse,
                            PointerDeviceKind.touch,
                          },
                        ),
                        theme: themeController.darkTheme ? dark : light,
                        locale: localizeController.locale,
                        translations: Messages(languages: widget.languages),
                        fallbackLocale: Locale(
                          AppConstants.languages[0].languageCode,
                          AppConstants.languages[0].countryCode,
                        ),
                        initialRoute: GetPlatform.isWeb
                            ? RouteHelper.getInitialRoute()
                            : RouteHelper.getSplashRoute(widget.body),
                        getPages: RouteHelper.routes,
                        defaultTransition: Transition.topLevel,
                        transitionDuration: const Duration(milliseconds: 500),
                      );
              },
            );
          },
        );
      },
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
