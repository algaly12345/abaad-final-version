import 'dart:math';

import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/features/services/controller/provider_statistics_controller.dart';
import 'package:abaad_flutter/features/services/data/models/provider_statistics_model.dart';
import 'package:abaad_flutter/shared/helpers/price_converter.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/root_fallback_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

String _formatNumber(int? v) => NumberFormat('#,##0').format(v ?? 0);

// ─── تنسيق التواريخ في هذه الشاشة فقط: الباكند يرسل created_at كـ ISO كامل
// (مثال: 2026-08-24T09:38:19.000000Z) وexpiry_date كتاريخ فقط (2026-09-24).
// DateTime.parse من Dart (وليس DateFormat.parse من intl) يُستخدم للتحليل هنا
// عمدًا لأنه يتقبّل عدد أرقام الكسور العشرية المتغيّر ولاحقة Z بأمان، بخلاف
// DateConverter.isoStringToLocalDate الحالي بالمشروع الذي يتوقع نمطًا صارمًا
// (SSS بالضبط بلا Z) قد يفشل مع صيغة الباكند الفعلية هنا.
String _formatDateTime(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    return DateFormat('d MMM yyyy - HH:mm').format(DateTime.parse(raw).toLocal());
  } catch (_) {
    return raw;
  }
}

String _formatDateOnly(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    return DateFormat('d MMM yyyy').format(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}

// عدد الأيام المتبقية حتى expiry_date (سالب إن كان الاشتراك منتهياً بالفعل).
// يُقارَن بمنتصف ليل اليوم الحالي (بلا وقت) حتى لا يظهر يوم الانتهاء نفسه
// كسالب بسبب فارق الساعات ضمن نفس اليوم.
int? _daysRemaining(String? expiryDate) {
  if (expiryDate == null || expiryDate.isEmpty) return null;
  try {
    final expiry = DateTime.parse(expiryDate);
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    return expiry.difference(todayDateOnly).inDays;
  } catch (_) {
    return null;
  }
}

// خطط الاشتراك الحالية كلها 1/3/6 أشهر فقط (راجع add_property_service_offer_screen.dart)
// فتُستخدم نفس مفاتيح الترجمة الجاهزة بدل تعقيد صياغة الجمع العربي؛ أي قيمة
// أخرى (احتياط للمستقبل) تُعرض كرقم + "شهر" مفرد.
String _durationLabel(int? months) {
  switch (months) {
    case 1:
      return 'one_month'.tr;
    case 3:
      return 'three_months'.tr;
    case 6:
      return 'six_months'.tr;
    default:
      return months != null ? '$months ${'one_month'.tr}' : '-';
  }
}

class ProviderStatisticsScreen extends StatefulWidget {
  const ProviderStatisticsScreen({super.key});

  @override
  State<ProviderStatisticsScreen> createState() =>
      _ProviderStatisticsScreenState();
}

class _ProviderStatisticsScreenState extends State<ProviderStatisticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Get.find<ProviderStatisticsController>().loadAll(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomRange(
      BuildContext context, ProviderStatisticsController controller) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: now,
      initialDateRange: controller.customFrom != null && controller.customTo != null
          ? DateTimeRange(start: controller.customFrom!, end: controller.customTo!)
          : null,
    );
    if (picked != null) {
      controller.setCustomRange(picked.start, picked.end);
    }
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              onTap: () => RootFallbackScope.handleBackTap(context),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'provider_statistics'.tr,
                style: robotoBold.copyWith(
                    fontSize: 17, color: AppColors.textPrimary(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── شريط التبويبات: نفس بنية/ألوان شريط MyServicesScreen حرفيًا (خلفية
  // cardColor، حدّ سفلي رفيع، مؤشّر سفلي بلون Primary) كي تبقى شاشات مزود
  // الخدمة كلها متسقة بصريًا ────────────────────────────────────────────────
  Widget _buildTabBar(BuildContext context, Color primary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: primary,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: robotoBold.copyWith(fontSize: 13),
        unselectedLabelStyle: robotoRegular.copyWith(fontSize: 13),
        indicatorColor: primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'stats_tab_overview'.tr),
          Tab(text: 'stats_tab_views'.tr),
          Tab(text: 'stats_tab_subscriptions'.tr),
          Tab(text: 'stats_tab_period'.tr),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildTopBar(context),
          Expanded(
            child: GetBuilder<ProviderStatisticsController>(
              builder: (controller) {
                if (controller.isLoading && controller.data == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = controller.data;
                if (data == null) {
                  return _ErrorState(
                    onRetry: () => controller.loadDashboard(),
                  );
                }

                return Column(
                  children: [
                    _buildTabBar(context, primary),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _OverviewTab(
                            summary: data.summary,
                            onRefresh: controller.loadAll,
                          ),
                          _ViewsTab(
                            viewsByZone: data.viewsByZone,
                            viewsByCategory: data.viewsByCategory,
                            onRefresh: controller.loadAll,
                          ),
                          _SubscriptionsTab(
                            subscriptions: data.subscriptions,
                            onRefresh: controller.loadAll,
                          ),
                          _PeriodTab(
                            controller: controller,
                            periodSummary: data.periodSummary,
                            periodSubscriptions: data.periodSubscriptions,
                            onPickCustomRange: () =>
                                _pickCustomRange(context, controller),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── محتوى التبويبات الأربعة ─────────────────────────────────────────────────
// كل تبويب عبارة عن غلاف رفيع فوق نفس أقسام العرض الموجودة أصلاً (بلا أي
// تغيير في منطقها) — مجرد إعادة تجميعها في صفحات منفصلة بدل قائمة تمرير واحدة
// طويلة، مع RefreshIndicator مستقل لكل تبويب.

class _OverviewTab extends StatelessWidget {
  final ProviderStatsSummary? summary;
  final Future<void> Function() onRefresh;
  const _OverviewTab({required this.summary, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _HeroSummaryCard(summary: summary),
          const SizedBox(height: Spacing.sectionGap),
          _StatusBreakdownCard(summary: summary),
        ],
      ),
    );
  }
}

class _ViewsTab extends StatelessWidget {
  final List<ZoneViewsEntry>? viewsByZone;
  final List<CategoryViewsEntry>? viewsByCategory;
  final Future<void> Function() onRefresh;
  const _ViewsTab({
    required this.viewsByZone,
    required this.viewsByCategory,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _RankedListSection(
            title: 'stats_views_by_zone'.tr,
            icon: Icons.map_outlined,
            zoneEntries: viewsByZone,
          ),
          const SizedBox(height: Spacing.sectionGap),
          _RankedListSection(
            title: 'stats_views_by_category'.tr,
            icon: Icons.category_outlined,
            categoryEntries: viewsByCategory,
          ),
        ],
      ),
    );
  }
}

class _SubscriptionsTab extends StatelessWidget {
  final List<SubscriptionEntry>? subscriptions;
  final Future<void> Function() onRefresh;
  const _SubscriptionsTab({required this.subscriptions, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _SubscriptionSection(subscriptions: subscriptions),
        ],
      ),
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final ProviderStatisticsController controller;
  final ProviderStatsSummary? periodSummary;
  final PeriodSubscriptions? periodSubscriptions;
  final VoidCallback onPickCustomRange;

  const _PeriodTab({
    required this.controller,
    required this.periodSummary,
    required this.periodSubscriptions,
    required this.onPickCustomRange,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _PeriodChips(
            selected: controller.selectedPeriod,
            onSelect: (p) =>
                p == 'custom' ? onPickCustomRange() : controller.setPeriod(p),
          ),
          const SizedBox(height: Spacing.md),
          _PeriodStatsSection(
            periodSummary: periodSummary,
            periodSubscriptions: periodSubscriptions,
          ),
          const SizedBox(height: Spacing.sectionGap),
          _ServiceDetailSection(
            offers: controller.periodOffers,
            isLoading: controller.isLoadingOffers,
            hasMore: controller.hasMoreOffers,
            onLoadMore: () => controller.loadMoreOffers(),
          ),
        ],
      ),
    );
  }
}

// ─── حالة الفشل ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.textSecondary(context)),
            const SizedBox(height: Spacing.md),
            Text('stats_load_error'.tr,
                style: AppTypography.body
                    .copyWith(color: AppColors.textSecondary(context)),
                textAlign: TextAlign.center),
            const SizedBox(height: Spacing.lg),
            OutlinedButton(onPressed: onRetry, child: Text('retry'.tr)),
          ],
        ),
      ),
    );
  }
}

