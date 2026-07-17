import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/scroll_reveal_item.dart';
import 'package:abaad_flutter/features/services/view/screens/filter_bottom_sheet.dart';
import 'package:abaad_flutter/features/services/view/screens/service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

String _cleanPhoneForWhatsapp(String phone) =>
    phone.replaceAll('+', '').replaceAll(' ', '');

// نصف قطر حواف حقل البحث/زر الفلاتر بالشريط العلوي — مستطيل مستدير الحواف
// معتدل (وليس كبسولة كاملة الاستدارة) مطابقةً تمامًا لتصميم التطبيق المرجعي.
const double _topBarRadius = 14;

// ارتفاع حقل البحث/رقاقة الموقع/زر الفلاتر بالشريط العلوي — موحّد بين الثلاثة
// بدل ارتفاع SearchSpec.height الأكبر (56) الذي كان يجعل حقل البحث يبدو أكبر
// من بقية عناصر الصف.
const double _topBarHeight = 48;

// ─── ألوان مدركة للثيم: بديل عن الألوان الثابتة (0xFF1A2340 وغيرها) التي كانت
// تجعل الشاشة تبدو بيضاء دائمًا حتى مع تفعيل الوضع الداكن ───────────────────
bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _primaryText(BuildContext context) =>
    _isDark(context) ? Colors.white : const Color(0xFF1A2340);

Color _secondaryText(BuildContext context) =>
    _isDark(context) ? Colors.grey.shade400 : Colors.grey.shade600;

class ServicesCatalogScreen extends StatefulWidget {
  final bool showAppBar;
  final List<Widget> extraActions;
  final Widget? floatingActionButton;

  const ServicesCatalogScreen({
    Key? key,
    this.showAppBar = true,
    this.extraActions = const [],
    this.floatingActionButton,
  }) : super(key: key);

  @override
  State<ServicesCatalogScreen> createState() => _ServicesCatalogScreenState();
}

