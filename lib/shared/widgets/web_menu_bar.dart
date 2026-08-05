import 'package:abaad_flutter/features/notification/controller/notification_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';

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
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GetBuilder<UserController>(builder: (estateController) {
              return Row(
                children: [
                  // زر القائمة
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: ontop as GestureTapCallback?,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          Images.menu,
                          width: 28.0,
                          height: 28.0,
                        ),
                      ),
                    ),
                  ),

                  // نص ترحيبي بدل نص الموقع (مثال: "مرحبًا، أحمد")
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          _greeting(),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall - 1,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Text(
                          estateController.userInfoModel?.name ?? 'guest'.tr, // آمن: يعرض "guest" لو المستخدم زائر أو البيانات لم تُحمَّل بعد
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: const Color(0xFF1A3C5E),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // أيقونة الإشعارات / الرئيسية
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => fromPage == "main"
                          ? Get.toNamed(RouteHelper.getInitialRoute())
                          : Get.toNamed(RouteHelper.getNotificationRoute()),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: GetBuilder<NotificationController>(
                          builder: (notificationController) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  fromPage == "main"
                                      ? Icons.home_outlined
                                      : Icons.notifications_active_outlined,
                                  size: 28,
                                  color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                                if (notificationController.hasNotification)
                                  Positioned(
                                    top: -1,
                                    right: -1,
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 1.5,
                                          color: Theme.of(context).cardColor,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // تحية تتغيّر حسب وقت اليوم
  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'good_morning'.tr; // "صباح الخير"
    } else if (hour < 17) {
      return 'good_afternoon'.tr; // "مساء الخير" أو "طاب يومك"
    } else {
      return 'good_evening'.tr; // "مساء الخير"
    }
  }

  // الارتفاع = حجم status bar + 60px للمحتوى
  @override
  Size get preferredSize {
    final statusBarHeight = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    ).padding.top;
    return Size(Dimensions.WEB_MAX_WIDTH, statusBarHeight + 60);
  }
}