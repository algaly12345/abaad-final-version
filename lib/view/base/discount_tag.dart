import 'package:abaad_flutter/helper/responsive_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:flutter/material.dart';

class DiscountTag extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double? fromTop;
  final double? fontSize;
  final bool? inLeft ;
  final bool? freeDelivery ;
  const DiscountTag({
    super.key,
    this.discount = 0,
    this.discountType,
    this.fromTop = 10,
    this.fontSize = 14,
    this.freeDelivery = false,
    this.inLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    return ((discount ?? 0) > 0 || (freeDelivery ?? false)) ? Positioned(
      top: fromTop, left: (inLeft ?? false) ? 0 : null, right: (inLeft ?? false) ? null : 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular((inLeft ?? false) ? Dimensions.RADIUS_SMALL : 0),
            left: Radius.circular((inLeft ?? false) ? 0 : Dimensions.RADIUS_SMALL),
          ),
        ),
        child: Text(
         'percent'  ,
          style: robotoMedium.copyWith(
            color: Colors.white,
            fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 8 : 12),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ) : SizedBox();
  }
}
