import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ServiceOfferRepo {
  final ApiClient apiClient;
  ServiceOfferRepo({required this.apiClient});

  Future<Response> getOfferSetupData() async {
    return await apiClient.getData(AppConstants.PROVIDER_OFFER_SETUP_DATA_URI);
  }

  Future<Response> calculatePrice({
    required int servicePlanId,
    required int subscriptionDuration,
    required int zonesCount,
  }) async {
    return await apiClient.postData(AppConstants.PROVIDER_CALCULATE_PRICE_URI, {
      'service_plan_id': servicePlanId,
      'subscription_duration': subscriptionDuration,
      'zones_count': zonesCount,
    });
  }

  /// حفظ فوري لبيانات هوية مزوّد الخدمة (فرد/منشأة) — يُستدعى من
  /// ProviderUpgradeScreen مباشرة بدل انتظار إتمام معالج "إضافة خدمة".
  Future<Response> updateIdentity({
    required String entityType, // 'individual' أو 'organization'
    String? identityNumber,
    String? freelanceMembershipNumber,
    String? commercialRegistrationNo,
  }) async {
    return await apiClient.postData(AppConstants.PROVIDER_UPDATE_IDENTITY_URI, {
      // الباكند يخزّن 'company' لا 'organization' في service_providers.identity_type.
      'identity_type': entityType == 'organization' ? 'company' : entityType,
      if (identityNumber != null) 'identity_number': identityNumber,
      if (freelanceMembershipNumber != null)
        'freelance_membership_number': freelanceMembershipNumber,
      if (commercialRegistrationNo != null)
        'commercial_registration_no': commercialRegistrationNo,
    });
  }

  /// يبني الحقول بصيغة categories[0]، categories[1]... حتى يفهمها
  /// Laravel كمصفوفة عند الإرسال بصيغة multipart/form-data.
  Future<Response> storeOffer({
    required String title,
    required String serviceType,
    required String offerType, // 'discount' أو 'price'
    String? servicePrice,
    String? discount,
    required String description,
    String? address,
    required int servicePlanId,
    required int subscriptionDuration,
    required List<int> categories,
    required List<int> zones,
    required double latitude,
    required double longitude,
    required XFile image,
    required String entityType, // 'individual' أو 'organization'
    String? identityNumber,
    String? freelanceMembershipNumber,
    String? commercialRegistrationNo,
    String? organizationIdType, // 'commercial' أو 'unified'
  }) async {
    Map<String, String> fields = {
      'title': title,
      'service_type': serviceType,
      'offer_type': offerType,
      'description': description,
      'service_plan_id': servicePlanId.toString(),
      'subscription_duration': subscriptionDuration.toString(),
      // الباكند يخزّن 'company' لا 'organization' في service_providers.identity_type
      // — يبقى الاسم الداخلي بالفلاتر 'organization' كما هو، والترجمة هنا فقط.
      // المفتاح هنا identity_type (وليس entity_type) لأن StoreOfferRequest في الباكند
      // يتحقق فقط من identity_type — بهذا يعمل "التأكيد الإضافي" لبيانات الهوية فعليًا.
      'identity_type': entityType == 'organization' ? 'company' : entityType,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    };

    if (address != null && address.trim().isNotEmpty) {
      fields['address'] = address.trim();
    }
    if (servicePrice != null) fields['service_price'] = servicePrice;
    if (discount != null) fields['discount'] = discount;
    if (identityNumber != null) fields['identity_number'] = identityNumber;
    if (freelanceMembershipNumber != null) {
      fields['freelance_membership_number'] = freelanceMembershipNumber;
    }
    if (commercialRegistrationNo != null) {
      fields['commercial_registration_no'] = commercialRegistrationNo;
    }
    if (organizationIdType != null) {
      fields['organization_id_type'] = organizationIdType;
    }

    for (int i = 0; i < categories.length; i++) {
      fields['categories[$i]'] = categories[i].toString();
    }
    for (int i = 0; i < zones.length; i++) {
      fields['zones[$i]'] = zones[i].toString();
    }

    return await apiClient.postMultipartData(
      AppConstants.PROVIDER_STORE_OFFER_URI,
      fields,
      [MultipartBody('image', image)],
    );
  }

  /// رفع/تحديث شعار مزوّد الخدمة (service_providers.image) — منفصل تمامًا
  /// عن صورة حساب المستخدم العامة (customer/update-profile) وعن صورة العرض
  /// (storeOffer)، ويظهر في بطاقات قائمة العروض بجانب اسم المزوّد.
  Future<Response> updateLogo(XFile image) async {
    return await apiClient.postMultipartData(
      AppConstants.PROVIDER_UPDATE_LOGO_URI,
      {},
      [MultipartBody('image', image)],
    );
  }

  /// حفظ عنوان عمل مزوّد الخدمة — تُستدعى من CompleteProviderProfileScreen
  /// عند إضافة مزوّد الخدمة أول عرض له وبياناته ناقصة.
  Future<Response> updateBusinessInfo({required String address}) async {
    return await apiClient.postData(AppConstants.PROVIDER_UPDATE_BUSINESS_INFO_URI, {
      'address': address,
    });
  }

  /// يرسل رمز تحقق لرقم جوال جديد يريد المستخدم المصادَق ربطه بحسابه —
  /// تُستدعى من قسم "الجوال" بشاشة CompleteProviderProfileScreen.
  Future<Response> sendPhoneOtp({required String phone}) async {
    return await apiClient.postData(AppConstants.CUSTOMER_SEND_PHONE_OTP_URI, {
      'phone': phone,
    });
  }

  /// يتحقق من الرمز ويحفظ الرقم مباشرة على حساب المستخدم عند النجاح.
  Future<Response> verifyPhoneOtp({required String phone, required String otp}) async {
    return await apiClient.postData(AppConstants.CUSTOMER_VERIFY_PHONE_OTP_URI, {
      'phone': phone,
      'otp': otp,
    });
  }

  Future<Response> getSubscriptionStatus(String subscriptionNumber) async {
    return await apiClient.getData(
      '${AppConstants.PROVIDER_SUBSCRIPTION_STATUS_PREFIX}$subscriptionNumber/status',
    );
  }

  /// يولّد رابط دفع موقّع جديد لاشتراك غير مدفوع (unpaid/failed) — يُستخدم
  /// من زر "ادفع الآن" في شاشة تفاصيل الخدمة بعد انتهاء صلاحية رابط الدفع
  /// الأصلي (ساعتان من إنشاء العرض).
  Future<Response> resumePayment(String subscriptionNumber) async {
    return await apiClient.getData(
      '${AppConstants.PROVIDER_RESUME_PAYMENT_PREFIX}$subscriptionNumber/resume-payment',
    );
  }
}