class _ServicesCatalogScreenState extends State<ServicesCatalogScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<ServicesController>();
      c.getFilters();
      // الأولوية لتحديد الموقع أولاً (بسقف زمني) قبل جلب أي قائمة — راجع
      // ServicesController.loadInitial(). إن رُفض الإذن أو تأخّر GPS، تُعرض
      // القائمة الافتراضية مع تلميح لطيف (_NearMeHint أدناه) بدل رسالة مقتحمة.
      c.loadInitial();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final c = Get.find<ServicesController>();
      if (!c.isLoading && c.hasMore) {
        c.getServicesList(c.offset + 1);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBody(Color primary) {
    return GetBuilder<ServicesController>(
      builder: (controller) {
        // الرقائق ثابتة دائمًا أعلى الشاشة (خارج المنطقة القابلة للتمرير)
        // بدل أن تختفي عند النزول في القائمة. حقل البحث انتقل إلى الشريط
        // العلوي نفسه (قابل للطي) بدل صندوق دائم هنا.
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 14),
                child: _ServiceTypesBar(controller: controller, primary: primary),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: primary,
                onRefresh: () => controller.getServicesList(1, reload: true),
                child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (!controller.nearMeActive &&
                !controller.isResolvingLocation &&
                controller.nearMeAutoDenied)
              const SliverToBoxAdapter(child: _NearMeHint()),
            // يظهر في حالتين متتاليتين بدل ترك المستخدم بلا أي مؤشر بينهما:
            // (1) أثناء تحديد الموقع نفسه (isResolvingLocation — قبل معرفة
            // الإحداثيات، سواء عند المحاولة التلقائية الصامتة عند فتح الشاشة
            // أو عند الضغط اليدوي)، ثم (2) أثناء تحميل قائمة أقرب مزودي
            // الخدمة بعد نجاح تحديد الموقع (nearMeActive && isLoading) —
            // سواء كانت القائمة لا تزال فارغة (أول تحميل) أو معروضة بالفعل
            // من نتيجة افتراضية سابقة (silentReload لا يمسحها).
            if (controller.isResolvingLocation ||
                (controller.nearMeActive && controller.isLoading))
              SliverToBoxAdapter(
                child: _NearbySearchingBanner(
                    resolving: controller.isResolvingLocation),
              ),
            if (controller.servicesList == null) ...[
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const _SkeletonCard(),
                    childCount: 5,
                  ),
                ),
              ),
            ] else if (controller.servicesList!.isEmpty) ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyServices(
                  primary: primary,
                  hasActiveFilters: controller.searchText.isNotEmpty ||
                      controller.selectedCategories.isNotEmpty ||
                      controller.selectedZones.isNotEmpty ||
                      controller.selectedServiceTypes.isNotEmpty ||
                      controller.selectedProviders.isNotEmpty ||
                      controller.selectedOfferType != 'الكل',
                  onReset: controller.clearFilters,
                ),
              ),
            ] else ...[
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      if (index < controller.servicesList!.length) {
                        return ScrollRevealItem(
                          scrollController: _scrollController,
                          child: _ServiceCard(
                            service: controller.servicesList![index],
                            primary: primary,
                          ),
                        );
                      }
                      return controller.hasMore
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.4, color: primary),
                                ),
                              ),
                            )
                          : Padding(
                              // bottom: 100 (بدل 24) — يفسح مساحة كافية أسفل
                              // آخر عنصر بالقائمة كي لا يحجبه زرّ "إضافة خدمة"
                              // العائم (FloatingActionButton) الذي يطفو فوق
                              // الجسم بلا حجز مساحة تلقائي منه.
                              padding:
                                  const EdgeInsets.only(bottom: 100, top: 10),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded,
                                        size: 15, color: Colors.grey.shade400),
                                    const SizedBox(width: 6),
                                    Text(
                                      'تم عرض جميع الخدمات',
                                      style: robotoMedium.copyWith(
                                          color: _secondaryText(context),
                                          fontSize: 12.5),
                                    ),
                                  ],
                                ),
                              ),
                            );
                    },
                    childCount: controller.servicesList!.length + 1,
                  ),
                ),
              ),
            ],
          ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── الشريط العلوي: مثبّت أعلى الشاشة دائمًا (خارج منطقة التمرير)، ويضمّ في
  // صفّ واحد: زرّ رجوع للرئيسية (هذه الشاشة تُفتح دائمًا عبر Get.to() من
  // القائمة الجانبية فوق الرئيسية — لا يوجد AppBar افتراضي يوفّر زرّ رجوع)، ثم
  // مؤشّر الموقع غير المؤطَّر (نص + سهم، راجع _LocationChip) + حقل البحث —
  // بنفس روح شريط "أوبر/كريم" المرجعي. ترتيب الأبناء هنا يتبع اتجاه القراءة
  // RTL: أول عنصر بالقائمة يقع أقصى اليمين. لا جرس إشعارات هنا — كان إضافة
  // اجتهادية غير مطلوبة أصلاً فحُذفت.
  Widget _buildTopBar() {
    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const _BackHomeButton(),
            const SizedBox(width: 8),
            const _LocationChip(),
            const SizedBox(width: 8),
            const Expanded(child: _ServiceSearchField()),
            const SizedBox(width: 8),
            ...widget.extraActions,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    // عند التضمين داخل شاشة أخرى، نُرجع المحتوى مباشرة بدون Scaffold
    if (!widget.showAppBar) {
      return ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _buildBody(primary),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(child: _buildBody(primary)),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

// ─── حقل البحث: دائم الظهور أعلى الشاشة (وليس مطويًا خلف أيقونة) — بنفس
// شكل حقل "حدّد الموقع" المستدير في التطبيق المرجعي، لكن للبحث عن الخدمة.
// البحث يطابق العنوان/الوصف/الموقع/نوع الخدمة معًا في نفس الحقل الواحد —
// راجع Offer::scopeSearch بالباكند ──────────────────────────────────────────

class _ServiceSearchField extends StatelessWidget {
  const _ServiceSearchField();

  @override
  Widget build(BuildContext context) {
    // مجرّد زر دخول لشاشة بحث مخصّصة (ServicesSearchScreen) بدل حقل قابل
    // للكتابة هنا مباشرةً — البحث ضمن القائمة الرئيسية المعروضة كان يستدعي
    // إعادة تحميلها من الخادم في مكانها فيسبّب تأخرًا/وميضًا ملحوظًا أثناء
    // الكتابة؛ شاشة منفصلة تعطي تجربة "نتائج بحث فورية" واضحة بلا التأثير
    // على القائمة الرئيسية إطلاقًا.
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(_topBarRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(_topBarRadius),
        onTap: () => Get.to(
          () => const ServicesSearchScreen(),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 200),
        ),
        child: Container(
          height: _topBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(_topBarRadius),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 21),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ابحث عن الخدمة',
                  style: robotoRegular.copyWith(
                      color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── شاشة بحث مخصّصة: تُفتح عند الضغط على حقل البحث بالشاشة الرئيسية بدل
// الكتابة في مكانه مباشرةً. البحث يُرسَل هنا فقط (searchStandalone) ولا يمسّ
// قائمة الكتالوج الرئيسية إطلاقًا (لا searchText ولا servicesList)، فتبقى
// القائمة الرئيسية كما هي تمامًا عند الرجوع دون اختيار نتيجة.

class ServicesSearchScreen extends StatefulWidget {
  const ServicesSearchScreen({super.key});

  @override
  State<ServicesSearchScreen> createState() => _ServicesSearchScreenState();
}

class _ServicesSearchScreenState extends State<ServicesSearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final ServicesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ServicesController>();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.clearSearchResults();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.fromLTRB(4, 10, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'رجوع',
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: _primaryText(context), size: 18),
                  ),
                  Expanded(
                    child: Container(
                      height: _topBarHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(_topBarRadius),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded,
                              color: Colors.grey.shade500, size: 21),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              onChanged: _controller.searchStandalone,
                              textAlignVertical: TextAlignVertical.center,
                              style: robotoBold.copyWith(
                                  fontSize: 14.5, color: _primaryText(context)),
                              decoration: InputDecoration(
                                hintText: 'ابحث عن الخدمة',
                                hintStyle: robotoRegular.copyWith(
                                    color: Colors.grey.shade500, fontSize: 14),
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _textController,
                            builder: (context, value, _) {
                              if (value.text.isEmpty) return const SizedBox.shrink();
                              return GestureDetector(
                                onTap: () {
                                  _textController.clear();
                                  _controller.searchStandalone('');
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.close_rounded,
                                      size: 14, color: Colors.grey.shade600),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _textController,
                builder: (context, value, _) {
                  if (value.text.trim().isEmpty) {
                    return const _SearchPromptHint();
                  }
                  return GetBuilder<ServicesController>(
                    builder: (c) {
                      if (c.isSearching) {
                        return ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: 4,
                          itemBuilder: (_, __) => const _SkeletonCard(),
                        );
                      }
                      final results = c.searchResults;
                      if (results == null || results.isEmpty) {
                        return const _NoSearchResultsView();
                      }
                      return ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: results.length,
                        itemBuilder: (ctx, i) =>
                            _ServiceCard(service: results[i], primary: primary),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPromptHint extends StatelessWidget {
  const _SearchPromptHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_rounded, size: 44, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'اكتب اسم الخدمة أو الموقع أو نوعها للبحث',
              textAlign: TextAlign.center,
              style: robotoMedium.copyWith(
                  color: _secondaryText(context), fontSize: 13.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoSearchResultsView extends StatelessWidget {
  const _NoSearchResultsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 44, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('لا توجد نتائج مطابقة',
                style: robotoBold.copyWith(
                    color: _primaryText(context), fontSize: 15)),
            const SizedBox(height: 4),
            Text('جرّب كلمات بحث أخرى',
                style: robotoRegular.copyWith(
                    color: _secondaryText(context), fontSize: 12.5)),
          ],
        ),
      ),
    );
  }
}

// ─── Icon mapping for categories ──────────────────────────────────────────────

IconData serviceCategoryIcon(String? name) {
  final n = (name ?? '').trim();
  if (n.isEmpty || n == 'الكل') return Icons.apps_rounded;

  // الأكثر تحديدًا أولاً لتفادي التطابق مع كلمات عامة (مثل "شقة صغيرة" قبل "شقة")
  const map = <String, IconData>{
    'شقة صغيرة': Icons.single_bed_rounded,
    'استوديو': Icons.single_bed_rounded,
    'الطاقة الشمسية': Icons.solar_power_rounded,
    'شمسية': Icons.solar_power_rounded,
    'شمسي': Icons.solar_power_rounded,
    'أنظمة الأمان': Icons.security_rounded,
    'الأمان': Icons.security_rounded,
    'أمان': Icons.security_rounded,
    'مراقبة': Icons.videocam_rounded,
    'كاميرات': Icons.videocam_rounded,
    'إنذار': Icons.notifications_active_rounded,
    'انذار': Icons.notifications_active_rounded,
    'أنظمة الاتصال': Icons.wifi_rounded,
    'شبكات': Icons.settings_ethernet_rounded,
    'مكافحة الحريق': Icons.local_fire_department_rounded,
    'حريق': Icons.local_fire_department_rounded,
    'مكافحة الحشرات': Icons.pest_control_rounded,
    'مكافحة': Icons.fire_extinguisher_rounded,
    'مصاعد': Icons.elevator_rounded,
    'مصعد': Icons.elevator_rounded,
    'التخزين': Icons.inventory_2_rounded,
    'تخزين': Icons.inventory_2_rounded,
    'الري والزراعة': Icons.water_drop_rounded,
    'الري': Icons.water_drop_rounded,
    'زراع': Icons.agriculture_rounded,
    'ذكية': Icons.sensors_rounded,
    'ذكي': Icons.sensors_rounded,
    'التراخيص': Icons.verified_user_rounded,
    'تراخيص': Icons.verified_user_rounded,
    'تصاريح': Icons.verified_user_rounded,
    'تصريح': Icons.verified_user_rounded,
    'دهانات': Icons.format_paint_rounded,
    'دهان': Icons.format_paint_rounded,
    'تشطيب': Icons.format_paint_rounded,
    'تأثيث': Icons.chair_alt_rounded,
    'إستراحة': Icons.cottage_rounded,
    'استراحة': Icons.cottage_rounded,
    'شاليه': Icons.cabin_rounded,
    'كوخ': Icons.cabin_rounded,
    'قصر': Icons.castle_rounded,
    'ورشة': Icons.handyman_rounded,
    'مستودع': Icons.warehouse_rounded,
    'مصنع': Icons.factory_rounded,
    'معمل': Icons.factory_rounded,
    'برج': Icons.location_city_rounded,
    'مزرعة': Icons.agriculture_rounded,
    'مدرسة': Icons.school_rounded,
    'جامعة': Icons.school_rounded,
    'مستشفى': Icons.local_hospital_rounded,
    'عيادة': Icons.medical_services_rounded,
    'صيدلية': Icons.local_pharmacy_rounded,
    'مسبح': Icons.pool_rounded,
    'قاعة': Icons.celebration_rounded,
    'صالة': Icons.fitness_center_rounded,
    'مغسلة': Icons.local_laundry_service_rounded,
    'موقف': Icons.local_parking_rounded,
    'كراج': Icons.garage_rounded,
    'جراج': Icons.garage_rounded,
    'غرفة': Icons.meeting_room_rounded,
    'دور': Icons.stairs_rounded,
    'أرض': Icons.terrain_rounded,
    'ارض': Icons.terrain_rounded,
    'معرض': Icons.storefront_rounded,
    'محل': Icons.storefront_rounded,
    'مكتب': Icons.business_center_rounded,
    'سينما': Icons.local_movies_rounded,
    'ترفيه': Icons.celebration_rounded,
    'ملعب': Icons.sports_soccer_rounded,
    'عمارة': Icons.apartment_rounded,
    'عقار': Icons.apartment_rounded,
    'مبنى': Icons.apartment_rounded,
    'صراف': Icons.currency_exchange_rounded,
    'بنك': Icons.account_balance_rounded,
    'مالي': Icons.account_balance_wallet_rounded,
    'شقة': Icons.home_rounded,
    'سكن': Icons.home_rounded,
    'فيلا': Icons.villa_rounded,
    'مطعم': Icons.restaurant_rounded,
    'مقهى': Icons.local_cafe_rounded,
    'كافيه': Icons.local_cafe_rounded,
    'صيانة': Icons.build_rounded,
    'نقل': Icons.local_shipping_rounded,
    'عفش': Icons.local_shipping_rounded,
    'تنظيف': Icons.cleaning_services_rounded,
    'أمن': Icons.security_rounded,
    'حراسة': Icons.security_rounded,
    'تصميم': Icons.design_services_rounded,
    'ديكور': Icons.design_services_rounded,
    'كهرباء': Icons.electrical_services_rounded,
    'سباكة': Icons.plumbing_rounded,
    'تكييف': Icons.ac_unit_rounded,
    'حديقة': Icons.grass_rounded,
    'تنسيق': Icons.grass_rounded,
    'مقاولات': Icons.construction_rounded,
    'بناء': Icons.construction_rounded,
    'تأمين': Icons.shield_rounded,
    'تسوق': Icons.shopping_bag_rounded,
    'متجر': Icons.storefront_rounded,
    'صحة': Icons.local_hospital_rounded,
    'طبي': Icons.local_hospital_rounded,
    'تعليم': Icons.school_rounded,
    'رياضة': Icons.fitness_center_rounded,
    'نادي': Icons.fitness_center_rounded,
    'فندق': Icons.hotel_rounded,
    'سياح': Icons.card_travel_rounded,
    'سيار': Icons.directions_car_rounded,
    'تأجير': Icons.car_rental_rounded,
    'قانون': Icons.gavel_rounded,
    'محاما': Icons.gavel_rounded,
    'تصوير': Icons.camera_alt_rounded,
    'انترنت': Icons.wifi_rounded,
    'اتصالات': Icons.wifi_rounded,
  };

  for (final entry in map.entries) {
    if (n.contains(entry.key)) return entry.value;
  }
  // أي اسم "نظام/أنظمة ..." لم يُطابق كلمة محددة أعلاه يحصل على أيقونة أنسب
  // من الافتراضي العام (مثال: "أنظمة التحكم"، "نظام الري الذكي" الجديد)
  if (n.contains('نظام') || n.contains('أنظمة')) {
    return Icons.settings_suggest_rounded;
  }
  return Icons.miscellaneous_services_rounded;
}

// ─── عدد الفلاتر الفعّالة (لشارة زر الفلترة) ───────────────────────────────

int _activeFilterCount(ServicesController controller) {
  int n = 0;
  if (controller.selectedOfferType != 'الكل') n++;
  if (controller.sortBy != 'الأحدث') n++;
  if (controller.searchText.isNotEmpty) n++;
  n += controller.selectedCategories.length;
  n += controller.selectedZones.length;
  n += controller.selectedServiceTypes.length;
  n += controller.selectedProviders.length;
  return n;
}

// ─── زرّ الرجوع للرئيسية: هذه الشاشة تُفتح دائمًا بالدفع (Get.to من القائمة
// الجانبية فوق الرئيسية، راجع drawer_menu.dart) وليست تبويبًا ضمن التنقّل
// السفلي، فلا يوفّر أي AppBar افتراضي زرّ رجوع — Get.back() هنا يعيد المستخدم
// تحديدًا إلى الشاشة التي فُتحت منها (الرئيسية).
class _BackHomeButton extends StatelessWidget {
  const _BackHomeButton();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.back(),
      borderRadius: BorderRadius.circular(_topBarRadius),
      child: Container(
        width: _topBarHeight,
        height: _topBarHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Theme.of(context).primaryColor),
      ),
    );
  }
}

// ─── مؤشّر الموقع: نص + سهم انسدال فقط بلا صندوق/حدّ — مطابقةً للتصميم
// المرجعي حيث يظهر الموقع كعنصر نصّي خفيف بجانب حقل البحث (وليس رقاقة
// مؤطَّرة بنفس وزن حقل البحث كما كان سابقًا). نفس منطق تحديد النص/الحالة
// والوجهة (ورقة ZoneFilterSheet) دون أي تغيير في السلوك — فقط في المظهر.
// زرّ الفلاتر المتقدمة انتقل إلى شريط أنواع الخدمة أسفله (راجع
// _ServiceTypesBar) بجانب رقاقة "الكل" بدل الشريط العلوي.
class _LocationChip extends StatelessWidget {
  const _LocationChip();

  void _open() => Get.bottomSheet(
        const ZoneFilterSheet(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicesController>(
      builder: (controller) {
        String label;
        if (controller.nearMeActive) {
          label = 'الأقرب إليك';
        } else if (controller.selectedZones.length == 1) {
          final zone = controller.filtersData?.zones
              ?.firstWhereOrNull((z) => z.id == controller.selectedZones.first);
          label = zone?.nameAr ?? zone?.name ?? 'المنطقة';
        } else if (controller.selectedZones.length > 1) {
          label = '${controller.selectedZones.length} مناطق';
        } else {
          label = 'الموقع';
        }

        return InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(_topBarRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 76),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: 13.5,
                      color: _primaryText(context),
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: Colors.grey.shade500),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── شريط أنواع الخدمة: صف أفقي دائم الظهور أسفل الشريط السريع (بدل حقل
// "نوع الخدمة" الذي كان يفتح ورقة مصغّرة منفصلة) — رقاقة "الكل" أولاً ثم كل
// نوع خدمة فعلي من filtersData، اختيار وحيد يُطبَّق فورًا عند الضغط (بلا زر
// "تطبيق" منفصل)، مطابقةً لأسلوب أشرطة الفئات الأفقية في تطبيقات الخدمات
// المرجعية (Careem/Uber Eats) بدل قائمة منسدلة مخفية خلف نافذة إضافية.
class _ServiceTypesBar extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _ServiceTypesBar({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    if (controller.filtersData == null) {
      return const _ServiceTypesBarSkeleton();
    }
    final types = controller.filtersData?.serviceTypes ?? [];
    if (types.isEmpty) return const SizedBox.shrink();

    final selectedId = controller.selectedServiceTypes.isNotEmpty
        ? controller.selectedServiceTypes.first
        : null;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            _FilterIconButton(
              filterCount: _activeFilterCount(controller),
              primary: primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: types.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _ServiceTypeChip(
                      icon: Icons.apps_rounded,
                      label: 'الكل',
                      isSelected: selectedId == null,
                      primary: primary,
                      onTap: () => controller.selectServiceType(null),
                    );
                  }
                  final type = types[i - 1];
                  final label = type.name ?? '';
                  return _ServiceTypeChip(
                    icon: serviceCategoryIcon(label),
                    label: label,
                    isSelected: selectedId == type.id,
                    primary: primary,
                    onTap: type.id != null
                        ? () => controller.selectServiceType(type.id)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── زرّ الفلاتر المتقدمة: انتقل من الشريط العلوي إلى هنا مباشرةً بجانب
// رقاقة "الكل" — عنصر ثابت لا يتحرك مع تمرير شريط أنواع الخدمة، بنفس ارتفاع
// الرقاقات المجاورة له (42) بدل ارتفاع حقل البحث الذي كان يلائم موضعه القديم
// فقط. الشارة البرتقالية تبقى تعرض عدد الفلاتر الفعّالة.
class _FilterIconButton extends StatelessWidget {
  final int filterCount;
  final Color primary;

  const _FilterIconButton({required this.filterCount, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () => Get.bottomSheet(
            const FilterBottomSheet(),
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(21),
          child: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Icon(Icons.tune_rounded, size: 18, color: primary),
          ),
        ),
        if (filterCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).cardColor, width: 1.2),
                ),
                child: Text(
                  '$filterCount',
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(color: Colors.white, fontSize: 8),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── رقاقة نوع خدمة واحدة (Material 3 Filter Chip): تعبئة تونالية خفيفة بلون
// التطبيق + حدّ بنفس اللون وأيقونة "✓" عند التحديد، بدل التدرّج اللوني والظلّ
// الثقيلين سابقًا — أقرب لروح رقاقات الفلترة الفعلية في MD3 وتطبيقات
// Uber/Careem، وأهدأ بصريًا ضمن شريط متكرر من العناصر. الارتفاع 42 (ضمن نطاق
// 40–44 المعتمد للرقاقات الأفقية).
class _ServiceTypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color primary;
  final VoidCallback? onTap;

  const _ServiceTypeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: AnimatedContainer(
          duration: AnimSpec.card,
          curve: Curves.easeOut,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? primary.withValues(alpha: dark ? 0.22 : 0.12)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
              color: isSelected ? primary : Theme.of(context).dividerColor,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // الأيقونة الأصلية تبقى ظاهرة دائمًا (بلا استبدال بعلامة "✓" عند
              // التحديد) — التلوين التوناليّ للخلفية والحدّ كافٍ للدلالة على
              // الاختيار، مطابقةً لرقاقة "الكل" في التصميم المرجعي.
              Icon(icon, size: 16, color: isSelected ? primary : Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                label,
                style: (isSelected ? robotoBold : robotoMedium).copyWith(
                  fontSize: 12.5,
                  color: isSelected ? primary : _secondaryText(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── هيكل تحميل لشريط أنواع الخدمة (شرائط بعرض متفاوت بحركة shimmer) —
// بانتظار وصول filtersData، بدل اختفاء الشريط بالكامل فتقفز الأبعاد لحظة
// وصول البيانات.
class _ServiceTypesBarSkeleton extends StatelessWidget {
  const _ServiceTypesBarSkeleton();

  static const List<double> _widths = [64, 96, 78, 110, 84, 92];

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final baseColor =
        dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEEF0F5);

    return SizedBox(
      height: 42,
      child: Shimmer(
        duration: const Duration(milliseconds: 1400),
        interval: const Duration(milliseconds: 350),
        color: dark ? Colors.white : Theme.of(context).primaryColor,
        colorOpacity: dark ? 0.16 : 0.3,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
          itemCount: _widths.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) => Container(
            width: _widths[i],
            height: 42,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(21),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Service card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceOffer service;
  final Color primary;

  const _ServiceCard({required this.service, required this.primary});

  @override
  Widget build(BuildContext context) {
    final provider = (service.providers?.isNotEmpty ?? false)
        ? service.providers!.first
        : null;
    final isDiscount = service.offerType == 'discount';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow:
            AppShadows.soft(blur: 16, opacity: _isDark(context) ? 0.28 : 0.06),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.to(
            () => ServiceDetailsScreen(serviceId: service.id!),
            transition: Transition.cupertino,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ServiceImageCarousel(
                images: (service.image != null && service.image!.isNotEmpty)
                    ? [service.image!]
                    : const [],
                topLeftBadge: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDiscount
                          ? [Colors.red.shade600, Colors.red.shade400]
                          : [Colors.green.shade600, Colors.green.shade500],
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isDiscount
                            ? Icons.local_offer_outlined
                            : Icons.payments_outlined,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isDiscount
                            ? '${service.formattedDiscount ?? '${service.discount}%'}  خصم'
                            : '${service.servicePrice} ر.س',
                        style:
                            robotoBold.copyWith(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                // شارة "حالة التوفّر" (نشط/منتهي) — مبنية على isExpired الحقيقي
                // من الباكند، منقولة إلى زاوية الصورة بدل شارة نصّية داخل جسم
                // البطاقة (نفس البيانات، موضع أوضح وأقرب لتطبيقات المرجع).
                topRightBadge: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (service.isExpired ?? false)
                              ? Colors.grey.shade500
                              : Colors.green.shade600,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        (service.isExpired ?? false) ? 'العرض منتهي' : 'متاح الآن',
                        style: robotoBold.copyWith(
                          fontSize: 11,
                          color: (service.isExpired ?? false)
                              ? Colors.grey.shade700
                              : Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                // حواف 16 موحّدة على كامل الجسم (شبكة 8pt: 16 = 2×8) بدل
                // الخليط السابق (16/12/16/16) غير المنضبط على الشبكة.
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: العنوان (أكبر وأوضح) + رقاقة المسافة أسفله مباشرة
                    Text(
                      service.title ?? '',
                      style: robotoBold.copyWith(
                          fontSize: 16.5, color: _primaryText(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // رقاقة مسافة صغيرة (بدل صفّ إحصاءات ضخم يهيمن على البطاقة) —
                    // الحقل الوحيد المتوفّر فعليًا من الباكند حاليًا (راجع
                    // ServiceOfferResource::distance_km)؛ لا تقييم هنا لعدم وجود
                    // نظام مراجعات فعلي بعد (provider.rating يبقى null دائمًا).
                    if (service.distanceKm != null) ...[
                      const SizedBox(height: 8),
                      _DistanceChip(distanceKm: service.distanceKm!),
                    ],
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    // Row 2: مزوّد الخدمة بأسلوب ListTile — صورة حقيقية إن
                    // وُجدت (ثقة أعلى للعميل) + الاسم، بلا سهم كشف زائد
                    // (البطاقة كلها قابلة للضغط أصلاً فلا معنى لسهم منفصل).
                    Row(
                      children: [
                        _ProviderAvatar(provider: provider, primary: primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider?.name ?? 'مزود خدمة',
                            style: robotoMedium.copyWith(
                                fontSize: 13, color: primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // وسم نوع الخدمة (كان يُعرض فوق الصورة سابقًا) مدمج مع
                    // وسوم فئات العرض في مجموعة واحدة أسفل صفّ مزوّد الخدمة
                    // مباشرة — بدل شارة منفصلة تُثقل الصورة بعنصر إضافي فوقها.
                    if (_tagLabels(service).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _tagLabels(service)
                            .map((l) => _TagChip(label: l))
                            .toList(),
                      ),
                    ],
                    if (provider?.phone?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 16),
                      _ServiceActionButtons(provider: provider!, service: service),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ─── وسوم البطاقة: نوع الخدمة (كان شارة منفصلة فوق الصورة) مدمج مع فئات
// العرض في قائمة واحدة تُعرض أسفل صفّ مزوّد الخدمة — راجع _ServiceCard.
List<String> _tagLabels(ServiceOffer service) {
  return <String>[
    if (service.serviceType?.name != null) service.serviceType!.name!,
    ...?service.categories?.map((c) => c.nameAr ?? c.name ?? ''),
  ].where((l) => l.trim().isNotEmpty).take(4).toList();
}

// ─── رقاقة مسافة صغيرة أسفل العنوان مباشرة: نص مضغوط بحجم رقاقة الفئة
// المجاورة لها (بدل صفّ إحصائيات ضخم يهيمن على عرض البطاقة بالكامل) — تُعرض
// فقط عند توفّر distance_km فعليًا من الباكند (راجع ServiceOfferResource).
class _DistanceChip extends StatelessWidget {
  final double distanceKm;

  const _DistanceChip({required this.distanceKm});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me_rounded, size: 11, color: primary),
          const SizedBox(width: 4),
          Text(
            '${distanceKm.toStringAsFixed(1)} كم عنك',
            style: robotoBold.copyWith(fontSize: 11, color: primary),
          ),
        ],
      ),
    );
  }
}

// ─── وسم فئة صغير (Wrap أسفل اسم مزوّد الخدمة): نص فقط بلا أيقونة، حدّ رفيع
// محايد — يعرض بيانات service.categories الموجودة أصلاً بالباكند ولم تكن
// تظهر على بطاقة القائمة سابقًا (كانت متاحة فقط بشاشة التفاصيل).
class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        label,
        style: robotoMedium.copyWith(fontSize: 11, color: _secondaryText(context)),
      ),
    );
  }
}

// ─── صورة مزوّد الخدمة: صورته الحقيقية إن وُجدت (ثقة أعلى للعميل) بدل أيقونة
// عامة ثابتة دائمًا — مع سقوط آمن لنفس الأيقونة المتدرّجة عند غياب الصورة ────

class _ProviderAvatar extends StatelessWidget {
  final ProviderData? provider;
  final Color primary;

  const _ProviderAvatar({required this.provider, required this.primary});

  @override
  Widget build(BuildContext context) {
    final hasImage = (provider?.image ?? '').trim().isNotEmpty;
    return ClipOval(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primary.withValues(alpha: 0.14),
              primary.withValues(alpha: 0.06),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: hasImage
            ? CustomImage(
                image: provider!.image,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              )
            : Icon(Icons.storefront_outlined, size: 16, color: primary),
      ),
    );
  }
}

// ─── أزرار الإجراءات: زر رئيسي عريض "طلب الخدمة" (يفتح واتساب مباشرة — بدون
// شاشة تفاصيل ولا نظام طلبات خلفي، بحسب الاتفاق) إلى جانب زرَّي أيقونة مربّعين
// صغيرين للاتصال/الخريطة، كلّها في صفّ واحد — الزرّ الرئيسي أوّل عنصر في
// أبناء Row فيقع أقصى اليمين بصريًا (اتجاه RTL) آخذًا معظم العرض، والزرّان
// الثانويّان يليانه يسارًا، مطابقةً لتخطيط بطاقة الخدمة في التصميم المرجعي.
// الخريطة تفتح موقع أول منطقة تغطية تملك إحداثيات (تقريب معقول لعدم وجود
// إحداثي مقر مستقل لمزود الخدمة).

class _ServiceActionButtons extends StatelessWidget {
  final ProviderData provider;
  final ServiceOffer service;

  const _ServiceActionButtons({required this.provider, required this.service});

  ZoneData? get _mappableZone {
    final zones = service.zones;
    if (zones == null) return null;
    for (final zone in zones) {
      if (zone.latitude != null && zone.longitude != null) return zone;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final zone = _mappableZone;
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(
                'https://wa.me/${_cleanPhoneForWhatsapp(provider.phone!)}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
              ),
              icon: const Icon(Icons.chat_rounded, size: 18),
              label:
                  Text('طلب الخدمة', style: robotoBold.copyWith(fontSize: 13.5)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _SquareIconButton(
          icon: Icons.call_rounded,
          color: Colors.blue.shade600,
          onTap: () => _launchUrl('tel:${provider.phone}'),
        ),
        if (zone != null) ...[
          const SizedBox(width: 8),
          _SquareIconButton(
            icon: Icons.map_outlined,
            color: Colors.deepOrange.shade400,
            onTap: () => _launchUrl(
              'https://www.google.com/maps/search/?api=1&query=${zone.latitude},${zone.longitude}',
            ),
          ),
        ],
      ],
    );
  }
}

// ─── زرّ أيقونة مربّع صغير (اتصال/خريطة): حدّ رفيع محايد بلا خلفية ملوّنة —
// إجراء ثانوي بوزن بصري أخفّ من الزرّ الرئيسي المُعبَّأ بجانبه.
class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SquareIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}

// ─── معرض صور البطاقة: يدعم Carousel بصريًا (نقاط + أسهم) لكن يعرض حاليًا
// صورة واحدة فقط (offers.image عمود وحيد بالباكند — لا يوجد معرض صور متعدد
// بعد). الأسهم/النقاط تظهر تلقائيًا فقط عند images.length > 1، فيعمل هذا
// المكوّن دون أي تعديل إضافي إن أُضيف معرض صور لاحقًا.

class _ServiceImageCarousel extends StatefulWidget {
  final List<String> images;
  final Widget? topLeftBadge;
  final Widget? topRightBadge;

  const _ServiceImageCarousel({
    required this.images,
    this.topLeftBadge,
    this.topRightBadge,
  });

  @override
  State<_ServiceImageCarousel> createState() => _ServiceImageCarouselState();
}

class _ServiceImageCarouselState extends State<_ServiceImageCarousel> {
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int delta, int count) {
    final next = (_index + delta).clamp(0, count - 1);
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.isEmpty ? const [''] : widget.images;
    final hasMultiple = images.length > 1;

    // نسبة بانورامية (2.5:1) ثابتة لصورة البطاقة — أقصر وأعرض من 16:9 الحرفية
    // التي بدت طويلة جدًا خصوصًا مع placeholder بلا صورة حقيقية، وأقرب لنسبة
    // صورة البطاقة في التصميم المرجعي (Uber/Careem).
    return AspectRatio(
      aspectRatio: 2.5,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => CustomImage(
                image: images[i],
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.45),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          if (hasMultiple) ...[
            Positioned(
              left: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrowButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: () => _goTo(-1, images.length),
                ),
              ),
            ),
            Positioned(
              right: 6,
              top: 0,
              bottom: 0,
              child: Center(
                child: _CarouselArrowButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: () => _goTo(1, images.length),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == _index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: active ? 0.95 : 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
          ],
            if (widget.topLeftBadge != null)
              Positioned(top: 12, left: 12, child: widget.topLeftBadge!),
            if (widget.topRightBadge != null)
              Positioned(top: 12, right: 12, child: widget.topRightBadge!),
          ],
        ),
      ),
    );
  }
}

class _CarouselArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CarouselArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.32),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── تلميح لطيف (غير مقتحم) يظهر فقط عند رفض/تعطيل صلاحية الموقع أثناء
// المحاولة التلقائية الصامتة عند فتح الشاشة — بدل رسالة/حوار مفاجئ، مع خيار
// إعادة المحاولة يدوياً (وحينها تظهر كل رسائل النظام الكاملة) أو التجاهل ──

class _NearMeHint extends StatelessWidget {
  const _NearMeHint();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final controller = Get.find<ServicesController>();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.soft(blur: 8, opacity: 0.04),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off_outlined, color: primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'فعّل الموقع لعرض أقرب مزوّدي الخدمة إليك',
              style: robotoMedium.copyWith(fontSize: 12.5, color: primary),
            ),
          ),
          GestureDetector(
            onTap: () => controller.enableNearMe(),
            child: Text(
              'تفعيل',
              style: robotoBold.copyWith(fontSize: 12.5, color: primary),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              controller.nearMeAutoDenied = false;
              controller.update();
            },
            child: Icon(Icons.close_rounded,
                size: 16, color: primary.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

// ─── شريط "جاري البحث عن أقرب مزودي الخدمة..." (يظهر فقط أثناء أول تحميل بعد
// تفعيل "الأقرب مني" — نبضة خفيفة على الأيقونة توضح أن البحث حي وليس متجمّدًا) ─

class _NearbySearchingBanner extends StatefulWidget {
  // true أثناء تحديد إحداثيات المستخدم نفسها (قبل معرفة أقرب مزوّد)، false
  // أثناء تحميل قائمة أقرب مزودي الخدمة بعد نجاح تحديد الموقع — نص/أيقونة
  // مختلفان لكل مرحلة حتى لا يبدو المستخدم عالقًا في نفس الرسالة طويلاً.
  final bool resolving;

  const _NearbySearchingBanner({this.resolving = false});

  @override
  State<_NearbySearchingBanner> createState() => _NearbySearchingBannerState();
}

class _NearbySearchingBannerState extends State<_NearbySearchingBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.soft(blur: 8, opacity: 0.04),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.15).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Icon(
              widget.resolving ? Icons.location_searching_rounded : Icons.near_me_rounded,
              color: primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.resolving
                  ? 'جاري تحديد موقعك...'
                  : 'جاري البحث عن أقرب مزودي الخدمة إليك...',
              style: robotoMedium.copyWith(fontSize: 12.5, color: primary),
            ),
          ),
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: primary),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton card (مع لمعة shimmer متحركة بدل كتلة رمادية ثابتة) ─────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    final baseColor = dark ? const Color(0xFF262A38) : const Color(0xFFE8ECF0);
    final highlightColor = dark ? const Color(0xFF3A4055) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        boxShadow: AppShadows.soft(blur: 10, opacity: dark ? 0.2 : 0.04),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        child: AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            final dx = _shimmerController.value * 3 - 1;
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (rect) => LinearGradient(
                colors: [baseColor, highlightColor, baseColor],
                stops: const [0.35, 0.5, 0.65],
                begin: Alignment(dx - 1, 0),
                end: Alignment(dx + 1, 0),
              ).createShader(rect),
              child: child,
            );
          },
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 2.5,
                child: Container(color: baseColor),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sh(baseColor, double.infinity, 16),
                    const SizedBox(height: 8),
                    _sh(baseColor, 220, 12),
                    const SizedBox(height: 12),
                    Row(children: [
                      _sc(baseColor, 32),
                      const SizedBox(width: 10),
                      _sh(baseColor, 120, 12),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sh(Color color, double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(8)));

  Widget _sc(Color color, double s) => Container(
      width: s,
      height: s,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyServices extends StatelessWidget {
  final Color primary;
  final bool hasActiveFilters;
  final VoidCallback onReset;

  const _EmptyServices({
    required this.primary,
    required this.hasActiveFilters,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(alpha: 0.1),
                    primary.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 42, color: primary.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 22),
            Text(
              'لا توجد خدمات متاحة',
              style: robotoBold.copyWith(
                  fontSize: 16, color: _primaryText(context)),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب تغيير الفلاتر أو البحث بكلمة مختلفة',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                  fontSize: 13, color: Colors.grey.shade500, height: 1.5),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onReset,
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  backgroundColor: primary.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('إعادة تعيين الفلاتر',
                    style: robotoBold.copyWith(fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
