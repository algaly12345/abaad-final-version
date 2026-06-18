
import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/location_controller.dart';
import 'package:abaad_flutter/view/base/custom_app_bar.dart';
import 'package:abaad_flutter/view/base/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccessLocationScreen extends StatelessWidget {
  final bool fromSignUp;
  final bool fromHome;
  final String route;
  const AccessLocationScreen({super.key, required this.fromSignUp, required this.fromHome, required this.route});

  @override
  Widget build(BuildContext context) {
    if(!fromHome) {
      Future.delayed(Duration(milliseconds: 500), () {
        Get.dialog(CustomLoader(), barrierDismissible: false);
        Get.find<LocationController>().autoNavigate(
          Get.find<LocationController>().getUserAddress()!,
          fromSignUp,
          route,
          route != null
        );
      });
    }
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(isLoggedIn) {
      Get.find<LocationController>().getAddressList();
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'set_location'.tr, isBackButtonExist: fromHome),
    );
  }
}


