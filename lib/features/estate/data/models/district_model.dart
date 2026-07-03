class DistrictModel {
  int districtId = 0;
  int cityId = 0;
  int regionId = 0;
  String nameAr = "";
  String nameEn = "";

  DistrictModel(this.districtId, this.cityId, this.regionId, this.nameAr, this.nameEn);

  DistrictModel.fromJson(Map<String, dynamic> json) {
    districtId = json['district_id'];
    cityId = json['city_id'];
    regionId = json['region_id'];
    nameAr = json['name_ar'];
    nameEn = json['name_en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['district_id'] = districtId;
    data['city_id'] = cityId;
    data['region_id'] = regionId;
    data['name_ar'] = nameAr;
    data['name_en'] = nameEn;
    return data;
  }
}