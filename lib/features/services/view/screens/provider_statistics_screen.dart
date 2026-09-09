import 'dart:math';

import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/estate/view/screens/estate_details.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/features/services/controller/provider_statistics_controller.dart';
import 'package:abaad_flutter/features/services/view/screens/service_details_screen.dart';
import 'package:abaad_flutter/features/services/data/models/provider_statistics_model.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart' show Estate;
import 'package:abaad_flutter/shared/helpers/price_converter.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/root_fallback_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// نخفي TextDirection من intl حتى لا تتعارض مع TextDirection في Flutter
// (المستخدمة في Directionality.of).
import 'package:intl/intl.dart' hide TextDirection;

String _formatNumber(num? v) => NumberFormat('#,##0').format(v ?? 0);

String _formatDecimal(num? v) => NumberFormat('#,##0.#').format(v ?? 0);

// اسم locale التطبيق الحالي (ar / en …) — بدونه يطبع intl أسماء الأشهر
// بالإنجليزية دائمًا حتى لو كان التطبيق عربيًا. بيانات locale محمّلة عبر
// flutter_localizations (نفس ما يجعل DateRangePicker يظهر بالعربية).
String? _localeName() => Get.locale?.languageCode;

// ─── تنسيق التواريخ في هذه الشاشة فقط: الباكند يرسل created_at كـ ISO كامل
// وexpiry_date كتاريخ فقط. DateTime.parse من Dart يُستخدم عمدًا لتقبّله عدد
// أرقام الكسور المتغيّر ولاحقة Z بأمان.
String _formatDateTime(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    return DateFormat('d MMM yyyy - HH:mm', _localeName())
        .format(DateTime.parse(raw).toLocal());
  } catch (_) {
    return raw;
  }
}

