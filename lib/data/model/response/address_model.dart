import 'package:abaad_flutter/data/model/response/zone_response_model.dart';
class AddressModel {
  int? id;
  String? addressType;
  String? contactPersonNumber;
  String? address;
  String? latitude;
  String? longitude;
  int? zoneId;
  List<int>? zoneIds;
  String? method;
  String? contactPersonName;
  String? road;
  String? house;
  String? floor;
  List<ZoneData>? zoneData;
  AddressModel({
      required this.id,
      required this.addressType,
      required this.contactPersonNumber,
      required this.address,
      required this.latitude,
      required this.longitude,
      required this.zoneId,
      required this.zoneIds,
      required this.method,
      required this.contactPersonName,
      required this.road,
      required this.house,
      required this.floor,
      required this.zoneData,
  });

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    zoneId = json['zone_id'];
    zoneIds = json['zone_ids']?.cast<int>();
    method = json['_method'];
    contactPersonName = json['contact_person_name'];
    floor = json['floor'];
    road = json['road'];
    house = json['house'];
    if (json['zone_data'] != null) {
      zoneData = [];
      json['zone_data'].forEach((v) {
        zoneData?.add(ZoneData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['address_type'] = addressType;
    data['contact_person_number'] = contactPersonNumber;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['zone_id'] = zoneId;
    data['zone_ids'] = zoneIds;
    data['_method'] = method;
    data['contact_person_name'] = contactPersonName;
    data['road'] = road;
    data['house'] = house;
    data['floor'] = floor;
    data['zone_data'] = zoneData?.map((v) => v.toJson()).toList();
      return data;
  }
}
