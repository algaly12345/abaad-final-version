class ConfigModel {
  String? businessName = "";
  String? logo = "";
  String? address = "";
  String? phone = "";
  String? email = "";
  BaseUrls? baseUrls;


  String? country = "";
  DefaultLocation? defaultLocation;
  String? appUrlAndroid = "";
  String? appUrlIos = "";
//  String? appUrlAndroid;
  bool? customerVerification = false;

  double? marketingCommission = 0;
  int? agentRegistration = 0;
  String? aboutUs = "";
  String? aboutUsAr = "";
  String? privacyPolicy = "";
  String? privacyPolicyAr = "";
  String? termsConditions = "";
  String? termsConditionsAr = "";

  String? googleMapKey = "";
  int? appMinimumVersionAndroid = 0;
  int? appMinimumVersionIos= 0;
  bool? demo = false;
  bool? maintenanceMode = false;
  bool? phoneVerification = false;
  int? freeTrialPeriodStatus = 0;
  int? freeTrialPeriodDay = 0;
  BusinessPlan? businessPlan;
  double? adminCommission = 0;
  String? currencySymbolDirection = "";
  int? loyaltyPointExchangeRate = 0;
  int? minimumPointToTransfer = 0;
  String? currencySymbol  = "";
  int? digitAfterDecimalPoint = 0;
  String? termsAndConditions  = "";
  String? featureAr = "";
  String? feature = "";



  ConfigModel({
    required this.businessName,
    required this.logo,
    required this.address,
    required this.phone,
    required this.email,
    required this.baseUrls,
    required this.privacyPolicy,
    required this.aboutUs,
    required this.country,
    required this.defaultLocation,
    required this.appUrlAndroid,
    required this.appUrlIos,
    required this.customerVerification,
    required this.appMinimumVersionAndroid,
    required this.appMinimumVersionIos,
    required this.termsConditions,
    required this.marketingCommission,
    required this.demo,
    required this.maintenanceMode,
    required this.agentRegistration,
    required this.phoneVerification,
    required this.freeTrialPeriodStatus,
    required this.freeTrialPeriodDay,
    required this.businessPlan,
    required this.adminCommission,
    required this.currencySymbolDirection,
    required this.loyaltyPointExchangeRate,
    required this.minimumPointToTransfer,
    required this.currencySymbol,
    required this.digitAfterDecimalPoint,
    required this.termsAndConditions,
    required this.termsConditionsAr,
    required this.aboutUsAr,
    required this.feature,
    required this.featureAr,
    required this.privacyPolicyAr,
    required this.googleMapKey
  });

  ConfigModel.fromJson(Map<String, dynamic> json) {
    businessName = json['business_name'];
    logo = json['logo'];
    address = json['address'];
    phone = json['phone'];
    email = json['email'];
    baseUrls = json['base_urls'] != null ? BaseUrls.fromJson(json['base_urls']) : null;
    privacyPolicy = json['privacy_policy'];
    aboutUs = json['about_us'];
    country = json['country'];
    defaultLocation = json['default_location'] != null ? DefaultLocation.fromJson(json['default_location']) : null;
     appUrlAndroid = json['app_url_android'];
    appUrlIos = json['app_url_ios'];
    customerVerification = json['customer_verification'];
    demo = json['demo'];
    maintenanceMode = json['maintenance_mode'];
    agentRegistration = json['agent_registration'];
    customerVerification = json['customer_verification'];
    termsConditions =json["terms_conditions"];
    appMinimumVersionAndroid = json['app_minimum_version_android'];
    appMinimumVersionIos = json['app_minimum_version_ios'];

    phoneVerification = json['phone_verification'];
    marketingCommission =json['marketing_commission'];

    freeTrialPeriodStatus = json['free_trial_period_status'];
    freeTrialPeriodDay = json['free_trial_period_data'];
    businessPlan = json['business_plan'] != null ? BusinessPlan.fromJson(json['business_plan']) : null;
    adminCommission = json['admin_commission'].toDouble();
    currencySymbolDirection = json['currency_symbol_direction'];
    loyaltyPointExchangeRate = json['loyalty_point_exchange_rate'];
    minimumPointToTransfer = json['minimum_point_to_transfer'];
    currencySymbol = json['currency_symbol'];
    digitAfterDecimalPoint = json['digit_after_decimal_point'];
    termsAndConditions = json['terms_and_conditions'];
    termsConditionsAr = json['terms_condition_ar'];
    termsAndConditions = json['terms_and_conditions'];
    aboutUsAr = json['about_us_ar'];
    feature= json['feature'];
    featureAr= json['feature_ar'];
    privacyPolicyAr= json['privacy_policy_ar'];
    googleMapKey=json['google_map_key'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_name'] = businessName;
    data['logo'] = logo;
    data['address'] = address;
    data['phone'] = phone;
    data['email'] = email;
    data['base_urls'] = baseUrls?.toJson();
      data['terms_conditions'] = termsConditions;
    data['privacy_policy'] = privacyPolicy;
    data['about_us'] = aboutUs;
    data['country'] = country;
    data['default_location'] = defaultLocation?.toJson();
       data['app_url_android'] = appUrlAndroid;
    data['app_url_ios'] = appUrlIos;
    data['customer_verification'] = customerVerification;
    data['demo'] = demo;
    data['maintenance_mode'] = maintenanceMode;
    data['customer_verification'] = customerVerification;
    data['app_minimum_version_android'] = appMinimumVersionAndroid;
    data['app_minimum_version_ios'] = appMinimumVersionIos;

    data['agent_registration'] = agentRegistration;
    data['phone_verification'] = phoneVerification;
    data['marketing_commission'] = marketingCommission;
    data['currency_symbol_direction'] = currencySymbolDirection;
    data['loyalty_point_exchange_rate'] = loyaltyPointExchangeRate;
    data['minimum_point_to_transfer'] = minimumPointToTransfer;
    data['currency_symbol'] = currencySymbol;
    data['digit_after_decimal_point'] = digitAfterDecimalPoint;
    data['terms_and_conditions']=termsAndConditions;
    data['terms_condition_ar']=termsConditionsAr;
    data['about_us_ar']=aboutUsAr;
    data['feature']=feature;
    data['feature_ar']=featureAr;
    data['privacy_policy_ar']=privacyPolicyAr;
    data['google_map_key']=googleMapKey;



    return data;
  }
}

class BaseUrls {
  String estateImageUrl = "";
  String categoryImageUrl = "";
  String customerImageUrl = "";
  String reviewImageUrl = "";
  String chatImageUrl = "";
  String agentImageUrl = "";
  String activitiesImageUrl = "";
  String notificationImageUrl = "";
  String planed = "";
  String provider = "";
  String banners = "";

  BaseUrls(
      {  required this.estateImageUrl,
        required this.categoryImageUrl,
        required this.customerImageUrl,
        required this.reviewImageUrl,
        required this.agentImageUrl,
        required this.notificationImageUrl,
        required this.banners,
        required this.provider,
        required this.chatImageUrl,
        required this.planed
      });

  BaseUrls.fromJson(Map<String, dynamic> json) {
    estateImageUrl = json['estate_image_url'];
    customerImageUrl = json['category_image_url'];
    customerImageUrl = json['customer_image_url'];
    categoryImageUrl = json['category_image_url'];
    agentImageUrl = json['agent_image_url'];
    activitiesImageUrl = json['activities_image_url'];
    notificationImageUrl = json['notification_image_url'];
    banners= json["banners"];
    provider= json["provider_image_url"];
    chatImageUrl = json['chat_image_url'];
    planed = json['planed'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['estate_image_url'] = estateImageUrl;
    data['category_image_url'] = categoryImageUrl;
    data['customer_image_url'] = customerImageUrl;
    data['review_image_url'] = reviewImageUrl;
    data['agent_image_url'] = agentImageUrl;
    data['activities_image_url'] = activitiesImageUrl;
    data['notification_image_url'] = notificationImageUrl;
    data['banners'] = banners;
    data['provider_image_url'] = provider;
    data['chat_image_url'] = chatImageUrl;
    data['planed'] = planed;

    return data;
  }
}

class DefaultLocation {
  String lat = "";
  String lng = "";

  DefaultLocation({required this.lat, required this.lng});

  DefaultLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class SocialLogin {
  String loginMedium = "";
  bool status =false;

  SocialLogin({required this.loginMedium, required this.status});

  SocialLogin.fromJson(Map<String, dynamic> json) {
    loginMedium = json['login_medium'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['login_medium'] = loginMedium;
    data['status'] = status;
    return data;
  }
}


class BusinessPlan {
  int commission = 0;
  int subscription = 0;

  BusinessPlan({required this.commission, required this.subscription});

  BusinessPlan.fromJson(Map<String, dynamic> json) {
    commission = json['commission'];
    subscription = json['subscription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['commission'] = commission;
    data['subscription'] = subscription;
    return data;
  }
}