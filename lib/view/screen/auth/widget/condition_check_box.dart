import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/screen/html/terms_condition_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConditionCheckBox extends StatelessWidget {
  final AuthController authController;
  const ConditionCheckBox({super.key, required this.authController});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 36,
          height: 36,
          child: Checkbox(
            activeColor: primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            value: authController.acceptTerms,
            onChanged: (bool? isChecked) => authController.toggleTerms(),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '${'i_agree_with'.tr} ',
                style: robotoRegular.copyWith(fontSize: 13),
              ),
              InkWell(
                onTap: () => Get.dialog(WebViewDialog(url: '')),
                child: Text(
                  'terms_conditions'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: 13,
                    color: primary,
                    decoration: TextDecoration.underline,
                    decorationColor: primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
