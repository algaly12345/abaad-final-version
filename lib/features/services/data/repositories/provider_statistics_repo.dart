import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:get/get.dart';

class ProviderStatisticsRepo {
  final ApiClient apiClient;
  ProviderStatisticsRepo({required this.apiClient});

  /// [period]: 'today' | 'week' | 'month' | 'all' | 'custom'. عند 'custom' يجب
  /// إرسال [from]/[to] (YYYY-MM-DD) وإلا يرفضهما الباكند بخطأ 422.
  /// [granularity]: 'day' | 'month' — دقة السلسلة الزمنية للمشاهدات (الباكند
  /// يُرقّي 'day' تلقائيًا إلى 'month' للمدى الأطول من 92 يومًا).
  Future<Response> getDashboard({
    String period = 'all',
    String? from,
    String? to,
    String granularity = 'day',
  }) async {
    String uri =
        '/api/v1/reports/provider/dashboard?period=$period&granularity=$granularity';
    if (from != null && from.isNotEmpty) {
      uri += '&from=$from';
    }
    if (to != null && to.isNotEmpty) {
      uri += '&to=$to';
    }
    return await apiClient.getData(uri);
  }

  /// درِل-داون: عروض المزوّد ضمن بُعد واحد.
  /// [type]: 'zone' | 'category' | 'service_type'. [period]/[from]/[to] بنفس
  /// دلالات getDashboard.
  Future<Response> getDimensionOffers({
    required String type,
    required int id,
    String period = 'all',
    String? from,
    String? to,
  }) async {
    String uri =
        '/api/v1/reports/provider/dimension?type=$type&id=$id&period=$period';
    if (from != null && from.isNotEmpty) {
      uri += '&from=$from';
    }
    if (to != null && to.isNotEmpty) {
      uri += '&to=$to';
    }
    return await apiClient.getData(uri);
  }
}
