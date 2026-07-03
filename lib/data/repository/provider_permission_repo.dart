import 'package:abaad_flutter/data/api/api_client.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:get/get.dart';

class ProviderPermissionRepo {
  final ApiClient apiClient;
  ProviderPermissionRepo({required this.apiClient});

  Future<Response> getPermissions() async {
    return await apiClient.getData(
      AppConstants.PROVIDER_PERMISSIONS_URI,
      handleError: false,
    );
  }
}
