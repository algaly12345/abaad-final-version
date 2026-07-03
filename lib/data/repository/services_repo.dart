import 'package:abaad_flutter/data/api/api_client.dart';
import 'package:get/get.dart';

class ServicesRepo {
  final ApiClient apiClient;
  ServicesRepo({required this.apiClient});

  Future<Response> getServices({
    required int offset,
    String? categoryId,
    String? zoneId,
    String? search,
    String? sortBy,
    String? offerType,
    String? serviceTypeId,
    String? providerId,
    bool myServices = false,
  }) async {
    // لوحة "خدماتي" لها مسار محمي بتسجيل الدخول مستقل عن كتالوج الخدمات العام،
    // ولا يجوز إرسال نفس استعلام الكتالوج العام مع my_services=true لأنه غير مدعوم بعد الآن.
    String uri = myServices
        ? '/api/v1/services/my-services?page=$offset&per_page=10'
        : '/api/v1/services?page=$offset&per_page=10';

    if (categoryId != null && categoryId.isNotEmpty) {
      uri += '&category_id=$categoryId';
    }
    if (zoneId != null && zoneId.isNotEmpty) {
      uri += '&zone_id=$zoneId';
    }
    if (serviceTypeId != null && serviceTypeId.isNotEmpty) {
      uri += '&service_type_id=$serviceTypeId';
    }
    // فلتر "مزود الخدمة": ids مفصولة بفواصل، مثل "4,9"
    if (providerId != null && providerId.isNotEmpty) {
      uri += '&provider_id=$providerId';
    }
    if (search != null && search.isNotEmpty) {
      uri += '&search=$search';
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      uri += '&sort_by=$sortBy';
    }
    // ملاحظة: offerType يجب أن يصل هنا بقيمة الباكند الصحيحة (discount/price) وليس
    // التسمية العربية المعروضة في الواجهة - التحويل يحدث في ServicesController.
    if (offerType != null && offerType.isNotEmpty) {
      uri += '&offer_type=$offerType';
    }

    return await apiClient.getData(uri);
  }

  Future<Response> getFiltersMetadata() async {
    return await apiClient.getData('/api/v1/services/filters');
  }

  Future<Response> getServiceDetails(int id) async {
    return await apiClient.getData('/api/v1/services/$id');
  }

  /// يفعّل/يوقف خدمة مملوكة لمقدّم الخدمة الحالي مؤقتًا (accept <-> pending).
  /// يتطلب توكن مقدّم خدمة مسجّل دخوله وأن يكون هو مالك الخدمة (يتحقق منه الباكند).
  Future<Response> toggleServiceStatus(int id) async {
    return await apiClient.postData('/api/v1/services/$id/toggle-status', {});
  }
}
