// import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:abaad_flutter/data/model/response/service_provider.dart';
class BasicCampaignModel {
  int? id = 0;
  String? title = "";
  String? image = "";
  String? description = "";
  String? availableDateStarts = "";
  String? availableDateEnds = "";
  String? startTime = "";
  String? endTime = "";
  List<ServiceProvider>? restaurants;

  BasicCampaignModel({
    this.id = 0,
    this.title = "",
    this.image = "",
    this.description = "",
    this.availableDateStarts = "",
    this.availableDateEnds = "",
    this.startTime = "",
    this.endTime = "",
    required this.restaurants
  });

  BasicCampaignModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    image = json['image'];
    description = json['description'];
    availableDateStarts = json['available_date_starts'];
    availableDateEnds = json['available_date_ends'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    if (json['restaurants'] != null) {
      restaurants = [];
      json['providers'].forEach((v) {
        restaurants?.add(ServiceProvider.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['image'] = image;
    data['description'] = description;
    data['available_date_starts'] = availableDateStarts;
    data['available_date_ends'] = availableDateEnds;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['providers'] = restaurants?.map((v) => v.toJson()).toList();
      return data;
  }
}
