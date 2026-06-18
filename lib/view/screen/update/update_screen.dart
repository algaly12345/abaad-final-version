import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatelessWidget {
   bool isUpdate;
  UpdateScreen({super.key, required this.isUpdate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

            Image.asset(
              isUpdate ? Images.update : Images.maintenance,
              width: MediaQuery.of(context).size.height*0.4,
              height: MediaQuery.of(context).size.height*0.4,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),

            Text(
              isUpdate ? 'update'.tr : 'we_are_under_maintenance'.tr,
              style: robotoBold.copyWith(fontSize: MediaQuery.of(context).size.height*0.023, color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height*0.01),

            Text(
              isUpdate ? 'your_app_is_deprecated'.tr : 'we_will_be_right_back'.tr,
              style: robotoRegular.copyWith(fontSize: MediaQuery.of(context).size.height*0.0175, color: Theme.of(context).disabledColor),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isUpdate ? MediaQuery.of(context).size.height*0.04 : 0),

            isUpdate ? CustomButton(height:40 , width:100, buttonText: 'update_now'.tr, onPressed: () async {
              String? appUrl;
              if(GetPlatform.isAndroid) {
                appUrl = Get.find<SplashController>().configModel?.appUrlAndroid;
              } else if(GetPlatform.isIOS) {
                appUrl = Get.find<SplashController>().configModel?.appUrlIos;
                print("like--------------------${appUrl}");
              }

              if(appUrl != null && await canLaunchUrlString(appUrl)) {
                launchUrlString(appUrl, mode: LaunchMode.externalApplication);
              } else {
                showCustomSnackBar('${'can_not_launch'.tr} ${appUrl ?? ''}');
              }

            }) : SizedBox(),

          ]),
        ),
      ),
    );
  }
}
