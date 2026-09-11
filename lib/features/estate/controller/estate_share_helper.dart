import 'dart:async';

import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/features/estate/data/repositories/estate_repo.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// رابط مشاركة العقار: رابط ChottuLink قصير من الباكند وجهته
/// `app.abaadapp.sa/details/{id}`. **بلا مكافأة/إحالة** — يعالجه
/// `ReferralLinkManager.handleUri()` كـ"تفاصيل عقار" فقط.
///
/// **تجربة مستخدم بلا انتظار** — ثلاث طبقات:
///  1. الباكند يُدرج `share_link` داخل رد `GET /api/v1/estate/details/{id}`
///     ويولّد الرابط القصير **بعد إرسال الرد**. [seedEstateShareLink] يخزّنه
///     فور فتح شاشة التفاصيل → زرّ المشاركة فوري في الغالبية العظمى.
///  2. [prefetchEstateShareLink] يجلبه بالخلفية احتياطًا فور فتح الشاشة.
///  3. [resolveEstateShareLink] عند الضغط: فوري من الكاش، وإلا مؤشّر تحميل
///     أنيق قصير جدًا ثم يتابع بالرابط الخام إن تأخّر (نادر).

/// كاش داخل ذاكرة الجلسة: معرّف العقار → رابط المشاركة القصير.
final Map<int, String> _shareLinkCache = {};

/// جلب جارٍ الآن لكل عقار — يمنع نداءين متوازيين؛ كلاهما ينتظر نفس الـ Future.
final Map<int, Future<String>> _inFlight = {};

bool _isShortLink(String link) =>
    link.contains(AppConstants.chottulinkDomain);

/// يخزّن رابط المشاركة القادم مع رد تفاصيل العقار (`response.body['share_link']`).
/// يتجاهل الرابط الخام المؤقّت (يعيده الباكند ريثما يولّد القصير) فيبقى الجلب
/// يحاول الحصول على القصير. نادِه من `EstateController.getEstateDetails`.
void seedEstateShareLink(int estateId, dynamic link) {
  if (estateId <= 0 || link is! String || link.isEmpty) return;
  if (_isShortLink(link)) {
    _shareLinkCache[estateId] = link;
  }
}

/// يُطلق جلب رابط المشاركة **بصمت وبلا انتظار** فور فتح شاشة/نافذة التفاصيل.
void prefetchEstateShareLink(int estateId) {
  if (estateId <= 0 || _shareLinkCache.containsKey(estateId)) return;
  unawaited(_fetchShareLink(estateId));
}

/// يُعيد رابط مشاركة العقار:
///  • مخزَّن (من رد التفاصيل / prefetch / مشاركة سابقة) → **فوري بلا مؤشّر**.
///  • غير ذلك → مؤشّر تحميل أنيق، وبحدٍّ أقصى [maxWait]؛ لو تأخّر يتابع بالرابط
///    الخام والجلب يكمل بالخلفية ويُخزَّن للمرّة القادمة.
Future<String> resolveEstateShareLink(
  int estateId, {
  Duration maxWait = const Duration(seconds: 2),
}) async {
  final String rawLink = '${AppConstants.ESTATE_DETAILS_DEEPLINK_BASE}$estateId';
  if (estateId <= 0) return rawLink;

  final String? cached = _shareLinkCache[estateId];
  if (cached != null) return cached;

  final Future<String> fetch = _fetchShareLink(estateId);

  bool loaderShown = false;
  try {
    if (Get.context != null && !(Get.isDialogOpen ?? false)) {
      loaderShown = true;
      Get.dialog(
        const _ShareLinkLoader(),
        barrierDismissible: false,
        barrierColor: Colors.black45,
      );
    }
    return await fetch.timeout(maxWait, onTimeout: () => rawLink);
  } finally {
    if (loaderShown && (Get.isDialogOpen ?? false)) Get.back();
  }
}

Future<String> _fetchShareLink(int estateId) {
  final Future<String>? existing = _inFlight[estateId];
  if (existing != null) return existing;

  final String rawLink = '${AppConstants.ESTATE_DETAILS_DEEPLINK_BASE}$estateId';

  final Future<String> run = () async {
    try {
      final EstateRepo repo = Get.isRegistered<EstateRepo>()
          ? Get.find<EstateRepo>()
          : EstateRepo(apiClient: Get.find<ApiClient>());

      final response = await repo
          .getShareLink(estateId)
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final dynamic body = response.body;
        final dynamic link = body is Map ? body['share_link'] : null;
        if (link is String && link.isNotEmpty) {
          // نخزّن القصير فقط؛ الخام لا يُخزَّن فتُعاد المحاولة لاحقًا.
          if (_isShortLink(link)) _shareLinkCache[estateId] = link;
          return link;
        }
      }
    } catch (_) {
      // شبكة/مهلة/خطأ خادم — نتراجع للرابط الخام بصمت.
    }
    return rawLink;
  }();

  _inFlight[estateId] = run;
  run.whenComplete(() {
    if (identical(_inFlight[estateId], run)) _inFlight.remove(estateId);
  });
  return run;
}

/// بطاقة تحميل صغيرة أنيقة تُعرض ريثما يجهز رابط المشاركة (نادر — الرابط عادةً
/// مخزَّن مسبقًا من رد التفاصيل).
class _ShareLinkLoader extends StatelessWidget {
  const _ShareLinkLoader();

  @override
  Widget build(BuildContext context) {
    final Color accent = Theme.of(context).primaryColor;
    return Center(
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(strokeWidth: 3, color: accent),
              ),
              const SizedBox(height: 14),
              Text(
                'preparing_share_link'.tr,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