String _formatDateOnly(String? raw) {
  if (raw == null || raw.isEmpty) return '-';
  try {
    return DateFormat('d MMM yyyy', _localeName()).format(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}

// 'yyyy-MM' → 'MMM yy' (للأعمدة الشهرية) — يتقبّل 'yyyy-MM-dd' أيضًا احتياطًا.
String _formatMonthLabel(String ym) {
  try {
    final parts = ym.split('-');
    final d = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMM', _localeName()).format(d);
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

  Widget _buildTopBar(
      BuildContext context, ProviderStatisticsController controller) {
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // فلتر الفترة العام: يعيد تأطير كل التبويبات (المشاهدات/الأداء/
            // المالية/التغطية + عدّ العروض). 'مخصّص' يفتح منتقي المدى.
            _PeriodMenuButton(
              selected: controller.selectedPeriod,
              onSelect: (key) => key == 'custom'
                  ? _pickCustomRange(context, controller)
                  : controller.setPeriod(key),
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
      body: GetBuilder<ProviderStatisticsController>(
        builder: (controller) {
          final data = controller.data;
          return Column(
            children: [
              _buildTopBar(context, controller),
              Expanded(
                child: data == null
                    ? (controller.isLoading
                        ? const _DashboardSkeleton()
                        : _ErrorState(
                            onRetry: () => controller.loadDashboard()))
                    : Column(
                        children: [
                          _buildTabBar(context, primary),
                          if (controller.selectedPeriod != 'all')
                            _PeriodBanner(
                              label: _periodLabel(controller.selectedPeriod),
                              from: data.period?.from,
                              to: data.period?.to,
                              onClear: () => controller.setPeriod('all'),
                            ),
                          // شريط تقدّم رفيع أثناء إعادة الجلب (تبديل الفترة/
                          // إعادة المحاولة) — البيانات القديمة تبقى ظاهرة معتَّمة.
                          SizedBox(
                            height: 2,
                            child: controller.isLoading
                                ? const LinearProgressIndicator(minHeight: 2)
                                : null,
                          ),
                          Expanded(
                            child: Stack(
                              children: [
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 150),
                                  opacity: controller.isLoading ? 0.45 : 1.0,
                                  child: TabBarView(
                                    controller: _tabController,
                                    children: [
                                      _OverviewTab(
                                          data: data,
                                          onRefresh: controller.loadAll),
                                      _PerformanceTab(
                                          perf: data.performance,
                                          periodScoped:
                                              controller.selectedPeriod != 'all',
                                          onRefresh: controller.loadAll),
                                      _FinanceTab(
                                          finance: data.finance,
                                          subscriptions: data.subscriptions,
                                          periodScoped:
                                              controller.selectedPeriod != 'all',
                                          onRefresh: controller.loadAll),
                                      _CoverageTab(
                                          coverage: data.coverage,
                                          onRefresh: controller.loadAll),
                                      _PeriodTab(
                                        controller: controller,
                                        periodSummary: data.periodSummary,
                                        periodSubscriptions:
                                            data.periodSubscriptions,
                                        periodViews: data.periodViews,
                                      ),
                                    ],
                                  ),
                                ),
                                if (controller.isLoading)
                                  const Positioned(
                                    top: 12,
                                    left: 0,
                                    right: 0,
                                    child: Center(child: _RefreshingPill()),
                                  ),
                                if (controller.isLoading)
                                  const Positioned.fill(
                                      child: AbsorbPointer(
                                          child: SizedBox.expand())),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _periodLabel(String key) {
    switch (key) {
      case 'today':
        return 'period_today'.tr;
      case 'week':
        return 'period_week'.tr;
      case 'month':
        return 'period_month'.tr;
      case 'custom':
        return 'period_custom'.tr;
      default:
        return 'period_all'.tr;
    }
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
    final scoped = (data.period?.key ?? 'all') != 'all';

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _KpiGrid(tiles: [
            _KpiData(
                Icons.storefront_rounded,
                scoped ? 'stats_period_offers'.tr : 'stats_total_offers'.tr,
                _formatNumber(s?.totalOffersCount)),
            _KpiData(Icons.check_circle_rounded, 'active_status'.tr,
                _formatNumber(s?.activeOffersCount)),
            _KpiData(
                Icons.visibility_rounded,
                scoped ? 'stats_period_views'.tr : 'stats_total_views'.tr,
                _formatNumber(s?.totalViews)),
            // ظهور الإعلان داخل صفحات العقارات + عدد العقارات المختلفة (الوصول)
            // — منفصلان عن "المشاهدات" (فتح صفحة العرض نفسها).
            _KpiData(
                Icons.campaign_rounded,
                scoped ? 'stats_period_appearances'.tr : 'stats_appearances'.tr,
                _formatNumber(s?.totalAppearances)),
            _KpiData(
                Icons.holiday_village_rounded,
                scoped ? 'stats_period_reach'.tr : 'stats_reach'.tr,
                _formatNumber(s?.totalReach)),
            _KpiData(Icons.trending_up_rounded, 'stats_views_last_30d'.tr,
                _formatNumber(s?.viewsLast30d)),
            _KpiData(
                Icons.payments_rounded,
                scoped ? 'stats_period_spend'.tr : 'stats_lifetime_spend'.tr,
                PriceConverter.convertPrice(f?.lifetimePaid ?? 0)),
            _KpiData(Icons.error_outline_rounded, 'stats_outstanding'.tr,
                PriceConverter.convertPrice(f?.outstandingAmount ?? 0),
                highlight: (f?.outstandingAmount ?? 0) > 0),
          ]),
          const SizedBox(height: Spacing.sectionGap),
          _AccountCard(account: data.account),
          const SizedBox(height: Spacing.sectionGap),
          _StatusBreakdownCard(
            summary: s,
            centerLabel: scoped
                ? 'stats_period_offers'.tr
                : 'stats_total_offers'.tr,
          ),
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
          if (completeness < 100) ...[
            const SizedBox(height: Spacing.md),
            _CompleteProfileAction(missing: _missingProfileItems(a)),
          ],
        ],
      ),
    );
  }

  // نفس قائمة الفحوص العشرة في الباكند (ProviderReportService::accountProfile).
  List<String> _missingProfileItems(AccountProfile a) {
    final items = <String>[];
    if (!a.hasImage) items.add('stats_missing_image'.tr);
    if (!a.emailVerified) items.add('stats_missing_email'.tr);
    if (!a.accountVerification) items.add('stats_missing_nafath'.tr);
    if (!a.phoneVerified) items.add('stats_missing_phone'.tr);
    if (!a.hasUnifiedNumber && !a.hasFalLicense) {
      items.add('stats_missing_unified_or_fal'.tr);
    }
    if ((a.commercialRegistrationNo ?? '').isEmpty) {
      items.add('stats_missing_cr'.tr);
    }
    if ((a.socialLinksCount ?? 0) == 0) items.add('stats_missing_social'.tr);
    return items;
  }
}

class _CompleteProfileAction extends StatelessWidget {
  final List<String> missing;
  const _CompleteProfileAction({required this.missing});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('stats_complete_profile_hint'.tr,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary(context))),
          if (missing.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('${'stats_missing_prefix'.tr}: ${missing.join('، ')}',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary(context))),
          ],
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(RouteHelper.getUpdateProfileRoute()),
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: Text('stats_complete_profile_cta'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium)),
              ),
            ),
          ),
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
  final bool periodScoped;
  final Future<void> Function() onRefresh;
  const _PerformanceTab({
    required this.perf,
    required this.onRefresh,
    this.periodScoped = false,
  });

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
                        child: _MiniStat(
                            periodScoped
                                ? 'stats_period_views'.tr
                                : 'stats_total_views'.tr,
                            _formatNumber(p?.totalViews))),
                    Expanded(
                        child: _MiniStat('stats_views_last_7d'.tr,
                            _formatNumber(p?.viewsLast7d))),
                    Expanded(
                        child: _MiniStat('stats_views_last_30d'.tr,
                            _formatNumber(p?.viewsLast30d))),
                  ],
                ),
                const Divider(height: Spacing.sectionGap),
                // ظهور الإعلان داخل صفحات العقارات، والوصول (عقارات مختلفة)،
                // مقابل إجمالي العقارات المؤهّلة لظهوره.
                Row(
                  children: [
                    Expanded(
                        child: _MiniStat(
                            periodScoped
                                ? 'stats_period_appearances'.tr
                                : 'stats_appearances'.tr,
                            _formatNumber(p?.totalAppearances))),
                    Expanded(
                        child: _MiniStat(
                            periodScoped
                                ? 'stats_period_reach'.tr
                                : 'stats_reach'.tr,
                            _formatNumber(p?.totalReach))),
                    Expanded(
                        child: _MiniStat('stats_eligible_estates'.tr,
                            _formatNumber(p?.totalEligibleEstates))),
                  ],
                ),
                if ((p?.totalViews ?? 0) == 0 &&
                    (p?.totalAppearances ?? 0) == 0) ...[
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
            type: 'zone',
            entries: p?.byZone ?? const [],
          ),
          const SizedBox(height: Spacing.sectionGap),
          _RankedDimensionSection(
            title: 'stats_views_by_category'.tr,
            icon: Icons.category_outlined,
            type: 'category',
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

// ─── نمط شارة حالة العرض (مشترك بين القائمة ونوافذ التفاصيل) ──────────────

({String label, Color color}) _offerBucketStyle(OfferViewsEntry o) {
  // نعتمد status_bucket من الباكند (نفس تصنيف الدونات). fallback لمنطق status
  // وحده فقط للتوافق مع نسخة باكند أقدم لا ترسله.
  final bucket = o.statusBucket ??
      (o.status == 'accept' && !o.isExpired
          ? 'active'
          : o.status == 'pending'
              ? 'pending'
              : o.status == 'rejected'
                  ? 'rejected'
                  : 'expired');
  switch (bucket) {
    case 'active':
      return (label: 'active_status'.tr, color: Colors.green.shade600);
    case 'pending':
      return (label: 'under_review'.tr, color: Colors.orange.shade600);
    case 'unpaid':
      return (label: 'unpaid_status'.tr, color: Colors.deepOrange.shade600);
    case 'rejected':
      return (label: 'rejected_status'.tr, color: Colors.red.shade600);
    default:
      return (label: 'expired_status'.tr, color: Colors.grey.shade600);
  }
}

// ─── نوافذ التفاصيل (درِل-داون) ──────────────────────────────────────────

IconData _dimensionIcon(String type) {
  switch (type) {
    case 'zone':
      return Icons.map_outlined;
    case 'category':
      return Icons.category_outlined;
    case 'service_type':
      return Icons.handyman_outlined;
    default:
      return Icons.list_alt_outlined;
  }
}

/// سهم "افتح هذا العنصر": في العربية يشير يمينًا (نحو العنوان)، وفي الإنجليزية
/// يسارًا. نعتمد لغة التطبيق (Get.locale) لا Directionality.of فقط — الأخيرة
/// قد تعود LTR داخل بعض الطبقات (نوافذ modal) رغم أن التطبيق عربي.
bool _isRtl(BuildContext context) {
  if (Directionality.of(context) == TextDirection.rtl) return true;
  return Bidi.isRtlLanguage(Get.locale?.languageCode ?? '');
}

IconData _forwardChevron(BuildContext context) => _isRtl(context)
    ? Icons.chevron_right_rounded
    : Icons.chevron_left_rounded;

/// عنوان قسم صغير داخل نافذة درِل-داون البُعد (أيقونة + نص).
Widget _dimSectionLabel(BuildContext context, IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 15, color: AppColors.textSecondary(context)),
      const SizedBox(width: 6),
      Text(text,
          style: AppTypography.smallBold
              .copyWith(color: AppColors.textPrimary(context))),
    ],
  );
}

