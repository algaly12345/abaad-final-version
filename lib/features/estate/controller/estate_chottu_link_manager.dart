import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/services/referral_link_manager.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:app_links/app_links.dart';
import 'package:chottu_link/chottu_link.dart';
import 'package:chottu_link/model/chottu_link_resolve_link.dart';
import 'package:get/get.dart';

/// يفتح شاشة تفاصيل العقار لرابط مشاركة عقار (`abaadapp.chottu.link/{slug}`
/// ← `app.abaadapp.sa/details/{id}`) — **بلا أي علاقة بكود إحالة مزوّد
/// الخدمة**. تصميم مُعزول تمامًا (كلاس، ملف، حالة، مستمعان مستقلّان) بعد
/// حادثة 2026-09-11: تعديل `referral_link_manager.dart` مباشرةً لدعم روابط
/// العقار سبّب خلطًا حقيقيًا مع تدفّق الإحالة (رابط إحالة فتح تفاصيل عقار
/// خطأً). القرار: **لا تُعدَّل `referral_link_manager.dart` أو
/// `splash_screen.dart` لأي غرض متعلّق بالعقار أبدًا** — كل منطق العقار هنا،
/// مستقلّ بالكامل، فلا يمكنه بنيويًا أن يلمس كود/حالة/تخزين الإحالة.
///
/// **كيف يتم الفصل فعليًا (لا مجرّد قناعة)**:
///  • مستمعان مستقلّان على نفس تيّاري app_links/ChottuLink اللذين يستمع
///    إليهما ReferralLinkManager أيضًا. كلاهما Stream **بثّ (broadcast)** من
///    تصميم الحزمتين (تحقّقتُ من الكود المصدري: `AppLinks` singleton +
///    `StreamController.broadcast()` لـ uriLinkStream، و
///    `EventChannel.receiveBroadcastStream().asBroadcastStream()` لـ
///    onLinkReceivedWithMeta) — الاستماع المتعدّد مدعوم رسميًا وآمن، كل
///    مستمع يستقبل كل حدث بشكل مستقل، بلا أي تنسيق أو تضارب بين الكلاسين.
///  • **لا حالة مشتركة تُكتَب**: لا يقرأ ولا يكتب أي حقل من ReferralLinkManager
///    (Sim باستثناء قراءة `splashHasRouted` — قراءة فقط، علم "استقرّت الوجهة
///    الطبيعية أم لا"، لا رابط له بمنطق حلّ الروابط).
///  • **لا يتصرّف مع أي وجهة غير تفاصيل عقار**: أي رابط يُحلّ لوجهة إحالة
///    (`abaadapp.sa/ref/...`) أو أي شيء آخر يُتجاهل بصمت هنا — هذا الكلاس
///    "لا يعرف" أصلًا ما هي الإحالة، فلا يمكنه إطلاقًا أن يخطئ في التعامل
///    معها (لا حفظ، لا توجيه، لا لمس تخزين).
///  • **لا يتصرّف مع إعادة بثّ الإسناد القديم**: `_realIntentSeen` علم محلّي
///    (لا صلة له بعلم مماثل سابق كان داخل الملف الممنوع — ذاك أُزيل بالكامل
///    مع الرجوع لآخر كوميت) يُضبط فقط من نيّة نظام حقيقية هذا التشغيل
///    (getInitialLink/uriLinkStream) — يمنع فتح عقار قديم على تشغيل عادي.
class EstateChottuLinkManager {
  EstateChottuLinkManager._();
  static final EstateChottuLinkManager instance = EstateChottuLinkManager._();

  bool _initDone = false;
  bool _realIntentSeen = false;
  int? _lastHandledEstateId;
  bool _navigating = false;

  /// يُستدعى مرّة من _MyAppState.initState (بجانب ReferralLinkManager.init،
  /// بلا أي استدعاء أو تعديل لذلك الكلاس). آمن للاستدعاء أكثر من مرّة.
  Future<void> init() async {
    if (_initDone) return;
    _initDone = true;

    final AppLinks appLinks = AppLinks(); // singleton مشترك بأمان (broadcast)

    try {
      appLinks.uriLinkStream.listen((Uri uri) {
        _realIntentSeen = true;
        _handleRawUri(uri);
      });

      final Uri? initialUri = await appLinks.getInitialLink();
      if (initialUri != null) {
        _realIntentSeen = true;
        _handleRawUri(initialUri);
      }
    } catch (_) {
      // نفس نمط ReferralLinkManager: أي خطأ منصّة يُبتلع بصمت.
    }

    try {
      ChottuLink.onLinkReceivedWithMeta.listen((ResolvedLink r) {
        // نتجاهل أي تسليم لم يسبقه نيّة نظام حقيقية هذا التشغيل — هذا ما
        // يمنع إعادة بثّ إسناد قديم (مؤجَّل/متبقٍّ من تثبيت سابق) من فتح
        // عقار قديم على تشغيل عادي بلا أي رابط.
        if (!_realIntentSeen) return;
        final String? target = r.link ?? r.shortLink;
        if (target == null || target.isEmpty) return;
        final Uri? uri = Uri.tryParse(target);
        if (uri != null) _handleResolved(uri);
      });
    } catch (_) {}
  }

