
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataView extends StatefulWidget {
  final String? value;
  final String? title;
  final bool? isButtonActive;
  final Function? onTap;

  const DataView({
    super.key,
    this.value,
    this.title,
    this.onTap,
    this.isButtonActive,
  });

  @override
  State<DataView> createState() => _DataViewState();
}

class _DataViewState extends State<DataView> {
  bool? _buttonActive;

  @override
  void initState() {
    super.initState();
    _buttonActive = widget.isButtonActive ?? false; // ✅ أعطينا قيمة افتراضية
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _buttonActive = !(_buttonActive ?? false); // ✅ نتأكد انها مش null
        });
        if (widget.onTap != null) {
          widget.onTap!(); // ✅ ننفذ فقط إذا مش null
        }
      },
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.PADDING_SIZE_SMALL,
          vertical: (_buttonActive ?? false)
              ? Dimensions.PADDING_SIZE_EXTRA_SMALL
              : Dimensions.PADDING_SIZE_DEFAULT,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
              spreadRadius: 1,
              blurRadius: 5,
            )
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
            Expanded(
              child: Text(
                widget.title ?? "", // ✅ ماعدش null
                style: robotoRegular,
              ),
            ),
            Text(widget.value ?? ""), // ✅ ماعدش null
          ],
        ),
      ),
    );
  }
}