void _showDimensionSheet(
    BuildContext context, String type, int? id, String title) {
  if (id == null) return;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => _DimensionDetailSheet(type: type, id: id, title: title),
  );
}

// عناصر بنفس قالب شاشة "طلب سحب" (مسطّح/فاتح، بلا تدرّجات داكنة): شارة أيقونة
// مصبوغة، رأس فاتح، بانر معلومات، شارة حالة، حالة فارغة.

/// شارة أيقونة داخل مربّع مصبوغ بلون التطبيق — نفس ReferralWithdrawal._sectionTitle.
Widget _iconBadge(BuildContext context, IconData icon, {double size = 30}) {
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: AppColors.primary(context).withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppRadius.small),
    ),
    child: Icon(icon, size: size * 0.5, color: AppColors.primary(context)),
  );
}

/// رأس فاتح لنافذة/ورقة سفلية: شارة أيقونة + عنوان (+ سطر ثانوي) + زر إغلاق،
/// مع فاصل سفلي — نفس هوية شريط شاشة "طلب سحب".
Widget _lightHeader(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  VoidCallback? onClose,
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.surface(context),
      border:
          Border(bottom: BorderSide(color: AppColors.divider(context))),
    ),
    padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _iconBadge(context, icon, size: 34),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: AppTypography.smallBold.copyWith(
                      fontSize: 15.5,
                      color: AppColors.textPrimary(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(subtitle,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context))),
              ],
            ],
          ),
        ),
        if (onClose != null)
          IconButton(
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.close_rounded,
                size: 20, color: AppColors.textSecondary(context)),
          ),
      ],
    ),
  );
}

