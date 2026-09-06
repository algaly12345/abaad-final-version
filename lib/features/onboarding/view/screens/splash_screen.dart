import 'dart:async';
import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/features/map/controller/location_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/notification/data/models/notification_body.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/services/referral_link_manager.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';

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

  // إصدار المتجر الحقيقي (من pubspec عبر package_info_plus) — يُعرض أسفل شاشة
  // الترحيب. فارغ حتى يصل، فلا يومض رقم مؤقت.
  String _appVersion = '';

  @override
  void initState() {
    super.initState();

    _loadAppVersion();
    Get.find<SplashController>().initSharedData();

    if (Get.find<LocationController>().getUserAddress()?.zoneData == null) {
      Get.find<AuthController>().clearSharedAddress();
    }

    _route();
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _appVersion = info.version);
    } catch (_) {
      // منصّة لا تدعم package_info (نادر) — نتركه فارغًا فلا يظهر شيء.
    }
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
        minimumVersion = splashCtrl.configModel?.appMinimumVersionAndroid ?? 0;
      } else if (GetPlatform.isIOS) {
        minimumVersion = splashCtrl.configModel?.appMinimumVersionIos ?? 0;
      }

      final maintenanceMode = splashCtrl.configModel?.maintenanceMode ?? false;

      if (AppConstants.APP_VERSION < minimumVersion || maintenanceMode) {
        Get.offNamed(
          RouteHelper.getUpdateRoute(AppConstants.APP_VERSION < minimumVersion),
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
    final ReferralLinkManager rlm = ReferralLinkManager.instance;
    // splashHasRouted يُضبط في finally فقط — يبقى false أثناء الانتظار أدناه
    // فيظل ReferralLinkManager في وضع "فتح بارد" ولا يوجّه بنفسه، والسبلاش
    // وحدها تملك قرار الوجهة هنا (لا ازدواج/رمشة رئيسية→تسجيل).
    try {
      if (!Get.find<AuthController>().isLoggedIn()) {
        // زائر غير مسجَّل — قد يكون فتح عبر رابط إحالة (مباشر أو مؤجَّل).
        //  (أ) referralLinkDetected: رُصد رابط في هذا التشغيل → انتظر اكتمال
        //      حلّه (ChottuLink SDK + احتياط الباكند).
        //  (ب) أول تشغيل بعد التثبيت: اصبر مهلة قصيرة لاحتمال وصول رابط
        //      ChottuLink مؤجَّل (deferred) — يصل خلال ثوانٍ على شبكة سريعة.
        //      لو تجاوز المهلة نُكمل، والفتح التالي يلتقط الكود المحفوظ.
        final bool firstLaunch = await rlm.isFirstLaunchThenMark();
        if (rlm.referralLinkDetected || firstLaunch) {
          // رابط رُصد فعلاً → مهلة أطول لاكتمال حلّه (~8s). أول تشغيل بلا رابط
          // مرصود بعد → مهلة قصيرة (~3s) لاحتمال deferred، حتى لا نُبطئ فتح
          // كل مستخدم جديد. الحلقة تنكسر فور توفّر كود. لو تجاوزت المهلة يظل
          // الكود محفوظًا ويُلتقَط في الفتح التالي.
          final int maxTries = rlm.referralLinkDetected ? 40 : 15;
          int tries = 0;
          while (!(await rlm.hasPendingReferral()) && tries < maxTries) {
            await Future.delayed(const Duration(milliseconds: 200));
            tries++;
          }
          rlm.referralLinkDetected = false;
          if (!mounted) return;
        }
      }

      // رابط تفاصيل عقار معلَّق: نتخطى فتح الرئيسية/تسجيل الدخول بالكامل هنا،
      // ونترك GetX ينتقل مباشرة لصفحة /details عبر GetPage المسجَّلة، لتفادي
      // ظهور الرئيسية للحظة قبل شاشة التفاصيل (الرمشة).
      if (rlm.pendingDetailsEstateId != null) {
        rlm.pendingDetailsEstateId = null;
        return;
      }

      if (Get.find<AuthController>().isLoggedIn()) {
        // مستخدم لديه حساب بالفعل — أي كود إحالة معلَّق لا معنى له (لا تسجيل
        // جديد ممكن). نمسحه حتى لا يُعاد التوجيه للتسجيل لو خرج ثم عاد.
        unawaited(rlm.clearAfterRegistration());
        await Get.find<WishListController>().getWishList();

        if (Get.find<LocationController>().getUserAddress() != null) {
          Get.offNamed(RouteHelper.getInitialRoute());
        } else {
          Get.offNamed(RouteHelper.getAccessLocationRoute('splash'));
        }
      } else {
        // إحالة معلَّقة → شاشة التسجيل مباشرة بدل الرئيسية/الإعداد الأولي.
        // hasPendingReferral(): علم الذاكرة أو كود محفوظ من تشغيل سابق (رابط
        // مؤجَّل وصل متأخرًا). الكود يبقى في التخزين ولا يُمسح إلا بعد نجاح
        // التسجيل — فأي فتح لاحق وأنت غير مسجَّل يعيد التوجيه للتسجيل.
        if (await rlm.hasPendingReferral()) {
          rlm.pendingReferralSignUp = false;
          Get.offAllNamed(RouteHelper.getSignUpRoute());
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
    } finally {
      rlm.splashHasRouted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _globalKey,
      body: GetBuilder<SplashController>(
        builder: (splashController) {
          if (!splashController.hasConnection) {
            return NoInternetScreen(child: SplashScreen(body: widget.body));
          }

          return Stack(
            children: [
              const Positioned.fill(child: SplashBackground()),

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Powered by Abaad",
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                      if (_appVersion.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          "${'version'.tr} $_appVersion",
                          style: robotoRegular.copyWith(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
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

    Get.find<EstateController>().getEstateDetails(
      Estate(id: int.parse(separatedLink[1])),
    );
    Get.toNamed(RouteHelper.getDetailsRoute(int.parse(separatedLink[1])));
  }
}
