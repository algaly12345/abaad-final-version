// import 'package:abaad_chatbot_ui/abaad_chatbot_ui.dart';
// import 'package:abaad_flutter/shared/widgets/details_dilog.dart';
// import 'package:flutter/material.dart';
// import 'dart:async';
// import 'dart:io';
//
// import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
// import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
// import 'package:abaad_flutter/features/map/controller/location_controller.dart';
// import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
// import 'package:abaad_flutter/shared/controllers/theme_controller.dart';
// import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';
// import 'package:abaad_flutter/features/notification/data/models/notification_body.dart';
// import 'package:abaad_flutter/shared/helpers/notification_helper.dart';
// import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
// import 'package:abaad_flutter/core/routes/route_helper.dart';
// import 'package:abaad_flutter/shared/theme/dark_theme.dart';
// import 'package:abaad_flutter/shared/theme/light_theme.dart';
// import 'package:abaad_flutter/shared/utils/app_constants.dart';
// import 'package:abaad_flutter/shared/utils/messages.dart';
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
//       final Uri? initialUri = await _appLinks.getInitialLink();
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
import 'package:abaad_flutter/shared/widgets/details_dilog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/auth/data/repositories/auth_repo.dart';
import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
import 'package:abaad_flutter/features/map/controller/location_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/controllers/theme_controller.dart';
import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';
import 'package:abaad_flutter/features/notification/data/models/notification_body.dart';
import 'package:abaad_flutter/shared/helpers/notification_helper.dart';
import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/core/routes/route_observer.dart';
import 'package:abaad_flutter/shared/theme/dark_theme.dart';
import 'package:abaad_flutter/shared/theme/light_theme.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/utils/messages.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/core/di/get_di.dart' as di;
import 'dart:async';
import 'dart:convert';
import 'package:app_links/app_links.dart';
import 'package:chottu_link/chottu_link.dart';
import 'package:chottu_link/model/chottu_link_resolve_link.dart';
import 'package:abaad_flutter/shared/utils/referral_code_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Color(0xFFF6F8FD),
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  if (ResponsiveHelper.isMobilePhone()) {
    HttpOverrides.global = MyHttpOverrides();
  }

  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ لازم di.init() يشتغل أول قبل أي Get.find
  Map<String, Map<String, String>> languages = await di.init();

  // ✅ الآن نقدر نستخدم Get.find بأمان
  final SharedPreferences sharedPreferences = Get.find<SharedPreferences>();

  // تهيئة ChottuLink SDK (بديل Firebase Dynamic Links) بمفتاح/نطاق مُخزَّنين
  // من آخر مزامنة لـ /api/v1/config (جدول business_settings) — مسار سريع
  // للفتح البارد. أول تشغيل (لا كاش بعد) يُهيّئه SplashController بعد وصول
  // الإعدادات. timeout + try/catch: مفتاح غير صالح أو تعذّر الوصول يجب ألا
  // يحجب الإقلاع.
  if (GetPlatform.isMobile) {
    final String cachedDomain =
        sharedPreferences.getString(AppConstants.CHOTTULINK_DOMAIN_PREF) ?? '';
    if (cachedDomain.isNotEmpty) AppConstants.chottulinkDomain = cachedDomain;

    final String cachedKey =
        sharedPreferences.getString(AppConstants.CHOTTULINK_SDK_KEY_PREF) ?? '';
    if (cachedKey.isNotEmpty) {
      try {
        await ChottuLink.init(apiKey: cachedKey)
            .timeout(const Duration(seconds: 8));
      } catch (e) {
        debugPrint('ChottuLink init error: $e');
      }
    }
  }

  NotificationBody? body;

  try {
    if (GetPlatform.isMobile) {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );
      await NotificationHelper.initialize();

      final AuthRepo authRepo = Get.find<AuthRepo>();
      if (authRepo.isLoggedIn()) {
        unawaited(authRepo.updateToken());
      }
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

  /// معرّف عقار من رابط تفاصيل معلَّق — يُقرأ من شاشة السبلاش بعد انتهاء
  /// تسلسلها الطبيعي (Get.offNamed) لتفادي تعارض توقيت يمسح التنقّل المباشر.
  static int? pendingDetailsEstateId;

  /// إحالة معلَّقة تنتظر البتّ في وجهتها: تُقرأ من شاشة السبلاش
  /// (SplashScreen._navigateToApp) لتذهب لصفحة التسجيل بدل الرئيسية مباشرة،
  /// عوضًا عن تنقّل مستقل هنا قد يتسابق مع تنقّل السبلاش الافتراضي (Get.offNamed
  /// للرئيسية) ويُطاح به بمجرد اكتمال جلب إعدادات السيرفر — وهذا ما كان يجعل
  /// رابط الإحالة يفتح صفحة التسجيل للحظة ثم يُعاد المستخدم للرئيسية (لوحظ
  /// تكراره تحديدًا على آيفون، حيث يصل الرابط الأولي عبر getInitialLink بعد
  /// أن يكون تنقّل السبلاش الافتراضي قد اكتمل غالبًا).
  static bool pendingReferralSignUp = false;

  /// يُضبط فورًا (بلا انتظار) في _handleReferralLink بمجرد التعرّف على أن
  /// التطبيق فُتح عبر رابط إحالة. شاشة السبلاش تنتظر عليه فتُؤجّل قرار الوجهة
  /// حتى يكتمل حلّ الرابط (نداء ChottuLink SDK + نداء باكند احتياطي قد
  /// يستغرقان ثوانٍ)، فتذهب للتسجيل مباشرة بدل فتح الرئيسية للحظة ثم التوجيه.
  static bool referralLinkDetected = false;

  /// صحيح فور أول استدعاء لـ SplashScreen._navigateToApp — يُستخدم هنا لمعرفة
  /// هل السبلاش انتهت من قرارها الأول (فتح دافئ لاحق للرابط) أم لا تزال
  /// تنتظر (فتح بارد، فنترك لها البتّ في pendingReferralSignUp بنفسها).
  static bool splashHasRouted = false;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _referralLinkSubscription;
  StreamSubscription<ResolvedLink>? _chottuLinkSubscription;

  @override
  void initState() {
    super.initState();
    _initReferralDeepLink();
  }

  @override
  void dispose() {
    _referralLinkSubscription?.cancel();
    _chottuLinkSubscription?.cancel();
    super.dispose();
  }

  /// يستقبل رابط الإحالة القصير من ChottuLink (https://go.abaadapp.sa/xxxxx)
  /// عبر onLinkReceivedWithMeta — يغطّي الحالتين معًا: التطبيق مثبَّت وفُتح
  /// بالرابط، وتثبيت جديد يحمل الكود بعد التثبيت (isDeferred). كما يستقبل
  /// الرابط الخام https://abaadapp.sa/ref/CODE ورابط تفاصيل العقار
  /// https://app.abaadapp.sa/details/{id} عبر app_links (احتياط للروابط
  /// المنتشرة سابقًا + الفتح البارد). getInitialLink() يلتقط الفتح البارد
  /// صراحة لأن uriLinkStream وحده قد لا يُصدر الرابط الأول قبل جهوزية
  /// GetMaterialApp.
  Future<void> _initReferralDeepLink() async {
    if (!GetPlatform.isMobile) return;

    unawaited(ReferralCodeStorage.captureFromPlayInstallReferrer());

    // ChottuLink: مصدر الاستقبال الأساسي للروابط الجديدة (مثبَّت + مؤجَّل).
    try {
      _chottuLinkSubscription =
          ChottuLink.onLinkReceivedWithMeta.listen((ResolvedLink resolved) {
        debugPrint(
            'DEEPLINK_DEBUG: ChottuLink meta link=${resolved.link} deferred=${resolved.isDeferred}');
        final String? target = resolved.link ?? resolved.shortLink;
        if (target == null || target.isEmpty) return;
        final Uri? uri = Uri.tryParse(target);
        if (uri != null) _handleReferralLink(uri);
      }, onError: (e) => debugPrint('ChottuLink stream error: $e'));
    } catch (e) {
      debugPrint('ChottuLink listen error: $e');
    }

    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      debugPrint('DEEPLINK_DEBUG: getInitialLink() returned: $initialUri');
      if (initialUri != null) {
        _handleReferralLink(initialUri);
      }

      _referralLinkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
        debugPrint('DEEPLINK_DEBUG: uriLinkStream emitted: $uri');
        _handleReferralLink(uri);
      });
    } catch (e) {
      debugPrint('Referral deep link error: $e');
    }
  }

  /// ينتظر جهوزية GetX Navigator (GetMaterialApp) قبل أي تنقّل — في الفتح
  /// البارد، initState() يُنفَّذ قبل بناء GetMaterialApp بالكامل، فأي
  /// Get.toNamed فوري يفشل بصمت لعدم وجود Navigator صالح بعد.
  Future<void> _waitForNavigatorReady() async {
    int tries = 0;
    while (Get.context == null && tries < 30) {
      await Future.delayed(const Duration(milliseconds: 200));
      tries++;
    }
  }

  void _handleReferralLink(Uri uri) async {

    // رابط تفاصيل عقار https://app.abaadapp.sa/details/{id}: نخزّن العلم
    // فقط ليقرأه السبلاش ويتخطى فتح الرئيسية (بدون فتح أي حوار هنا، لتفادي
    // الازدواجية — الحوار الفعلي تفتحه آلية GetX التلقائية وحدها).
    if (uri.host == 'app.abaadapp.sa' &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'details') {
      MyApp.pendingDetailsEstateId = int.tryParse(uri.pathSegments[1]);
      return;
    }
    // رابط ChottuLink القصير (abaadapp.chottu.link/xxxxx): نحاول أولًا حلّه عبر
    // ChottuLink SDK (يغطّي التثبيت المؤجَّل + الإحصاءات). قد يسبق هذا اكتمال
    // ChottuLink.init (تُستدعى في main() من الكاش، أو في SplashController بعد
    // /api/v1/config) وgetAppLinkDataFromUrl ينتظر التهيئة 3s فقط — فننتظر هنا
    // حتى isInitialized. وعند فشل/تأخّر SDK نلجأ للباكند: يعرف الكود المقابل
    // لهذا الرابط القصير لأنه أنشأه (users.referral_short_link).
    if (uri.host == AppConstants.chottulinkDomain) {
      // علم فوري (بلا await) لتقرأه شاشة السبلاش وتؤجّل قرار وجهتها.
      MyApp.referralLinkDetected = true;

      final String slug =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      bool resolved = false;

      int waited = 0;
      while (!ChottuLink.isInitialized() && waited < 20) {
        await Future.delayed(const Duration(milliseconds: 300));
        waited++;
      }

      if (ChottuLink.isInitialized()) {
        try {
          await ChottuLink.getAppLinkDataFromUrl(
            shortUrl: uri.toString(),
            onSuccess: (ResolvedLink r) {
              final Uri? target = Uri.tryParse(r.link ?? '');
              if (target != null) {
                resolved = true;
                _handleReferralLink(target);
              }
            },
            onError: (e) => debugPrint('ChottuLink resolve error: ${e.message}'),
          );
        } catch (e) {
          debugPrint('ChottuLink resolve exception: $e');
        }
      }

      if (!resolved && slug.isNotEmpty) {
        final String? code = await _resolveReferralViaBackend(slug);
        if (code != null && code.isNotEmpty) {
          await _applyReferralCode(code);
        }
      }
      return;
    }

    if (uri.host != 'abaadapp.sa') return;
    if (uri.pathSegments.length < 2 || uri.pathSegments.first != 'ref') return;

    final String code = uri.pathSegments[1];
    if (code.isEmpty) return;

    MyApp.referralLinkDetected = true;
    await _applyReferralCode(code);
  }

  /// يخزّن كود الإحالة ويوجّه الزائر غير المسجَّل لصفحة التسجيل — مصدر واحد
  /// لكل مسارات الوصول (ChottuLink مثبَّت/مؤجَّل، رابط abaadapp.sa/ref خام،
  /// Play Install Referrer). آمن للاستدعاء أكثر من مرة لنفس الكود.
  Future<void> _applyReferralCode(String code) async {
    await ReferralCodeStorage.save(code);

    if (!Get.find<AuthController>().isLoggedIn()) {
      MyApp.pendingReferralSignUp = true;
      await _waitForNavigatorReady();

      // إن كانت السبلاش لم تبتّ في وجهتها بعد (فتح بارد)، نترك لها القرار
      // (انظر SplashScreen._navigateToApp) لتفادي تسابق يُطيح بصفحة التسجيل
      // بمجرد فتحها. غير ذلك (فتح دافئ: السبلاش انتهت أصلًا)، ننقّل هنا مباشرة.
      if (MyApp.pendingReferralSignUp && MyApp.splashHasRouted) {
        MyApp.pendingReferralSignUp = false;
        Get.offNamed(RouteHelper.getSignUpRoute());
      }
    }
  }

  /// احتياط حلّ رابط ChottuLink القصير: يسأل الباكند عن كود الإحالة المقابل
  /// لـ slug (الجزء الأخير من الرابط). الباكند يطابقه بـ users.referral_short_link.
  /// GET عام بلا مصادقة، بلا اعتماديات إضافية (HttpClient من dart:io).
  Future<String?> _resolveReferralViaBackend(String slug) async {
    try {
      final Uri url = Uri.parse(
          '${AppConstants.BASE_URL}${AppConstants.REFERRAL_LIST_URL}/resolve/$slug');
      final HttpClient client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8);
      final HttpClientRequest req = await client.getUrl(url);
      req.headers.set('Accept', 'application/json');
      final HttpClientResponse resp =
          await req.close().timeout(const Duration(seconds: 10));
      final String body = await resp.transform(utf8.decoder).join();
      client.close();
      if (resp.statusCode != 200) return null;
      final dynamic json = jsonDecode(body);
      final dynamic code = json is Map ? json['referral_code'] : null;
      return code is String && code.isNotEmpty ? code : null;
    } catch (e) {
      debugPrint('Referral backend resolve error: $e');
      return null;
    }
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
                        navigatorObservers: [routeObserver],
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
                        // بلا هذين: أي ودجت Material أصلي (DateRangePicker
                        // مثلاً) يبقى بالإنجليزية دومًا حتى مع locale عربي،
                        // لأن Flutter يقتصر افتراضياً على دعم en فقط لودجتاته
                        // الأصلية إن لم تُذكر باقي اللغات صراحة هنا.
                        localizationsDelegates: const [
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        supportedLocales: AppConstants.languages
                            .map((l) => Locale(l.languageCode, l.countryCode))
                            .toList(),
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
