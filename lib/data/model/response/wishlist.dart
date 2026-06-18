import 'package:abaad_flutter/data/model/response/estate_model.dart';

class Wishlist {
  int id = 0;
  int userId = 0;
  int estateId = 0;
  String createdAt = "";
  String updatedAt = "";
  Estate? estate;

  Wishlist({
    required this.id,
    required this.userId,
    required this.estateId,
    required this.createdAt,
    required this.updatedAt,
    required this.estate
  });

  Wishlist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    estateId = json['estate_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    estate =
    json['estate'] != null ? Estate.fromJson(json['estate']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['estate_id'] = estateId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['estate'] = estate?.toJson();
      return data;
  }
}
