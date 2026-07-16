import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// يحجب الوصول لأي مسار مرتبط به إن لم يكن المستخدم مسجّلاً دخوله، ويعيد
/// التوجيه لشاشة تسجيل الدخول بدل ترك الشاشة تُبنى وتفشل لاحقاً عند أول
/// طلب API. لا يفحص نوع المستخدم (عميل/مزود) عمداً — يُستخدم فقط على
/// مسارات يجب أن تبقى متاحة لأي عميل مسجّل دخول (تدفّق "التقديم ليصبح
/// مزود خدمة")، بينما فحص صلاحيات المزوّد الدقيقة يبقى داخل الشاشات نفسها
/// عبر ProviderPermissionController كما هو معمول به حالياً.
class AuthGuardMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final loggedIn = Get.find<AuthController>().isLoggedIn();
    if (!loggedIn) {
      showCustomSnackBar('يجب تسجيل الدخول أولاً');
      return const RouteSettings(name: RouteHelper.signIn);
    }
    return null;
  }
}
