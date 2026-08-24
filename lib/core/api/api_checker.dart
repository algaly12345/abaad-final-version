import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';

import 'package:get/get.dart';

class ApiChecker {
  // لا تنقل المستخدم قسراً لشاشة تسجيل الدخول هنا: هذا الفحص يعمل خلف أي
  // طلب API في التطبيق (بينها طلبات خلفية لا علاقة لها بما يتصفحه المستخدم
  // فعلياً)، فتحويله عند أي 401 كان يقاطع تصفحه ويُبقيه عالقاً بين شاشة
  // الدخول وما كان يفعله. شاشات/مسارات المزوّد المحمية (NotLoggedInScreen،
  // AuthGuardMiddleware) تتحقق من isLoggedIn() بنفسها وتعرض طلب تسجيل الدخول
  // فقط عند محاولة استخدام ميزة تتطلبه فعلاً — مسح الجلسة المحلية هنا يكفي
  // ليجعل تلك الفحوصات تعمل بشكل صحيح في المرة القادمة.
  static void checkApi(Response response, {required bool showToaster}) {
    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      Get.find<WishListController>().removeWishes();
    }else {
     //showCustomSnackBar(_extractMessage(response));
    }
  }

  // الباكند يرسل رسالة عربية مفهومة ضمن body['message'] (مثلاً عند فشل
  // التحقق 422) — استخدام response.statusText وحده كان يعرض نص HTTP الخام
  // بالإنجليزية (مثل "Unprocessable Content") بدل هذه الرسالة.
  static String _extractMessage(Response response) {
    final body = response.body;
    if (body is Map && body['message'] is String && (body['message'] as String).isNotEmpty) {
      return body['message'] as String;
    }
    return response.statusText?.toString() ?? 'حدث خطأ غير متوقع';
  }
}
