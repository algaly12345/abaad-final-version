// المصدر الخام لكل الحقول الرقمية هنا هو Laravel/PDO — أعمدة SUM()/COUNT()
// الخام (selectRaw) تصل أحياناً كسلاسل نصية بدل أرقام JSON فعلية (مثال:
// "805786" بدل 805786)، وبعض الأعمدة العددية (مثل duration) قد تصل كأي من
// النوعين حسب مسار التنفيذ. تحويل دفاعي هنا يمنع كسر تحليل الاستجابة بالكامل
// بصمت (try/catch في ProviderStatisticsController) لمجرد اختلاف نوع حقل واحد.
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

class ProviderStatisticsModel {
  ProviderStatsSummary? summary;
  List<ZoneViewsEntry>? viewsByZone;
  List<CategoryViewsEntry>? viewsByCategory;
  List<SubscriptionEntry>? subscriptions;
  PeriodInfo? period;
  ProviderStatsSummary? periodSummary;
  PeriodSubscriptions? periodSubscriptions;

  ProviderStatisticsModel.fromJson(Map<String, dynamic> json) {
    summary = json['summary'] != null
        ? ProviderStatsSummary.fromJson(json['summary'])
        : null;

    if (json['views_by_zone'] != null) {
      viewsByZone = [];
      json['views_by_zone'].forEach((v) {
        viewsByZone!.add(ZoneViewsEntry.fromJson(v));
      });
    }

    if (json['views_by_category'] != null) {
      viewsByCategory = [];
      json['views_by_category'].forEach((v) {
        viewsByCategory!.add(CategoryViewsEntry.fromJson(v));
      });
    }

    if (json['subscriptions'] != null) {
      subscriptions = [];
      json['subscriptions'].forEach((v) {
        subscriptions!.add(SubscriptionEntry.fromJson(v));
      });
    }

    period = json['period'] != null ? PeriodInfo.fromJson(json['period']) : null;
    periodSummary = json['period_summary'] != null
        ? ProviderStatsSummary.fromJson(json['period_summary'])
        : null;
    periodSubscriptions = json['period_subscriptions'] != null
        ? PeriodSubscriptions.fromJson(json['period_subscriptions'])
        : null;
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
  // موجود فقط في period_summary (عدد الخدمات المُنشأة خلال الفترة) — null دومًا
  // في summary العادية (الحالة الآنية).
  int? newOffersCount;

  ProviderStatsSummary.fromJson(Map<String, dynamic> json) {
    activeOffersCount = _toInt(json['active_offers_count']);
    pendingOffersCount = _toInt(json['pending_offers_count']);
    unpaidOffersCount = _toInt(json['unpaid_offers_count']);
    rejectedOffersCount = _toInt(json['rejected_offers_count']);
    expiredOffersCount = _toInt(json['expired_offers_count']);
    totalOffersCount = _toInt(json['total_offers_count']);
    totalViews = _toInt(json['total_views']);
    newOffersCount = _toInt(json['new_offers_count']);
  }
}

class PeriodInfo {
  String? key;
  String? from;
  String? to;

  PeriodInfo.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    from = json['from'];
    to = json['to'];
  }
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

// مشتركة بين views_by_zone و views_by_category — نفس بنية الحقول تماماً
// (id, name, name_ar, estates_count, total_views) في الطرفين بالباكند.
class ZoneViewsEntry {
  int? id;
  String? name;
  String? nameAr;
  int? estatesCount;
  int? totalViews;

  ZoneViewsEntry.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    name = json['name'];
    nameAr = json['name_ar'];
    estatesCount = _toInt(json['estates_count']);
    totalViews = _toInt(json['total_views']);
  }
}

class CategoryViewsEntry {
  int? id;
  String? name;
  String? nameAr;
  int? estatesCount;
  int? totalViews;

  CategoryViewsEntry.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    name = json['name'];
    nameAr = json['name_ar'];
    estatesCount = _toInt(json['estates_count']);
    totalViews = _toInt(json['total_views']);
  }
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
  String? createdAt;

  SubscriptionEntry.fromJson(Map<String, dynamic> json) {
    id = _toInt(json['id']);
    planName = json['service_plan']?['name'];
    price = json['price'] != null ? double.tryParse(json['price'].toString()) : null;
    paymentStatus = json['payment_status'];
    subscriptionStatus = json['subscription_status'];
    duration = _toInt(json['duration']);
    expiryDate = json['expiry_date'];
    subscriptionNumber = json['subscription_number'];
    createdAt = json['created_at'];
  }
}
