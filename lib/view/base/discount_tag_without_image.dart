import 'package:abaad_flutter/helper/responsive_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:flutter/material.dart';

class DiscountTagWithoutImage extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double? fromTop;
  final double? fontSize;
  final bool? freeDelivery;
  const DiscountTagWithoutImage({
    super.key,
    this.discount,
    this.discountType,
    this.fromTop = 10,
    this.fontSize,
    this.freeDelivery = false,
  });

  @override
  Widget build(BuildContext context) {
    return ((discount ?? 0) > 0 || (freeDelivery ?? false)) ? Container(
      padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      decoration: BoxDecoration(
        // color: Colors.green,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
      ),
      child: Text(
        'percent',
        style: robotoBold.copyWith(
          color: Colors.green,
          fontSize: fontSize ?? (ResponsiveHelper.isMobile(context) ? 8 : 12),
        ),
        textAlign: TextAlign.center,
      ),
    ) : SizedBox();
  }
}
