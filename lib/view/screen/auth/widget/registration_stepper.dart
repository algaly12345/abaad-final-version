
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:flutter/material.dart';
class RegistrationStepper extends StatelessWidget {
  final bool? isActive;
  final bool? haveLeftBar;
  final bool? haveRightBar;
  final String? title;
  final bool? rightActive;
  final bool? onGoing;
  final bool? processing;

  const RegistrationStepper({
    Key? key,
    this.isActive,
    this.haveLeftBar,
    this.haveRightBar,
    this.title,
    this.rightActive,
    this.onGoing = false,
    this.processing = false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color = (onGoing ?? false) ? Theme.of(context).primaryColor : (isActive ?? false) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor;
    Color right = (onGoing ?? false) ? Theme.of(context).disabledColor : (rightActive ?? false) ? Theme.of(context).primaryColor : Theme.of(context).disabledColor;
    return Expanded(
      child: Column(children: [

        Row(children: [
          Expanded(child: (haveLeftBar ?? false) ? Divider(color: color, thickness: 2) : SizedBox()),
          Icon( (onGoing ?? false) ? Icons.adjust : (processing ?? false) ? Icons.adjust : (rightActive ?? false) ? Icons.check_circle : Icons.circle_outlined, color: color, size: 30),
          Expanded(child: (haveRightBar ?? false) ? Divider(color: right, thickness: 2) : SizedBox()),
          ]),

          SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

          SizedBox(
            height: 30,
            child: Text(
              (title ?? ""),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeExtraSmall),
            ),
          ),
      ]),
    );
  }
}
