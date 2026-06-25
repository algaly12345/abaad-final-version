import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/screen/services/my_services_screen.dart';
import 'package:abaad_flutter/view/screen/services/services_catalog_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicesHubScreen extends StatelessWidget {
  const ServicesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            'service'.tr,
            style: robotoBold.copyWith(color: Colors.black),
          ),
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: 'all_services'.tr),
              Tab(text: 'my_services'.tr),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ServicesCatalogScreen(showAppBar: false),
            MyServicesScreen(showAppBar: false),
          ],
        ),
      ),
    );
  }
}
