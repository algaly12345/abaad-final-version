import 'package:abaad_flutter/core/routes/route_helper.dart';
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
