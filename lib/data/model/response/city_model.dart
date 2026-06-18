class CityModel {
  int cityId = 0;
  int regionId = 0;
  String nameAr = "";
  String nameEn = "";

  CityModel({required this.cityId, required this.regionId, required this.nameAr, required this.nameEn});

  CityModel.fromJson(Map<String, dynamic> json) {
    cityId = json['city_id'];
    regionId = json['region_id'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['city_id'] = cityId;
    data['region_id'] = regionId;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    return data;
  }
}