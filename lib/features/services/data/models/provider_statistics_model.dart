// المصدر الخام لكل الحقول الرقمية هنا هو Laravel/PDO — أعمدة SUM()/COUNT()
// الخام (selectRaw) تصل أحياناً كسلاسل نصية بدل أرقام JSON فعلية (مثال:
// "805786" بدل 805786)، وبعض الأعمدة العددية قد تصل كأي من النوعين حسب مسار
// التنفيذ. تحويل دفاعي هنا يمنع كسر تحليل الاستجابة بالكامل بصمت (try/catch في
// ProviderStatisticsController) لمجرد اختلاف نوع حقل واحد.
int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

bool _toBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return false;
}

List<T> _mapList<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) {
  if (raw is! List) return <T>[];
  return raw
      .whereType<Map>()
      .map((e) => fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

class ProviderStatisticsModel {
  PeriodInfo? period;
  ProviderStatsSummary? summary;
  AccountProfile? account;
  PerformanceBlock? performance;
  FinanceBlock? finance;
  List<SubscriptionEntry> subscriptions;
  CoverageBlock? coverage;
  ProviderStatsSummary? periodSummary;
  PeriodSubscriptions? periodSubscriptions;
  PeriodViews? periodViews;

  ProviderStatisticsModel({
    this.period,
    this.summary,
    this.account,
    this.performance,
    this.finance,
    this.subscriptions = const [],
    this.coverage,
    this.periodSummary,
    this.periodSubscriptions,
    this.periodViews,
  });

  factory ProviderStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ProviderStatisticsModel(
      period:
          json['period'] is Map ? PeriodInfo.fromJson(Map<String, dynamic>.from(json['period'])) : null,
      summary: json['summary'] is Map
          ? ProviderStatsSummary.fromJson(Map<String, dynamic>.from(json['summary']))
          : null,
      account: json['account'] is Map && (json['account'] as Map).isNotEmpty
          ? AccountProfile.fromJson(Map<String, dynamic>.from(json['account']))
          : null,
      performance: json['performance'] is Map
          ? PerformanceBlock.fromJson(Map<String, dynamic>.from(json['performance']))
          : null,
      finance: json['finance'] is Map
          ? FinanceBlock.fromJson(Map<String, dynamic>.from(json['finance']))
          : null,
      subscriptions: _mapList(json['subscriptions'], SubscriptionEntry.fromJson),
      coverage: json['coverage'] is Map
          ? CoverageBlock.fromJson(Map<String, dynamic>.from(json['coverage']))
          : null,
      periodSummary: json['period_summary'] is Map
          ? ProviderStatsSummary.fromJson(Map<String, dynamic>.from(json['period_summary']))
          : null,
      periodSubscriptions: json['period_subscriptions'] is Map
          ? PeriodSubscriptions.fromJson(Map<String, dynamic>.from(json['period_subscriptions']))
          : null,
      periodViews: json['period_views'] is Map
          ? PeriodViews.fromJson(Map<String, dynamic>.from(json['period_views']))
          : null,
    );
  }
}

class PeriodInfo {
  String? key;
  String? from;
  String? to;
  String? granularity;

  PeriodInfo.fromJson(Map<String, dynamic> json) {
    key = json['key']?.toString();
    from = json['from']?.toString();
    to = json['to']?.toString();
    granularity = json['granularity']?.toString();
  }
}

class ProviderStatsSummary {
  int? activeOffersCount;
  int? pendingOffersCount;
  int? unpaidOffersCount;
  int? rejectedOffersCount;
  int? expiredOffersCount;
  int? totalOffersCount;
  int? totalViews;
  // مرّات ظهور إعلانات المزوّد داخل صفحات العقارات، وعدد العقارات المختلفة
  // التي ظهرت فيها (الوصول) — منفصلان تمامًا عن totalViews (فتح صفحة العرض).
  int? totalAppearances;
  int? totalReach;
  int? viewsLast7d;
  int? viewsLast30d;
  double? avgViewsPerActiveOffer;
  // موجود فقط في period_summary (عدد الخدمات المُنشأة خلال الفترة).
  int? newOffersCount;

  ProviderStatsSummary.fromJson(Map<String, dynamic> json) {
    activeOffersCount = _toInt(json['active_offers_count']);
    pendingOffersCount = _toInt(json['pending_offers_count']);
    unpaidOffersCount = _toInt(json['unpaid_offers_count']);
    rejectedOffersCount = _toInt(json['rejected_offers_count']);
    expiredOffersCount = _toInt(json['expired_offers_count']);
    totalOffersCount = _toInt(json['total_offers_count']);
    totalViews = _toInt(json['total_views']);
    totalAppearances = _toInt(json['total_appearances']);
    totalReach = _toInt(json['total_reach']);
    viewsLast7d = _toInt(json['views_last_7d']);
    viewsLast30d = _toInt(json['views_last_30d']);
    avgViewsPerActiveOffer = _toDouble(json['avg_views_per_active_offer']);
    newOffersCount = _toInt(json['new_offers_count']);
  }
}

class AccountProfile {
  String? name;
  String? image;
  bool hasImage;
  String? userType;
  String? memberSince;
  bool accountVerification;
  bool phoneVerified;
  bool emailVerified;
  bool hasUnifiedNumber;
  bool hasFalLicense;
  String? commercialRegistrationNo;
  String? identityType;
  String? serviceTypeName;
  String? zoneName;
  int? socialLinksCount;
  int? profileCompleteness;

  AccountProfile.fromJson(Map<String, dynamic> json)
      : name = json['name']?.toString(),
        image = json['image']?.toString(),
        hasImage = _toBool(json['has_image']),
        userType = json['user_type']?.toString(),
        memberSince = json['member_since']?.toString(),
        accountVerification = _toBool(json['account_verification']),
        phoneVerified = _toBool(json['phone_verified']),
        emailVerified = _toBool(json['email_verified']),
        hasUnifiedNumber = _toBool(json['has_unified_number']),
        hasFalLicense = _toBool(json['has_fal_license']),
        commercialRegistrationNo = json['commercial_registration_no']?.toString(),
        identityType = json['identity_type']?.toString(),
        serviceTypeName = json['service_type_name']?.toString(),
        zoneName = json['zone_name']?.toString(),
        socialLinksCount = _toInt(json['social_links_count']),
        profileCompleteness = _toInt(json['profile_completeness']);
}

class PerformanceBlock {
  int? totalViews;
  int? totalAppearances;
  int? totalReach;
  // إجمالي العقارات النشطة المؤهّلة لظهور إعلانات المزوّد (تقاطع مناطق ×
  // تصنيفات عروضه النشطة) — مفهوم آني لا يتأثّر بفلتر الفترة.
  int? totalEligibleEstates;
  int? viewsLast7d;
  int? viewsLast30d;
  List<OfferViewsEntry> byOffer;
  List<DimensionViewsEntry> byZone;
  List<DimensionViewsEntry> byCategory;
  List<ViewsPoint> timeseries;

  PerformanceBlock.fromJson(Map<String, dynamic> json)
      : totalViews = _toInt(json['total_views']),
        totalAppearances = _toInt(json['total_appearances']),
        totalReach = _toInt(json['total_reach']),
        totalEligibleEstates = _toInt(json['total_eligible_estates']),
        viewsLast7d = _toInt(json['views_last_7d']),
        viewsLast30d = _toInt(json['views_last_30d']),
        byOffer = _mapList(json['by_offer'], OfferViewsEntry.fromJson),
        byZone = _mapList(json['by_zone'], DimensionViewsEntry.fromJson),
        byCategory = _mapList(json['by_category'], DimensionViewsEntry.fromJson),
        timeseries = _mapList(json['timeseries'], ViewsPoint.fromJson);
}

class OfferViewsEntry {
  int? offerId;
  String? title;
  String? status;
  // فئة موحّدة من الباكند: active | pending | unpaid | rejected | expired —
  // نفس تصنيف دونات "توزيع حالة العروض" كي لا تتناقض التسميتان.
  String? statusBucket;
  bool isExpired;
  int? views;
  int? viewsAllTime;
  // ظهور هذا الإعلان داخل صفحات العقارات + عدد العقارات المختلفة (الوصول).
  int? appearances;
  int? reach;
  String? createdAt;
  // موجود فقط في استجابة درِل-داون البُعد.
  String? expiryDate;

  OfferViewsEntry.fromJson(Map<String, dynamic> json)
      : offerId = _toInt(json['offer_id']),
        title = json['title']?.toString(),
        status = json['status']?.toString(),
        statusBucket = json['status_bucket']?.toString(),
        isExpired = _toBool(json['is_expired']),
        views = _toInt(json['views']),
        viewsAllTime = _toInt(json['views_all_time']),
        appearances = _toInt(json['appearances']),
        reach = _toInt(json['reach']),
        createdAt = json['created_at']?.toString(),
        expiryDate = json['expiry_date']?.toString();
}

// ─── درِل-داون بُعد واحد (منطقة/تصنيف/نوع خدمة) لنوافذ التفاصيل ────────────

class DimensionMeta {
  final String? type;
  final int? id;
  final String? name;
  final String? nameAr;

  DimensionMeta.fromJson(Map<String, dynamic> json)
      : type = json['type']?.toString(),
        id = _toInt(json['id']),
        name = json['name']?.toString(),
        nameAr = json['name_ar']?.toString();

  String get displayName => (nameAr?.isNotEmpty ?? false)
      ? nameAr!
      : (name?.isNotEmpty ?? false)
          ? name!
          : '-';
}

class DimensionOffers {
  final DimensionMeta? dimension;
  final int totalViews;
  final int totalAppearances;
  final int totalReach;
  final List<OfferViewsEntry> offers;
  // العقارات النشطة التي تغطّيها إعلانات المزوّد ضمن هذا البُعد (منطقة/تصنيف):
  // أعلى 50 حسب المشاهدات، مع العدد الكلي.
  final List<DimensionEstate> coveredEstates;
  final int coveredEstatesCount;

  DimensionOffers.fromJson(Map<String, dynamic> json)
      : dimension = json['dimension'] is Map
            ? DimensionMeta.fromJson(
                Map<String, dynamic>.from(json['dimension']))
            : null,
        totalViews = _toInt(json['total_views']) ?? 0,
        totalAppearances = _toInt(json['total_appearances']) ?? 0,
        totalReach = _toInt(json['total_reach']) ?? 0,
        offers = _mapList(json['offers'], OfferViewsEntry.fromJson),
        coveredEstates =
            _mapList(json['covered_estates'], DimensionEstate.fromJson),
        coveredEstatesCount = _toInt(json['covered_estates_count']) ?? 0;
}

/// عقار واحد ضمن "العقارات المُغطّاة" في نافذة درِل-داون البُعد.
class DimensionEstate {
  final int? estateId;
  final String? title;
  final String? categoryName;
  final String? categoryNameAr;
  final String? city;
  final String? districts;
  final double? price;
  final int? views;
  // مرّات ظهور إعلان المزوّد داخل صفحة هذا العقار.
  final int? appearances;

  DimensionEstate.fromJson(Map<String, dynamic> json)
      : estateId = _toInt(json['estate_id']),
        title = json['title']?.toString(),
        categoryName = json['category_name']?.toString(),
        categoryNameAr = json['category_name_ar']?.toString(),
        city = json['city']?.toString(),
        districts = json['districts']?.toString(),
        price = _toDouble(json['price']),
        views = _toInt(json['views']),
        appearances = _toInt(json['appearances']);

  String get displayCategory => (categoryNameAr?.isNotEmpty ?? false)
      ? categoryNameAr!
      : (categoryName ?? '');
}

// مشتركة بين by_zone / by_category / views_by_zone / views_by_category — نفس
// البنية تمامًا (id, name, name_ar, offers_count, total_views).
class DimensionViewsEntry {
  int? id;
  String? name;
  String? nameAr;
  int? offersCount;
  int? totalViews;
  // موجودان فقط في by_zone (توزيع المشاهدات حسب المنطقة): عدد العقارات التي
  // ظهر فيها إعلان المزوّد بهذه المنطقة، وعدد العقارات المؤهّلة فيها.
  int? reach;
  int? eligibleEstates;

  DimensionViewsEntry.fromJson(Map<String, dynamic> json)
      : id = _toInt(json['id']),
        name = json['name']?.toString(),
        nameAr = json['name_ar']?.toString(),
        offersCount = _toInt(json['offers_count']),
        totalViews = _toInt(json['total_views']),
        reach = _toInt(json['reach']),
        eligibleEstates = _toInt(json['eligible_estates']);
}

class ViewsPoint {
  String date;
  int views;

  ViewsPoint.fromJson(Map<String, dynamic> json)
      : date = json['date']?.toString() ?? '',
        views = _toInt(json['views']) ?? 0;
}

class FinanceBlock {
  double? lifetimePaid;
  double? outstandingAmount;
  int? subscriptionsTotal;
  int? paidCount;
  int? unpaidCount;
  String? lastPaymentAt;
  String? nextRenewalAt;
  String? soonestExpiryAt;
  List<PlanSpendEntry> spendByPlan;
  List<MonthSpendEntry> spendByMonth;

  FinanceBlock.fromJson(Map<String, dynamic> json)
      : lifetimePaid = _toDouble(json['lifetime_paid']),
        outstandingAmount = _toDouble(json['outstanding_amount']),
        subscriptionsTotal = _toInt(json['subscriptions_total']),
        paidCount = _toInt(json['paid_count']),
        unpaidCount = _toInt(json['unpaid_count']),
        lastPaymentAt = json['last_payment_at']?.toString(),
        nextRenewalAt = json['next_renewal_at']?.toString(),
        soonestExpiryAt = json['soonest_expiry_at']?.toString(),
        spendByPlan = _mapList(json['spend_by_plan'], PlanSpendEntry.fromJson),
        spendByMonth = _mapList(json['spend_by_month'], MonthSpendEntry.fromJson);
}

class PlanSpendEntry {
  String? planName;
  double? paid;
  int? count;

  PlanSpendEntry.fromJson(Map<String, dynamic> json)
      : planName = json['plan_name']?.toString(),
        paid = _toDouble(json['paid']),
        count = _toInt(json['count']);
}

class MonthSpendEntry {
  String month;
  double paid;

  MonthSpendEntry.fromJson(Map<String, dynamic> json)
      : month = json['month']?.toString() ?? '',
        paid = _toDouble(json['paid']) ?? 0;
}

class SubscriptionEntry {
  int? id;
  String? planName;
  double? price;
  String? paymentStatus;
  String? subscriptionStatus;
  int? duration;
  String? expiryDate;
  String? subscriptionNumber;
  String? moyasarPaymentId;
  String? createdAt;
  String? updatedAt;
  int? numberOfAds;
  int? numberOfZone;
  int? numberOfCategories;
  int? offerId;
  String? offerTitle;
  // يحدّده الباكند: أحدث اشتراك مدفوع غير منتهٍ — لا مجرد أحدث صف.
  bool isCurrent;

  SubscriptionEntry.fromJson(Map<String, dynamic> json)
      : id = _toInt(json['id']),
        planName = (json['service_plan'] is Map) ? json['service_plan']['name']?.toString() : null,
        price = _toDouble(json['price']),
        paymentStatus = json['payment_status']?.toString(),
        subscriptionStatus = json['subscription_status']?.toString(),
        duration = _toInt(json['duration']),
        expiryDate = json['expiry_date']?.toString(),
        subscriptionNumber = json['subscription_number']?.toString(),
        moyasarPaymentId = json['moyasar_payment_id']?.toString(),
        createdAt = json['created_at']?.toString(),
        updatedAt = json['updated_at']?.toString(),
        numberOfAds = _toInt(json['number_of_ads']),
        numberOfZone = _toInt(json['number_of_zone']),
        numberOfCategories = _toInt(json['number_of_categories']),
        offerId = _toInt(json['offer_id']),
        offerTitle = (json['offer'] is Map) ? json['offer']['title']?.toString() : null,
        isCurrent = _toBool(json['is_current']);
}

class CoverageBlock {
  List<CoverageEntry> zones;
  List<CoverageEntry> categories;
  List<CoverageEntry> serviceTypes;
  PlanAllowance? planAllowance;

  CoverageBlock.fromJson(Map<String, dynamic> json)
      : zones = _mapList(json['zones'], CoverageEntry.fromJson),
        categories = _mapList(json['categories'], CoverageEntry.fromJson),
        serviceTypes = _mapList(json['service_types'], CoverageEntry.fromJson),
        planAllowance = json['plan_allowance'] is Map
            ? PlanAllowance.fromJson(Map<String, dynamic>.from(json['plan_allowance']))
            : null;
}

class CoverageEntry {
  int? id;
  String? name;
  String? nameAr;
  int? offersCount;

  CoverageEntry.fromJson(Map<String, dynamic> json)
      : id = _toInt(json['id']),
        name = json['name']?.toString(),
        nameAr = json['name_ar']?.toString(),
        offersCount = _toInt(json['offers_count']);
}

class PlanAllowance {
  int ads;
  int zones;
  int categories;
  int activeSubscriptions;
  int activeOffers;
  int zonesUsed;
  int categoriesUsed;

  PlanAllowance.fromJson(Map<String, dynamic> json)
      : ads = _toInt(json['ads']) ?? 0,
        zones = _toInt(json['zones']) ?? 0,
        categories = _toInt(json['categories']) ?? 0,
        activeSubscriptions = _toInt(json['active_subscriptions']) ?? 0,
        activeOffers = _toInt(json['active_offers']) ?? 0,
        zonesUsed = _toInt(json['zones_used']) ?? 0,
        categoriesUsed = _toInt(json['categories_used']) ?? 0;
}

class PeriodSubscriptions {
  int? count;
  double? totalAmount;
  int? paidCount;
  double? paidAmount;

  PeriodSubscriptions.fromJson(Map<String, dynamic> json) {
    count = _toInt(json['count']);
    totalAmount = _toDouble(json['total_amount']);
    paidCount = _toInt(json['paid_count']);
    paidAmount = _toDouble(json['paid_amount']);
  }
}

class PeriodViews {
  int? totalViews;
  List<OfferViewsEntry> byOffer;
  List<ViewsPoint> timeseries;

  PeriodViews.fromJson(Map<String, dynamic> json)
      : totalViews = _toInt(json['total_views']),
        byOffer = _mapList(json['by_offer'], OfferViewsEntry.fromJson),
        timeseries = _mapList(json['timeseries'], ViewsPoint.fromJson);
}
