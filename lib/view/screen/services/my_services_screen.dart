import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/services_controller.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyServicesScreen extends StatefulWidget {
  final bool showAppBar;
  const MyServicesScreen({super.key, this.showAppBar = true});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<ServicesController>().getServicesList(
          1,
          reload: true,
          myServices: true,
        );
      }
    });
  }

  TabBar _statusTabBar(BuildContext context) {
    return TabBar(
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey,
      indicatorColor: Theme.of(context).primaryColor,
      tabs: const [
        Tab(text: 'العروض النشطة'),
        Tab(text: 'قيد المراجعة'),
        Tab(text: 'المنتهية/الملغية'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return NotLoggedInScreen();
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: widget.showAppBar
            ? AppBar(
                title: Text(
                  'my_services'.tr,
                  style: robotoBold.copyWith(color: Colors.black),
                ),
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.black),
                bottom: _statusTabBar(context),
              )
            : null,
        floatingActionButton: FloatingActionButton(
          onPressed: () => Get.toNamed(RouteHelper.getAddServiceOfferRoute()),
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.add),
        ),
        body: Column(
          children: [
            // عند الدمج داخل ServicesHubScreen تظهر تبويبات الحالة هنا بدل الـ AppBar
            if (!widget.showAppBar)
              Material(color: Colors.white, child: _statusTabBar(context)),
            Expanded(
              child: GetBuilder<ServicesController>(
                builder: (controller) {
                  if (controller.isMyServicesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.myServicesList == null ||
                      controller.myServicesList!.isEmpty) {
                    return const Center(
                      child: Text('لا توجد عروض مضافة حتى الآن'),
                    );
                  }

                  List active = controller.myServicesList!
                      .where(
                        (e) => e.status == 'accept' && !(e.isExpired ?? false),
                      )
                      .toList();
                  List pending = controller.myServicesList!
                      .where((e) => e.status == 'pending')
                      .toList();
                  List expired = controller.myServicesList!
                      .where(
                        (e) =>
                            e.status == 'cancelled' || (e.isExpired ?? false),
                      )
                      .toList();

                  return TabBarView(
                    children: [
                      _buildList(active, Colors.green),
                      _buildList(pending, Colors.orange),
                      _buildList(expired, Colors.red),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List services, Color badgeColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(service.image ?? ''),
            ),
            title: Text(service.title ?? '', style: robotoBold),
            subtitle: Text(
              'ينتهي في: ${service.expiryDate}',
              style: robotoRegular.copyWith(fontSize: 12),
            ),
            trailing: Switch(
              value: service.status == 'accept',
              activeColor: Theme.of(context).primaryColor,
              onChanged: service.status == 'cancelled' || service.id == null
                  ? null
                  : (val) {
                      Get.find<ServicesController>().toggleServiceStatus(
                        service.id!,
                      );
                    },
            ),
          ),
        );
      },
    );
  }
}
