import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'registration_stepper.dart';
class RegistrationStepperWidget extends StatelessWidget {
  final String? status;
  const RegistrationStepperWidget({Key? key, this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int status = 0;
     if(status == 'business') {
      status = 1;
    }else if(status == 'payment') {
      status = 2;
    }else if(status == 'complete') {
      status = 3;
    }
    return Container(
      child: Row(children: [
        RegistrationStepper(
          title: 'property_information'.tr, isActive: true, haveLeftBar: false, haveRightBar: true, rightActive: true, onGoing: status == 0,
        ),




        RegistrationStepper(
          title: 'marketing_plan'.tr, isActive: status > 1, haveLeftBar: true, haveRightBar: true, rightActive: status > 1, onGoing: status == 1, processing: status != 3 && status != 0,
        ),



        RegistrationStepper(
          title: 'complete'.tr, isActive: status == 3, haveLeftBar: true, haveRightBar: false, rightActive: status == 3,
        ),


      ]),
    );
  }
}
