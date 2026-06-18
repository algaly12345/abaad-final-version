class RegionModel {
  int regionId = 0;
  int capitalCityId = 0;
  String code = "";
  String nameAr = "";
  String nameEn = "";
  int population = 0;
  String latitude = "";
  String longitude = "";

  RegionModel({
    required this.regionId,
    required this.capitalCityId,
    required this.code,
    required this.nameAr,
    required this.nameEn,
    required this.population,
    required this.latitude,
    required this.longitude
  });

  RegionModel.fromJson(Map<String, dynamic> json) {
    regionId = json['region_id'];
    capitalCityId = json['capital_city_id'];
    code = json['code'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
    population = json['population'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['region_id'] = regionId;
    data['capital_city_id'] = capitalCityId;
    data['code'] = code;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    data['population'] = population;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}