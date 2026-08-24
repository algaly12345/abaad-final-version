import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/dashboard/view/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// يمنع خروج التطبيق كاملاً عند ضغط زر الرجوع على شاشة قد تكون الجذر الوحيد
/// في المكدّس (مثلاً وجهة العودة بعد تسجيل الدخول عبر Get.offAll، التي تمسح
/// المكدّس بالكامل قبل عرضها) — إن وُجد شيء يمكن الرجوع إليه فعلياً يُنفَّذ
/// الرجوع الطبيعي، وإلا يذهب للصفحة الرئيسية بدل إغلاق التطبيق.
///
/// شفّاف تماماً عند استخدام الشاشة نفسها في سياق تنقّل عادي (لديها بالفعل ما
/// تعود إليه في المكدّس) — لا يغيّر سلوك الرجوع في تلك الحالة إطلاقاً.
class RootFallbackScope extends StatelessWidget {
  final Widget child;
  const RootFallbackScope({super.key, required this.child});

  /// لأزرار الرجوع اليدوية (أيقونة الشريط العلوي) في أي شاشة قد تكون وجهة
  /// عودة بعد تسجيل الدخول (راجع AuthController.setPendingPostAuthRedirect
  /// و my_services_screen.dart/provider_upgrade_screen.dart/
  /// complete_provider_profile_screen.dart) — Get.back() وحدها تتحقق من
  /// canPop() داخلياً ولا تستدعي Navigator.pop() إطلاقاً لو كان المكدّس يحوي
  /// مساراً واحداً فقط، فلا يُفعِّل onPopInvokedWithResult أعلاه أبداً (لأنه
  /// لا يُستدعى إلا حين تُحاوَل عملية pop فعلية). لذلك على زرّ الرجوع اليدوي
  /// استدعاء هذه الدالة بدل Get.back() مباشرة كي يعمل في الحالتين. الوجهة
  /// البديلة هنا "قائمة الخدمات" (pageIndex: 2) لا الرئيسية مباشرة، لأن كل
  /// الشاشات الثلاث المذكورة أعلاه جزء من مسار "الانضمام كمزوّد خدمة" المنطلق
  /// أصلاً من تبويب الخدمات.
  static void handleBackTap(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Get.back();
    } else {
      goToServices();
    }
  }

  /// ينقل مباشرة إلى تبويب "قائمة الخدمات" (Dashboard pageIndex 2)، بمسح
  /// المكدّس بالكامل — لا Get.back() تدريجي عبر شاشات المسار الوسيطة (مثلاً
  /// ProviderLandingScreen قبل ProviderUpgradeScreen). تُستخدَم من أزرار
  /// رجوع بعينها تريد تجاوز تلك الشاشات الوسيطة عمداً بدل عرضها مجدداً عند
  /// الرجوع (راجع نداءها من provider_upgrade_screen.dart)، بخلاف
  /// handleBackTap العام أعلاه الذي يبقي الرجوع الطبيعي متى أمكن.
  static void goToServices() {
    Get.offAll(() => const DashboardScreen(pageIndex: 2));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      },
      child: child,
    );
  }
}
