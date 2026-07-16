import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/shared/helpers/date_converter.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/scroll_reveal_item.dart';
import 'package:abaad_flutter/features/services/view/screens/filter_bottom_sheet.dart';
import 'package:abaad_flutter/features/services/view/screens/service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

String _cleanPhoneForWhatsapp(String phone) =>
    phone.replaceAll('+', '').replaceAll(' ', '');

// ─── ألوان مدركة للثيم: بديل عن الألوان الثابتة (0xFF1A2340 وغيرها) التي كانت
// تجعل الشاشة تبدو بيضاء دائمًا حتى مع تفعيل الوضع الداكن ───────────────────
bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _primaryText(BuildContext context) =>
    _isDark(context) ? Colors.white : const Color(0xFF1A2340);

Color _secondaryText(BuildContext context) =>
    _isDark(context) ? Colors.grey.shade400 : Colors.grey.shade600;

Color _cardBorder(BuildContext context) => Theme.of(context).dividerColor;

String? _cardFormatDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return DateConverter.stringToLocalDateOnly(raw.split('T').first);
  } catch (_) {
    try {
      return DateConverter.isoStringToLocalDateOnly(raw);
    } catch (_) {
      return raw.split('T').first;
    }
  }
}

class ServicesCatalogScreen extends StatefulWidget {
  final bool showAppBar;
  final String title;
  final String subtitle;
  final List<Widget> extraActions;
  final Widget? floatingActionButton;

  const ServicesCatalogScreen({
    Key? key,
    this.showAppBar = true,
    this.title = 'دليل الخدمات العقارية',
    this.subtitle = 'أفضل العروض والخصومات الحصرية',
    this.extraActions = const [],
    this.floatingActionButton,
  }) : super(key: key);

  @override
  State<ServicesCatalogScreen> createState() => _ServicesCatalogScreenState();
}

