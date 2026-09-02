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

/// إعدادات تسعير اشتراك مزوّد الخدمة العامة (99 ريال أساسي، منطقة ونوع منتج
/// واحد مشمولان، 49 ريال لكل إضافة) — تحل محل ServicePlanModel (الباقات
/// الثلاث الثابتة القديمة). قيَم افتراضية آمنة عند غياب الحقل من الرد.
class SubscriptionPricingSettingsModel {
  double basePrice;
  int includedZones;
  int includedCategories;
  double extraZonePrice;
  double extraCategoryPrice;
  // نسبة ضريبة القيمة المضافة المطبَّقة فوق الإجمالي بعد الخصم (افتراضي 15%).
  double vatPercent;

  SubscriptionPricingSettingsModel({
    this.basePrice = 99,
    this.includedZones = 1,
    this.includedCategories = 1,
    this.extraZonePrice = 49,
    this.extraCategoryPrice = 49,
    this.vatPercent = 15,
  });

  SubscriptionPricingSettingsModel.fromJson(Map<String, dynamic> json)
      : basePrice = double.tryParse(json['base_price'].toString()) ?? 99,
        includedZones = int.tryParse(json['included_zones'].toString()) ?? 1,
        includedCategories =
            int.tryParse(json['included_categories'].toString()) ?? 1,
        extraZonePrice =
            double.tryParse(json['extra_zone_price'].toString()) ?? 49,
        extraCategoryPrice =
            double.tryParse(json['extra_category_price'].toString()) ?? 49,
        vatPercent = double.tryParse(json['vat_percent'].toString()) ?? 15;
}

/// نسبة الخصم المطبَّقة على إجمالي قيمة الاشتراك الشهري حسب مدة الاشتراك
/// المختارة (1/3/6/12 شهرًا).
class DurationDiscountModel {
  int durationMonths;
  int discountPercent;

  DurationDiscountModel({
    required this.durationMonths,
    required this.discountPercent,
  });

  DurationDiscountModel.fromJson(Map<String, dynamic> json)
      : durationMonths = int.tryParse(json['duration_months'].toString()) ?? 1,
        discountPercent =
            int.tryParse(json['discount_percent'].toString()) ?? 0;
}

class OfferSetupDataModel {
  List<ServiceTypeModel>? serviceTypes;
  List<OfferCategoryModel>? categories;
  List<OfferZoneModel>? zones;
  SubscriptionPricingSettingsModel? pricingSettings;
  List<DurationDiscountModel>? durationDiscounts;

  OfferSetupDataModel({
    this.serviceTypes,
    this.categories,
    this.zones,
    this.pricingSettings,
    this.durationDiscounts,
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
    if (json['pricing_settings'] != null) {
      pricingSettings =
          SubscriptionPricingSettingsModel.fromJson(json['pricing_settings']);
    }
    if (json['duration_discounts'] != null) {
      durationDiscounts = [];
      for (var item in json['duration_discounts']) {
        durationDiscounts?.add(DurationDiscountModel.fromJson(item));
      }
    }
  }
}

class PriceCalculationModel {
  double? basePrice;
  int? extraZones;
  double? extraZonesCost;
  int? extraCategories;
  double? extraCategoriesCost;
  double? monthlyTotal;
  double? subtotalBeforeDiscount;
  int? discountPercent;
  double? discountAmount;
  double? totalBeforeVat;
  double? vatPercent;
  double? vatAmount;
  // شامل ضريبة القيمة المضافة — هو المبلغ الذي يُدفَع فعليًا.
  double? totalPrice;

  PriceCalculationModel({
    this.basePrice,
    this.extraZones,
    this.extraZonesCost,
    this.extraCategories,
    this.extraCategoriesCost,
    this.monthlyTotal,
    this.subtotalBeforeDiscount,
    this.discountPercent,
    this.discountAmount,
    this.totalBeforeVat,
    this.vatPercent,
    this.vatAmount,
    this.totalPrice,
  });

  PriceCalculationModel.fromJson(Map<String, dynamic> json) {
    basePrice = double.tryParse(json['base_price'].toString()) ?? 0;
    extraZones = int.tryParse(json['extra_zones'].toString()) ?? 0;
    extraZonesCost = double.tryParse(json['extra_zones_cost'].toString()) ?? 0;
    extraCategories = int.tryParse(json['extra_categories'].toString()) ?? 0;
    extraCategoriesCost =
        double.tryParse(json['extra_categories_cost'].toString()) ?? 0;
    monthlyTotal = double.tryParse(json['monthly_total'].toString()) ?? 0;
    subtotalBeforeDiscount =
        double.tryParse(json['subtotal_before_discount'].toString()) ?? 0;
    discountPercent = int.tryParse(json['discount_percent'].toString()) ?? 0;
    discountAmount = double.tryParse(json['discount_amount'].toString()) ?? 0;
    totalBeforeVat =
        double.tryParse(json['total_before_vat'].toString()) ?? 0;
    vatPercent = double.tryParse(json['vat_percent'].toString()) ?? 0;
    vatAmount = double.tryParse(json['vat_amount'].toString()) ?? 0;
    totalPrice = double.tryParse(json['total_price'].toString()) ?? 0;
  }
}

class StoreOfferResponseModel {
  int? offerId;
  int? subscriptionId;
  String? subscriptionNumber;
  int? duration;
  String? expiryDate;
  double? basePrice;
  int? extraZones;
  double? extraZonesCost;
  int? extraCategories;
  double? extraCategoriesCost;
  double? monthlyTotal;
  double? subtotalBeforeDiscount;
  int? discountPercent;
  double? discountAmount;
  double? totalBeforeVat;
  double? vatPercent;
  double? vatAmount;
  double? amountToPay;
  String? currency;
  String? paymentUrl;

  StoreOfferResponseModel.fromJson(Map<String, dynamic> json) {
    offerId = json['offer_id'];
    subscriptionId = json['subscription_id'];
    subscriptionNumber = json['subscription_number'];
    duration = json['duration'];
    expiryDate = json['expiry_date'];
    basePrice = double.tryParse(json['base_price'].toString()) ?? 0;
    extraZones = int.tryParse(json['extra_zones'].toString()) ?? 0;
    extraZonesCost = double.tryParse(json['extra_zones_cost'].toString()) ?? 0;
    extraCategories = int.tryParse(json['extra_categories'].toString()) ?? 0;
    extraCategoriesCost =
        double.tryParse(json['extra_categories_cost'].toString()) ?? 0;
    monthlyTotal = double.tryParse(json['monthly_total'].toString()) ?? 0;
    subtotalBeforeDiscount =
        double.tryParse(json['subtotal_before_discount'].toString()) ?? 0;
    discountPercent = int.tryParse(json['discount_percent'].toString()) ?? 0;
    discountAmount = double.tryParse(json['discount_amount'].toString()) ?? 0;
    totalBeforeVat =
        double.tryParse(json['total_before_vat'].toString()) ?? 0;
    vatPercent = double.tryParse(json['vat_percent'].toString()) ?? 0;
    vatAmount = double.tryParse(json['vat_amount'].toString()) ?? 0;
    amountToPay = double.tryParse(json['amount_to_pay'].toString()) ?? 0;
    currency = json['currency'];
    paymentUrl = json['payment_url'];
  }
}
