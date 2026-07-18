class UserInfoModel {
  int? id = 0;
  String? name = "";
  String? phone = "";
  String? email = "";
  String? emailVerifiedAt = "";
  String? refCode = "";
  String? isActive = "";
  String? userType = "";
  String? isPhoneVerifiedAt = "";
  String? cmFirebaseToken = "";
  String? createdAt = "";
  String? updatedAt = "";
  Userinfo? userinfo;
  int? estateCount = 0;
  String? image = "";
  double? walletBalance = 0;
  int? loyaltyPoint = 0;

  String? youtube = "";
  String? snapchat = "";
  String? instagram = "";
  String? website = "";
  String? tiktok = "";
  String? twitter = "";

  Userinfo? agent;
  String? membershipType = "";
  String? accountVerification = "";
  String? advertiserNo = "";
  String? unified_number = "";
  ProviderIdentity? provider;

  UserInfoModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.emailVerifiedAt,
    this.refCode,
    this.isActive,
    this.userType,
    this.isPhoneVerifiedAt,
    this.cmFirebaseToken,
    this.createdAt,
    this.updatedAt,
    this.userinfo,
    this.estateCount,
    this.image,
    this.agent,
    this.walletBalance,
    this.loyaltyPoint,
    this.youtube,
    this.snapchat,
    this.instagram,
    this.website,
    this.tiktok,
    this.twitter,
    this.membershipType,
    this.accountVerification,
    this.advertiserNo,
    this.unified_number,
  });

  UserInfoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    refCode = json['ref_code'];
    isActive = json['is_active'];
    userType = json['user_type'];
    isPhoneVerifiedAt = json['is_phone_verified_at'];
    cmFirebaseToken = json['cm_firebase_token'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    image = json['image'];

    // 🛠️ تم إزالة الـ ! ليكون آمن تماماً في حال كان الحساب لا يحتوي على معلومات مسوق عقاري
    userinfo = json['userinfo'] != null
        ? Userinfo.fromJson(json['userinfo'])
        : null;

    estateCount = json['estate_count'];
    agent = json['agent'] != null ? Userinfo.fromJson(json['agent']) : null;
    provider = json['provider'] != null
        ? ProviderIdentity.fromJson(json['provider'])
        : null;

    // 🛠️ حماية المحفظة والنقاط من قيم الـ null
    walletBalance = json['wallet_balance'] != null
        ? (double.tryParse(json['wallet_balance'].toString()) ?? 0.0)
        : 0.0;

    loyaltyPoint = json['loyalty_point'] != null
        ? (int.tryParse(json['loyalty_point'].toString()) ?? 0)
        : 0;

    youtube = json['youtube'];
    snapchat = json['snapchat'];
    instagram = json['instagram'];
    website = json['website'];
    tiktok = json['tiktok'];
    twitter = json['twitter'];
    membershipType = json['membership_type'];
    accountVerification = json['account_verification']?.toString() ?? "0";
    advertiserNo = json['advertiser_no']?.toString();
    unified_number = json['unified_number']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['phone'] = phone;
    data['email'] = email;
    data['email_verified_at'] = emailVerifiedAt;
    data['ref_code'] = refCode;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['is_phone_verified_at'] = isPhoneVerifiedAt;
    data['cm_firebase_token'] = cmFirebaseToken;
    data['created_at'] = createdAt;
    data['image'] = image;
    data['updated_at'] = updatedAt;
    data['wallet_balance'] = walletBalance;
    data['loyalty_point'] = loyaltyPoint;
    data['youtube'] = youtube;
    data['snapchat'] = snapchat;
    data['instagram'] = instagram;
    data['website'] = website;
    data['tiktok'] = tiktok;
    data['twitter'] = twitter;
    data['membership_type'] = membershipType;
    data['account_verification'] = accountVerification;
    data['advertiser_no'] = advertiserNo;
    data['unified_number'] = unified_number;
    data['userinfo'] = userinfo?.toJson();
    data['estate_count'] = estateCount;
    data['agent'] = agent?.toJson();
    return data;
  }
}

class Userinfo {
  int? id = 0;
  String? identity = "";
  String? advertiserNo = "";
  String? membershipType = "";
  String? identityType = "";
  String? image = "";
  String? commercialRegisterionNo = "";
  String? userId = "";
  String? name = "";
  String? phone = "";
  String? createdAt = "";
  String? updatedAt = "";
  String? falLicenseNumber = "";

  Userinfo({
    this.id,
    this.name,
    this.phone,
    this.identity,
    this.image,
    this.commercialRegisterionNo,
    this.userId,
    this.advertiserNo,
    this.membershipType,
    this.identityType,
    this.createdAt,
    this.updatedAt,
    this.falLicenseNumber,
  });

  Userinfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    phone = json['phone'];
    identity = json['identity'];
    image = json['image'];
    commercialRegisterionNo = json['commercial_registerion_no'];
    userId = json['user_id']?.toString();
    advertiserNo = json['advertiser_no'];
    membershipType = json['membership_type'];
    identityType = json['identity_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    falLicenseNumber = json['fal_license_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['identity'] = identity;
    data['image'] = image;
    data['commercial_registerion_no'] = commercialRegisterionNo;
    data['user_id'] = userId;
    data['name'] = name;
    data['phone'] = phone;
    data['advertiser_no'] = advertiserNo;
    data['membership_type'] = membershipType;
    data['identity_type'] = identityType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['fal_license_number'] = falLicenseNumber;
    return data;
  }
}

/// بيانات هوية مزوّد الخدمة (فرد/منشأة) كما تُخزَّن في جدول service_providers
/// بالباكند — تُقرأ هنا بدل الاعتماد على حالة محلية في التطبيق (راجع
/// ServiceOfferController.hydrateEntityFromProvider) حتى لا يُطلَب من
/// مزوّد معتمد إعادة إدخالها في كل عرض جديد.
class ProviderIdentity {
  String? identityType; // 'individual' أو 'company'
  String? identityNumber;
  String? commercialRegistrationNo;

  ProviderIdentity({
    this.identityType,
    this.identityNumber,
    this.commercialRegistrationNo,
  });

  ProviderIdentity.fromJson(Map<String, dynamic> json) {
    identityType = json['identity_type'];
    identityNumber = json['identity_number'];
    commercialRegistrationNo = json['commercial_registration_no'];
  }

  // القيم الوهمية ('pending') تُخلَّف من مسارات تسجيل قديمة (AgentController/
  // RegisterController) ولا تمثّل بيانات حقيقية أدخلها المستخدم — تُعامَل هنا
  // كبيانات غير مكتملة.
  bool get isComplete =>
      (identityType == 'individual' &&
          (identityNumber?.isNotEmpty ?? false) &&
          identityNumber != 'pending') ||
      (identityType == 'company' &&
          (commercialRegistrationNo?.isNotEmpty ?? false) &&
          commercialRegistrationNo != 'pending');
}
