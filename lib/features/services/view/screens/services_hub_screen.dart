import 'package:abaad_flutter/features/provider/controller/provider_permission_controller.dart';
import 'package:abaad_flutter/features/provider/view/screens/provider_landing_screen.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
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
        // أيقونة "طلباتي" الإضافية الخاصة بها وزر الإجراء العائم.
        return ServicesCatalogScreen(
          showAppBar: true,
          extraActions: [
            // أيقونة "طلباتي/خدماتي" مقصورة على مزودي الخدمة المعتمدين فقط —
            // العميل العادي غير المسجَّل كمزود لا يجب أن يراها إطلاقاً.
            if (pc.isProvider)
              IconButton(
                tooltip: 'my_applications'.tr,
                icon: Icon(Icons.assignment_outlined, color: primary),
                onPressed: () => Get.toNamed(RouteHelper.getMyServicesRoute()),
              ),
          ],
          // مزود خدمة معتمد: الزرّ العائم يفتح مباشرة نموذج "إضافة خدمة"
          // (بدل شاشة "خدماتي" — الوصول إليها بات محصوراً في أيقونة
          // "طلباتي" أعلاه فقط، فلا تكرار بين الاثنين). زائر/عميل عادي: الزرّ
          // يفتح شاشة تعريفية تُقنعه بالتسجيل كمزود بدل توجيهه مباشرة لنموذج
          // بيانات لا سياق له، ودون أي خطأ ظاهر لغياب صلاحية المزود.
          floatingActionButton: pc.isProvider
              ? FloatingActionButton.extended(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () =>
                      Get.toNamed(RouteHelper.getAddServiceOfferRoute()),
                  icon: const Icon(Icons.add_business),
                  label: Text('إضافة خدمة',
                      style: robotoBold.copyWith(
                          color: Colors.white, fontSize: 13)),
                )
              : FloatingActionButton.extended(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () => Get.to(() => const ProviderLandingScreen()),
                  icon: const Icon(Icons.handshake_outlined),
                  label: Text('انضم كمزود خدمة',
                      style: robotoBold.copyWith(
                          color: Colors.white, fontSize: 13)),
                ),
        );
      },
    );
  }
}