// ─── بطاقة الترويسة: إجمالي العروض + إجمالي المشاهدات ──────────────────────
// بديل مرئي أكثر احترافية عن أول بلاطتين بالشبكة القديمة — بطاقة متدرّجة
// بلون Primary تُبرز أهم رقمين فوراً دون الحاجة لقراءة شبكة كاملة.

class _HeroSummaryCard extends StatelessWidget {
  final ProviderStatsSummary? summary;
  const _HeroSummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xl, horizontal: Spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [primary, primary.withValues(alpha: 0.78)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.soft(blur: 18, opacity: 0.20),
      ),
      child: Row(
        children: [
          Expanded(
            child: _HeroStat(
              icon: Icons.storefront_rounded,
              label: 'stats_total_offers'.tr,
              value: _formatNumber(summary?.totalOffersCount),
            ),
          ),
          Container(
            width: 1,
            height: 46,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          Expanded(
            child: _HeroStat(
              icon: Icons.visibility_rounded,
              label: 'stats_total_views'.tr,
              value: _formatNumber(summary?.totalViews),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _HeroStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.h3.copyWith(color: Colors.white)),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.88)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── شريحة حالة واحدة ضمن توزيع حالات العروض — مصدر مشترك لكل من الدونات
// (نظرة عامة) والشريط النسبي (تبويب الفترة) كي تبقى الألوان/الترتيب متطابقين ─

class _StatusSlice {
  final String label;
  final int value;
  final Color color;
  const _StatusSlice(this.label, this.value, this.color);
}

List<_StatusSlice> _statusSlices(ProviderStatsSummary? s) => [
      _StatusSlice('active_status'.tr, s?.activeOffersCount ?? 0, Colors.green.shade600),
      _StatusSlice('under_review'.tr, s?.pendingOffersCount ?? 0, Colors.orange.shade600),
      _StatusSlice('unpaid_status'.tr, s?.unpaidOffersCount ?? 0, Colors.deepOrange.shade600),
      _StatusSlice('rejected_status'.tr, s?.rejectedOffersCount ?? 0, Colors.red.shade600),
      _StatusSlice('expired_status'.tr, s?.expiredOffersCount ?? 0, Colors.grey.shade600),
    ];

// ─── بطاقة توزيع حالة العروض: رسم دونات + قائمة مفتاح (لون/اسم/عدد/نسبة) ────

class _StatusBreakdownCard extends StatelessWidget {
  final ProviderStatsSummary? summary;
  const _StatusBreakdownCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final slices = _statusSlices(summary);
    final total = slices.fold<int>(0, (sum, s) => sum + s.value);

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart_rounded, size: 18, color: AppColors.primary(context)),
              const SizedBox(width: Spacing.sm),
              Text('stats_status_breakdown'.tr,
                  style: AppTypography.smallBold
                      .copyWith(color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _DonutChart(
                slices: slices,
                total: total,
                centerLabel: 'stats_total_offers'.tr,
              ),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: slices.map((s) => _LegendRow(slice: s, total: total)).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final _StatusSlice slice;
  final int total;
  const _LegendRow({required this.slice, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : (slice.value / total * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              slice.label,
              style: AppTypography.small.copyWith(color: AppColors.textPrimary(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(_formatNumber(slice.value),
              style:
                  AppTypography.smallBold.copyWith(color: AppColors.textPrimary(context))),
          const SizedBox(width: 6),
          SizedBox(
            width: 32,
            child: Text(
              '$pct%',
              textAlign: TextAlign.end,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary(context)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── رسم الدونات: CustomPainter بسيط بلا أي حزمة خارجية — قوس لكل حالة بطول
// نسبي من قيمتها، بفجوة صغيرة بين الأقواس وطرف مستدير (لمسة "احترافية" بلا
// إضافة اعتمادية جديدة على مشروع لم يكن به أي حزمة رسوم بيانية أصلاً) ────────

class _DonutChart extends StatelessWidget {
  final List<_StatusSlice> slices;
  final int total;
  final String centerLabel;
  const _DonutChart({required this.slices, required this.total, required this.centerLabel});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 116,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(116, 116),
            painter: _DonutChartPainter(
              slices,
              strokeWidth: 15,
              trackColor: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatNumber(total),
                  style: AppTypography.title.copyWith(color: AppColors.textPrimary(context))),
              Text(centerLabel,
                  style: AppTypography.badge.copyWith(color: AppColors.textSecondary(context))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<_StatusSlice> slices;
  final double strokeWidth;
  final Color trackColor;
  _DonutChartPainter(this.slices, {required this.strokeWidth, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    final total = slices.fold<int>(0, (sum, s) => sum + s.value);
    if (total == 0) return;

    const gap = 0.035;
    double startAngle = -pi / 2;
    for (final slice in slices) {
      final sweep = (slice.value / total) * (2 * pi);
      if (slice.value > 0 && sweep > gap) {
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + gap / 2,
          sweep - gap,
          false,
          Paint()
            ..color = slice.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round,
        );
      }
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

// ─── المشاهدات حسب المنطقة/التصنيف ──────────────────────────────────────────
// عرض مرتّب (ranked list) بشريط تناسبي بلون Primary وحيد (سطحية = مقياس، لا
// هوية) بدل رسم بياني كامل — لا حاجة لمقياس أو محورين هنا، فقط ترتيب نسبي.

class _RankedListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<ZoneViewsEntry>? zoneEntries;
  final List<CategoryViewsEntry>? categoryEntries;

  const _RankedListSection({
    required this.title,
    required this.icon,
    this.zoneEntries,
    this.categoryEntries,
  });

  @override
  Widget build(BuildContext context) {
    // نفس اصطلاح بقية الشاشات بالتطبيق (filter_bottom_sheet.dart، service_details_screen.dart):
    // الاسم العربي أولاً إن وُجد، ثم الإنجليزي كاحتياط. estatesCount (عدد
    // العروض ضمن هذه المنطقة/التصنيف) كان موجوداً بالبيانات القادمة من الباكند
    // دون أي عرض له بالتصميم القديم — يُستخدم الآن كسطر ثانوي لدقّة أعلى.
    final rows = zoneEntries != null
        ? zoneEntries!
            .map((e) => (e.nameAr ?? e.name ?? '', e.totalViews ?? 0, e.estatesCount ?? 0))
            .toList()
        : (categoryEntries ?? [])
            .map((e) => (e.nameAr ?? e.name ?? '', e.totalViews ?? 0, e.estatesCount ?? 0))
            .toList();

    final maxViews = rows.isEmpty
        ? 0
        : rows.map((r) => r.$2).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary(context)),
              const SizedBox(width: Spacing.sm),
              Text(title,
                  style: AppTypography.smallBold
                      .copyWith(color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'stats_views_approx_note'.tr,
            style: AppTypography.caption
                .copyWith(color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: Spacing.md),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              child: Text(
                'stats_no_views_data'.tr,
                style: AppTypography.small
                    .copyWith(color: AppColors.textSecondary(context)),
              ),
            )
          else
            ...rows.take(5).toList().asMap().entries.map((indexed) {
              final rank = indexed.key + 1;
              final row = indexed.value;
              final ratio = maxViews == 0 ? 0.0 : row.$2 / maxViews;
              return Padding(
                padding: const EdgeInsets.only(bottom: Spacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RankBadge(rank: rank),
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(row.$1,
                                    style: AppTypography.small.copyWith(
                                        color: AppColors.textPrimary(context)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              Text(_formatNumber(row.$2),
                                  style: AppTypography.smallBold.copyWith(
                                      color: AppColors.textPrimary(context))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: ratio.clamp(0.02, 1.0),
                              minHeight: 6,
                              backgroundColor:
                                  AppColors.primary(context).withValues(alpha: 0.10),
                              valueColor: AlwaysStoppedAnimation(
                                  AppColors.primary(context)),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.storefront_outlined,
                                  size: 12, color: AppColors.textSecondary(context)),
                              const SizedBox(width: 3),
                              Text('${row.$3}',
                                  style: AppTypography.caption
                                      .copyWith(color: AppColors.textSecondary(context))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

// شارة الترتيب (١..٥) بتدرّج شفافية للون Primary — الأعلى مشاهدة أوضح لوناً.
class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final opacity = switch (rank) {
      1 => 1.0,
      2 => 0.78,
      3 => 0.58,
      _ => 0.38,
    };
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 1),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: primary.withValues(alpha: opacity), shape: BoxShape.circle),
      child: Text('$rank',
          style: AppTypography.captionMedium.copyWith(color: Colors.white)),
    );
  }
}

// ─── الاشتراك ────────────────────────────────────────────────────────────────

class _SubscriptionSection extends StatelessWidget {
  final List<SubscriptionEntry>? subscriptions;
  const _SubscriptionSection({required this.subscriptions});

  Color _paymentColor(String? status) {
    switch (status) {
      case 'paid':
        return Colors.green.shade600;
      case 'unpaid':
      case 'failed':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _paymentLabel(String? status) {
    switch (status) {
      case 'paid':
        return 'payment_paid'.tr;
      case 'unpaid':
        return 'payment_unpaid'.tr;
      case 'failed':
        return 'payment_failed'.tr;
      default:
        return status ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = subscriptions ?? [];

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined,
                  size: 18, color: AppColors.primary(context)),
              const SizedBox(width: Spacing.sm),
              Text('stats_subscription_section'.tr,
                  style: AppTypography.smallBold
                      .copyWith(color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: Spacing.md),
          if (list.isEmpty)
            Text(
              'stats_no_subscription'.tr,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary(context)),
            )
          else ...[
            _SubscriptionCard(
              entry: list.first,
              isCurrent: true,
              paymentColor: _paymentColor(list.first.paymentStatus),
              paymentLabel: _paymentLabel(list.first.paymentStatus),
            ),
            if (list.length > 1) ...[
              const SizedBox(height: Spacing.lg),
              Text('stats_subscription_history'.tr,
                  style: AppTypography.smallMedium
                      .copyWith(color: AppColors.textSecondary(context))),
              const SizedBox(height: Spacing.sm),
              ...list.skip(1).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.sm),
                    child: _SubscriptionCard(
                      entry: e,
                      isCurrent: false,
                      paymentColor: _paymentColor(e.paymentStatus),
                      paymentLabel: _paymentLabel(e.paymentStatus),
                    ),
                  )),
            ],
          ],
        ],
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionEntry entry;
  final bool isCurrent;
  final Color paymentColor;
  final String paymentLabel;

  const _SubscriptionCard({
    required this.entry,
    required this.isCurrent,
    required this.paymentColor,
    required this.paymentLabel,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final remaining = isCurrent ? _daysRemaining(entry.expiryDate) : null;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: isCurrent ? primary.withValues(alpha: 0.06) : AppColors.background(context),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isCurrent ? primary.withValues(alpha: 0.3) : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCurrent)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium_rounded, size: 14, color: primary),
                  const SizedBox(width: 4),
                  Text('stats_current_subscription'.tr,
                      style: AppTypography.captionMedium.copyWith(color: primary)),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entry.planName ?? '-',
                  style: AppTypography.smallBold
                      .copyWith(color: AppColors.textPrimary(context)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: paymentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  paymentLabel,
                  style: AppTypography.captionMedium.copyWith(color: paymentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: Spacing.md,
            runSpacing: 4,
            children: [
              if (entry.price != null)
                _InfoBit(icon: Icons.sell_outlined, text: PriceConverter.convertPrice(entry.price!)),
              if (entry.duration != null)
                _InfoBit(
                  icon: Icons.calendar_month_outlined,
                  text: '${'stats_duration_label'.tr}: ${_durationLabel(entry.duration)}',
                ),
              if (entry.expiryDate != null)
                _InfoBit(
                  icon: Icons.event_busy_outlined,
                  text: '${'stats_expiry_date'.tr}: ${_formatDateOnly(entry.expiryDate)}',
                ),
              if (entry.subscriptionNumber != null)
                _InfoBit(
                  icon: Icons.tag_rounded,
                  text: entry.subscriptionNumber!,
                ),
            ],
          ),
          if (remaining != null) ...[
            const SizedBox(height: 8),
            _RemainingChip(days: remaining),
          ],
        ],
      ),
    );
  }
}

// معلومة صغيرة بأيقونة + نص — تُستخدم لعرض السعر/المدة/تاريخ الانتهاء داخل
// بطاقة الاشتراك وبطاقة العرض بنفس الشكل الموحّد.
class _InfoBit extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoBit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary(context)),
        const SizedBox(width: 4),
        Text(text,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary(context))),
      ],
    );
  }
}

// شارة الأيام المتبقية للاشتراك الحالي — أخضر (>30 يوم) / برتقالي (≤30) /
// أحمر (≤7) / رمادي إن انتهى بالفعل، حتى يتنبّه المزوّد لتجديد اشتراكه بصرياً
// دون الحاجة لحساب الفارق ذهنياً من تاريخ الانتهاء.
class _RemainingChip extends StatelessWidget {
  final int days;
  const _RemainingChip({required this.days});

  @override
  Widget build(BuildContext context) {
    final expired = days < 0;
    final color = expired
        ? Colors.grey.shade600
        : days <= 7
            ? Colors.red.shade600
            : days <= 30
                ? Colors.orange.shade600
                : Colors.green.shade600;
    final label = expired
        ? 'stats_subscription_expired'.tr
        : 'stats_days_remaining'.trParams({'days': '$days'});

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration:
          BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(expired ? Icons.event_busy_rounded : Icons.schedule_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.captionMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── فلتر الفترة الزمنية ─────────────────────────────────────────────────────

class _PeriodChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _PeriodChips({required this.selected, required this.onSelect});

  static const _options = [
    ('all', 'period_all'),
    ('today', 'period_today'),
    ('week', 'period_week'),
    ('month', 'period_month'),
    ('custom', 'period_custom'),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          final (key, labelKey) = _options[index];
          final isSelected = key == selected;
          return ChoiceChip(
            label: Text(labelKey.tr),
            selected: isSelected,
            onSelected: (_) => onSelect(key),
            labelStyle: AppTypography.smallMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary(context),
            ),
            selectedColor: primary,
            backgroundColor: Theme.of(context).cardColor,
            side: BorderSide(
                color: isSelected ? primary : Theme.of(context).dividerColor),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }
}

// ─── إحصائيات الفترة المحددة (عروض جديدة + اشتراكات) ────────────────────────

class _PeriodStatsSection extends StatelessWidget {
  final ProviderStatsSummary? periodSummary;
  final PeriodSubscriptions? periodSubscriptions;

  const _PeriodStatsSection({
    required this.periodSummary,
    required this.periodSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final sub = periodSubscriptions;
    final slices = _statusSlices(periodSummary);
    final totalAmount = sub?.totalAmount ?? 0;
    final paidAmount = sub?.paidAmount ?? 0;
    final collectedRatio = totalAmount <= 0 ? 0.0 : (paidAmount / totalAmount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_note_outlined,
                  size: 18, color: AppColors.primary(context)),
              const SizedBox(width: Spacing.sm),
              Text('stats_period_section'.tr,
                  style: AppTypography.smallBold
                      .copyWith(color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            '${'stats_new_offers'.tr}: ${_formatNumber(periodSummary?.newOffersCount)}',
            style: AppTypography.body
                .copyWith(color: AppColors.textPrimary(context)),
          ),
          const SizedBox(height: Spacing.sm),
          _ProportionalBar(slices: slices),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.xs,
            children: slices.map((s) => _MiniBadge(s.label, s.value, s.color)).toList(),
          ),
          Divider(height: Spacing.xl, color: Theme.of(context).dividerColor),
          Text(
            '${'stats_period_subscriptions'.tr}: ${sub?.count ?? 0}',
            style: AppTypography.body
                .copyWith(color: AppColors.textPrimary(context)),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('stats_collected'.tr,
                  style: AppTypography.small
                      .copyWith(color: AppColors.textSecondary(context))),
              Text(
                '${PriceConverter.convertPrice(paidAmount)} / ${PriceConverter.convertPrice(totalAmount)}',
                style: AppTypography.smallBold
                    .copyWith(color: AppColors.textPrimary(context)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: collectedRatio,
              minHeight: 8,
              backgroundColor: AppColors.success.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(AppColors.success),
            ),
          ),
        ],
      ),
    );
  }
}

// شريط نسبي متعدد الشرائح يوضّح توزيع حالات العروض الجديدة خلال الفترة
// المحددة بنظرة واحدة، قبل تفصيلها بالشارات أسفله.
class _ProportionalBar extends StatelessWidget {
  final List<_StatusSlice> slices;
  const _ProportionalBar({required this.slices});

  @override
  Widget build(BuildContext context) {
    final total = slices.fold<int>(0, (sum, s) => sum + s.value);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: total == 0
            ? Container(color: Theme.of(context).dividerColor.withValues(alpha: 0.4))
            : Row(
                children: slices
                    .where((s) => s.value > 0)
                    .map((s) => Expanded(
                          flex: s.value,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            color: s.color,
                          ),
                        ))
                    .toList(),
              ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final int? value;
  final Color color;
  const _MiniBadge(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: ${value ?? 0}',
        style: AppTypography.captionMedium.copyWith(color: color),
      ),
    );
  }
}

// ─── تفاصيل كل خدمة (قائمة العروض ضمن الفترة المحددة) ───────────────────────

class _ServiceDetailSection extends StatelessWidget {
  final List<ServiceOffer>? offers;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback onLoadMore;

  const _ServiceDetailSection({
    required this.offers,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
  });

  ({String label, Color color, IconData icon}) _statusBucket(ServiceOffer o) {
    final isExpired = o.isExpired ?? false;
    final paymentStatus = o.paymentStatus;

    if (o.status == 'accept' && !isExpired) {
      return (
        label: 'active_status'.tr,
        color: Colors.green.shade600,
        icon: Icons.check_circle_outline_rounded,
      );
    }
    if (o.status == 'pending' &&
        (paymentStatus == 'unpaid' || paymentStatus == 'failed')) {
      return (
        label: 'unpaid_status'.tr,
        color: Colors.deepOrange.shade600,
        icon: Icons.payment_outlined,
      );
    }
    if (o.status == 'pending') {
      return (
        label: 'under_review'.tr,
        color: Colors.orange.shade600,
        icon: Icons.hourglass_empty_rounded,
      );
    }
    if (o.status == 'rejected') {
      return (label: 'rejected_status'.tr, color: Colors.red.shade600, icon: Icons.block_rounded);
    }
    return (label: 'expired_status'.tr, color: Colors.grey.shade600, icon: Icons.cancel_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final list = offers ?? [];

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.list_alt_outlined,
                  size: 18, color: AppColors.primary(context)),
              const SizedBox(width: Spacing.sm),
              Text('stats_service_details'.tr,
                  style: AppTypography.smallBold
                      .copyWith(color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: Spacing.md),
          if (list.isEmpty && !isLoading)
            Text(
              'stats_no_services_in_period'.tr,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary(context)),
            )
          else
            ...list.map((o) {
              final bucket = _statusBucket(o);
              final price = o.servicePrice != null ? double.tryParse(o.servicePrice!) : null;

              return Container(
                margin: const EdgeInsets.only(bottom: Spacing.sm),
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: bucket.color.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(bucket.icon, size: 15, color: bucket.color),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  o.title ?? '-',
                                  style: AppTypography.smallBold.copyWith(
                                      color: AppColors.textPrimary(context)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: bucket.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            bucket.label,
                            style: AppTypography.captionMedium
                                .copyWith(color: bucket.color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: Spacing.md,
                      runSpacing: 4,
                      children: [
                        if (price != null)
                          _InfoBit(icon: Icons.sell_outlined, text: PriceConverter.convertPrice(price)),
                        if (o.formattedDiscount != null)
                          _InfoBit(icon: Icons.local_offer_outlined, text: o.formattedDiscount!),
                        if (o.createdAt != null)
                          _InfoBit(
                            icon: Icons.add_circle_outline_rounded,
                            text: '${'created_at_label'.tr}: ${_formatDateTime(o.createdAt)}',
                          ),
                        if (o.expiryDate != null)
                          _InfoBit(
                            icon: Icons.event_busy_outlined,
                            text: '${'stats_expiry_date'.tr}: ${_formatDateOnly(o.expiryDate)}',
                          ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!isLoading && hasMore)
            Center(
              child: TextButton(
                onPressed: onLoadMore,
                child: Text('stats_load_more'.tr),
              ),
            ),
        ],
      ),
    );
  }
}
