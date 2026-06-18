import 'package:abaad_flutter/data/api/api_client.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';
class BannerRepo {
  final ApiClient apiClient;
  BannerRepo({required this.apiClient});

  Future<Response> getBannerList(int zoneId) async {
    return await apiClient.getData("${AppConstants.BANNER_URI}?zone_id=$zoneId", query: {}, headers: {});
  }

}