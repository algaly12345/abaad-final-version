import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/provider/view/screens/add_property_service_offer_screen.dart';
import 'package:abaad_flutter/features/provider/view/screens/provider_upgrade_screen.dart';
import 'package:abaad_flutter/features/services/view/screens/my_services_screen.dart';
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
      // يحفظ الوجهة المقصودة كي يعود المستخدم إليها مباشرة بعد تسجيل الدخول
      // بدل السقوط دائماً للصفحة الرئيسية — راجع
      // AuthController.setPendingPostAuthRedirect / NotLoggedInScreen.
      Get.find<AuthController>().setPendingPostAuthRedirect(
        () => switch (route) {
          RouteHelper.myServices => const MyServicesScreen(),
          RouteHelper.addServiceOffer => const AddPropertyServiceOfferScreen(),
          // service-provider و service-offer-payment: لا يمكن استرجاع
          // وجهتهما الدقيقة بأمان (الأول يعتمد userType قبل تسجيل الدخول،
          // والثاني يحتاج معاملات دفع ديناميكية). نقطة استهلاك pendingRedirect
          // تجلب بيانات مستخدم طازجة قبل استدعاء هذا الإغلاق، فنقرأ القرار
          // الصحيح فوراً بلا أي شاشة وسيطة: "خدماتي" لمن لديه طلب مزوّد خدمة
          // مسبقًا، أو شاشة الانضمام لمن لا يملك طلبًا بعد.
          _ => Get.find<UserController>().userInfoModel?.provider != null
              ? const MyServicesScreen()
              : const ProviderUpgradeScreen(),
        },
      );
      return const RouteSettings(name: RouteHelper.signIn);
    }
    return null;
  }
}