  void _handleRawUri(Uri uri) {
    if (_isEstateDetailsUri(uri)) {
      _openEstate(int.tryParse(uri.pathSegments[1]));
      return;
    }
    if (uri.host == AppConstants.chottulinkDomain) {
      unawaited(_resolveChottuSlug(uri));
    }
    // أي شيء آخر (كوجهة إحالة abaadapp.sa/ref/...): ليس شأننا، نتجاهله بصمت.
  }

  void _handleResolved(Uri uri) {
    if (_isEstateDetailsUri(uri)) {
      _openEstate(int.tryParse(uri.pathSegments[1]));
    }
    // غير ذلك (إحالة أو أي وجهة أخرى): تجاهل تام.
  }

  bool _isEstateDetailsUri(Uri uri) =>
      uri.host == 'app.abaadapp.sa' &&
      uri.pathSegments.length >= 2 &&
      uri.pathSegments.first == 'details';

  /// يحاول حلّ رابط ChottuLink القصير **بمعزل تمامًا** عن ReferralLinkManager:
  /// نداء SDK مستقل (نداء طلب/ردّ عادي، لا تيّار، آمن التكرار)، ثم احتياط
  /// باكند عقارات فقط (`estate/resolve-link/{slug}` — لا يلمس جدول users
  /// ولا شيئًا يخصّ الإحالة إطلاقًا).
  Future<void> _resolveChottuSlug(Uri uri) async {
    final String slug = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    if (slug.isEmpty) return;

    int waited = 0;
    while (!ChottuLink.isInitialized() && waited < 20) {
      await Future.delayed(const Duration(milliseconds: 300));
      waited++;
    }

    bool resolved = false;
    if (ChottuLink.isInitialized()) {
      try {
        await ChottuLink.getAppLinkDataFromUrl(
          shortUrl: uri.toString(),
          onSuccess: (ResolvedLink r) {
            final Uri? target = Uri.tryParse(r.link ?? '');
            if (target != null && _isEstateDetailsUri(target)) {
              resolved = true;
              _openEstate(int.tryParse(target.pathSegments[1]));
            }
          },
          onError: (_) {},
        );
      } catch (_) {}
    }

    if (!resolved) {
      final int? estateId = await _resolveEstateViaBackend(slug);
      if (estateId != null) _openEstate(estateId);
    }
  }

  /// GET عام بلا مصادقة → معرّف العقار المقابل لـ slug رابط المشاركة القصير
  /// (`estates.share_short_link` فقط — لا صلة بجدول الإحالة).
  Future<int?> _resolveEstateViaBackend(String slug) async {
    try {
      final Uri url = Uri.parse(
          '${AppConstants.BASE_URL}${AppConstants.ESTATE_SHARE_LINK_URI}resolve-link/$slug');
      final HttpClient client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      final HttpClientRequest reqObj = await client.getUrl(url);
      reqObj.headers.set('Accept', 'application/json');
      final HttpClientResponse resp =
          await reqObj.close().timeout(const Duration(seconds: 6));
      final String bodyStr = await resp.transform(utf8.decoder).join();
      client.close();
      if (resp.statusCode != 200) return null;
      final dynamic json = jsonDecode(bodyStr);
      final dynamic id = json is Map ? json['estate_id'] : null;
      return id is int ? id : int.tryParse('$id');
    } catch (_) {
      return null;
    }
  }

  void _openEstate(int? id) {
    if (id == null || id == _lastHandledEstateId) return;
    _lastHandledEstateId = id;
    unawaited(_navigate(id));
  }

  Future<void> _navigate(int id) async {
    if (_navigating) return;
    _navigating = true;
    try {
      // ننتظر استقرار وجهة السبلاش الطبيعية (رئيسية/تسجيل/onboarding) —
      // قراءة فقط لعلم عام جاهز أصلًا (بلا أي تعديل على ReferralLinkManager)
      // — حتى تكون لشاشة العقار "أرضية" يكشفها زرّ الرجوع، لا شاشة عالقة.
      int tries = 0;
      while (!ReferralLinkManager.instance.splashHasRouted && tries < 150) {
        await Future.delayed(const Duration(milliseconds: 200));
        tries++;
      }
      int ctxTries = 0;
      while (Get.context == null && ctxTries < 30) {
        await Future.delayed(const Duration(milliseconds: 200));
        ctxTries++;
      }
      if (Get.context == null) return;
      Get.toNamed(RouteHelper.detailsDeepLink.replaceFirst(':id', '$id'));
    } finally {
      _navigating = false;
    }
  }
}
