import 'package:abaad_flutter/helper/responsive_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

class TitleWidget extends StatelessWidget {
  final String? title;
  final Function? onTap;
  const TitleWidget({super.key, this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title ?? "", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
      (!ResponsiveHelper.isDesktop(context)) ? InkWell(
        onTap: onTap as GestureTapCallback?,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 5, 0, 5),
          child: Text(
            'view_all'.tr,
            style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor),
          ),
        ),
      ) : SizedBox(),
    ]);
  }
}
