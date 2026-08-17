import 'package:abaad_flutter/features/provider/controller/provider_permission_controller.dart';
import 'package:abaad_flutter/features/provider/view/screens/provider_landing_screen.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/features/services/view/screens/services_catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return GetBuilder<ProviderPermissionController>(
      builder: (pc) {
        // الشريط العلوي (حقل بحث دائم + زر فلترة) بات مملوكاً بالكامل من
        // ServicesCatalogScreen بدل تكراره هنا — هذه الشاشة تمرّر فقط
        // زر الإجراء العائم. أيقونة "طلباتي/خدماتي" أُزيلت لأنها باتت
        // مكررة بعد أن صار الزرّ العائم ينقل مزوّد الخدمة إلى نفس الشاشة.
        final fab = pc.isProvider
            ? FloatingActionButton.extended(

          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          onPressed: () =>
              Get.toNamed(RouteHelper.getMyServicesRoute()),
          icon: const Icon(Icons.add_business),
          label: Text('خدماتي',
              style: AppTypography.smallBold
                  .copyWith(color: Colors.white)),
        )
            : FloatingActionButton.extended(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 4,
          onPressed: () => Get.to(() => const ProviderLandingScreen()),
          icon: const Icon(Icons.handshake_outlined),
          label: Text('انضم كمزود خدمة',
              style: AppTypography.smallBold
                  .copyWith(color: Colors.white)),
        );

        return ServicesCatalogScreen(
          showAppBar: true,
          // مزود خدمة معتمد: الزرّ العائم ينقله مباشرة إلى شاشة "خدماتي"
          // الخاصة به. زائر/عميل عادي: الزرّ يفتح شاشة تعريفية تُقنعه
          // بالتسجيل كمزود بدل توجيهه مباشرة لنموذج بيانات لا سياق له،
          // ودون أي خطأ ظاهر لغياب صلاحية المزود.
          //
          // ملاحظة مهمة: هذه الشاشة تُعرض كصفحة داخل PageView جوّا
          // DashboardScreen، الذي عنده Scaffold خارجي بـ extendBody: true
          // و bottomNavigationBar (BottomAppBar). الـ Scaffold الداخلي هنا
          // (داخل ServicesCatalogScreen) لا يعرف بوجود ذلك الشريط السفلي
          // إطلاقًا، فيضع الزر العائم افتراضيًا عند أسفل حدوده الخاصة —
          // التي تمتد بسبب extendBody لتغطي كامل الشاشة، فينتهي الزر مرسومًا
          // تحديدًا خلف BottomAppBar (محجوبًا بصريًا رغم أنه موجود فعليًا).
          // الحل: رفع الزر بمقدار يعادل تقريبًا ارتفاع الشريط السفلي كي
          // يظهر فوقه بوضوح.
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 100),

            child: fab,
          ),
        );
      },
    );
  }
}