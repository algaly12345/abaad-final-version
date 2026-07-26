import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class ReferralRepo {
  final ApiClient apiClient;
  ReferralRepo({required this.apiClient});

  Future<Response> getMyLink() async {
    return await apiClient.getData(AppConstants.REFERRAL_MY_LINK_URL);
  }

  Future<Response> getReferralList() async {
    return await apiClient.getData(AppConstants.REFERRAL_LIST_URL);
  }

  Future<Response> getSummary() async {
    return await apiClient.getData(AppConstants.REFERRAL_SUMMARY_URL);
  }

  Future<Response> getWithdrawals() async {
    return await apiClient.getData(AppConstants.REFERRAL_WITHDRAWALS_URL);
  }

  Future<Response> requestWithdrawal({required double amount}) async {
    return await apiClient.postData(AppConstants.REFERRAL_WITHDRAWALS_URL, {"amount": amount});
  }
}
