import 'package:abaad_flutter/controller/provider_permission_controller.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/screen/services/my_services_screen.dart';
import 'package:abaad_flutter/view/screen/services/services_catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicesHubScreen extends StatefulWidget {
  const ServicesHubScreen({super.key});

  @override
  State<ServicesHubScreen> createState() => _ServicesHubScreenState();
}

class _ServicesHubScreenState extends State<ServicesHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _wasProvider = false;

  @override
  void initState() {
    super.initState();
    final isProvider =
        Get.find<ProviderPermissionController>().isProvider;
    _wasProvider = isProvider;
    _tabController = TabController(
      length: isProvider ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // يُعيد بناء الـ TabController إذا تغيّرت حالة "مزود الخدمة"
  void _rebuildIfNeeded(bool isProvider) {
    if (_wasProvider != isProvider) {
      _wasProvider = isProvider;
      _tabController.dispose();
      _tabController = TabController(
        length: isProvider ? 2 : 1,
        vsync: this,
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return GetBuilder<ProviderPermissionController>(
      builder: (pc) {
        _rebuildIfNeeded(pc.isProvider);
        final isProvider = pc.isProvider;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6F9),
          appBar: AppBar(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'service'.tr,
              style: robotoBold.copyWith(fontSize: 17, color: Colors.white),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelStyle: robotoMedium.copyWith(fontSize: 14),
              unselectedLabelStyle: robotoRegular.copyWith(fontSize: 14),
              tabs: [
                Tab(text: 'all_services'.tr),
                if (isProvider) Tab(text: 'my_services'.tr),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              const ServicesCatalogScreen(showAppBar: false),
              if (isProvider) const MyServicesScreen(showAppBar: false),
            ],
          ),
        );
      },
    );
  }
}
