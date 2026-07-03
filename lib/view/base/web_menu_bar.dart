import 'package:abaad_flutter/controller/notification_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WebMenuBar extends StatelessWidget implements PreferredSizeWidget {
  final Function? ontop;
  final String? fromPage;
  const WebMenuBar({super.key, this.ontop, this.fromPage});

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).appBarTheme.backgroundColor ?? Colors.white;
    return Container(
      color: bg,
      // SafeArea يضمن أن المحتوى يبدأ أسفل status bar بدقة على كل جهاز
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GetBuilder<UserController>(builder: (estateController) {
              return Row(
                children: [
                  InkWell(
                    onTap: ontop as GestureTapCallback?,
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(Images.menu, width: 34.0, height: 34.0),
                  ),
                  const Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'your_location'.tr,
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        '${estateController.address}',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: const Color(0xFF1A3C5E),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    child: GetBuilder<NotificationController>(
                        builder: (notificationController) {
                      return Stack(children: [
                        Icon(
                          fromPage == "main"
                              ? Icons.home_outlined
                              : Icons.notifications_active_outlined,
                          size: 34,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        if (notificationController.hasNotification)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              height: 10,
                              width: 10,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 1,
                                  color: Theme.of(context).cardColor,
                                ),
                              ),
                            ),
                          ),
                      ]);
                    }),
                    onTap: () => fromPage == "main"
                        ? Get.toNamed(RouteHelper.getInitialRoute())
                        : Get.toNamed(RouteHelper.getNotificationRoute()),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // الارتفاع = حجم status bar + 56px للمحتوى
  @override
  Size get preferredSize {
    final statusBarHeight = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).padding.top;
    return Size(Dimensions.WEB_MAX_WIDTH, statusBarHeight + 56);
  }
}
