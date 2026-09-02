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

String _formatNumber(num? v) => NumberFormat('#,##0').format(v ?? 0);

String _formatDecimal(num? v) => NumberFormat('#,##0.#').format(v ?? 0);

// ─── تنسيق التواريخ في هذه الشاشة فقط: الباكند يرسل created_at كـ ISO كامل
// وexpiry_date كتاريخ فقط. DateTime.parse من Dart يُستخدم عمدًا لتقبّله عدد
// أرقام الكسور المتغيّر ولاحقة Z بأمان.
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

// 'yyyy-MM' → 'MMM yy' (للأعمدة الشهرية) — يتقبّل 'yyyy-MM-dd' أيضًا احتياطًا.
String _formatMonthLabel(String ym) {
  try {
    final parts = ym.split('-');
    final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMM').format(d);
  } catch (_) {
    return ym;
  }
}

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
    _tabController = TabController(length: 5, vsync: this);
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
      initialDateRange:
          controller.customFrom != null && controller.customTo != null
              ? DateTimeRange(
                  start: controller.customFrom!, end: controller.customTo!)
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
          Tab(text: 'stats_tab_performance'.tr),
          Tab(text: 'stats_tab_finance'.tr),
          Tab(text: 'stats_tab_coverage'.tr),
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
                  return _ErrorState(onRetry: () => controller.loadDashboard());
                }

                return Column(
                  children: [
                    _buildTabBar(context, primary),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _OverviewTab(data: data, onRefresh: controller.loadAll),
                          _PerformanceTab(
                              perf: data.performance,
                              onRefresh: controller.loadAll),
                          _FinanceTab(
                              finance: data.finance,
                              subscriptions: data.subscriptions,
                              onRefresh: controller.loadAll),
                          _CoverageTab(
                              coverage: data.coverage,
                              onRefresh: controller.loadAll),
                          _PeriodTab(
                            controller: controller,
                            periodSummary: data.periodSummary,
                            periodSubscriptions: data.periodSubscriptions,
                            periodViews: data.periodViews,
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

// ═══════════════════════════════════════════════════════════════════════════
// تبويب ١: نظرة عامة
// ═══════════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final ProviderStatisticsModel data;
  final Future<void> Function() onRefresh;
  const _OverviewTab({required this.data, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final s = data.summary;
    final f = data.finance;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _KpiGrid(tiles: [
            _KpiData(Icons.storefront_rounded, 'stats_total_offers'.tr,
                _formatNumber(s?.totalOffersCount)),
            _KpiData(Icons.check_circle_rounded, 'active_status'.tr,
                _formatNumber(s?.activeOffersCount)),
            _KpiData(Icons.visibility_rounded, 'stats_total_views'.tr,
                _formatNumber(s?.totalViews)),
            _KpiData(Icons.trending_up_rounded, 'stats_views_last_30d'.tr,
                _formatNumber(s?.viewsLast30d)),
            _KpiData(Icons.payments_rounded, 'stats_lifetime_spend'.tr,
                PriceConverter.convertPrice(f?.lifetimePaid ?? 0)),
            _KpiData(Icons.error_outline_rounded, 'stats_outstanding'.tr,
                PriceConverter.convertPrice(f?.outstandingAmount ?? 0),
                highlight: (f?.outstandingAmount ?? 0) > 0),
          ]),
          const SizedBox(height: Spacing.sectionGap),
          _AccountCard(account: data.account),
          const SizedBox(height: Spacing.sectionGap),
          _StatusBreakdownCard(summary: s),
        ],
      ),
    );
  }
}

class _KpiData {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  const _KpiData(this.icon, this.label, this.value, {this.highlight = false});
}

class _KpiGrid extends StatelessWidget {
  final List<_KpiData> tiles;
  const _KpiGrid({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      const spacing = Spacing.md;
      final w = (c.maxWidth - spacing) / 2;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: tiles
            .map((t) => SizedBox(width: w, child: _KpiTile(data: t)))
            .toList(),
      );
    });
  }
}

