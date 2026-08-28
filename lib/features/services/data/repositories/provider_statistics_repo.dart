import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:get/get.dart';

class ProviderStatisticsRepo {
  final ApiClient apiClient;
  ProviderStatisticsRepo({required this.apiClient});

  /// [period]: 'today' | 'week' | 'month' | 'all' | 'custom'. عند 'custom' يجب
  /// إرسال [from]/[to] (YYYY-MM-DD) وإلا يرفضهما الباكند بخطأ 422.
  Future<Response> getDashboard({
    String period = 'all',
    String? from,
    String? to,
  }) async {
    String uri = '/api/v1/reports/provider/dashboard?period=$period';
    if (from != null && from.isNotEmpty) {
      uri += '&from=$from';
    }
    if (to != null && to.isNotEmpty) {
      uri += '&to=$to';
    }
    return await apiClient.getData(uri);
  }
}
