class NotificationModel {
  int id = 0;
  String title = "";
  String description = "";
  String tergat = "";
  String type = "";
  String readAt = "";
  int status = 0;
  int userId = 0;
  String createdAt = "";
  String updatedAt = "";
  int zoneId = 0;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tergat,
    required this.type,
    required this.readAt,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.zoneId,
  });

  /// ملاحظة: تم إصلاح fromJson فقط — الكلاس واسم الكونستركتور وكل الحقول
  /// كما هي بالضبط. المشكلة كانت أن السيرفر أحيانًا يرجع بعض الحقول
  /// (type, user_id, zone_id) بقيمة null، وحقل read_at أحيانًا لا يكون
  /// موجودًا في الاستجابة إطلاقًا — وإسنادها مباشرة لحقول غير قابلة للـ
  /// null (String/int) كان يسبب الكراش. الآن كل حقل له قيمة افتراضية
  /// آمنة (""  أو 0) إذا جاء null أو كان القيمة مفقودة.
  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    title = json['title']?.toString() ?? "";
    description = json['description']?.toString() ?? "";
    tergat = json['tergat']?.toString() ?? "";
    type = json['type']?.toString() ?? "";
    readAt = json['read_at']?.toString() ?? "";
    status = json['status'] ?? 0;
    userId = json['user_id'] ?? 0;
    createdAt = json['created_at']?.toString() ?? "";
    updatedAt = json['updated_at']?.toString() ?? "";
    zoneId = json['zone_id'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['tergat'] = tergat;
    data['type'] = type;
    data['read_at'] = readAt;
    data['status'] = status;
    data['user_id'] = userId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['zone_id'] = zoneId;
    return data;
  }
}