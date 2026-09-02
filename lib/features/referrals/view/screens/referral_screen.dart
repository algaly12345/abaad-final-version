import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/referrals/controller/referral_controller.dart';
import 'package:abaad_flutter/features/referrals/data/models/referral_model.dart';
import 'package:abaad_flutter/features/referrals/view/screens/referral_payout_method_screen.dart';
import 'package:abaad_flutter/features/referrals/view/screens/referral_withdrawal_screen.dart';
import 'package:abaad_flutter/features/referrals/view/widgets/payout_form_widgets.dart';
import 'package:abaad_flutter/features/provider/view/screens/provider_upgrade_screen.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/helpers/date_converter.dart';
import 'package:abaad_flutter/shared/helpers/price_converter.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with SingleTickerProviderStateMixin {
  final bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
  bool _loadedForProvider = false;
  late final TabController _tabController = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    if (_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// برنامج الإحالة حصراً لمزوّدي الخدمة — نفس الشرط المستخدم لإظهار عنصر
  /// القائمة في DrawerMenu. هذا الفحص يمنع أي عميل عادي وصل للمسار مباشرة
  /// (رابط عميق، إعادة بناء الحالة، ...) من رؤية بياناته أو استدعاء
  /// endpoints الإحالة المحمية بـ provider.api على الباكند فتُرجع 403.
  bool _isProvider(UserController userController) =>
      userController.userInfoModel?.userType == 'provider';

  /// نفس المبدأ المطبَّق قبل AddPropertyServiceOfferScreen (راجع
  /// ServiceOfferController.hydrateEntityFromProvider وProviderUpgradeScreen):
  /// مزوّد قديم لم يُكمل هويته (رقم هوية فردي أو سجل تجاري) بعد لا يُعامَل
  /// كمزوّد فعلي هنا أيضاً — نفس isComplete المشتقة في ProviderIdentity.
  bool _hasCompleteIdentity(UserController userController) =>
      userController.userInfoModel?.provider?.isComplete ?? false;

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return _scaffold(context, const NotLoggedInScreen());
    }

    return GetBuilder<UserController>(
      builder: (userController) {
        if (userController.userInfoModel == null) {
          return _scaffold(context, const Center(child: CircularProgressIndicator()));
        }

        if (!_isProvider(userController)) {
          return _scaffold(context, _providerOnlyScreen(context));
        }

        if (!_hasCompleteIdentity(userController)) {
          // نفس تحويل AddPropertyServiceOfferScreen بالضبط لمزوّد لم يُكمل
          // هويته بعد: يُستبدَل بشاشة إكمال الهوية بدل عرض صفحة الإحالة.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.off(() => const ProviderUpgradeScreen());
          });
          return _scaffold(context, const Center(child: CircularProgressIndicator()));
        }

        if (!_loadedForProvider) {
          _loadedForProvider = true;
          Get.find<ReferralController>().loadAll();
        }

        return _scaffold(
          context,
          GetBuilder<ReferralController>(
            builder: (controller) {
              if (controller.isLoading && controller.summary == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _linkCard(context, controller),
                          const SizedBox(height: Spacing.lg),
                          _earningsCard(context, controller),
                          const SizedBox(height: Spacing.md),
                          _balanceCard(context, controller),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabBarDelegate(_tabBar(context)),
                  ),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _referralsTab(context, controller),
                    _withdrawalsTab(context, controller),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ─── هيكل الشاشة: نفس بنية لوحة تحكم المزوّد (my_services_screen) — خلفية
  // scaffoldBackground، شريط علوي مسطّح بحدّ سفلي وزرّ رجوع دائري ───────────
  Widget _scaffold(BuildContext context, Widget child) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _topBar(context),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(bottom: BorderSide(color: AppColors.divider(context))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider(context)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: AppColors.primary(context)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'referral_program'.tr,
              style: robotoBold.copyWith(fontSize: 17, color: AppColors.textPrimary(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBar(BuildContext context) {
    final primary = AppColors.primary(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(bottom: BorderSide(color: AppColors.divider(context))),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: primary,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: robotoBold.copyWith(fontSize: 13),
        unselectedLabelStyle: robotoRegular.copyWith(fontSize: 13),
        indicatorColor: primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'tab_referrals'.tr),
          Tab(text: 'tab_withdrawals'.tr),
        ],
      ),
    );
  }

  Widget _providerOnlyScreen(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 72, color: AppColors.textSecondary(context)),
            const SizedBox(height: 20),
            Text(
              'referral_provider_only_title'.tr,
              style: AppTypography.subtitle.copyWith(color: AppColors.textPrimary(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'referral_provider_only_desc'.tr,
              style: AppTypography.small.copyWith(color: AppColors.textSecondary(context)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─── بطاقة رابط الإحالة (Hero — مصمتة بلون التطبيق) ──────────────────────
  Widget _linkCard(BuildContext context, ReferralController controller) {
    final String code = controller.link?.referralCode ?? '';
    final String link = controller.link?.referralLink ?? '';
    final Color primary = AppColors.primary(context);

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.soft(blur: 16, opacity: 0.12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                'your_referral_link'.tr,
                style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  link.isEmpty ? '…' : link,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // رابط لاتيني: نفرض اتجاه LTR ومحاذاة يسار حتى يُقتطع من نهايته
                  // بثلاث نقاط طبيعية بدل ظهور "…" في بدايته داخل سياق RTL.
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  style: AppTypography.bodyBold.copyWith(color: Colors.white),
                ),
              ),
              if (link.isNotEmpty) ...[
                _linkIconButton(Icons.copy_rounded, () {
                  Clipboard.setData(ClipboardData(text: link));
                  Get.snackbar('', 'copied'.tr);
                }),
                Builder(
                  builder: (buttonContext) => _linkIconButton(Icons.ios_share_rounded, () {
                    final RenderBox? box = buttonContext.findRenderObject() as RenderBox?;
                    Share.share(
                      controller.link?.shareText ?? link,
                      subject: 'Abaad App',
                      sharePositionOrigin:
                          box != null ? box.localToGlobal(Offset.zero) & box.size : null,
                    );
                  }),
                ),
              ],
            ],
          ),
          if (code.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${'your_referral_code'.tr}: $code',
              style: AppTypography.caption.copyWith(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _linkIconButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: Colors.white, size: 20),
      onPressed: onTap,
    );
  }

  // ─── بطاقة الأرباح: إجمالي عمولات الإحالة + تفصيل يتصالح مع "متاح للسحب" ──
  // إجمالي عمولات الإحالة = قيد الحجز + قيد المراجعة + تم تحويلها + متاح للسحب.
  // هكذا لا يرى المستخدم رقمين متناقضين بلا رابط بينهما (5.00 متاحة / 0.00
  // متاح للسحب) — كل جزء يظهر أين ذهب.
  Widget _earningsCard(BuildContext context, ReferralController controller) {
    final ReferralSummaryModel? s = controller.summary;
    final double lifetime = s?.lifetimeEarned ?? 0;
    final double onHold = s?.pendingTotal ?? 0;
    final double underReview = s?.withdrawalUnderReviewTotal ?? 0;
    final double transferred = s?.withdrawalTransferredTotal ?? 0;

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.card(context),
        border: Border.all(color: AppColors.divider(context).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.workspace_premium_outlined,
                  size: 16, color: AppColors.primary(context)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'total_referral_earnings'.tr,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary(context)),
                ),
              ),
              Text(
                _commissionText(lifetime),
                style: AppTypography.bodyBold
                    .copyWith(color: AppColors.textPrimary(context)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            child: Divider(height: 1, color: AppColors.divider(context)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _miniStat(context, 'commissions_on_hold'.tr, onHold, AppColors.warning),
              _miniDivider(context),
              _miniStat(context, 'withdrawal_under_review'.tr, underReview, AppColors.info),
              _miniDivider(context),
              _miniStat(context, 'withdrawal_transferred'.tr, transferred, AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(BuildContext context, String label, double amount, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(_commissionText(amount),
              style: AppTypography.smallBold.copyWith(color: color)),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: AppTypography.badge
                .copyWith(fontSize: 10, color: AppColors.textSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _miniDivider(BuildContext context) => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        color: AppColors.divider(context),
      );

  // ─── بطاقة الرصيد المتاح + شريط التقدّم نحو الحد الأدنى + زرّ طلب السحب ───
  Widget _balanceCard(BuildContext context, ReferralController controller) {
    final double available = controller.summary?.availableBalance ?? 0;
    final double minPayout = controller.summary?.minPayoutLimit ?? 0;
    final Color primary = AppColors.primary(context);

    // زرّ الطلب يُفعَّل فقط عند بلوغ الحد الأدنى (أو أي رصيد موجب إن لم يكن
    // هناك حد أدنى). قبل ذلك يبقى الزرّ معطّلاً ويوضّح الشريط كم بقي.
    final bool canWithdraw = available > 0 && (minPayout <= 0 || available >= minPayout);

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_wallet_outlined,
                    color: primary, size: IconSpec.small),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'available_for_withdrawal'.tr,
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary(context)),
                    ),
                    const SizedBox(height: 2),
                    Text(_commissionText(available),
                        style: AppTypography.title.copyWith(color: primary)),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: canWithdraw
                      ? () => Get.to(() => ReferralWithdrawalScreen(
                            availableBalance: available,
                            minPayoutLimit: minPayout,
                          ))
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primary.withValues(alpha: 0.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ButtonSpec.radius)),
                  ),
                  child: Text('request_withdrawal'.tr,
                      style: AppTypography.smallBold.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // showHeader:false — المبلغ معروض في الصفّ أعلاه، فلا نكرّره هنا.
          WithdrawalMinimumProgress(
            available: available,
            minimum: minPayout,
            showHeader: false,
          ),
        ],
      ),
    );
  }

  /// عمولات الإحالة كثيراً ما تكون كسوراً صغيرة (10% من 49 ر.س = 4.9). التنسيق
  /// العام يقرّب لعدد صحيح فتظهر "0"، لذا نثبّت خانتين عشريتين هنا.
  String _commissionText(double amount) => PriceConverter.convertPrice(amount, decimalDigits: 2);

  // ─── تبويب "المُحالون" ─────────────────────────────────────────────────
  Widget _referralsTab(BuildContext context, ReferralController controller) {
    final List<ReferralItemModel>? items = controller.referrals;

    return RefreshIndicator(
      onRefresh: () => controller.loadAll(),
      child: items == null
          ? _centeredLoader()
          : items.isEmpty
              ? _emptyList(context, Icons.people_outline_rounded, 'no_referrals_yet'.tr)
              : ListView.builder(
                  key: const PageStorageKey('referrals_tab'),
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _referralCard(context, items[index]),
                ),
    );
  }

  Widget _referralCard(BuildContext context, ReferralItemModel item) {
    final String imageUrl =
        '${Get.find<SplashController>().configModel?.baseUrls?.customerImageUrl ?? ''}/${item.referredImage ?? ''}';
    final String statusRaw = item.commissionStatus ?? item.referralStatus;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: AppShadows.card(context),
      ),
      child: Row(
        children: [
          ClipOval(child: CustomImage(image: imageUrl, height: 44, width: 44, fit: BoxFit.cover)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.referredName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.smallBold.copyWith(color: AppColors.textPrimary(context)),
                ),
                if (item.packageName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.packageName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary(context)),
                  ),
                ],
                if (item.createdAt != null) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 11, color: AppColors.textSecondary(context)),
                      const SizedBox(width: 4),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          DateConverter.dateToDateAndTime(item.createdAt!),
                          style: AppTypography.badge.copyWith(
                              fontSize: 10, color: AppColors.textSecondary(context)),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.commissionAmount != null ? _commissionText(item.commissionAmount!) : '—',
                style: AppTypography.smallBold.copyWith(color: AppColors.textPrimary(context)),
              ),
              const SizedBox(height: 4),
              _statusBadge(statusRaw.toLowerCase().tr, _referralStatusColor(statusRaw)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── تبويب "السحوبات" ─────────────────────────────────────────────────
  Widget _withdrawalsTab(BuildContext context, ReferralController controller) {
    final List<WithdrawalRequestModel>? items = controller.withdrawals;

    return RefreshIndicator(
      onRefresh: () => controller.getWithdrawals(),
      child: ListView(
        key: const PageStorageKey('withdrawals_tab'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
        children: [
          _payoutAccountCard(context, controller),
          const SizedBox(height: 6),
          if (items == null)
            Padding(
              padding: EdgeInsets.only(top: Get.height * 0.14),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: Get.height * 0.1),
              child: _emptyState(context, Icons.receipt_long_outlined, 'no_withdrawals_yet'.tr),
            )
          else
            ...items.map((w) => _withdrawalCard(context, w)),
        ],
      ),
    );
  }

  // ─── بطاقة حساب الإيداع البنكي (تفتح شاشة تعديله المستقلة) ───────────────
  Widget _payoutAccountCard(BuildContext context, ReferralController controller) {
    final PayoutMethodModel? m = controller.payoutMethod;
    final Color primary = AppColors.primary(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: AppShadows.card(context),
        border: Border.all(color: AppColors.divider(context).withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        onTap: () => Get.to(() => const ReferralPayoutMethodScreen()),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.account_balance_outlined, color: primary, size: IconSpec.small),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'payout_account'.tr,
                      style: AppTypography.smallBold.copyWith(color: AppColors.textPrimary(context)),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      m == null ? 'payout_account_not_set'.tr : '${m.bankName} · ${_maskIban(m.iban)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: m == null ? AppColors.warning : AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Icon(Icons.chevron_left_rounded, color: AppColors.textSecondary(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _withdrawalCard(BuildContext context, WithdrawalRequestModel w) {
    final Color color = _withdrawalStatusColor(w.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _commissionText(w.amount),
                  style: AppTypography.bodyBold.copyWith(color: AppColors.textPrimary(context)),
                ),
              ),
              _statusBadge(w.status.toLowerCase().tr, color),
            ],
          ),
          if (w.iban != null && w.iban!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _cardMeta(context, Icons.account_balance_outlined,
                '${w.bankName ?? ''} · ${_maskIban(w.iban!)}'.trim()),
          ],
          if (w.requestedAt != null) ...[
            const SizedBox(height: 6),
            _dateMeta(context, Icons.schedule_rounded, 'requested_on'.tr, w.requestedAt!),
          ],
          if (w.processedAt != null) ...[
            const SizedBox(height: 4),
            _dateMeta(context, Icons.task_alt_rounded, 'processed_on'.tr, w.processedAt!),
          ],
        ],
      ),
    );
  }

  Widget _cardMeta(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary(context)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text, style: AppTypography.caption.copyWith(color: AppColors.textSecondary(context))),
        ),
      ],
    );
  }

  /// سطر "تسمية: تاريخ" — التاريخ في صندوق LTR منفصل حتى لا تُعاد ترتيب مقاطعه
  /// (YYYY-MM-DD hh:mm a) داخل الفقرة العربية فيظهر مبعثرًا.
  Widget _dateMeta(BuildContext context, IconData icon, String label, DateTime dt) {
    final style = AppTypography.caption.copyWith(color: AppColors.textSecondary(context));
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary(context)),
        const SizedBox(width: 5),
        Text('$label: ', style: style),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(DateConverter.dateToDateAndTimeAm(dt), style: style),
        ),
      ],
    );
  }

  // ─── عناصر مشتركة ─────────────────────────────────────────────────────
  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: AppTypography.badge.copyWith(fontSize: 10, color: color)),
    );
  }

  Widget _centeredLoader() => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: Get.height * 0.22),
          const Center(child: CircularProgressIndicator()),
        ],
      );

  Widget _emptyList(BuildContext context, IconData icon, String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: Get.height * 0.16),
        _emptyState(context, icon, message),
      ],
    );
  }

  Widget _emptyState(BuildContext context, IconData icon, String message) {
    final primary = AppColors.primary(context);
    return Center(
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary.withValues(alpha: 0.1), primary.withValues(alpha: 0.03)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(icon, size: 40, color: primary.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 18),
          Text(message, style: AppTypography.smallMedium.copyWith(color: AppColors.textSecondary(context))),
        ],
      ),
    );
  }

  /// يُخفي وسط الآيبان: SA00 •••• 1234.
  String _maskIban(String iban) {
    if (iban.length <= 8) return iban;
    return '${iban.substring(0, 4)} •••• ${iban.substring(iban.length - 4)}';
  }

  /// حالات طلب السحب: pending / approved / rejected / paid.
  Color _withdrawalStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'approved':
        return AppColors.info;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  /// حالة عمولة/إحالة المُحال.
  Color _referralStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'approved':
      case 'completed':
      case 'withdrawn':
        return AppColors.success;
      case 'cancelled':
      case 'rejected':
      case 'expired':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }
}

/// يثبّت شريط التبويبات أعلى المحتوى أثناء تمرير القوائم داخل NestedScrollView.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverTabBarDelegate(this.child);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) => oldDelegate.child != child;
}