class _ServicesCatalogScreenState extends State<ServicesCatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchFocusNode.addListener(_onSearchFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<ServicesController>();
      c.applySavedZoneDefault();
      c.getServicesList(1, reload: true);
      c.getFilters();
      // ترتيب تلقائي حسب الأقرب عند فتح الشاشة لأول مرة — دون أي ضغط زر.
      // إن رُفض الإذن، تبقى القائمة بالترتيب الافتراضي مع تلميح لطيف
      // (_NearMeHint أدناه) بدل رسالة مقتحمة.
      c.enableNearMe(silent: true);
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

  // عند فقد التركيز يُطوى شريط البحث تلقائيًا، لكن فقط إن كان الحقل فارغًا —
  // حتى لا يُمحى استعلام كتبه المستخدم لمجرد اختفاء لوحة المفاتيح.
  void _onSearchFocusChange() {
    if (!_searchFocusNode.hasFocus &&
        _searchExpanded &&
        Get.find<ServicesController>().searchController.text.isEmpty) {
      setState(() => _searchExpanded = false);
    }
  }

  void _expandSearch() {
    setState(() => _searchExpanded = true);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchFocusNode.requestFocus());
  }

  void _collapseSearch() {
    _searchFocusNode.unfocus();
    setState(() => _searchExpanded = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchFocusNode.dispose();
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
              color: Theme.of(context).cardColor,
              child: _QuickFilterRow(controller: controller, primary: primary),
            ),
            Expanded(
              child: RefreshIndicator(
                color: primary,
                onRefresh: () => controller.getServicesList(1, reload: true),
                child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (!controller.nearMeActive && controller.nearMeAutoDenied)
              const SliverToBoxAdapter(child: _NearMeHint()),
            // يظهر أثناء أي إعادة تحميل متعلقة بـ"الأقرب مني" — سواء كانت
            // القائمة لا تزال فارغة (أول تحميل) أو معروضة بالفعل من نتيجة
            // افتراضية سابقة (silentReload لا يمسحها)، بدل اختفاء القائمة
            // المعروضة فجأة إلى هيكل عظمي فارغ لمجرد وصول موقع GPS لاحقًا.
            if (controller.nearMeActive && controller.isLoading)
              const SliverToBoxAdapter(child: _NearbySearchingBanner()),
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
                              padding:
                                  const EdgeInsets.only(bottom: 24, top: 10),
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

  // ─── الصف الأول (AppBar): عنوان + بحث + فلاتر متقدمة فقط — بلا أي عنصر
  // إضافي (لا يوجد وضع Grid/Map بديل في هذه الشاشة فيُستغنى عن زر تبديل
  // العرض). البحث لا يشغل مساحة دائمة: أيقونة فقط، وعند الضغط عليها ينزلق
  // حقل بحث كامل العرض من الأعلى (Slide + Fade) بدل حقل مطويّ أفقيًا ────────
  PreferredSizeWidget _buildAppBar(Color primary) {
    final controller = Get.find<ServicesController>();

    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 64,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primary, primary.withValues(alpha: 0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.35),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: _searchExpanded
            ? _ExpandedSearchField(
                key: const ValueKey('expanded'),
                controller: controller,
                focusNode: _searchFocusNode,
              )
            : ServicesAppBarTitle(
                key: const ValueKey('collapsed'),
                title: widget.title,
                subtitle: widget.subtitle,
              ),
      ),
      actions: _searchExpanded
          ? [
              IconButton(
                tooltip: 'إغلاق البحث',
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: _collapseSearch,
              ),
            ]
          : [
              ...widget.extraActions,
              const _FilterAction(),
              IconButton(
                tooltip: 'بحث',
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: _expandSearch,
              ),
            ],
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
      appBar: _buildAppBar(primary),
      body: _buildBody(primary),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

// ─── حقل البحث الموسَّع: ينزلق من الأعلى بدل صندوق دائم في الشريط (يوفّر
// مساحة الشاشة عندما لا يُستخدم). البحث يطابق العنوان/الوصف/الموقع/نوع
// الخدمة معًا في نفس الحقل الواحد — راجع Offer::scopeSearch بالباكند ────────

class _ExpandedSearchField extends StatelessWidget {
  final ServicesController controller;
  final FocusNode focusNode;

  const _ExpandedSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    // خلفية بيضاء صلبة بدل تراكب شفاف على تدرّج الشريط العلوي — التراكب
    // الشفاف كان يعطي تباينًا هشًا (نص/تلميح أبيض على خلفية شبه شفافة قد
    // يبدو شبه غير مرئي حسب سطوع الشاشة)، بينما صندوق أبيض صلب بنص/أيقونات
    // داكنة يضمن وضوحًا ثابتًا في كل الظروف، مطابقةً لنمط شرائط البحث العائمة
    // في التطبيقات العالمية (خرائط جوجل، كريم، وغيرها).
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              focusNode: focusNode,
              autofocus: true,
              onChanged: controller.searchServices,
              textAlignVertical: TextAlignVertical.center,
              style: robotoMedium.copyWith(
                  fontSize: 14, color: const Color(0xFF1A2340)),
              decoration: InputDecoration(
                hintText: 'ابحث بالموقع، اسم الإعلان، أو نوع الخدمة',
                hintStyle: robotoRegular.copyWith(
                    color: Colors.grey.shade500, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return GestureDetector(
                onTap: () {
                  controller.searchController.clear();
                  controller.searchServices('');
                },
                child: Icon(Icons.cancel_rounded,
                    size: 18, color: Colors.grey.shade400),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─── زر "فلترة" الوحيد في الشريط العلوي: يفتح ورقة الفلاتر المتقدمة الشاملة
// (الفرز/السعر/المنطقة/نوع العقار/مزود الخدمة) مع شارة صغيرة بعدد الفلاتر
// الفعّالة — بدل عدة أزرار متفرقة كما كان سابقًا ────────────────────────────

class _FilterAction extends StatelessWidget {
  const _FilterAction();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicesController>(
      builder: (controller) {
        final count = _activeFilterCount(controller);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'الفلاتر المتقدمة',
              icon: const Icon(Icons.tune_rounded, color: Colors.white),
              onPressed: () => Get.bottomSheet(
                const FilterBottomSheet(),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              ),
            ),
            if (count > 0)
              Positioned(
                top: 8,
                right: 6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Theme.of(context).primaryColor, width: 1.4),
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: robotoBold.copyWith(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
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

// ─── App-bar title ─────────────────────────────────────────────────────────────

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

class ServicesAppBarTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const ServicesAppBarTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.local_offer_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(fontSize: 17, color: Colors.white),
              ),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                    fontSize: 10.5, color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── شريط سريع بعنصرين فقط: الموقع (تلقائي أو يدوي، زر واحد موحّد) ونوع
// الخدمة (يفتح شبكة أيقونات في ورقة مصغّرة) — بقية الفلاتر (الفرز/السعر/
// العروض/التقييم/مزود الخدمة) انتقلت بالكامل إلى "البحث المتقدم" (زر ⚙ في
// الشريط العلوي)، فلا يبقى هنا سوى أكثر عنصرين استخدامًا، مطابقةً لتطبيق
// العقارات المرجعي الذي أرفقه المستخدم (حقل موقع + زر نوع عقار فقط) ────────

class _QuickFilterRow extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _QuickFilterRow({required this.controller, required this.primary});

  void _openLocation() => Get.bottomSheet(
        const ZoneFilterSheet(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );

  void _openServiceType() => Get.bottomSheet(
        const TypeFilterSheet(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      );

  @override
  Widget build(BuildContext context) {
    final locationActive =
        controller.nearMeActive || controller.selectedZones.isNotEmpty;
    String locationLabel;
    IconData locationIcon;
    if (controller.nearMeActive) {
      locationLabel = 'الأقرب إليك';
      locationIcon = Icons.near_me_rounded;
    } else if (controller.selectedZones.length == 1) {
      final zone = controller.filtersData?.zones
          ?.firstWhereOrNull((z) => z.id == controller.selectedZones.first);
      locationLabel = zone?.nameAr ?? zone?.name ?? 'منطقة واحدة';
      locationIcon = Icons.location_on_rounded;
    } else if (controller.selectedZones.length > 1) {
      locationLabel = '${controller.selectedZones.length} مناطق';
      locationIcon = Icons.location_on_rounded;
    } else {
      locationLabel = 'حدّد الموقع';
      locationIcon = Icons.location_on_outlined;
    }

    final selectedTypeId = controller.selectedServiceTypes.isNotEmpty
        ? controller.selectedServiceTypes.first
        : null;
    final selectedTypeName = selectedTypeId != null
        ? controller.filtersData?.serviceTypes
            ?.firstWhereOrNull((t) => t.id == selectedTypeId)
            ?.name
        : null;
    final selectedCategoryId = controller.selectedCategories.isNotEmpty
        ? controller.selectedCategories.first
        : null;
    final selectedCategory = selectedCategoryId != null
        ? controller.filtersData?.categories
            ?.firstWhereOrNull((c) => c.id == selectedCategoryId)
        : null;
    final selectedCategoryName = selectedCategory?.nameAr ?? selectedCategory?.name;
    final typeActive = selectedTypeName != null || selectedCategoryName != null;
    final typeLabel = selectedTypeName ?? selectedCategoryName ?? 'نوع الخدمة';
    final typeIcon = typeActive
        ? serviceCategoryIcon(typeLabel)
        : Icons.category_outlined;

    return Container(
      width: double.infinity,
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: _QuickField(
              icon: locationIcon,
              label: locationLabel,
              active: locationActive,
              primary: primary,
              trailing: Icons.location_on_rounded,
              onTap: _openLocation,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _QuickField(
              icon: typeIcon,
              label: typeLabel,
              active: typeActive,
              primary: primary,
              trailing: Icons.keyboard_arrow_down_rounded,
              onTap: _openServiceType,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── حقل سريع موحّد (Location / نوع الخدمة): صندوق مستدير الحواف بحدّ رفيع،
// أيقونة + نص + أيقونة اتجاه، بنفس القياسات والروح البصرية لحقل "حدّد الموقع"
// في التطبيق المرجعي — بلون تطبيقنا بدل الأخضر ─────────────────────────────

class _QuickField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color primary;
  final IconData trailing;
  final VoidCallback onTap;

  const _QuickField({
    required this.icon,
    required this.label,
    required this.active,
    required this.primary,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = _isDark(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active
                ? primary.withValues(alpha: dark ? 0.16 : 0.08)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: active ? primary : Theme.of(context).dividerColor,
              width: active ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  icon,
                  key: ValueKey(icon),
                  size: 18,
                  color: active ? primary : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: (active ? robotoBold : robotoMedium).copyWith(
                    fontSize: 13.5,
                    color: active ? primary : _secondaryText(context),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Icon(trailing, size: 18, color: active ? primary : Colors.grey.shade400),
            ],
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: _isDark(context) ? 0.28 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
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
                topRightBadge: Container(
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
                bottomLeftBadge: service.serviceType?.name != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              serviceCategoryIcon(service.serviceType!.name),
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.serviceType!.name!,
                              style: robotoMedium.copyWith(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان
                    Text(
                      service.title ?? '',
                      style: robotoBold.copyWith(
                          fontSize: 15, color: _primaryText(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // سطر الوسوم: نوع الخدمة + الفئات (نص رمادي مفصول بفواصل)
                    if (_tagsLine(service).isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _tagsLine(service),
                        style: robotoRegular.copyWith(
                            fontSize: 12, color: _secondaryText(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // سطر السعر/الخصم
                    Row(
                      children: [
                        Icon(
                          isDiscount
                              ? Icons.local_offer_outlined
                              : Icons.payments_outlined,
                          size: 14,
                          color: primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            isDiscount
                                ? 'خصم ${service.formattedDiscount ?? '${service.discount}%'}'
                                : 'السعر ${service.servicePrice} ر.س',
                            style: robotoBold.copyWith(
                                fontSize: 13, color: primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (service.distanceKm != null) ...[
                          Icon(Icons.near_me_outlined,
                              size: 13, color: Colors.indigo.shade400),
                          const SizedBox(width: 3),
                          Text(
                            '${service.distanceKm!.toStringAsFixed(1)} كم',
                            style: robotoMedium.copyWith(
                                fontSize: 11.5, color: Colors.indigo.shade400),
                          ),
                        ],
                      ],
                    ),
                    // سطر الموقع
                    if (_locationLabel(service) != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: _secondaryText(context)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _locationLabel(service)!,
                              style: robotoRegular.copyWith(
                                  fontSize: 12, color: _secondaryText(context)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    // صندوق "صلاحية العرض"
                    if (_cardFormatDate(service.expiryDate) != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (service.isExpired ?? false)
                                  ? Icons.event_busy_rounded
                                  : Icons.schedule_rounded,
                              size: 15,
                              color: (service.isExpired ?? false)
                                  ? Colors.red.shade600
                                  : _secondaryText(context),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'صلاحية العرض',
                              style: robotoRegular.copyWith(
                                  fontSize: 11.5,
                                  color: _secondaryText(context)),
                            ),
                            const Spacer(),
                            Text(
                              (service.isExpired ?? false)
                                  ? 'منتهي'
                                  : _cardFormatDate(service.expiryDate)!,
                              style: robotoBold.copyWith(
                                fontSize: 12.5,
                                color: (service.isExpired ?? false)
                                    ? Colors.red.shade600
                                    : _primaryText(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          Container(
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
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.storefront_outlined,
                                size: 16, color: primary),
                          ),
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
                          if (provider?.rating != null) ...[
                            Icon(Icons.star_rounded,
                                size: 14, color: Colors.amber.shade700),
                            const SizedBox(width: 2),
                            Text(
                              provider!.rating!.toStringAsFixed(1),
                              style: robotoBold.copyWith(
                                  fontSize: 12, color: Colors.amber.shade800),
                            ),
                            const SizedBox(width: 6),
                          ],
                          // سهم الكشف يشير جهة اليسار (وليس arrow_forward)
                          // لأن اتجاه القراءة RTL: "المزيد" يقع بصريًا يسار
                          // الصف، فيتّجه السهم لجهة الحركة الطبيعية للعين
                          Icon(Icons.arrow_back_ios_new_rounded,
                              size: 12, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                    if (provider?.phone?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 6),
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

  String _tagsLine(ServiceOffer service) {
    final parts = <String>[];
    if (service.serviceType?.name != null) parts.add(service.serviceType!.name!);
    if (service.categories != null) {
      parts.addAll(service.categories!.map((c) => c.nameAr ?? c.name ?? ''));
    }
    return parts.where((p) => p.isNotEmpty).join('، ');
  }

  String? _locationLabel(ServiceOffer service) {
    final zones = service.zones;
    if (zones == null || zones.isEmpty) return null;
    if (zones.length == 1) return zones.first.nameAr ?? zones.first.name;
    return '${zones.length} مناطق';
  }
}

// ─── أزرار إجراءات سريعة: اتصال / طلب عبر واتساب / عرض على الخريطة ───────────
// "طلب الخدمة" يفتح واتساب مباشرة (بدون شاشة تفاصيل ولا نظام طلبات خلفي —
// بحسب الاتفاق) والخريطة تفتح موقع أول منطقة تغطية تملك إحداثيات (تقريب
// معقول لعدم وجود إحداثي مقر مستقل لمزود الخدمة).

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
          child: _ActionChip(
            icon: Icons.call_rounded,
            label: 'اتصال',
            color: Colors.blue.shade600,
            onTap: () => _launchUrl('tel:${provider.phone}'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionChip(
            icon: Icons.chat_rounded,
            label: 'طلب الخدمة',
            color: Colors.green.shade600,
            onTap: () => _launchUrl(
              'https://wa.me/${_cleanPhoneForWhatsapp(provider.phone!)}',
            ),
          ),
        ),
        if (zone != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _ActionChip(
              icon: Icons.map_outlined,
              label: 'الخريطة',
              color: Colors.deepOrange.shade400,
              onTap: () => _launchUrl(
                'https://www.google.com/maps/search/?api=1&query=${zone.latitude},${zone.longitude}',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: _isDark(context) ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(fontSize: 11.5, color: color),
              ),
            ),
          ],
        ),
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
  final Widget? topRightBadge;
  final Widget? bottomLeftBadge;

  const _ServiceImageCarousel({
    required this.images,
    this.topRightBadge,
    this.bottomLeftBadge,
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
      child: Stack(
        children: [
          SizedBox(
            height: 170,
            width: double.infinity,
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => CustomImage(
                image: images[i],
                height: 170,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
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
          if (widget.topRightBadge != null)
            Positioned(top: 12, right: 12, child: widget.topRightBadge!),
          if (widget.bottomLeftBadge != null)
            Positioned(bottom: 10, left: 12, child: widget.bottomLeftBadge!),
        ],
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off_outlined, color: primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'فعّل الموقع لعرض الأقرب إليك أولاً',
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
  const _NearbySearchingBanner();

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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.15).animate(
              CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
            ),
            child: Icon(Icons.near_me_rounded, color: primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'جاري البحث عن أقرب مزودي الخدمة إليك...',
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorder(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
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
              Container(
                height: 170,
                color: baseColor,
              ),
              Padding(
                padding: const EdgeInsets.all(14),
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
