import 'dart:async';
import 'package:abaad_flutter/main.dart' as app_main;
import 'package:abaad_flutter/shared/widgets/details_dilog.dart';
import 'package:abaad_flutter/main.dart' as app_main;
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

import '../widgets/splash_background.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBody body;
  const SplashScreen({super.key, required this.body});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();

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

    Get.find<SplashController>().initSharedData();

    if (Get.find<LocationController>().getUserAddress()?.zoneData == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    _route();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // الرسوم المتحركة وطلب الشبكة يعملان الآن بالتوازي معاً، لا بالتتابع.
  // الانتقال يحدث فور اكتمال أبطأ الاثنين فقط — بدون أي تأخير ثابت إضافي.
  void _route() async {
    final animationFuture = _animationController.forward();
    final configFuture = Get.find<SplashController>().getConfigData();

    final results = await Future.wait([
      animationFuture.then((_) => true),
      configFuture,
    ]);

    if (!mounted) return;

    final bool isSuccess = results[1] as bool;

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
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: Container(
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

                            const SizedBox(height: 22),

                            SizedBox(
                              width: 140,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: const LinearProgressIndicator(
                                  minHeight: 4,
                                  backgroundColor: Color(0x33FFFFFF),
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
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