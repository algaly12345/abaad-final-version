
enum NotificationType{
  message,
  order,
  general,
}

class NotificationBody {
  NotificationType? notificationType;
  int? orderId;
  int? adminId;
  int? deliverymanId;
  int? restaurantId;
  String? type;
  int? conversationId;

  NotificationBody({
     this.notificationType,
     this.orderId,
     this.adminId,
     this.deliverymanId,
     this.restaurantId,
     this.type,
     this.conversationId,
  });

  NotificationBody.fromJson(Map<String, dynamic>? json) {
    notificationType = convertToEnum(json?['order_notification'] ?? "order");
    orderId = json?['order_id'] ?? 0;
    adminId = json?['admin_id'] ?? 0;
    deliverymanId = json?['deliveryman_id'] ?? 0;
    restaurantId = json?['restaurant_id'] ?? 0;
    type = json?['type'] ?? "order";
    conversationId = json?['conversation_id'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_notification'] = notificationType.toString();
    data['order_id'] = orderId;
    data['admin_id'] = adminId;
    data['deliveryman_id'] = deliverymanId;
    data['restaurant_id'] = restaurantId;
    data['type'] = type;
    data['conversation_id'] = conversationId;
    return data;
  }

  NotificationType convertToEnum(String enumString) {
    if(enumString == NotificationType.general.toString()) {
      return NotificationType.general;
    }else if(enumString == NotificationType.order.toString()) {
      return NotificationType.order;
    }else if(enumString == NotificationType.message.toString()) {
      return NotificationType.message;
    }
    return NotificationType.general;
  }

}
