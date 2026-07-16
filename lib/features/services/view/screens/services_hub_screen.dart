import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/provider/controller/provider_permission_controller.dart';
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
        // الشريط العلوي (متدرّج + بحث قابل للطي) بات مملوكاً بالكامل من
        // ServicesCatalogScreen بدل تكراره هنا — هذه الشاشة تمرّر فقط
        // العنوان وأيقونة "طلباتي" الإضافية الخاصة بها وزر الإجراء العائم.
        return ServicesCatalogScreen(
          showAppBar: true,
          title: 'services'.tr,
          subtitle: 'أفضل العروض والخصومات الحصرية',
          extraActions: [
            // نقطة وصول دائمة لحالة طلباتي/خدماتي، بغض النظر عن كونه
            // مزود خدمة فعلياً أو لسه بانتظار موافقة الأدمن — بعكس زر
            // "خدماتي" العائم اللي يظهر فقط لمزودي الخدمة المعتمدين.
            if (Get.find<AuthController>().isLoggedIn())
              IconButton(
                tooltip: 'my_applications'.tr,
                icon: const Icon(Icons.assignment_outlined, color: Colors.white),
                onPressed: () => Get.toNamed(RouteHelper.getMyServicesRoute()),
              ),
          ],
          floatingActionButton: pc.isProvider
              ? FloatingActionButton.extended(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () =>
                      Get.toNamed(RouteHelper.getMyServicesRoute()),
                  icon: const Icon(Icons.dashboard_customize_rounded),
                  label: Text('خدماتي',
                      style: robotoBold.copyWith(
                          color: Colors.white, fontSize: 13)),
                )
              : FloatingActionButton.extended(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  onPressed: () =>
                      Get.toNamed(RouteHelper.getServiceProviderRoute()),
                  icon: const Icon(Icons.handshake_outlined),
                  label: Text('صير مزود خدمة',
                      style: robotoBold.copyWith(
                          color: Colors.white, fontSize: 13)),
                ),
        );
      },
    );
  }
}
