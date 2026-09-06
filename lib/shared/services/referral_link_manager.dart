import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/utils/referral_code_storage.dart';
import 'package:app_links/app_links.dart';
import 'package:chottu_link/chottu_link.dart';
import 'package:chottu_link/model/chottu_link_resolve_link.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// نقطة موحّدة لكل ما يخصّ روابط الإحالة العميقة (Deep / Deferred Deep Links):
///
///  • تهيئة ChottuLink SDK (بمفتاح/نطاق مخزَّنين من /api/v1/config).
///  • استقبال الرابط من كل المصادر: تدفّق ChottuLink (`onLinkReceivedWithMeta`
///    — يغطّي المثبَّت + المؤجَّل)، `app_links` (رابط خام + فتح بارد)،
///    Play Install Referrer (أندرويد، احتياط للروابط الخام القديمة).
///  • تحديد هل الرابط ChottuLink قصير أم خام أم رابط تفاصيل عقار.
///  • حلّ الرابط القصير عبر SDK، ثم احتياط عبر الباكند إن فشل/تأخّر SDK.
///  • **حفظ كود الإحالة فورًا في التخزين المحلي** (ReferralCodeStorage) —
///    مصدر الحقيقة الوحيد. لا يُحذَف إلا بعد نجاح التسجيل (clearAfterRegistration).
///  • توجيه الزائر غير المسجَّل لشاشة التسجيل دون فقدان الكود عبر
///    Splash / Login / Register (شاشة السبلاش تسأل hasPendingReferral()).
///
/// كل الحالات مغطّاة: التطبيق مغلق كليًا، غير مثبَّت ثم يُثبَّت، في الخلفية،
/// مفتوح بالفعل — وiOS كأندرويد (نفس تدفّق Dart عبر الـ SDK).
class ReferralLinkManager {
  ReferralLinkManager._();
  static final ReferralLinkManager instance = ReferralLinkManager._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _appLinksSub;
  StreamSubscription<ResolvedLink>? _chottuSub;
  bool _initDone = false;

  // ── حالة مشتركة تقرأها شاشة السبلاش (SplashScreen._navigateToApp) ────────
  /// معرّف عقار من رابط تفاصيل معلَّق (app.abaadapp.sa/details/{id}).
  int? pendingDetailsEstateId;

  /// إحالة معلَّقة في هذا التشغيل تنتظر توجيه السبلاش لشاشة التسجيل. يُصفَّر
  /// بعد التوجيه. (الكود المحفوظ في التخزين هو الاحتياط عبر إعادة التشغيل.)
  bool pendingReferralSignUp = false;

  /// يُضبط فور رؤية رابط إحالة (بلا await) — شاشة السبلاش تنتظر عليه قليلاً
  /// قبل تقرير الوجهة حتى لا تفتح الرئيسية للحظة ثم يُعاد التوجيه.
  bool referralLinkDetected = false;

  /// صحيح فور أول قرار توجيه من السبلاش — يخبر هذا الـ manager هل يوجّه بنفسه
  /// (فتح دافئ / رابط مؤجَّل وصل متأخرًا) أم يترك القرار للسبلاش (فتح بارد).
  bool splashHasRouted = false;

  // ═══════════════════════ التهيئة والاستماع ═══════════════════════════════

