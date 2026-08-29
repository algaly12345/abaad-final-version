import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// يخزّن كود إحالة وصل عبر رابط abaadapp.sa/ref/CODE (فتح مباشر لو التطبيق
/// مثبَّت) أو عبر Play Install Referrer (ترحيل تلقائي بعد تثبيت جديد)، حتى
/// تقرأه شاشة التسجيل وتُعبّيه تلقائيًا. مصدر مستقل عن StorageService لتفادي
/// أي اعتماد على توقيت تهيئة DI عند القراءة المبكرة جدًا (أول تشغيل للتطبيق).
class ReferralCodeStorage {
  static const String _key = 'pending_referral_code';
  static const String _pasteboardCheckedKey = 'referral_pasteboard_checked';
  static const String _pasteboardPrefix = 'abaad_ref:';

  static Future<void> save(String code) async {
    if (code.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  /// يقرأ الكود المحفوظ (إن وُجد) ثم يمسحه فورًا، حتى لا يُعاد استخدامه في
  /// عمليات تسجيل لاحقة غير مرتبطة بنفس الإحالة.
  static Future<String?> consume() async {
    final prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(_key);
    if (code != null) {
      await prefs.remove(_key);
    }
    return code;
  }

  /// يُستدعى مرة واحدة عند أول تشغيل للتطبيق (أندرويد فقط): يقرأ Play
  /// Install Referrer (القيمة اللي مرّرها ReferralLinkController على الباكند
  /// ضمن رابط متجر بلاي عند التحويل من abaadapp.sa/ref/CODE)، ويحفظ الكود
  /// إن وُجد ليُستهلك لاحقًا في شاشة التسجيل. لا يفعل شيئًا على غير أندرويد،
  /// ويتجاهل أي خطأ بصمت (تثبيت جانبي/عدم توفر خدمات Google Play/... إلخ) —
  /// هذا مجرد تحسين، لا يعطّل التسجيل اليدوي بالكود.
  static Future<void> captureFromPlayInstallReferrer() async {
    if (!GetPlatform.isAndroid) return;

    try {
      final ReferrerDetails details = await PlayInstallReferrer.installReferrer;
      final String? referrer = details.installReferrer;
      if (referrer == null || referrer.isEmpty) return;

      final String? code = Uri.splitQueryString(referrer)['ref_code'];
      if (code != null && code.isNotEmpty) {
        await save(code);
      }
    } catch (e) {
      debugPrint('Play Install Referrer error: $e');
    }
  }

  /// نظير captureFromPlayInstallReferrer على آيفون: Apple ما عندها آلية
  /// مكافئة لـ Play Install Referrer، فـ ReferralLinkController على الباكند
  /// يكتب الكود بالحافظة (clipboard) قبل تحويل المستخدم لـ App Store (انظر
  /// ReferralLinkController::iosStoreRedirectWithAttribution). نقرأه هنا
  /// مرة واحدة فقط عند أول تشغيل — قراءة الحافظة على iOS 14+ تُظهر تنبيه
  /// نظام "Allow Paste"، فنتجنب تكراره بعلامة SharedPreferences دائمة،
  /// ونتحقق من بادئة abaad_ref: حتى لا نلتقط نصًا عشوائيًا نسخه المستخدم
  /// لسبب آخر.
  static Future<void> captureFromPasteboard() async {
    if (!GetPlatform.isIOS) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_pasteboardCheckedKey) == true) return;
    await prefs.setBool(_pasteboardCheckedKey, true);

    try {
      final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
      final String? text = data?.text;
      if (text != null && text.startsWith(_pasteboardPrefix)) {
        final String code = text.substring(_pasteboardPrefix.length);
        if (code.isNotEmpty) {
          await save(code);
        }
      }
    } catch (e) {
      debugPrint('Referral pasteboard read error: $e');
    }
  }
}
