import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// التخزين المحلي لكود الإحالة (مصدر الحقيقة الوحيد). يُدير حياته
/// [ReferralLinkManager]:
///  • يُكتَب فور استلام الكود من أي مصدر (ChottuLink SDK — مثبَّت/مؤجَّل،
///    الرابط الخام abaadapp.sa/ref/CODE، Play Install Referrer).
///  • يُقرأ عبر [peek] دون مسح (شاشة السبلاش للتوجيه، وشاشة التسجيل للتعبئة).
///  • **لا يُحذَف إلا عبر [clear]** بعد نجاح التسجيل وإرسال ref_code للباكند
///    (أو نجاح تسجيل دخول مستخدم قديم).
///
/// مستقل عن StorageService لتفادي أي اعتماد على توقيت تهيئة DI عند القراءة
/// المبكرة جدًا (أول تشغيل للتطبيق، قبل بناء GetMaterialApp).
class ReferralCodeStorage {
  static const String _key = 'pending_referral_code';

  static Future<void> save(String code) async {
    if (code.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);
  }

  /// يقرأ الكود المحفوظ دون مسحه. المسح الفعلي في [clear] فقط بعد نجاح التسجيل.
  static Future<String?> peek() async {
    final prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(_key);
    return (code != null && code.isNotEmpty) ? code : null;
  }

  /// يمسح الكود — يُستدعى **فقط** بعد نجاح التسجيل (وإرساله للباكند) أو نجاح
  /// تسجيل دخول مستخدم قديم. انظر ReferralLinkManager.clearAfterRegistration.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// قراءة/كتابة سلسلة عامة في SharedPreferences — يستخدمها ReferralLinkManager
  /// لمفتاح/نطاق ChottuLink (من /api/v1/config) وعلم أول تشغيل، دون اعتماد
  /// على تهيئة DI (قراءة مبكرة جدًا في main()).
  static Future<String?> readString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> writeString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// أندرويد فقط: يقرأ Play Install Referrer (القيمة التي مرّرها
  /// ReferralLinkController ضمن رابط متجر بلاي عند التحويل من
  /// abaadapp.sa/ref/CODE) ويحفظ الكود إن وُجد، ويعيده. احتياط للروابط الخام
  /// القديمة؛ الروابط عبر ChottuLink يغطّيها الـ SDK (تمرّر `cid` لا `ref_code`).
  /// يعيد null لو لم يحمل الـ referrer `ref_code`. يتجاهل أي خطأ بصمت.
  static Future<String?> captureFromPlayInstallReferrer() async {
    if (!GetPlatform.isAndroid) return null;

    try {
      final ReferrerDetails details = await PlayInstallReferrer.installReferrer;
      final String? referrer = details.installReferrer;
      if (referrer == null || referrer.isEmpty) return null;

      final String? code = Uri.splitQueryString(referrer)['ref_code'];
      if (code != null && code.isNotEmpty) {
        await save(code);
        return code;
      }
    } catch (e) {
      debugPrint('Play Install Referrer error: $e');
    }
    return null;
  }
}