/// بانر معلومات مسطّح — نفس ReferralWithdrawal._balanceProgress
/// (خلفية لون التطبيق 6٪ + حدّ 20٪).
Widget _infoBanner(BuildContext context, {required List<Widget> children}) {
  final primary = AppColors.primary(context);
  return Container(
    padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md, vertical: Spacing.md),
    decoration: BoxDecoration(
      color: primary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppRadius.medium),
      border: Border.all(color: primary.withValues(alpha: 0.2)),
    ),
    child: Row(children: children),
  );
}

Widget _bannerStat(BuildContext context, IconData icon, String value,
    String label) {
  return Expanded(
    child: Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary(context)),
        const SizedBox(width: 8),
        Flexible(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary(context)),
              children: [
                TextSpan(
                  text: '$value ',
                  style: AppTypography.smallBold
                      .copyWith(color: AppColors.textPrimary(context)),
                ),
                TextSpan(text: label),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

/// شارة حالة بحدّ خفيف — نفس نمط شاشة الإحالة/السحب.
Widget _premiumBadge(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Text(label,
        style: AppTypography.badge
            .copyWith(color: color, fontWeight: FontWeight.w600)),
  );
}

/// حالة فارغة مسطّحة: دائرة مصبوغة خفيفة + أيقونة + رسالة.
Widget _emptyState(BuildContext context, IconData icon, String message) {
  final primary = AppColors.primary(context);
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withValues(alpha: 0.08),
          ),
          child: Icon(icon, size: 36, color: primary.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 16),
        Text(message,
            textAlign: TextAlign.center,
            style: AppTypography.smallMedium
                .copyWith(color: AppColors.textSecondary(context))),
      ],
    ),
  );
}

/// نافذة تفاصيل عرض واحد (من قائمة "المشاهدات لكل خدمة") — تصميم مميّز.
class _OfferDetailDialog extends StatelessWidget {
  final OfferViewsEntry entry;
  const _OfferDetailDialog({required this.entry});

