import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';

import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response, {required bool showToaster}) {
    if(response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
     Get.find<WishListController>().removeWishes();
       Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
    }else {
     showCustomSnackBar(response.statusText.toString());
    }
  }
}
