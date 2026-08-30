import 'dart:async';
import 'package:abaad_flutter/main.dart' as app_main;
import 'package:abaad_flutter/shared/widgets/details_dilog.dart';
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

import '../../../category/controller/category_controller.dart';
import '../widgets/splash_background.dart';

/// ملاحظة: نفس اسم الكلاس وكل الدوال (initState، _route، openApp،
/// _navigateToApp، handleMyLink) بدون أي تغيير في منطقها. التعديل هنا:
/// تم حذف كل الأنيميشن (fade/scale/elastic) بالكامل — اللوجو والنصوص
/// تظهر فورًا وبشكل ثابت بدون أي حركة، لتسريع الشاشة قدر الإمكان (لا
/// حاجة لـ AnimationController أو SingleTickerProviderStateMixin بعد
/// الآن، فالانتقال أصلًا كان مربوطًا فقط بجاهزية بيانات السيرفر منذ
/// التعديل السابق).
class SplashScreen extends StatefulWidget {
  final NotificationBody body;
  const SplashScreen({super.key, required this.body});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    Get.find<SplashController>().initSharedData();

    if (Get.find<LocationController>().getUserAddress()?.zoneData == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    _route();
  }

  // الانتقال للتطبيق يحصل بمجرد ما بيانات السيرفر تجهز فقط — بدون أي
  // انتظار لأي أنيميشن (لم يعد هناك أنيميشن أصلًا).
  void _route() async {
    final bool isSuccess = await Get.find<SplashController>().getConfigData();

    if (!mounted) return;

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
  }

  void openApp() async {
    _navigateToApp();
  }

  void _navigateToApp() async {
    app_main.MyApp.splashHasRouted = true;

    // رابط تفاصيل عقار معلَّق: نتخطى فتح الرئيسية/تسجيل الدخول بالكامل هنا،
    // ونترك GetX ينتقل مباشرة لصفحة /details عبر GetPage المسجَّلة، لتفادي
    // ظهور الرئيسية للحظة قبل شاشة التفاصيل (الرمشة).
    // نُصفّر القيمة فور قراءتها حتى لا تُستهلَك خطأً في أي فتح تالٍ للتطبيق.
    if (app_main.MyApp.pendingDetailsEstateId != null) {
      app_main.MyApp.pendingDetailsEstateId = null;
      return;
    }

    if (Get.find<AuthController>().isLoggedIn()) {
      await Get.find<WishListController>().getWishList();

      if (Get.find<LocationController>().getUserAddress() != null) {
        Get.offNamed(RouteHelper.getInitialRoute());
      } else {
        Get.offNamed(RouteHelper.getAccessLocationRoute('splash'));
      }
    } else {
      // إحالة معلَّقة (رابط abaadapp.sa/ref/CODE): اذهب لصفحة التسجيل مباشرة
      // بدل الرئيسية/الإعداد الأولي — هذا هو القرار الحاسم الوحيد الذي يمنع
      // تسابق مع main.dart._handleReferralLink (انظر MyApp.pendingReferralSignUp).
      if (app_main.MyApp.pendingReferralSignUp) {
        app_main.MyApp.pendingReferralSignUp = false;
        Get.offNamed(RouteHelper.getSignUpRoute());
        return;
      }

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
              const Positioned.fill(
                child: SplashBackground(),
              ),

              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.10),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: const Alignment(0, 0.62),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            Images.logo_an,
                            width: 72,
                            height: 72,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          "abaad".tr,
                          textAlign: TextAlign.center,
                          style: robotoMedium.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "optimal_real_estate_marketing".tr,
                          textAlign: TextAlign.center,
                          style: robotoRegular.copyWith(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white.withValues(alpha: 0.9),
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
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