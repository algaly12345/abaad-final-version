class ServiceTypeModel {
  int? id;
  String? name;

  ServiceTypeModel({this.id, this.name});

  ServiceTypeModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class OfferCategoryModel {
  int? id;
  String? name;
  String? nameAr;

  OfferCategoryModel({this.id, this.name, this.nameAr});

  OfferCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
  }
}

class OfferZoneModel {
  int? id;
  String? name;
  String? nameAr;

  OfferZoneModel({this.id, this.name, this.nameAr});

  OfferZoneModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    nameAr = json['name_ar'];
  }
}

class ServicePlanModel {
  int? id;
  String? name;
  double? price;
  int? numberOfAds;
  int? numberOfCategories;
  int? numberOfZone;
  bool? featuredDisplay;
  bool? interactiveReports;
  bool? crmSystem;

  ServicePlanModel({
    this.id,
    this.name,
    this.price,
    this.numberOfAds,
    this.numberOfCategories,
    this.numberOfZone,
    this.featuredDisplay,
    this.interactiveReports,
    this.crmSystem,
  });

  ServicePlanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'] ?? json['package_name'];
    price = double.tryParse(json['price'].toString()) ?? 0;
    numberOfAds = int.tryParse(json['number_of_ads'].toString()) ?? 0;
    numberOfCategories =
        int.tryParse(json['number_of_categories'].toString()) ?? 0;
    numberOfZone = int.tryParse(json['number_of_zone'].toString()) ?? 0;
    featuredDisplay =
        json['featured_display'] == 1 || json['featured_display'] == true;
    interactiveReports =
        json['interactive_reports'] == 1 || json['interactive_reports'] == true;
    crmSystem = json['crm_system'] == 1 || json['crm_system'] == true;
  }
}

class OfferSetupDataModel {
  List<ServiceTypeModel>? serviceTypes;
  List<OfferCategoryModel>? categories;
  List<OfferZoneModel>? zones;
  List<ServicePlanModel>? servicePlans;

  OfferSetupDataModel({
    this.serviceTypes,
    this.categories,
    this.zones,
    this.servicePlans,
  });

  OfferSetupDataModel.fromJson(Map<String, dynamic> json) {
    if (json['service_types'] != null) {
      serviceTypes = [];
      for (var item in json['service_types']) {
        serviceTypes?.add(ServiceTypeModel.fromJson(item));
      }
    }
    if (json['categories'] != null) {
      categories = [];
      for (var item in json['categories']) {
        categories?.add(OfferCategoryModel.fromJson(item));
      }
    }
    if (json['zones'] != null) {
      zones = [];
      for (var item in json['zones']) {
        zones?.add(OfferZoneModel.fromJson(item));
      }
    }
    if (json['service_plans'] != null) {
      servicePlans = [];
      for (var item in json['service_plans']) {
        servicePlans?.add(ServicePlanModel.fromJson(item));
      }
    }
  }
}

class PriceCalculationModel {
  double? basePrice;
  int? extraZones;
  double? extraZonesCost;
  double? totalPrice;

  PriceCalculationModel({
    this.basePrice,
    this.extraZones,
    this.extraZonesCost,
    this.totalPrice,
  });

  PriceCalculationModel.fromJson(Map<String, dynamic> json) {
    basePrice = double.tryParse(json['base_price'].toString()) ?? 0;
    extraZones = int.tryParse(json['extra_zones'].toString()) ?? 0;
    extraZonesCost = double.tryParse(json['extra_zones_cost'].toString()) ?? 0;
    totalPrice = double.tryParse(json['total_price'].toString()) ?? 0;
  }
}

class StoreOfferResponseModel {
  int? offerId;
  int? subscriptionId;
  String? subscriptionNumber;
  String? planName;
  int? duration;
  String? expiryDate;
  double? basePrice;
  int? extraZones;
  double? extraZonesCost;
  double? amountToPay;
  String? currency;
  String? paymentUrl;

  StoreOfferResponseModel.fromJson(Map<String, dynamic> json) {
    offerId = json['offer_id'];
    subscriptionId = json['subscription_id'];
    subscriptionNumber = json['subscription_number'];
    planName = json['plan_name'];
    duration = json['duration'];
    expiryDate = json['expiry_date'];
    basePrice = double.tryParse(json['base_price'].toString()) ?? 0;
    extraZones = int.tryParse(json['extra_zones'].toString()) ?? 0;
    extraZonesCost = double.tryParse(json['extra_zones_cost'].toString()) ?? 0;
    amountToPay = double.tryParse(json['amount_to_pay'].toString()) ?? 0;
    currency = json['currency'];
    paymentUrl = json['payment_url'];
  }
}
