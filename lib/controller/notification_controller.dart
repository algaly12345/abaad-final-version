import 'package:abaad_flutter/data/api/api_checker.dart';
import 'package:abaad_flutter/data/model/response/notification_model.dart';
import 'package:abaad_flutter/data/repository/notification_repo.dart';
import 'package:abaad_flutter/helper/date_converter.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationRepo notificationRepo;
  NotificationController({required this.notificationRepo});

  List<NotificationModel>? _notificationList;
  final bool _hasNotification = false;
  List<NotificationModel>? get notificationList => _notificationList;
  bool get hasNotification => _hasNotification;

  Future<int?> getNotificationList(bool reload) async {
    if(reload) {
      Response response = await notificationRepo.getNotificationList();
      if (response.statusCode == 200) {
        _notificationList = [];
        response.body.forEach((notification) => _notificationList?.add(NotificationModel.fromJson(notification)));
        _notificationList?.sort((a, b) {
          return DateConverter.isoStringToLocalDate(a.updatedAt).compareTo(DateConverter.isoStringToLocalDate(b.updatedAt));
        });
        Iterable iterable = _notificationList?.reversed as Iterable;
        _notificationList = iterable.cast<NotificationModel>().toList();
       // _hasNotification = _notificationList.length != getSeenNotificationCount();
      } else {
        ApiChecker.checkApi(response, showToaster: true);
      }
      update();
    }
    return _notificationList?.length;
  }

  // void saveSeenNotificationCount(int count) {
  //   notificationRepo.saveSeenNotificationCount(count);
  // }
  //
  // int getSeenNotificationCount() {
  //   return notificationRepo.getSeenNotificationCount();
  // }

  void clearNotification() {
    _notificationList = null;
  }

}
