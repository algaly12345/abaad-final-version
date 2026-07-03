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

  /// يبني الحقول بصيغة categories[0]، categories[1]... حتى يفهمها
  /// Laravel كمصفوفة عند الإرسال بصيغة multipart/form-data.
  Future<Response> storeOffer({
    required String title,
    required String serviceType,
    required String offerType, // 'discount' أو 'price'
    String? servicePrice,
    String? discount,
    required String description,
    required int servicePlanId,
    required int subscriptionDuration,
    required List<int> categories,
    required List<int> zones,
    required XFile image,
  }) async {
    Map<String, String> fields = {
      'title': title,
      'service_type': serviceType,
      'offer_type': offerType,
      'description': description,
      'service_plan_id': servicePlanId.toString(),
      'subscription_duration': subscriptionDuration.toString(),
    };

    if (servicePrice != null) fields['service_price'] = servicePrice;
    if (discount != null) fields['discount'] = discount;

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

  Future<Response> getSubscriptionStatus(String subscriptionNumber) async {
    return await apiClient.getData(
      '${AppConstants.PROVIDER_SUBSCRIPTION_STATUS_PREFIX}$subscriptionNumber/status',
    );
  }
}
