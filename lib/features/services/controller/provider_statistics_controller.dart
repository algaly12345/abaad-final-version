import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/features/services/data/models/provider_statistics_model.dart';
import 'package:abaad_flutter/features/services/data/repositories/provider_statistics_repo.dart';
import 'package:abaad_flutter/features/services/data/repositories/services_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ProviderStatisticsController extends GetxController implements GetxService {
  final ProviderStatisticsRepo providerStatisticsRepo;
  final ServicesRepo servicesRepo;

  ProviderStatisticsController({
    required this.providerStatisticsRepo,
    required this.servicesRepo,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProviderStatisticsModel? _data;
  ProviderStatisticsModel? get data => _data;

  // ─── فلتر الفترة الزمنية: يؤثر فقط على period_summary/period_subscriptions
  // وعلى قائمة "تفاصيل كل خدمة" (كلاهما created_at حقيقي) — لا يؤثر إطلاقاً
  // على الشبكة العلوية (الحالة الآنية) ولا على المشاهدات (بلا تاريخ فعلي) ──
  String selectedPeriod = 'all'; // today | week | month | all | custom
  DateTime? customFrom;
  DateTime? customTo;

  // ─── قائمة "تفاصيل كل خدمة" — نفس نمط الترقيم المستخدم في
  // ServicesController.getServicesList (offset/pageSize/hasMore) ───────────
  List<ServiceOffer>? _periodOffers;
  List<ServiceOffer>? get periodOffers => _periodOffers;
  bool _isLoadingOffers = false;
  bool get isLoadingOffers => _isLoadingOffers;
  int _offersOffset = 1;
  int? _offersPageSize;
  bool get hasMoreOffers => (_periodOffers?.length ?? 0) < (_offersPageSize ?? 0);

  // ملاحظة: /reports/provider/dashboard يحسب حدود اليوم/الأسبوع/الشهر بنفسه
  // من period فقط (Carbon::now() في الباكند)، لكن /services/my-services (قائمة
  // "تفاصيل كل خدمة") لا يفهم إلا from_date/to_date صريحين — فيجب حساب نفس
  // الحدود هنا محليًا لكل الخيارات الجاهزة أيضًا، وإلا تُعرض القائمة بلا أي
  // تصفية بينما تُظهر بطاقة "خلال الفترة" أرقامًا مصفّاة، فيتناقض الاثنان.
  String? get _fromDateParam {
    final now = DateTime.now();
    switch (selectedPeriod) {
      case 'today':
        return _formatDate(now);
      case 'week':
        return _formatDate(now.subtract(Duration(days: now.weekday - 1)));
      case 'month':
        return _formatDate(DateTime(now.year, now.month, 1));
      case 'custom':
        return customFrom != null ? _formatDate(customFrom!) : null;
      default:
        return null; // 'all'
    }
  }

  String? get _toDateParam {
    switch (selectedPeriod) {
      case 'today':
      case 'week':
      case 'month':
        return _formatDate(DateTime.now());
      case 'custom':
        return customTo != null ? _formatDate(customTo!) : null;
      default:
        return null;
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // دقة السلسلة الزمنية للمشاهدات: يومية للفترات القصيرة، شهرية عند "الكل".
  // للمدى المخصّص نُرسل 'day' ويُرقّيه الباكند تلقائيًا إلى 'month' إن تجاوز 92 يومًا.
  String get _granularityParam => selectedPeriod == 'all' ? 'month' : 'day';

  Future<void> loadDashboard() async {
    _isLoading = true;
    update();

    try {
      final response = await providerStatisticsRepo.getDashboard(
        period: selectedPeriod,
        from: _fromDateParam,
        to: _toDateParam,
        granularity: _granularityParam,
      );

      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['data'] is Map) {
        _data = ProviderStatisticsModel.fromJson(
          Map<String, dynamic>.from(response.body['data'] as Map),
        );
      } else {
        ApiChecker.checkApi(response, showToaster: true);
      }
    } catch (e) {
      // يُترك _data كما هو (null أو آخر قيمة محمَّلة) — الشاشة تعرض حالة فشل عامة.
      // debugPrint فقط (وليس toaster) كي لا يظهر خطأ تقني للمستخدم، لكن يبقى
      // مرئياً في سجل التطوير لتشخيص أي تغيّر مستقبلي في شكل استجابة الباكند.
      debugPrint('ProviderStatisticsController.loadDashboard failed: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  Future<void> loadPeriodOffers({bool reload = false}) async {
    if (reload) {
      _offersOffset = 1;
      _periodOffers = null;
      _isLoadingOffers = true;
      update();
    }

    try {
      final response = await servicesRepo.getServices(
        offset: _offersOffset,
        myServices: true,
        fromDate: _fromDateParam,
        toDate: _toDateParam,
      );

      if (response.statusCode == 200 && response.body is Map) {
        final model = ServiceModel.fromJson(response.body);

        if (_offersOffset == 1) {
          _periodOffers = [];
        }
        _periodOffers ??= [];
        _periodOffers!.addAll(model.services ?? []);
        _offersPageSize = model.totalSize;
      } else {
        _periodOffers ??= [];
        ApiChecker.checkApi(response, showToaster: true);
      }
    } catch (e) {
      _periodOffers ??= [];
      debugPrint('ProviderStatisticsController.loadPeriodOffers failed: $e');
    } finally {
      _isLoadingOffers = false;
      update();
    }
  }

  Future<void> loadMoreOffers() async {
    if (_isLoadingOffers || !hasMoreOffers) return;
    _offersOffset++;
    await loadPeriodOffers();
  }

  Future<void> setPeriod(String period) async {
    if (selectedPeriod == period) return;
    selectedPeriod = period;
    update();
    await Future.wait([loadDashboard(), loadPeriodOffers(reload: true)]);
  }

  Future<void> setCustomRange(DateTime from, DateTime to) async {
    selectedPeriod = 'custom';
    customFrom = from;
    customTo = to;
    update();
    await Future.wait([loadDashboard(), loadPeriodOffers(reload: true)]);
  }

  Future<void> loadAll() async {
    await Future.wait([loadDashboard(), loadPeriodOffers(reload: true)]);
  }
}
