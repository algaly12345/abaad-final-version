import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/widgets/notifi_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool? isBackButtonExist;
  final Function? onBackPressed;
  final bool? showCart;

  const CustomAppBar({
    super.key,
    this.title = "",
    this.isBackButtonExist = true,
    this.onBackPressed,
    this.showCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AppBar(
        title: Text(
          title ?? "",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
        ),
        centerTitle: true,
        leading: isBackButtonExist!
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: () => onBackPressed != null
                      ? onBackPressed!()
                      : Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 18,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              )
            : const SizedBox(),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: showCart!
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: NotifIconWidget(
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size(Dimensions.WEB_MAX_WIDTH, GetPlatform.isDesktop ? 70 : 56);
}
