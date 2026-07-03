
class PackageModel {
  List<Packages>? packages = [];

  PackageModel({ required this.packages});

  PackageModel.fromJson(Map<String, dynamic> json) {
    if (json['packages'] != null) {
      packages = <Packages>[];
      json['packages'].forEach((v) { packages?.add(Packages.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['packages'] = packages?.map((v) => v.toJson()).toList();
      return data;
  }
}

class Packages {
  int id = 0;
  String packageName = "";
  double price = 0;
  int validity = 0;
  String ?maxOrder = "";
  String maxProduct = "";
  int pos = 0;
  int mobileApp = 0;
  int chat = 0;
  int review = 0;
  int selfDelivery = 0;
  int status = 0;
  int def = 0;
  String createdAt = "";
  String updatedAt = "";
  String color = "";

  Packages({required this.id, required this.packageName, required this.price, required this.validity, required this.maxOrder, required this.maxProduct, required this.pos, required this.mobileApp, required this.chat, required this.review, required this.selfDelivery, required this.status, required this.def, required this.createdAt, required this.updatedAt, required this.color});

Packages.fromJson(Map<String, dynamic> json) {
  id = json['id'];
  packageName = json['package_name'];
  price = json['price'].toDouble();
  validity = json['validity'];
  maxOrder = json['max_order'];
  maxProduct = json['max_product'];
  pos = json['pos'];
  mobileApp = json['mobile_app'];
  chat = json['chat'];
  review = json['review'];
  selfDelivery = json['self_delivery'];
  status = json['status'];
  def = json['default'];
  createdAt = json['created_at'];
  updatedAt = json['updated_at'];
  color = json['colour'];
}

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = id;
  data['package_name'] = packageName;
  data['price'] = price;
  data['validity'] = validity;
  data['max_order'] = maxOrder;
  data['max_product'] = maxProduct;
  data['pos'] = pos;
  data['mobile_app'] = mobileApp;
  data['chat'] = chat;
  data['review'] = review;
  data['self_delivery'] = selfDelivery;
  data['status'] = status;
  data['default'] = def;
  data['created_at'] = createdAt;
  data['updated_at'] = updatedAt;
  data['colour'] = color;
  return data;
}
}
