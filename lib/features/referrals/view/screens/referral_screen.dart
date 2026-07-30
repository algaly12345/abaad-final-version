import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/referrals/controller/referral_controller.dart';
import 'package:abaad_flutter/features/referrals/data/models/referral_model.dart';
import 'package:abaad_flutter/features/referrals/view/widgets/referral_withdrawal_sheet.dart';
import 'package:abaad_flutter/features/provider/view/screens/provider_upgrade_screen.dart';
import 'package:abaad_flutter/shared/helpers/price_converter.dart';
import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_app_bar.dart';
import 'package:abaad_flutter/shared/widgets/custom_button.dart';
import 'package:abaad_flutter/shared/widgets/no_data_screen.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:abaad_flutter/shared/widgets/title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
  bool _loadedForProvider = false;

  @override
  void initState() {
    super.initState();
    if (_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
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
      return Scaffold(
        appBar: CustomAppBar(title: 'referral_program'.tr, isBackButtonExist: true),
        body: const NotLoggedInScreen(),
      );
    }

    return GetBuilder<UserController>(
      builder: (userController) {
        if (userController.userInfoModel == null) {
          return Scaffold(
            appBar: CustomAppBar(title: 'referral_program'.tr, isBackButtonExist: true),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!_isProvider(userController)) {
          return Scaffold(
            appBar: CustomAppBar(title: 'referral_program'.tr, isBackButtonExist: true),
            body: _providerOnlyScreen(context),
          );
        }

        if (!_hasCompleteIdentity(userController)) {
          // نفس تحويل AddPropertyServiceOfferScreen بالضبط لمزوّد لم يُكمل
          // هويته بعد: يُستبدَل بشاشة إكمال الهوية بدل عرض صفحة الإحالة.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.off(() => const ProviderUpgradeScreen());
          });
          return Scaffold(
            appBar: CustomAppBar(title: 'referral_program'.tr, isBackButtonExist: true),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!_loadedForProvider) {
          _loadedForProvider = true;
          Get.find<ReferralController>().loadAll();
        }

        return Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          appBar: CustomAppBar(title: 'referral_program'.tr, isBackButtonExist: true),
          body: GetBuilder<ReferralController>(
            builder: (controller) {
              if (controller.isLoading && controller.summary == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadAll(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
                  child: Center(
                    child: SizedBox(
                      width: Dimensions.WEB_MAX_WIDTH,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _referralCodeCard(context, controller),
                          SizedBox(height: Dimensions.PADDING_SIZE_OVER_LARGE),
                          _summaryRow(context, controller),
                          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                          _availableBalanceCard(context, controller),
                          SizedBox(height: Dimensions.PADDING_SIZE_OVER_LARGE),
                          TitleWidget(title: 'referred_providers'.tr),
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                          _referralsList(context, controller),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _providerOnlyScreen(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_outlined, size: 72, color: theme.disabledColor),
            const SizedBox(height: 20),
            Text(
              'referral_provider_only_title'.tr,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'referral_provider_only_desc'.tr,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.disabledColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _referralCodeCard(BuildContext context, ReferralController controller) {
    final String code = controller.link?.referralCode ?? '';
    final String link = controller.link?.referralLink ?? '';

    return Container(
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_OVER_LARGE),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'your_referral_link'.tr,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).cardColor),
          ),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          Row(
            children: [
              Expanded(
                child: Text(
                  link.isEmpty ? '...' : link,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).cardColor,
                  ),
                ),
              ),
              if (link.isNotEmpty) ...[
                IconButton(
                  icon: Icon(Icons.copy, color: Theme.of(context).cardColor),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link));
                    Get.snackbar('', 'copied'.tr);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.share, color: Theme.of(context).cardColor),
                  onPressed: () {
                    Share.share(
                      controller.link?.shareText ?? link,
                      subject: 'Abaad App',
                    );
                  },
                ),
              ],
            ],
          ),
          if (code.isNotEmpty) ...[
            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
            Text(
              '${'your_referral_code'.tr}: $code',
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).cardColor.withValues(alpha: 0.85),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, ReferralController controller) {
    final ReferralSummaryModel? summary = controller.summary;

    return Row(
      children: [
        Expanded(
          child: _summaryTile(context, 'pending_commissions'.tr, summary?.pendingTotal ?? 0, Colors.orange),
        ),
        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
        Expanded(
          child: _summaryTile(context, 'available_commissions'.tr, summary?.availableTotal ?? 0, Colors.green),
        ),
      ],
    );
  }

  Widget _summaryTile(BuildContext context, String title, double amount, Color color) {
    return Container(
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
          SizedBox(height: 6),
          Text(
            PriceConverter.convertPrice(amount),
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: color),
          ),
        ],
      ),
    );
  }

  Widget _availableBalanceCard(BuildContext context, ReferralController controller) {
    final double available = controller.summary?.availableBalance ?? 0;

    return Container(
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('available_for_withdrawal'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
                SizedBox(height: 6),
                Text(
                  PriceConverter.convertPrice(available),
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 140,
            child: CustomButton(
              buttonText: 'request_withdrawal'.tr,
              onPressed: available > 0
                  ? () {
                      ResponsiveHelper.isMobile(context)
                          ? Get.bottomSheet(ReferralWithdrawalSheet(availableBalance: available))
                          : Get.dialog(Dialog(child: ReferralWithdrawalSheet(availableBalance: available)));
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _referralsList(BuildContext context, ReferralController controller) {
    final List<ReferralItemModel>? items = controller.referrals;

    if (items == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return NoDataScreen(text: 'no_data_found'.tr);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(color: Theme.of(context).disabledColor),
      itemBuilder: (context, index) {
        final ReferralItemModel item = items[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.PADDING_SIZE_SMALL),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.referredName ?? '', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                    if (item.packageName != null)
                      Text(item.packageName!, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.commissionAmount != null ? PriceConverter.convertPrice(item.commissionAmount!) : '-',
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                  Text(
                    (item.commissionStatus ?? item.referralStatus).toLowerCase().tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).disabledColor),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
