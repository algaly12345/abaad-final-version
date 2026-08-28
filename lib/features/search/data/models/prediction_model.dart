class PredictionModel {
  String description = "";
  String id = "";
  int distanceMeters = 0;
  String placeId = "";
  String reference = "";

  PredictionModel({
    required this.description,
    required this.id,
    required this.distanceMeters,
    required this.placeId,
    required this.reference
  });

  /// ملاحظة: تم إصلاح fromJson فقط — نفس اسم الكلاس وكل الحقول والكونستركتور
  /// كما هي بالضبط. المشكلة كانت أن استجابة Google Places Autocomplete
  /// غالبًا لا تحتوي إطلاقًا على الحقلين id وdistance_meters (هذان ليسا
  /// من الحقول القياسية في الاستجابة)، فكانت القيمة تصل null ويتم إسنادها
  /// مباشرة لحقول غير قابلة للـ null (String/int) فيحدث الكراش. الآن كل
  /// حقل له قيمة افتراضية آمنة ("" أو 0) إذا جاء null أو كان مفقودًا.
  PredictionModel.fromJson(Map<String, dynamic> json) {
    description = json['description']?.toString() ?? "";
    id = json['id']?.toString() ?? "";
    distanceMeters = json['distance_meters'] is int
        ? json['distance_meters']
        : int.tryParse(json['distance_meters']?.toString() ?? "") ?? 0;
    placeId = json['place_id']?.toString() ?? "";
    reference = json['reference']?.toString() ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['id'] = id;
    data['distance_meters'] = distanceMeters;
    data['place_id'] = placeId;
    data['reference'] = reference;
    return data;
  }
}