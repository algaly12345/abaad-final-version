import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class CustomButton extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isBold;
  const CustomButton({Key? key, this.onPressed, required this.buttonText, this.transparent = false, this.margin, this.width, this.height,
    this.fontSize, this.radius = 10, this.icon, this.color, this.textColor, this.isLoading = false, this.isBold = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: onPressed == null ? Theme.of(context).disabledColor : transparent
          ? Colors.transparent : color ?? Theme.of(context).primaryColor,
      minimumSize: Size(width != null ? width! : Dimensions.fontSizeLarge, height != null ? height! : 50),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    return Center(child: SizedBox(width: 300 ?? Dimensions.fontSizeLarge, child: Padding(
      padding: margin == null ? const EdgeInsets.all(10) : margin!,
      child: TextButton(
        onPressed: isLoading ? null : onPressed as void Function()?,
        style: flatButtonStyle,
        child: isLoading ? Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const SizedBox(
            height: 15, width: 15,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          Text('loading'.tr, style: robotoMedium.copyWith(color: Colors.white)),
        ]),
        ) :

        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          icon != null ? Container(
            padding: const EdgeInsets.only(right: 0),
            child: Icon(icon, color: transparent ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
          ) : const SizedBox(),
          Text(buttonText, textAlign: TextAlign.center,  style: isBold ? robotoBold.copyWith(
            color: textColor ?? (transparent ? Theme.of(context).primaryColor : Colors.white),
            fontSize: fontSize ?? Dimensions.fontSizeLarge,
          ) : robotoRegular.copyWith(
            color: textColor ?? (transparent ? Theme.of(context).primaryColor : Colors.white),
            fontSize: fontSize ?? Dimensions.fontSizeLarge,
          )
          ),
        ]),
      ),
    )));
  }
}
// class CustomButton extends StatelessWidget {
//   final Function? onPressed;
//   final String? buttonText;
//   final bool? transparent;
//   final EdgeInsets? margin;
//   final double? height;
//   final double? width;
//   final double? fontSize;
//   final double? radius;
//   final IconData? icon;
//
//   const CustomButton({
//     super.key,
//     this.onPressed,
//     this.buttonText = "",
//     this.transparent = false,
//     this.margin,
//     this.width = 100,
//     this.height = 0,
//     this.fontSize = 14,
//     this.radius = 5,
//     this.icon
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final ButtonStyle flatButtonStyle = TextButton.styleFrom(
//       backgroundColor: onPressed == null ? Theme.of(context).disabledColor : (transparent ?? false)
//           ? Colors.transparent : Theme.of(context).primaryColor,
//       // minimumSize: Size(width ?? Dimensions.WEB_MAX_WIDTH, height ?? 50),
//       padding: EdgeInsets.zero,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(radius!),
//       ),
//     );
//
//     return Center(
//       child: SizedBox(
//         // width: width ?? Dimensions.WEB_MAX_WIDTH,
//         child: Container(
//           padding: margin ?? EdgeInsets.all(1),
//           child: TextButton(
//             onPressed: onPressed  ,
//             style: flatButtonStyle.copyWith(
//               minimumSize: MaterialStateProperty.all<Size>(
//                 Size(double.infinity, 2), // عرض الزر لا نهائي (بحسب الحاوية)
//               ),
//               padding: MaterialStateProperty.all<EdgeInsets>(
//                 EdgeInsets.symmetric(vertical: 16),
//               ),
//             ),
//             child: Text(
//               buttonText ?? '',
//               textAlign: TextAlign.center,
//               style: robotoBold.copyWith(
//                 color: transparent ?? false
//                     ? Theme.of(context).primaryColor
//                     : Theme.of(context).cardColor,
//                 fontSize: fontSize ?? Dimensions.fontSizeLarge,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//
//
//     // return Center(child: SizedBox(width: width ?? Dimensions.WEB_MAX_WIDTH, child: Padding(
//     //   padding: margin ?? EdgeInsets.all(10),
//     //   child: TextButton(
//     //     onPressed: onPressed as VoidCallback,
//     //     style: flatButtonStyle,
//     //     child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//     //       icon != null ? Padding(
//     //         padding: EdgeInsets.only(right: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//     //         child: Icon(icon, color: transparent ?? false ? Theme.of(context).primaryColor : Theme.of(context).cardColor),
//     //       ) : SizedBox(),
//     //       Text(buttonText ??'', textAlign: TextAlign.center, style: robotoBold.copyWith(
//     //         color: transparent ?? false ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
//     //         fontSize: fontSize ?? Dimensions.fontSizeLarge,
//     //       )),
//     //     ]),
//     //   ),
//     // )));
//   }
// }
