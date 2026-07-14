class ServiceModel {
  int? totalSize;
  int? limit;
  int? offset;
  List<ServiceOffer>? services;

  ServiceModel({this.totalSize, this.limit, this.offset, this.services});

  ServiceModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['data'] != null) {
      services = [];
      json['data'].forEach((v) {
        services!.add(ServiceOffer.fromJson(v));
      });
    }
  }
}

class ServiceOffer {
  int? id;
  String? title;
  String? description;
  String? image;
  String? offerType;
  String? servicePrice;
  double? discount;
  String? discountType; // 'percentage' أو 'fixed'
  String? formattedDiscount; // جاهز من الباكند: "10 %" أو "25.00 ريال"
  String? expiryDate;
  bool? isExpired;
  String? status;
  String? rejectionReason;
  // معرّف مقدّم الخدمة الذي أنشأ العرض (owner_id من الباكند) - يُستخدم لمقارنة الملكية
  int? ownerId;
  ServiceTypeData? serviceType;
  List<CategoryData>? categories;
  List<ZoneData>? zones;
  List<ProviderData>? providers;
  String? createdAt;

  ServiceOffer({
    this.id,
    this.title,
    this.description,
    this.image,
    this.offerType,
    this.servicePrice,
    this.discount,
    this.discountType,
    this.formattedDiscount,
    this.expiryDate,
    this.isExpired,
    this.status,
    this.rejectionReason,
    this.ownerId,
    this.serviceType,
    this.categories,
    this.zones,
    this.providers,
    this.createdAt,
  });

  ServiceOffer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    image = json['image'];
    offerType = json['offer_type'];
    servicePrice = json['service_price']?.toString();
    discount = json['discount'] != null
        ? double.tryParse(json['discount'].toString())
        : null;
    discountType = json['discount_type'];
    formattedDiscount = json['formatted_discount'];
    expiryDate = json['expiry_date'];
    isExpired = json['is_expired'] ?? false;
    status = json['status'];
    rejectionReason = json['rejection_reason'];
    ownerId = json['owner_id'] != null
        ? int.tryParse(json['owner_id'].toString())
        : null;
    serviceType = json['service_type'] != null
        ? ServiceTypeData.fromJson(json['service_type'])
        : null;

    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach(
        (v) => categories!.add(CategoryData.fromJson(v)),
      );
    }
    if (json['zones'] != null) {
      zones = [];
      json['zones'].forEach((v) => zones!.add(ZoneData.fromJson(v)));
    }
    if (json['providers'] != null) {
      providers = [];
      json['providers'].forEach(
        (v) => providers!.add(ProviderData.fromJson(v)),
      );
    }
    createdAt = json['created_at'];
  }
}

class ServiceTypeData {
  int? id;
  String? name;
  ServiceTypeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class CategoryData {
  int? id;
  String? name;
  String? nameAr;
  CategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
  }
}

class ZoneData {
  int? id;
  String? name;
  String? nameAr;
  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
  }
}

class ProviderData {
  int? id;
  String? name;
  String? phone;
  String? snapchat;
  String? instagram;
  String? website;
  String? tiktok;
  String? twitter;
  String? image;

  ProviderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    snapchat = json['snapchat'];
    instagram = json['instagram'];
    website = json['website'];
    tiktok = json['tiktok'];
    twitter = json['twitter'];
    image = json['image'];
  }
}

class FiltersData {
  List<CategoryData>? categories;
  List<ZoneData>? zones;
  List<ServiceTypeData>? serviceTypes;
  // مزودو الخدمة المتاحون لتعبئة فلتر "مزود الخدمة" في شاشة الكتالوج
  List<ProviderData>? providers;
  double? minPrice;
  double? maxPrice;

  FiltersData.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = [];
      json['categories'].forEach(
        (v) => categories!.add(CategoryData.fromJson(v)),
      );
    }
    if (json['zones'] != null) {
      zones = [];
      json['zones'].forEach((v) => zones!.add(ZoneData.fromJson(v)));
    }
    if (json['service_types'] != null) {
      serviceTypes = [];
      json['service_types'].forEach(
        (v) => serviceTypes!.add(ServiceTypeData.fromJson(v)),
      );
    }
    if (json['providers'] != null) {
      providers = [];
      json['providers'].forEach(
        (v) => providers!.add(ProviderData.fromJson(v)),
      );
    }
    minPrice = json['price_range']?['min'] != null
        ? double.parse(json['price_range']['min'].toString())
        : 0;
    maxPrice = json['price_range']?['max'] != null
        ? double.parse(json['price_range']['max'].toString())
        : 5000;
  }
}