  /// يُستدعى مرة واحدة من _MyAppState.initState. آمن للاستدعاء أكثر من مرة.
  Future<void> init() async {
    if (_initDone || !GetPlatform.isMobile) return;
    _initDone = true;
    await _appLinksSub?.cancel();
    await _chottuSub?.cancel();

    // مفتاح/نطاق ChottuLink من آخر مزامنة إعدادات (يخزّنهما SplashController).
    final prefsDomain = await ReferralCodeStorage.readString(
        AppConstants.CHOTTULINK_DOMAIN_PREF);
    if (prefsDomain != null && prefsDomain.isNotEmpty) {
      AppConstants.chottulinkDomain = prefsDomain;
    }
    final prefsKey =
        await ReferralCodeStorage.readString(AppConstants.CHOTTULINK_SDK_KEY_PREF);
    if (prefsKey != null && prefsKey.isNotEmpty) {
      await _initChottuSdk(prefsKey);
    }

    // احتياط أندرويد: Play Install Referrer للروابط الخام القديمة.
    unawaited(ReferralCodeStorage.captureFromPlayInstallReferrer().then((_) async {
      final code = await ReferralCodeStorage.peek();
      if (code != null) {
        _log('REFERRAL', 'from Play Install Referrer: $code');
        await _onCodeReceived(code, deferred: true);
      }
    }));

    // ChottuLink: المصدر الأساسي (مثبَّت + مؤجَّل، أندرويد وiOS).
    try {
      _chottuSub = ChottuLink.onLinkReceivedWithMeta.listen(
        (ResolvedLink r) {
          _log('DEEPLINK',
              'ChottuLink meta link=${r.link} shortLink=${r.shortLink} isDeferred=${r.isDeferred}');
          final String? target = r.link ?? r.shortLink;
          if (target == null || target.isEmpty) return;
          final Uri? uri = Uri.tryParse(target);
          if (uri != null) handleUri(uri, deferred: r.isDeferred ?? false);
        },
        onError: (e) => _log('DEEPLINK', 'ChottuLink stream error: $e'),
      );
    } catch (e) {
      _log('DEEPLINK', 'ChottuLink listen error: $e');
    }

    // app_links: الفتح البارد (getInitialLink) + الروابط أثناء التشغيل.
    try {
      final Uri? initialUri = await _appLinks.getInitialLink();
      _log('DEEPLINK', 'getInitialLink() = $initialUri');
      if (initialUri != null) handleUri(initialUri);

      _appLinksSub = _appLinks.uriLinkStream.listen((Uri uri) {
        _log('DEEPLINK', 'uriLinkStream emitted: $uri');
        handleUri(uri);
      });
    } catch (e) {
      _log('DEEPLINK', 'app_links error: $e');
    }
  }

  /// يُستدعى من SplashController بعد وصول /api/v1/config (المفتاح/النطاق من
  /// جدول business_settings). يهيّئ الـ SDK إن لم يكن مُهيّأً (أول تشغيل /
  /// تدوير المفتاح).
  Future<void> onConfigChottuLink({required String key, required String domain}) async {
    if (!GetPlatform.isMobile) return;
    if (domain.isNotEmpty) AppConstants.chottulinkDomain = domain;
    if (key.isNotEmpty && !ChottuLink.isInitialized()) {
      await _initChottuSdk(key);
    }
  }

  Future<void> _initChottuSdk(String key) async {
    try {
      await ChottuLink.init(apiKey: key).timeout(const Duration(seconds: 8));
      _log('DEEPLINK', 'ChottuLink.init OK isInitialized=${ChottuLink.isInitialized()}');
    } catch (e) {
      _log('DEEPLINK', 'ChottuLink.init error: $e');
    }
  }

  // ═══════════════════════ توجيه الرابط ═══════════════════════════════════

  /// نقطة الدخول الموحّدة لأي رابط عميق.
  Future<void> handleUri(Uri uri, {bool deferred = false}) async {
    // (1) رابط تفاصيل عقار — نضبط العلم فقط ليقرأه السبلاش (لا تنقّل هنا).
    if (uri.host == 'app.abaadapp.sa' &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'details') {
      pendingDetailsEstateId = int.tryParse(uri.pathSegments[1]);
      return;
    }

    // (2) رابط ChottuLink القصير (abaadapp.chottu.link/xxxxx) — نحلّه لوجهته.
    if (uri.host == AppConstants.chottulinkDomain) {
      referralLinkDetected = true;
      await _resolveChottuShortLink(uri);
      return;
    }

    // (3) الرابط الخام / الوجهة abaadapp.sa/ref/CODE (وجهة روابط ChottuLink،
    //     وأيضًا الروابط الخام القديمة المنتشرة).
    if (uri.host == 'abaadapp.sa' &&
        uri.pathSegments.length >= 2 &&
        uri.pathSegments.first == 'ref') {
      final String code = uri.pathSegments[1].trim();
      if (code.isEmpty) return;
      referralLinkDetected = true;
      _log('REFERRAL', 'code from ${deferred ? "deferred" : "direct"} link: $code');
      await _onCodeReceived(code, deferred: deferred);
      return;
    }
  }

