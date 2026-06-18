import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NoInternetScreen extends StatelessWidget {
  final Widget? child;
  const NoInternetScreen({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.025),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Images.no_internet, width: 150, height: 150),
            Text('oops'.tr, style: robotoBold.copyWith(
              fontSize: 30,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Text(
              'no_internet_connection'.tr,
              textAlign: TextAlign.center,
              style: robotoRegular,
            ),
            SizedBox(height: 40),
            Container(
              height: 45,
              margin: EdgeInsets.symmetric(horizontal: 40),
              child: CustomButton(
                onPressed: () async {
                  if(await Connectivity().checkConnectivity() != ConnectivityResult.none) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => child as Widget));
                  }
                },
                buttonText: 'retry'.tr,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