class _KpiTile extends StatelessWidget {
  final _KpiData data;
  const _KpiTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final accent = data.highlight ? Colors.deepOrange.shade600 : primary;
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: data.highlight
              ? accent.withValues(alpha: 0.4)
              : Theme.of(context).dividerColor,
        ),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(data.icon, size: 17, color: accent),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            data.value,
            style: AppTypography.title
                .copyWith(color: AppColors.textPrimary(context)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textSecondary(context)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── بطاقة الحساب / التوثيق ────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final AccountProfile? account;
  const _AccountCard({required this.account});

  @override
  Widget build(BuildContext context) {
    final a = account;
    if (a == null) return const SizedBox.shrink();

    final primary = AppColors.primary(context);
    final completeness = a.profileCompleteness ?? 0;

    return _Card(
      icon: Icons.badge_outlined,
      title: 'stats_account_section'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: primary.withValues(alpha: 0.12),
                backgroundImage: (a.image != null && a.image!.isNotEmpty)
                    ? NetworkImage(a.image!)
                    : null,
                child: (a.image == null || a.image!.isEmpty)
                    ? Icon(Icons.person_rounded, color: primary)
                    : null,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name ?? '-',
                        style: AppTypography.smallBold
                            .copyWith(color: AppColors.textPrimary(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (a.serviceTypeName != null &&
                        a.serviceTypeName!.isNotEmpty)
                      Text(a.serviceTypeName!,
                          style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary(context)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    if (a.memberSince != null && a.memberSince!.isNotEmpty)
                      Text(
                        '${'stats_member_since'.tr}: ${_formatDateOnly(a.memberSince)}',
                        style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(context)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Text('stats_profile_completeness'.tr,
                  style: AppTypography.small
                      .copyWith(color: AppColors.textSecondary(context))),
              const Spacer(),
              Text('$completeness%',
                  style: AppTypography.smallBold
                      .copyWith(color: AppColors.textPrimary(context))),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (completeness / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: primary.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation(
                  completeness >= 80 ? AppColors.success : primary),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.xs,
            children: [
              _VerifyChip('stats_verify_nafath'.tr, a.accountVerification),
              _VerifyChip('stats_verify_phone'.tr, a.phoneVerified),
              _VerifyChip('stats_verify_email'.tr, a.emailVerified),
              _VerifyChip('stats_verify_unified_number'.tr, a.hasUnifiedNumber),
              _VerifyChip('stats_verify_fal'.tr, a.hasFalLicense),
              _VerifyChip('stats_verify_cr'.tr,
                  (a.commercialRegistrationNo ?? '').isNotEmpty),
            ],
          ),
          if ((a.commercialRegistrationNo ?? '').isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            _InfoBit(
              icon: Icons.numbers_rounded,
              text:
                  '${'stats_verify_cr'.tr}: ${a.commercialRegistrationNo}',
            ),
          ],
          if (a.zoneName != null && a.zoneName!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _InfoBit(
              icon: Icons.place_outlined,
              text: '${'stats_primary_zone'.tr}: ${a.zoneName}',
            ),
          ],
        ],
      ),
    );
  }
}

class _VerifyChip extends StatelessWidget {
  final String label;
  final bool ok;
  const _VerifyChip(this.label, this.ok);

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.success : Colors.grey.shade500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ok ? Icons.verified_rounded : Icons.remove_circle_outline_rounded,
              size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.captionMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// تبويب ٢: الأداء والمشاهدات
// ═══════════════════════════════════════════════════════════════════════════

class _PerformanceTab extends StatelessWidget {
  final PerformanceBlock? perf;
  final Future<void> Function() onRefresh;
  const _PerformanceTab({required this.perf, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final p = perf;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _Card(
            icon: Icons.insights_rounded,
            title: 'stats_views_summary'.tr,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _MiniStat('stats_total_views'.tr,
                            _formatNumber(p?.totalViews))),
                    Expanded(
                        child: _MiniStat('stats_views_last_7d'.tr,
                            _formatNumber(p?.viewsLast7d))),
                    Expanded(
                        child: _MiniStat('stats_views_last_30d'.tr,
                            _formatNumber(p?.viewsLast30d))),
                  ],
                ),
                if ((p?.totalViews ?? 0) == 0) ...[
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'stats_views_tracking_note'.tr,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary(context)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.sectionGap),
          _Card(
            icon: Icons.show_chart_rounded,
            title: 'stats_views_trend'.tr,
            child: _LineChart(points: p?.timeseries ?? const []),
          ),
          const SizedBox(height: Spacing.sectionGap),
          _OfferViewsSection(entries: p?.byOffer ?? const []),
          const SizedBox(height: Spacing.sectionGap),
          _RankedDimensionSection(
            title: 'stats_views_by_zone'.tr,
            icon: Icons.map_outlined,
            entries: p?.byZone ?? const [],
          ),
          const SizedBox(height: Spacing.sectionGap),
          _RankedDimensionSection(
            title: 'stats_views_by_category'.tr,
            icon: Icons.category_outlined,
            entries: p?.byCategory ?? const [],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.title
                .copyWith(color: AppColors.textPrimary(context))),
        const SizedBox(height: 2),
        Text(label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textSecondary(context)),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// ─── المشاهدات لكل عرض ─────────────────────────────────────────────────────

class _OfferViewsSection extends StatelessWidget {
  final List<OfferViewsEntry> entries;
  const _OfferViewsSection({required this.entries});

  ({String label, Color color}) _statusBucket(BuildContext context, OfferViewsEntry o) {
    if (o.status == 'accept' && !o.isExpired) {
      return (label: 'active_status'.tr, color: Colors.green.shade600);
    }
    if (o.status == 'pending') {
      return (label: 'under_review'.tr, color: Colors.orange.shade600);
    }
    if (o.status == 'rejected') {
      return (label: 'rejected_status'.tr, color: Colors.red.shade600);
    }
    return (label: 'expired_status'.tr, color: Colors.grey.shade600);
  }

  @override
  Widget build(BuildContext context) {
    final rows = entries.toList();
    final maxViews = rows.isEmpty
        ? 0
        : rows.map((r) => r.views ?? 0).reduce((a, b) => a > b ? a : b);

    return _Card(
      icon: Icons.leaderboard_outlined,
      title: 'stats_views_by_offer'.tr,
      child: rows.isEmpty
          ? Text('stats_no_views_data'.tr,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary(context)))
          : Column(
              children: rows.asMap().entries.map((indexed) {
                final rank = indexed.key + 1;
                final o = indexed.value;
                final bucket = _statusBucket(context, o);
                final ratio =
                    maxViews == 0 ? 0.0 : (o.views ?? 0) / maxViews;
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
                              children: [
                                Expanded(
                                  child: Text(o.title ?? '-',
                                      style: AppTypography.small.copyWith(
                                          color:
                                              AppColors.textPrimary(context)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(_formatNumber(o.views),
                                    style: AppTypography.smallBold.copyWith(
                                        color:
                                            AppColors.textPrimary(context))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio.clamp(0.02, 1.0),
                                minHeight: 6,
                                backgroundColor: AppColors.primary(context)
                                    .withValues(alpha: 0.10),
                                valueColor: AlwaysStoppedAnimation(
                                    AppColors.primary(context)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        bucket.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(bucket.label,
                                      style: AppTypography.badge
                                          .copyWith(color: bucket.color)),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${'stats_all_time'.tr}: ${_formatNumber(o.viewsAllTime)}',
                                  style: AppTypography.caption.copyWith(
                                      color:
                                          AppColors.textSecondary(context)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ─── المشاهدات حسب المنطقة/التصنيف ────────────────────────────────────────

class _RankedDimensionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<DimensionViewsEntry> entries;

  const _RankedDimensionSection({
    required this.title,
    required this.icon,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final rows = entries
        .map((e) =>
            (e.nameAr ?? e.name ?? '', e.totalViews ?? 0, e.offersCount ?? 0))
        .toList();
    final maxViews = rows.isEmpty
        ? 0
        : rows.map((r) => r.$2).reduce((a, b) => a > b ? a : b);

    return _Card(
      icon: icon,
      title: title,
      child: rows.isEmpty
          ? Text('stats_no_views_data'.tr,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary(context)))
          : Column(
              children: rows.take(6).toList().asMap().entries.map((indexed) {
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
                              children: [
                                Expanded(
                                  child: Text(row.$1,
                                      style: AppTypography.small.copyWith(
                                          color:
                                              AppColors.textPrimary(context)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(_formatNumber(row.$2),
                                    style: AppTypography.smallBold.copyWith(
                                        color:
                                            AppColors.textPrimary(context))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: ratio.clamp(0.02, 1.0),
                                minHeight: 6,
                                backgroundColor: AppColors.primary(context)
                                    .withValues(alpha: 0.10),
                                valueColor: AlwaysStoppedAnimation(
                                    AppColors.primary(context)),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.storefront_outlined,
                                    size: 12,
                                    color: AppColors.textSecondary(context)),
                                const SizedBox(width: 3),
                                Text('${row.$3}',
                                    style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(
                                            context))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

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
      decoration: BoxDecoration(
          color: primary.withValues(alpha: opacity), shape: BoxShape.circle),
      child: Text('$rank',
          style: AppTypography.captionMedium.copyWith(color: Colors.white)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// تبويب ٣: المالية والاشتراكات
// ═══════════════════════════════════════════════════════════════════════════

class _FinanceTab extends StatelessWidget {
  final FinanceBlock? finance;
  final List<SubscriptionEntry> subscriptions;
  final Future<void> Function() onRefresh;
  const _FinanceTab({
    required this.finance,
    required this.subscriptions,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final f = finance;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _KpiGrid(tiles: [
            _KpiData(Icons.payments_rounded, 'stats_lifetime_spend'.tr,
                PriceConverter.convertPrice(f?.lifetimePaid ?? 0)),
            _KpiData(Icons.error_outline_rounded, 'stats_outstanding'.tr,
                PriceConverter.convertPrice(f?.outstandingAmount ?? 0),
                highlight: (f?.outstandingAmount ?? 0) > 0),
            _KpiData(Icons.event_repeat_rounded, 'stats_next_renewal'.tr,
                _formatDateOnly(f?.nextRenewalAt)),
            _KpiData(Icons.hourglass_bottom_rounded, 'stats_soonest_expiry'.tr,
                _formatDateOnly(f?.soonestExpiryAt)),
          ]),
          const SizedBox(height: Spacing.sm),
          if (f != null)
            Text(
              '${'stats_paid_subscriptions'.tr}: ${_formatNumber(f.paidCount)}  •  '
              '${'stats_unpaid_subscriptions'.tr}: ${_formatNumber(f.unpaidCount)}',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary(context)),
            ),
          const SizedBox(height: Spacing.sectionGap),
          _Card(
            icon: Icons.bar_chart_rounded,
            title: 'stats_spend_by_month'.tr,
            child: _MiniBarChart(entries: f?.spendByMonth ?? const []),
          ),
          const SizedBox(height: Spacing.sectionGap),
          _SpendByPlanSection(entries: f?.spendByPlan ?? const []),
          const SizedBox(height: Spacing.sectionGap),
          _SubscriptionSection(subscriptions: subscriptions),
        ],
      ),
    );
  }
}

class _SpendByPlanSection extends StatelessWidget {
  final List<PlanSpendEntry> entries;
  const _SpendByPlanSection({required this.entries});

  @override
  Widget build(BuildContext context) {
    final maxPaid = entries.isEmpty
        ? 0.0
        : entries
            .map((e) => e.paid ?? 0)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();

    return _Card(
      icon: Icons.workspace_premium_outlined,
      title: 'stats_spend_by_plan'.tr,
      child: entries.isEmpty
          ? Text('stats_no_subscription'.tr,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary(context)))
          : Column(
              children: entries.map((e) {
                final ratio =
                    maxPaid == 0 ? 0.0 : (e.paid ?? 0) / maxPaid;
                return Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${e.planName ?? '-'}  (${_formatNumber(e.count)})',
                              style: AppTypography.small.copyWith(
                                  color: AppColors.textPrimary(context)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(PriceConverter.convertPrice(e.paid ?? 0),
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
                          backgroundColor: AppColors.primary(context)
                              .withValues(alpha: 0.10),
                          valueColor: AlwaysStoppedAnimation(
                              AppColors.primary(context)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ─── الاشتراكات ────────────────────────────────────────────────────────────

class _SubscriptionSection extends StatelessWidget {
  final List<SubscriptionEntry> subscriptions;
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
    final list = subscriptions;

    return _Card(
      icon: Icons.receipt_long_outlined,
      title: 'stats_subscription_section'.tr,
      child: list.isEmpty
          ? Text('stats_no_subscription'.tr,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary(context)))
          : Column(
              children: [
                _SubscriptionCard(
                  entry: list.first,
                  isCurrent: true,
                  paymentColor: _paymentColor(list.first.paymentStatus),
                  paymentLabel: _paymentLabel(list.first.paymentStatus),
                ),
                if (list.length > 1) ...[
                  const SizedBox(height: Spacing.lg),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('stats_subscription_history'.tr,
                        style: AppTypography.smallMedium.copyWith(
                            color: AppColors.textSecondary(context))),
                  ),
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
        color: isCurrent
            ? primary.withValues(alpha: 0.06)
            : AppColors.background(context),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isCurrent
              ? primary.withValues(alpha: 0.3)
              : Theme.of(context).dividerColor,
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
                  Icon(Icons.workspace_premium_rounded,
                      size: 14, color: primary),
                  const SizedBox(width: 4),
                  Text('stats_current_subscription'.tr,
                      style: AppTypography.captionMedium
                          .copyWith(color: primary)),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.planName ?? entry.offerTitle ?? '-',
                  style: AppTypography.smallBold
                      .copyWith(color: AppColors.textPrimary(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: paymentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(paymentLabel,
                    style: AppTypography.captionMedium
                        .copyWith(color: paymentColor)),
              ),
            ],
          ),
          if (entry.offerTitle != null && entry.offerTitle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            _InfoBit(
                icon: Icons.link_rounded,
                text: '${'stats_linked_offer'.tr}: ${entry.offerTitle}'),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: Spacing.md,
            runSpacing: 4,
            children: [
              if (entry.price != null)
                _InfoBit(
                    icon: Icons.sell_outlined,
                    text: PriceConverter.convertPrice(entry.price!)),
              if (entry.duration != null)
                _InfoBit(
                  icon: Icons.calendar_month_outlined,
                  text:
                      '${'stats_duration_label'.tr}: ${_durationLabel(entry.duration)}',
                ),
              if (entry.expiryDate != null)
                _InfoBit(
                  icon: Icons.event_busy_outlined,
                  text:
                      '${'stats_expiry_date'.tr}: ${_formatDateOnly(entry.expiryDate)}',
                ),
              if (entry.subscriptionNumber != null)
                _InfoBit(
                    icon: Icons.tag_rounded, text: entry.subscriptionNumber!),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: 4,
            children: [
              if ((entry.numberOfAds ?? 0) > 0)
                _MiniBadge('stats_ads_allowance'.tr, entry.numberOfAds,
                    primary),
              if ((entry.numberOfZone ?? 0) > 0)
                _MiniBadge('stats_zones_allowance'.tr, entry.numberOfZone,
                    primary),
              if ((entry.numberOfCategories ?? 0) > 0)
                _MiniBadge('stats_categories_allowance'.tr,
                    entry.numberOfCategories, primary),
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

// ═══════════════════════════════════════════════════════════════════════════
// تبويب ٤: التغطية
// ═══════════════════════════════════════════════════════════════════════════

class _CoverageTab extends StatelessWidget {
  final CoverageBlock? coverage;
  final Future<void> Function() onRefresh;
  const _CoverageTab({required this.coverage, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final c = coverage;
    final a = c?.planAllowance;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          if (a != null)
            _Card(
              icon: Icons.tune_rounded,
              title: 'stats_plan_allowance'.tr,
              child: Column(
                children: [
                  _AllowanceBar(
                    label: 'stats_active_offers'.tr,
                    used: a.activeOffers,
                    allowed: a.ads,
                  ),
                  _AllowanceBar(
                    label: 'stats_coverage_zones'.tr,
                    used: a.zonesUsed,
                    allowed: a.zones,
                  ),
                  _AllowanceBar(
                    label: 'stats_coverage_categories'.tr,
                    used: a.categoriesUsed,
                    allowed: a.categories,
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${'stats_active_subscriptions'.tr}: ${_formatNumber(a.activeSubscriptions)}',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary(context)),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Spacing.sectionGap),
          _CoverageListSection(
            title: 'stats_coverage_zones'.tr,
            icon: Icons.map_outlined,
            entries: c?.zones ?? const [],
          ),
          const SizedBox(height: Spacing.sectionGap),
          _CoverageListSection(
            title: 'stats_coverage_categories'.tr,
            icon: Icons.category_outlined,
            entries: c?.categories ?? const [],
          ),
          const SizedBox(height: Spacing.sectionGap),
          _CoverageListSection(
            title: 'stats_coverage_service_types'.tr,
            icon: Icons.handyman_outlined,
            entries: c?.serviceTypes ?? const [],
          ),
        ],
      ),
    );
  }
}

class _AllowanceBar extends StatelessWidget {
  final String label;
  final int used;
  final int allowed;
  const _AllowanceBar({
    required this.label,
    required this.used,
    required this.allowed,
  });

  @override
  Widget build(BuildContext context) {
    final over = allowed > 0 && used > allowed;
    final ratio = allowed <= 0 ? 0.0 : (used / allowed).clamp(0.0, 1.0);
    final color = over ? Colors.deepOrange.shade600 : AppColors.primary(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label,
                    style: AppTypography.small.copyWith(
                        color: AppColors.textPrimary(context))),
              ),
              Text(
                allowed > 0
                    ? 'stats_used_of'.trParams(
                        {'used': '$used', 'total': '$allowed'})
                    : '$used',
                style: AppTypography.smallBold.copyWith(
                    color: over ? color : AppColors.textPrimary(context)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: allowed <= 0 ? null : ratio,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<CoverageEntry> entries;
  const _CoverageListSection({
    required this.title,
    required this.icon,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      icon: icon,
      title: title,
      child: entries.isEmpty
          ? Text('stats_no_coverage_data'.tr,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary(context)))
          : Column(
              children: entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: AppColors.primary(context)),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Text(e.nameAr ?? e.name ?? '-',
                            style: AppTypography.small.copyWith(
                                color: AppColors.textPrimary(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text(
                        '${e.offersCount ?? 0} ${'stats_offers_unit'.tr}',
                        style: AppTypography.captionMedium.copyWith(
                            color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// تبويب ٥: الفترة والتفاصيل
// ═══════════════════════════════════════════════════════════════════════════

class _PeriodTab extends StatelessWidget {
  final ProviderStatisticsController controller;
  final ProviderStatsSummary? periodSummary;
  final PeriodSubscriptions? periodSubscriptions;
  final PeriodViews? periodViews;
  final VoidCallback onPickCustomRange;

  const _PeriodTab({
    required this.controller,
    required this.periodSummary,
    required this.periodSubscriptions,
    required this.periodViews,
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
          _Card(
            icon: Icons.show_chart_rounded,
            title: 'stats_period_views'.tr,
            child: Column(
              children: [
                Text(
                  '${'stats_total_views'.tr}: ${_formatNumber(periodViews?.totalViews)}',
                  style: AppTypography.body
                      .copyWith(color: AppColors.textPrimary(context)),
                ),
                const SizedBox(height: Spacing.sm),
                _LineChart(points: periodViews?.timeseries ?? const []),
              ],
            ),
          ),
          if ((periodViews?.byOffer ?? const []).isNotEmpty) ...[
            const SizedBox(height: Spacing.sectionGap),
            _OfferViewsSection(entries: periodViews!.byOffer),
          ],
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
    final collectedRatio =
        totalAmount <= 0 ? 0.0 : (paidAmount / totalAmount).clamp(0.0, 1.0);

    return _Card(
      icon: Icons.event_note_outlined,
      title: 'stats_period_section'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            children: slices
                .map((s) => _MiniBadge(s.label, s.value, s.color))
                .toList(),
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
            ? Container(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.4))
            : Row(
                children: slices
                    .where((s) => s.value > 0)
                    .map((s) => Expanded(
                          flex: s.value,
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 0.5),
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
      child: Text('$label: ${value ?? 0}',
          style: AppTypography.captionMedium.copyWith(color: color)),
    );
  }
}

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
      return (
        label: 'rejected_status'.tr,
        color: Colors.red.shade600,
        icon: Icons.block_rounded
      );
    }
    return (
      label: 'expired_status'.tr,
      color: Colors.grey.shade600,
      icon: Icons.cancel_outlined
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = offers ?? [];

    return _Card(
      icon: Icons.list_alt_outlined,
      title: 'stats_service_details'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (list.isEmpty && !isLoading)
            Text('stats_no_services_in_period'.tr,
                style: AppTypography.small
                    .copyWith(color: AppColors.textSecondary(context)))
          else
            ...list.map((o) {
              final bucket = _statusBucket(o);
              final price = o.servicePrice != null
                  ? double.tryParse(o.servicePrice!)
                  : null;

              return Container(
                margin: const EdgeInsets.only(bottom: Spacing.sm),
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: AppColors.background(context),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border:
                      Border.all(color: bucket.color.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(bucket.icon, size: 15, color: bucket.color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(o.title ?? '-',
                              style: AppTypography.smallBold.copyWith(
                                  color: AppColors.textPrimary(context)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: bucket.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(bucket.label,
                              style: AppTypography.captionMedium
                                  .copyWith(color: bucket.color)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: Spacing.md,
                      runSpacing: 4,
                      children: [
                        if (price != null)
                          _InfoBit(
                              icon: Icons.sell_outlined,
                              text: PriceConverter.convertPrice(price)),
                        if (o.formattedDiscount != null)
                          _InfoBit(
                              icon: Icons.local_offer_outlined,
                              text: o.formattedDiscount!),
                        if (o.createdAt != null)
                          _InfoBit(
                            icon: Icons.add_circle_outline_rounded,
                            text:
                                '${'created_at_label'.tr}: ${_formatDateTime(o.createdAt)}',
                          ),
                        if (o.expiryDate != null)
                          _InfoBit(
                            icon: Icons.event_busy_outlined,
                            text:
                                '${'stats_expiry_date'.tr}: ${_formatDateOnly(o.expiryDate)}',
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

// ═══════════════════════════════════════════════════════════════════════════
// عناصر مشتركة
// ═══════════════════════════════════════════════════════════════════════════

class _Card extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _Card({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Text(title,
                    style: AppTypography.smallBold
                        .copyWith(color: AppColors.textPrimary(context))),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          child,
        ],
      ),
    );
  }
}

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
        Flexible(
          child: Text(text,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

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
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(expired ? Icons.event_busy_rounded : Icons.schedule_rounded,
              size: 13, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.captionMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── توزيع حالة العروض (دونات) ─────────────────────────────────────────────

class _StatusSlice {
  final String label;
  final int value;
  final Color color;
  const _StatusSlice(this.label, this.value, this.color);
}

List<_StatusSlice> _statusSlices(ProviderStatsSummary? s) => [
      _StatusSlice('active_status'.tr, s?.activeOffersCount ?? 0,
          Colors.green.shade600),
      _StatusSlice('under_review'.tr, s?.pendingOffersCount ?? 0,
          Colors.orange.shade600),
      _StatusSlice('unpaid_status'.tr, s?.unpaidOffersCount ?? 0,
          Colors.deepOrange.shade600),
      _StatusSlice('rejected_status'.tr, s?.rejectedOffersCount ?? 0,
          Colors.red.shade600),
      _StatusSlice('expired_status'.tr, s?.expiredOffersCount ?? 0,
          Colors.grey.shade600),
    ];

class _StatusBreakdownCard extends StatelessWidget {
  final ProviderStatsSummary? summary;
  const _StatusBreakdownCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final slices = _statusSlices(summary);
    final total = slices.fold<int>(0, (sum, s) => sum + s.value);

    return _Card(
      icon: Icons.pie_chart_rounded,
      title: 'stats_status_breakdown'.tr,
      child: Row(
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
              children: slices
                  .map((s) => _LegendRow(slice: s, total: total))
                  .toList(),
            ),
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
            decoration:
                BoxDecoration(color: slice.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(slice.label,
                style: AppTypography.small
                    .copyWith(color: AppColors.textPrimary(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
          Text(_formatNumber(slice.value),
              style: AppTypography.smallBold
                  .copyWith(color: AppColors.textPrimary(context))),
          const SizedBox(width: 6),
          SizedBox(
            width: 32,
            child: Text('$pct%',
                textAlign: TextAlign.end,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary(context))),
          ),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  final List<_StatusSlice> slices;
  final int total;
  final String centerLabel;
  const _DonutChart(
      {required this.slices, required this.total, required this.centerLabel});

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
              trackColor:
                  Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_formatNumber(total),
                  style: AppTypography.title
                      .copyWith(color: AppColors.textPrimary(context))),
              Text(centerLabel,
                  style: AppTypography.badge
                      .copyWith(color: AppColors.textSecondary(context))),
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
  _DonutChartPainter(this.slices,
      {required this.strokeWidth, required this.trackColor});

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

// ─── رسم اتجاه المشاهدات (خط + منطقة) — CustomPainter بلا حزمة خارجية ──────

class _LineChart extends StatelessWidget {
  final List<ViewsPoint> points;
  const _LineChart({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text('stats_no_views_data'.tr,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary(context))),
        ),
      );
    }

    final maxV = points.map((p) => p.views).fold<int>(0, max);
    final first = points.first.date;
    final last = points.last.date;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 110,
          child: CustomPaint(
            painter: _LineChartPainter(
              points: points,
              color: AppColors.primary(context),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_axisLabel(first),
                style: AppTypography.badge
                    .copyWith(color: AppColors.textSecondary(context))),
            Text('${'stats_peak'.tr}: ${_formatNumber(maxV)}',
                style: AppTypography.badge
                    .copyWith(color: AppColors.textSecondary(context))),
            Text(_axisLabel(last),
                style: AppTypography.badge
                    .copyWith(color: AppColors.textSecondary(context))),
          ],
        ),
      ],
    );
  }

  String _axisLabel(String raw) {
    // 'yyyy-MM' → 'MMM'، 'yyyy-MM-dd' → 'd MMM'
    try {
      final parts = raw.split('-');
      if (parts.length == 2) return _formatMonthLabel(raw);
      final d = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      return DateFormat('d MMM').format(d);
    } catch (_) {
      return raw;
    }
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ViewsPoint> points;
  final Color color;
  _LineChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = max(1, points.map((p) => p.views).fold<int>(0, max));
    final n = points.length;
    final dx = n <= 1 ? 0.0 : size.width / (n - 1);

    Offset pointAt(int i) {
      final x = n <= 1 ? size.width / 2 : dx * i;
      final y = size.height - (points[i].views / maxV) * (size.height - 6) - 3;
      return Offset(x, y);
    }

    // خط الأساس
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..strokeWidth = 1,
    );

    final linePath = Path();
    final fillPath = Path()..moveTo(0, size.height);
    for (var i = 0; i < n; i++) {
      final p = pointAt(i);
      if (i == 0) {
        linePath.moveTo(p.dx, p.dy);
        fillPath.lineTo(p.dx, p.dy);
      } else {
        linePath.lineTo(p.dx, p.dy);
        fillPath.lineTo(p.dx, p.dy);
      }
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round,
    );

    // آخر نقطة مميّزة
    if (n > 0) {
      canvas.drawCircle(pointAt(n - 1), 3, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => true;
}

// ─── أعمدة الإنفاق الشهري ──────────────────────────────────────────────────

class _MiniBarChart extends StatelessWidget {
  final List<MonthSpendEntry> entries;
  const _MiniBarChart({required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty || entries.every((e) => e.paid == 0)) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text('stats_no_spend_data'.tr,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary(context))),
        ),
      );
    }

    final maxPaid =
        entries.map((e) => e.paid).fold<double>(0, (a, b) => a > b ? a : b);
    final primary = AppColors.primary(context);

    return Column(
      children: [
        SizedBox(
          height: 96,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: entries.map((e) {
              final ratio = maxPaid == 0 ? 0.0 : e.paid / maxPaid;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        e.paid > 0 ? _formatDecimal(e.paid) : '',
                        style: AppTypography.badge.copyWith(
                            color: AppColors.textSecondary(context)),
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        height: (ratio * 66).clamp(2.0, 66.0),
                        decoration: BoxDecoration(
                          color: e.paid > 0
                              ? primary
                              : primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: entries.map((e) {
            return Expanded(
              child: Text(
                _formatMonthLabel(e.month),
                textAlign: TextAlign.center,
                style: AppTypography.badge
                    .copyWith(color: AppColors.textSecondary(context)),
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── حالة الفشل ───────────────────────────────────────────────────────────

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