  @override
  Widget build(BuildContext context) {
    final b = _offerBucketStyle(entry);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.divider(context)),
          boxShadow: AppShadows.soft(blur: 18, opacity: 0.08),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _lightHeader(
              context,
              icon: Icons.design_services_rounded,
              title: entry.title ?? '-',
              onClose: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg,
                  Spacing.lg, Spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _premiumBadge(b.label, b.color),
                  ),
                  const SizedBox(height: Spacing.md),
                  _DetailRow(
                    icon: Icons.visibility_rounded,
                    label: 'stats_period_views'.tr,
                    value: _formatNumber(entry.views),
                    emphasize: true,
                  ),
                  _DetailRow(
                    icon: Icons.all_inclusive_rounded,
                    label: 'stats_all_time'.tr,
                    value: _formatNumber(entry.viewsAllTime),
                  ),
                  // ظهور هذا الإعلان داخل صفحات العقارات + عدد العقارات
                  // المختلفة التي ظهر فيها (الوصول).
                  _DetailRow(
                    icon: Icons.campaign_rounded,
                    label: 'stats_appearances'.tr,
                    value: _formatNumber(entry.appearances),
                  ),
                  _DetailRow(
                    icon: Icons.holiday_village_rounded,
                    label: 'stats_reach'.tr,
                    value: _formatNumber(entry.reach),
                  ),
                  if (entry.createdAt != null)
                    _DetailRow(
                      icon: Icons.add_circle_outline_rounded,
                      label: 'created_at_label'.tr,
                      value: _formatDateOnly(entry.createdAt),
                    ),
                  if (entry.expiryDate != null)
                    _DetailRow(
                      icon: Icons.event_busy_outlined,
                      label: 'stats_expiry_date'.tr,
                      value: _formatDateOnly(entry.expiryDate),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.lg, Spacing.xs, Spacing.lg, Spacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: DSSecondaryButton(
                      label: 'stats_close'.tr,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  if (entry.offerId != null) ...[
                    const SizedBox(width: Spacing.sm),
                    Expanded(
                      flex: 2,
                      child: DSPrimaryButton(
                        label: 'stats_open_service'.tr,
                        icon: _forwardChevron(context),
                        onPressed: () {
                          Navigator.pop(context);
                          Get.to(
                            () => ServiceDetailsScreen(
                                serviceId: entry.offerId!),
                            transition: Transition.cupertino,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: emphasize
            ? primary.withValues(alpha: 0.06)
            : AppColors.background(context),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: emphasize
              ? primary.withValues(alpha: 0.25)
              : AppColors.divider(context).withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: primary.withValues(alpha: 0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary(context))),
          ),
          Text(value,
              style:
                  (emphasize ? AppTypography.bodyBold : AppTypography.smallBold)
                      .copyWith(color: AppColors.textPrimary(context))),
        ],
      ),
    );
  }
}

class _DimOfferRow extends StatelessWidget {
  final OfferViewsEntry entry;
  const _DimOfferRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final b = _offerBucketStyle(entry);
    return InkWell(
      onTap: entry.offerId == null
          ? null
          : () {
              Navigator.pop(context);
              Get.to(
                () => ServiceDetailsScreen(serviceId: entry.offerId!),
                transition: Transition.cupertino,
              );
            },
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.divider(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(entry.title ?? '-',
                      style: AppTypography.smallBold
                          .copyWith(color: AppColors.textPrimary(context)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                Icon(Icons.visibility_outlined,
                    size: 13, color: AppColors.textSecondary(context)),
                const SizedBox(width: 3),
                Text(_formatNumber(entry.views),
                    style: AppTypography.smallBold
                        .copyWith(color: AppColors.primary(context))),
                const SizedBox(width: 4),
                Icon(_forwardChevron(context),
                    size: 18, color: AppColors.textSecondary(context)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _premiumBadge(b.label, b.color),
                if (entry.viewsAllTime != null &&
                    entry.viewsAllTime != entry.views)
                  _InfoBit(
                      icon: Icons.all_inclusive_rounded,
                      text:
                          '${'stats_all_time'.tr}: ${_formatNumber(entry.viewsAllTime)}'),
                if (entry.createdAt != null)
                  _InfoBit(
                      icon: Icons.add_circle_outline_rounded,
                      text: _formatDateOnly(entry.createdAt)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// صف عقار واحد ضمن "العقارات المُغطّاة" — الضغط يفتح تفاصيل العقار.
class _DimEstateRow extends StatelessWidget {
  final DimensionEstate entry;
  const _DimEstateRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cat = entry.displayCategory;
    final loc = [entry.city, entry.districts]
        .where((s) => (s ?? '').trim().isNotEmpty)
        .join(' · ');
    final shown = (entry.appearances ?? 0) > 0;

    return InkWell(
      onTap: entry.estateId == null
          ? null
          : () {
              Navigator.pop(context);
              Get.to(
                () => EstateDetails(estate: Estate(id: entry.estateId!)),
                transition: Transition.cupertino,
              );
            },
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        margin: const EdgeInsets.only(bottom: Spacing.sm),
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.divider(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (entry.title?.isNotEmpty ?? false)
                        ? entry.title!
                        : (cat.isNotEmpty ? cat : '-'),
                    style: AppTypography.smallBold
                        .copyWith(color: AppColors.textPrimary(context)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if ((entry.views ?? 0) > 0) ...[
                  Icon(Icons.visibility_outlined,
                      size: 13, color: AppColors.textSecondary(context)),
                  const SizedBox(width: 3),
                  Text(_formatNumber(entry.views),
                      style: AppTypography.smallBold
                          .copyWith(color: AppColors.textSecondary(context))),
                ],
                const SizedBox(width: 4),
                Icon(_forwardChevron(context),
                    size: 18, color: AppColors.textSecondary(context)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: Spacing.sm,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (cat.isNotEmpty)
                  _premiumBadge(cat, AppColors.primary(context)),
                if (loc.isNotEmpty)
                  _InfoBit(icon: Icons.place_outlined, text: loc),
                if ((entry.price ?? 0) > 0)
                  _InfoBit(
                      icon: Icons.sell_outlined,
                      text: PriceConverter.convertPrice(entry.price ?? 0.0)),
                if (shown)
                  _InfoBit(
                      icon: Icons.campaign_rounded,
                      text:
                          '${'stats_appearances'.tr}: ${_formatNumber(entry.appearances)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// نافذة سفلية: كل عروض المزوّد ضمن منطقة/تصنيف/نوع خدمة واحد.
class _DimensionDetailSheet extends StatefulWidget {
  final String type;
  final int id;
  final String title;
  const _DimensionDetailSheet(
      {required this.type, required this.id, required this.title});

  @override
  State<_DimensionDetailSheet> createState() => _DimensionDetailSheetState();
}

class _DimensionDetailSheetState extends State<_DimensionDetailSheet> {
  // يُنشأ مرّة واحدة — لا داخل builder الذي يُعاد بناؤه مع كل سحب.
  late final Future<DimensionOffers?> _future = Get
      .find<ProviderStatisticsController>()
      .fetchDimensionOffers(widget.type, widget.id);

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.of(context).size.height * 0.85;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius:
          const BorderRadius.vertical(top: Radius.circular(AppRadius.extraLarge)),
      child: Container(
        color: AppColors.background(context),
        constraints: BoxConstraints(maxHeight: maxH),
        child: FutureBuilder<DimensionOffers?>(
          future: _future,
          builder: (context, snap) {
            final loading = snap.connectionState == ConnectionState.waiting;
            final d = snap.data;
            final offers = d?.offers ?? const <OfferViewsEntry>[];

            Widget body;
            if (loading) {
              body = _Shimmer(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(Spacing.lg),
                  children: List.generate(
                    5,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: Spacing.sm),
                      child: _SkeletonBox(height: 72, radius: 12),
                    ),
                  ),
                ),
              );
            } else if (d == null) {
              body = Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: _emptyState(context, Icons.wifi_off_rounded,
                    'stats_dimension_load_error'.tr),
              );
            } else if (offers.isEmpty && d.coveredEstates.isEmpty) {
              body = Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: _emptyState(context, Icons.inbox_rounded,
                    'stats_no_services_in_period'.tr),
              );
            } else {
              body = ListView(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(
                    Spacing.lg, Spacing.lg, Spacing.lg, 20 + bottomInset),
                children: [
                  _infoBanner(context, children: [
                    _bannerStat(context, Icons.visibility_rounded,
                        _formatNumber(d.totalViews), 'stats_total_views'.tr),
                    _bannerStat(context, Icons.campaign_rounded,
                        _formatNumber(d.totalAppearances),
                        'stats_appearances'.tr),
                    _bannerStat(context, Icons.holiday_village_rounded,
                        _formatNumber(d.totalReach), 'stats_reach'.tr),
                  ]),
                  const SizedBox(height: Spacing.sm),
                  Text('stats_dimension_hint'.tr,
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(context))),
                  if (offers.isNotEmpty) ...[
                    const SizedBox(height: Spacing.md),
                    _dimSectionLabel(context, Icons.design_services_rounded,
                        '${'stats_dim_services_header'.tr} (${_formatNumber(offers.length)})'),
                    const SizedBox(height: Spacing.sm),
                    ...offers.map((o) => _DimOfferRow(entry: o)),
                  ],
                  // العقارات التي تغطّيها إعلانات المزوّد ضمن هذه المنطقة/التصنيف.
                  if (d.coveredEstates.isNotEmpty) ...[
                    const SizedBox(height: Spacing.md),
                    _dimSectionLabel(context, Icons.holiday_village_outlined,
                        '${'stats_covered_estates'.tr} (${_formatNumber(d.coveredEstatesCount)})'),
                    const SizedBox(height: Spacing.sm),
                    ...d.coveredEstates.map((e) => _DimEstateRow(entry: e)),
                    if (d.coveredEstatesCount > d.coveredEstates.length) ...[
                      const SizedBox(height: 2),
                      Text(
                        'stats_showing_top_n'.trParams(
                            {'n': _formatNumber(d.coveredEstates.length)}),
                        style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ],
                ],
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _lightHeader(
                  context,
                  icon: _dimensionIcon(widget.type),
                  title: widget.title,
                  subtitle: _dimensionTypeLabel(widget.type),
                  onClose: () => Navigator.pop(context),
                ),
                Flexible(child: body),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _dimensionTypeLabel(String type) {
  switch (type) {
    case 'zone':
      return 'stats_dim_zone'.tr;
    case 'category':
      return 'stats_dim_category'.tr;
    case 'service_type':
      return 'stats_dim_service_type'.tr;
    default:
      return '';
  }
}

// ─── المشاهدات لكل عرض ─────────────────────────────────────────────────────

class _OfferViewsSection extends StatelessWidget {
  final List<OfferViewsEntry> entries;
  const _OfferViewsSection({required this.entries});

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
                final bucket = _offerBucketStyle(o);
                final ratio =
                    maxViews == 0 ? 0.0 : (o.views ?? 0) / maxViews;
                return InkWell(
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (_) => _OfferDetailDialog(entry: o),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: Spacing.md, top: 2),
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
                                const SizedBox(width: 4),
                                Icon(Icons.info_outline_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary(context)),
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
                                // "كل الوقت" يُعرض فقط حين يختلف عن مشاهدات الفترة
                                // (في العرض الافتراضي بلا فترة يتطابقان دائمًا).
                                if (o.viewsAllTime != null &&
                                    o.viewsAllTime != o.views) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '${'stats_all_time'.tr}: ${_formatNumber(o.viewsAllTime)}',
                                    style: AppTypography.caption.copyWith(
                                        color:
                                            AppColors.textSecondary(context)),
                                  ),
                                ],
                              ],
                            ),
                            // ظهور هذا الإعلان داخل صفحات العقارات + عدد
                            // العقارات المختلفة التي ظهر فيها (الوصول).
                            if ((o.appearances ?? 0) > 0 ||
                                (o.reach ?? 0) > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                '${'stats_appearances'.tr}: ${_formatNumber(o.appearances)}'
                                '  ·  ${'stats_reach'.tr}: ${_formatNumber(o.reach)}',
                                style: AppTypography.caption.copyWith(
                                    color: AppColors.textSecondary(context)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
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
  final String type; // zone | category — لدرِل-داون التفاصيل

  const _RankedDimensionSection({
    required this.title,
    required this.icon,
    required this.entries,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final rows = entries.take(6).toList();
    final maxViews = rows.isEmpty
        ? 0
        : rows
            .map((e) => e.totalViews ?? 0)
            .reduce((a, b) => a > b ? a : b);

    return _Card(
      icon: icon,
      title: title,
      child: rows.isEmpty
          ? Text('stats_no_views_data'.tr,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary(context)))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.sm),
                  child: Text('stats_multi_dimension_note'.tr,
                      style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary(context))),
                ),
                ...rows.asMap().entries.map((indexed) {
                  final rank = indexed.key + 1;
                  final e = indexed.value;
                  final name = e.nameAr ?? e.name ?? '-';
                  final views = e.totalViews ?? 0;
                  final ratio = maxViews == 0 ? 0.0 : views / maxViews;
                  return InkWell(
                    onTap: () => _showDimensionSheet(
                        context, type, e.id, name),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                    padding: const EdgeInsets.only(
                        bottom: Spacing.md, top: 2),
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
                                  child: Text(name,
                                      style: AppTypography.small.copyWith(
                                          color:
                                              AppColors.textPrimary(context)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Text(_formatNumber(views),
                                    style: AppTypography.smallBold.copyWith(
                                        color:
                                            AppColors.textPrimary(context))),
                                const SizedBox(width: 4),
                                Icon(Icons.info_outline_rounded,
                                    size: 14,
                                    color: AppColors.textSecondary(context)),
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
                                Text('${e.offersCount ?? 0}',
                                    style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(
                                            context))),
                                // "ظهر في N شقة من M مؤهلة" — متاح لتوزيع
                                // المناطق فقط (by_zone).
                                if (type == 'zone' &&
                                    ((e.reach ?? 0) > 0 ||
                                        (e.eligibleEstates ?? 0) > 0)) ...[
                                  const SizedBox(width: 10),
                                  Icon(Icons.holiday_village_outlined,
                                      size: 12,
                                      color:
                                          AppColors.textSecondary(context)),
                                  const SizedBox(width: 3),
                                  Text(
                                    'stats_reach_of_eligible'.trParams({
                                      'n': _formatNumber(e.reach),
                                      'm': _formatNumber(e.eligibleEstates),
                                    }),
                                    style: AppTypography.caption.copyWith(
                                        color: AppColors.textSecondary(
                                            context)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                  );
                }),
              ],
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
  final bool periodScoped;
  final Future<void> Function() onRefresh;
  const _FinanceTab({
    required this.finance,
    required this.subscriptions,
    required this.onRefresh,
    this.periodScoped = false,
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
            _KpiData(
                Icons.payments_rounded,
                periodScoped
                    ? 'stats_period_spend'.tr
                    : 'stats_lifetime_spend'.tr,
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

    // "الاشتراك الحالي" يحدّده الباكند (أحدث مدفوع غير منتهٍ) — لا مجرد أحدث
    // صف، وإلا ظهرت مسودة "إضافة خدمة" مهجورة كاشتراك حالي.
    final current = list.isEmpty
        ? null
        : list.firstWhere((e) => e.isCurrent, orElse: () => list.first);
    final history = current == null
        ? <SubscriptionEntry>[]
        : list.where((e) => e != current).toList();

    return _Card(
      icon: Icons.receipt_long_outlined,
      title: 'stats_subscription_section'.tr,
      child: current == null
          ? Text('stats_no_subscription'.tr,
              style: AppTypography.small
                  .copyWith(color: AppColors.textSecondary(context)))
          : Column(
              children: [
                _SubscriptionCard(
                  entry: current,
                  isCurrent: true,
                  paymentColor: _paymentColor(current.paymentStatus),
                  paymentLabel: _paymentLabel(current.paymentStatus),
                ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: Spacing.lg),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('stats_subscription_history'.tr,
                        style: AppTypography.smallMedium.copyWith(
                            color: AppColors.textSecondary(context))),
                  ),
                  const SizedBox(height: Spacing.sm),
                  ...history.map((e) => Padding(
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
            type: 'zone',
            entries: c?.zones ?? const [],
          ),
          const SizedBox(height: Spacing.sectionGap),
          _CoverageListSection(
            title: 'stats_coverage_categories'.tr,
            icon: Icons.category_outlined,
            type: 'category',
            entries: c?.categories ?? const [],
          ),
          const SizedBox(height: Spacing.sectionGap),
          _CoverageListSection(
            title: 'stats_coverage_service_types'.tr,
            icon: Icons.handyman_outlined,
            type: 'service_type',
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
  final String type; // zone | category | service_type
  final List<CoverageEntry> entries;
  const _CoverageListSection({
    required this.title,
    required this.icon,
    required this.type,
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
                final name = e.nameAr ?? e.name ?? '-';
                return InkWell(
                  onTap: () =>
                      _showDimensionSheet(context, type, e.id, name),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Icon(Icons.circle,
                            size: 6, color: AppColors.primary(context)),
                        const SizedBox(width: Spacing.sm),
                        Expanded(
                          child: Text(name,
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
                        const SizedBox(width: 4),
                        Icon(Icons.info_outline_rounded,
                            size: 14,
                            color: AppColors.textSecondary(context)),
                      ],
                    ),
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

  const _PeriodTab({
    required this.controller,
    required this.periodSummary,
    required this.periodSubscriptions,
    required this.periodViews,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.loadAll,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
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

// ─── فلتر الفترة العام (الشريط العلوي) ────────────────────────────────────

const _kPeriodOptions = [
  ('all', 'period_all'),
  ('today', 'period_today'),
  ('week', 'period_week'),
  ('month', 'period_month'),
  ('custom', 'period_custom'),
];

class _PeriodMenuButton extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _PeriodMenuButton({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final active = selected != 'all';
    final label = _kPeriodOptions
        .firstWhere((o) => o.$1 == selected, orElse: () => _kPeriodOptions.first)
        .$2
        .tr;

    return PopupMenuButton<String>(
      tooltip: 'stats_period_filter'.tr,
      onSelected: onSelect,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium)),
      itemBuilder: (context) => _kPeriodOptions
          .map((o) => PopupMenuItem<String>(
                value: o.$1,
                child: Row(
                  children: [
                    Icon(
                      o.$1 == selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: 16,
                      color: o.$1 == selected
                          ? primary
                          : AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 8),
                    Text(o.$2.tr),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: active ? primary : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(
              color: active ? primary : Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded,
                size: 15,
                color: active ? Colors.white : AppColors.textSecondary(context)),
            const SizedBox(width: 6),
            Text(label,
                style: AppTypography.captionMedium.copyWith(
                    color: active
                        ? Colors.white
                        : AppColors.textPrimary(context))),
            Icon(Icons.arrow_drop_down_rounded,
                size: 18,
                color: active ? Colors.white : AppColors.textSecondary(context)),
          ],
        ),
      ),
    );
  }
}

class _PeriodBanner extends StatelessWidget {
  final String label;
  final String? from;
  final String? to;
  final VoidCallback onClear;
  const _PeriodBanner({
    required this.label,
    required this.from,
    required this.to,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final range = (from != null && to != null)
        ? ' · ${_formatDateOnly(from)} – ${_formatDateOnly(to)}'
        : '';

    return Container(
      width: double.infinity,
      color: primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Icon(Icons.event_note_rounded, size: 15, color: primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${'stats_period_scope_label'.tr}: $label$range',
              style: AppTypography.caption
                  .copyWith(color: AppColors.textPrimary(context)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('stats_period_clear'.tr,
                style: AppTypography.captionMedium.copyWith(color: primary)),
          ),
        ],
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
          if (list.isEmpty && isLoading)
            _Shimmer(
              child: Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: i == 2 ? 0 : Spacing.sm),
                    child: const _SkeletonBox(height: 74, radius: 10),
                  ),
                ),
              ),
            )
          else if (list.isEmpty && !isLoading)
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
          if (isLoading && list.isNotEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: Spacing.md),
              child: Center(
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))),
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
  final String centerLabel;
  const _StatusBreakdownCard(
      {required this.summary, this.centerLabel = ''});

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
            centerLabel: centerLabel.isEmpty
                ? 'stats_total_offers'.tr
                : centerLabel,
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
      return DateFormat('d MMM', _localeName()).format(d);
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

// ─── حالات التحميل (هيكل عظمي + مؤشّر إعادة الجلب) ────────────────────────

/// نبض خفيف يلفّ عناصر الهيكل العظمي — بديل بسيط عن حزمة shimmer.
class _Shimmer extends StatefulWidget {
  final Widget child;
  const _Shimmer({required this.child});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;
  const _SkeletonBox({required this.height, this.width, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.textSecondary(context).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final int lines;
  const _SkeletonCard({this.lines = 4});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(height: 16, width: 150),
          const SizedBox(height: Spacing.md),
          for (var i = 0; i < lines; i++) ...[
            _SkeletonBox(height: 11, width: i.isEven ? double.infinity : 220),
            const SizedBox(height: 11),
          ],
        ],
      ),
    );
  }
}

/// يُعرض في أول تحميل بدل مؤشّر دائري وحيد — يحاكي تخطيط تبويب "نظرة عامة".
class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _Shimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LayoutBuilder(builder: (context, c) {
            final w = (c.maxWidth - Spacing.md) / 2;
            return Wrap(
              spacing: Spacing.md,
              runSpacing: Spacing.md,
              children: List.generate(
                6,
                (_) => SizedBox(
                  width: w,
                  child: Container(
                    padding: const EdgeInsets.all(Spacing.md),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.large),
                      border:
                          Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBox(height: 30, width: 30, radius: 9),
                        SizedBox(height: Spacing.sm),
                        _SkeletonBox(height: 18, width: 70),
                        SizedBox(height: 6),
                        _SkeletonBox(height: 11, width: 110),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: Spacing.sectionGap),
          const _SkeletonCard(lines: 4),
          const SizedBox(height: Spacing.sectionGap),
          const _SkeletonCard(lines: 5),
        ],
      ),
    );
  }
}

/// حبّة "جارٍ التحديث…" تطفو فوق البيانات القديمة أثناء إعادة الجلب.
class _RefreshingPill extends StatelessWidget {
  const _RefreshingPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppColors.primary(context)),
          ),
          const SizedBox(width: 8),
          Text('stats_updating'.tr,
              style: AppTypography.captionMedium
                  .copyWith(color: AppColors.textPrimary(context))),
        ],
      ),
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