  Future<void> _resolveChottuShortLink(Uri uri) async {
    final String slug = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    bool resolved = false;

    // getAppLinkDataFromUrl ينتظر تهيئة SDK 3s فقط — ننتظر هنا حتى isInitialized.
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
              handleUri(target);
            }
          },
          onError: (e) => _log('DEEPLINK', 'SDK resolve error: ${e.message}'),
        );
      } catch (e) {
        _log('DEEPLINK', 'SDK resolve exception: $e');
      }
    }

    // احتياط: الباكند يعرف الكود المقابل للرابط القصير (users.referral_short_link).
    if (!resolved && slug.isNotEmpty) {
      final String? code = await _resolveViaBackend(slug);
      _log('REFERRAL', 'backend resolve $slug => $code');
      if (code != null && code.isNotEmpty) {
        await _onCodeReceived(code, deferred: false);
      }
    }
  }

  /// GET عام بلا مصادقة → كود الإحالة المقابل لـ slug.
  Future<String?> _resolveViaBackend(String slug) async {
    try {
      final Uri url = Uri.parse(
          '${AppConstants.BASE_URL}${AppConstants.REFERRAL_LIST_URL}/resolve/$slug');
      final HttpClient client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 8);
      final HttpClientRequest reqObj = await client.getUrl(url);
      reqObj.headers.set('Accept', 'application/json');
      final HttpClientResponse resp =
          await reqObj.close().timeout(const Duration(seconds: 10));
      final String bodyStr = await resp.transform(utf8.decoder).join();
      client.close();
      if (resp.statusCode != 200) return null;
      final dynamic json = jsonDecode(bodyStr);
      final dynamic code = json is Map ? json['referral_code'] : null;
      return code is String && code.isNotEmpty ? code : null;
    } catch (e) {
      _log('REFERRAL', 'backend resolve error: $e');
      return null;
    }
  }

  // ═══════════════════════ استلام الكود + التوجيه ════════════════════════

  Future<void> _onCodeReceived(String code, {required bool deferred}) async {
    await ReferralCodeStorage.save(code);
    _log('REFERRAL', 'saved locally (deferred=$deferred): $code');

    final bool loggedIn = _isLoggedIn();
    if (loggedIn) {
      // مستخدم قديم فتح رابط إحالة — لا تسجيل جديد ممكن؛ نترك الكود ويُمسح
      // عند أي تسجيل لاحق أو عبر clearAfterRegistration.
      return;
    }

    pendingReferralSignUp = true;
    await _waitForNavigatorReady();

    // فتح بارد والسبلاش لم تبتّ بعد → نتركها هي توجّه (تقرأ hasPendingReferral).
    // غير ذلك (دافئ / مؤجَّل وصل متأخرًا والتطبيق على الرئيسية) → نوجّه هنا.
    if (pendingReferralSignUp && splashHasRouted) {
      pendingReferralSignUp = false;
      _log('REFERRAL', 'navigating to sign-up (warm/late)');
      Get.offAllNamed(RouteHelper.getSignUpRoute());
    }
  }

  Future<void> _waitForNavigatorReady() async {
    int tries = 0;
    while (Get.context == null && tries < 30) {
      await Future.delayed(const Duration(milliseconds: 200));
      tries++;
    }
  }

  // ═══════════════════════ واجهة للشاشات الأخرى ═════════════════════════

  /// هل يوجد كود إحالة معلَّق (في الذاكرة أو محفوظ من تشغيل سابق)؟
  /// تستخدمه شاشة السبلاش لتوجيه الزائر غير المسجَّل لشاشة التسجيل.
  Future<bool> hasPendingReferral() async {
    if (pendingReferralSignUp) return true;
    return (await ReferralCodeStorage.peek()) != null;
  }

  /// الكود المعلَّق دون مسحه — لتعبئة حقل شاشة التسجيل.
  Future<String?> pendingReferralCode() => ReferralCodeStorage.peek();

  /// true مرة واحدة فقط — أول تشغيل بعد التثبيت. تستخدمه شاشة السبلاش لتصبر
  /// مهلة قصيرة على وصول رابط الإحالة المؤجَّل (deferred) من ChottuLink قبل
  /// تقرير الوجهة، فيصل المُحال لشاشة التسجيل في أول فتح على شبكة سريعة.
  static const String _firstLaunchKey = 'app_first_launch_seen';
  Future<bool> isFirstLaunchThenMark() async {
    final seen = await ReferralCodeStorage.readString(_firstLaunchKey);
    if (seen == '1') return false;
    await ReferralCodeStorage.writeString(_firstLaunchKey, '1');
    return true;
  }

  /// يُستدعى **فقط بعد نجاح التسجيل** (وإرسال ref_code للباكند) أو نجاح تسجيل
  /// دخول مستخدم قديم — عندها فقط يُحذف الكود من التخزين.
  Future<void> clearAfterRegistration() async {
    pendingReferralSignUp = false;
    referralLinkDetected = false;
    await ReferralCodeStorage.clear();
    _log('REFERRAL', 'cleared after registration/login');
  }

  bool _isLoggedIn() {
    try {
      return Get.find<AuthController>().isLoggedIn();
    } catch (_) {
      return false;
    }
  }

  void _log(String tag, String msg) => debugPrint('[$tag] $msg');
}
