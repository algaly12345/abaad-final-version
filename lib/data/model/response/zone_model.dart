import 'package:google_maps_flutter/google_maps_flutter.dart';

class ZoneModel {
  int id = 0;
  String name = "";
  Coordinates? coordinates;
  String status = "";
  String nameAr = "";
  String latitude = "";
  String longitude = "";
  String createdAt = "";
  int territory_id = 0;
  String estate_count = "";
  String image = "";
  String updatedAt = "";


  ZoneModel({required this.id, required this.name,required this.nameAr, required this.coordinates , required this.status, required this.createdAt, required this.updatedAt ,required this.latitude, required this.longitude,required this.image});

  ZoneModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    coordinates = json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : null;
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    territory_id = json['territory_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    estate_count = json['estate_count'];
    nameAr=json['name_ar'];
    image=json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    // if (required this.coordinates != null) {
    //   data['coordinates'] = required this.coordinates.toJson();
    // }
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['territory_id'] = territory_id;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['estate_count'] = estate_count;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}

class Coordinates {
  String type = "";
  List<LatLng>? coordinates;

  Coordinates({required this.type, required this.coordinates});

  Coordinates.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['coordinates'] != null) {
      coordinates = <LatLng>[];
      json['coordinates'][0].forEach((v) {
        coordinates?.add(LatLng(double.parse(v[0].toString()), double.parse(v[1].toString())));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates?.map((v) => v.toJson()).toList();
      return data;
  }
}
