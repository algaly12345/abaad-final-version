class FacilitiesModel {
  int id = 0;
  String name = "";
  String image = "";
  Null createdAt;
  Null updatedAt;

  FacilitiesModel({required this.id, required this.name,required this.image, required this.createdAt, required this.updatedAt});

  FacilitiesModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}