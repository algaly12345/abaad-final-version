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
        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            toolbarHeight: 64,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            title: ServicesAppBarTitle(
              title: 'services'.tr,
              subtitle: 'أفضل العروض والخصومات الحصرية',
            ),
            actions: const [ServicesAppBarActions()],
          ),
          body: const ServicesCatalogScreen(showAppBar: false),
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
              : null,
        );
      },
    );
  }
}
