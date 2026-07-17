import 'package:flutter/material.dart';

// ─── Design tokens (8pt grid + MD3/HIG-lite) — محلية لهذه الشاشة، بنفس روح
// shared/theme/design_system.dart (الألوان الأساسية مأخوذة من نفس هوية
// التطبيق: كحلي غامق #1A3C5E المستخدم في FAB لوحة التحكم الحالية).
class _Palette {
  static const Color navy = Color(0xFF1A3C5E);
  static const Color navyLight = Color(0xFF2E6DA4);
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1A2340);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE9EBF2);
  static const Color discount = Color(0xFFE0342A);
  static const Color available = Color(0xFF1FAA59);
  static const Color star = Color(0xFFFFB300);
  static const Color chipBg = Color(0xFFF1F3F8);
}

const String _fontFamily = 'IBMPlexSansArabic';

class _Type {
  static const TextStyle sectionTitle = TextStyle(
      fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w700, color: _Palette.textPrimary);
  static const TextStyle sectionSubtitle = TextStyle(
      fontFamily: _fontFamily, fontSize: 12.5, fontWeight: FontWeight.w400, color: _Palette.textSecondary);
  static const TextStyle cardTitle = TextStyle(
      fontFamily: _fontFamily, fontSize: 15.5, fontWeight: FontWeight.w700, color: _Palette.textPrimary);
  static const TextStyle cardSubtitle = TextStyle(
      fontFamily: _fontFamily, fontSize: 12.5, fontWeight: FontWeight.w400, color: _Palette.textSecondary);
  static const TextStyle statValue = TextStyle(
      fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w700, color: _Palette.textPrimary);
  static const TextStyle statLabel = TextStyle(
      fontFamily: _fontFamily, fontSize: 10.5, fontWeight: FontWeight.w400, color: _Palette.textSecondary);
  static const TextStyle chip = TextStyle(
      fontFamily: _fontFamily, fontSize: 12.5, fontWeight: FontWeight.w600);
  static const TextStyle tag = TextStyle(
      fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w600, color: _Palette.textSecondary);
  static const TextStyle button = TextStyle(
      fontFamily: _fontFamily, fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white);
  static const TextStyle navLabel = TextStyle(
      fontFamily: _fontFamily, fontSize: 10.5, fontWeight: FontWeight.w500);
  static const TextStyle badge = TextStyle(
      fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white);
}

// ─── Data models ────────────────────────────────────────────────────────────
// حقول جاهزة للربط المباشر بأي استجابة API حقيقية لاحقًا (أسماء الحقول تطابق
// نمط بيانات مزوّدي الخدمة المعتاد: تقييم، صور، حالة توفّر، إحداثيات مسافة...).

class ServiceCategoryModel {
  final String id;
  final String label;
  final IconData icon;

  const ServiceCategoryModel({required this.id, required this.label, required this.icon});
}

class ServiceProviderModel {
  final String id;
  final String name;
  final String title;
  final String coverImageUrl;
  final bool isVerified;
  final bool isAvailable;
  final int? discountPercent;
  final double rating;
  final int reviewsCount;
  final int completedServices;
  final double distanceKm;
  final int arrivalMinutes;
  final List<String> tags;
  final String phone;
  final String categoryId;

  const ServiceProviderModel({
    required this.id,
    required this.name,
    required this.title,
    required this.coverImageUrl,
    this.isVerified = true,
    this.isAvailable = true,
    this.discountPercent,
    required this.rating,
    required this.reviewsCount,
    required this.completedServices,
    required this.distanceKm,
    required this.arrivalMinutes,
    this.tags = const [],
    required this.phone,
    required this.categoryId,
  });
}

// ─── Mock data (استبدل هذه القائمة باستدعاء API الحقيقي عند الربط) ─────────

const List<ServiceCategoryModel> _mockCategories = [
  ServiceCategoryModel(id: 'all', label: 'الكل', icon: Icons.grid_view_rounded),
  ServiceCategoryModel(id: 'electricity', label: 'كهرباء', icon: Icons.electrical_services_rounded),
  ServiceCategoryModel(id: 'plumbing', label: 'سباكة', icon: Icons.plumbing_rounded),
  ServiceCategoryModel(id: 'paint', label: 'دهان', icon: Icons.format_paint_rounded),
  ServiceCategoryModel(id: 'carpentry', label: 'نجارة', icon: Icons.chair_alt_rounded),
  ServiceCategoryModel(id: 'cleaning', label: 'تنظيف', icon: Icons.cleaning_services_rounded),
];

final List<ServiceProviderModel> _mockProviders = [
  const ServiceProviderModel(
    id: 'p1',
    name: 'شركة المهندس',
    title: 'تركيب وصيانة الأنظمة الكهربائية',
    coverImageUrl: 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=800&q=80',
    discountPercent: 15,
    rating: 4.9,
    reviewsCount: 320,
    completedServices: 1200,
    distanceKm: 2.3,
    arrivalMinutes: 15,
    tags: ['كهرباء', 'صيانة'],
    phone: '+966500000001',
    categoryId: 'electricity',
  ),
  const ServiceProviderModel(
    id: 'p2',
    name: 'أكوا سباكة',
    title: 'جميع أعمال السباكة والكشف عن التسربات',
    coverImageUrl: 'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800&q=80',
    discountPercent: 10,
    rating: 4.8,
    reviewsCount: 210,
    completedServices: 980,
    distanceKm: 3.1,
    arrivalMinutes: 20,
    tags: ['سباكة', 'كشف تسربات'],
    phone: '+966500000002',
    categoryId: 'plumbing',
  ),
  const ServiceProviderModel(
    id: 'p3',
    name: 'دهانات الإبداع',
    title: 'دهانات داخلية وخارجية بأعلى جودة',
    coverImageUrl: 'https://images.unsplash.com/photo-1562259949-e8e7689d7828?w=800&q=80',
    discountPercent: 20,
    rating: 4.7,
    reviewsCount: 165,
    completedServices: 640,
    distanceKm: 4.6,
    arrivalMinutes: 25,
    tags: ['دهان', 'تشطيب'],
    phone: '+966500000003',
    categoryId: 'paint',
  ),
  const ServiceProviderModel(
    id: 'p4',
    name: 'نجارة الأصالة',
    title: 'تفصيل وتركيب أثاث خشبي حسب الطلب',
    coverImageUrl: 'https://images.unsplash.com/photo-1601058268499-e52658b8bb88?w=800&q=80',
    isAvailable: false,
    rating: 4.6,
    reviewsCount: 98,
    completedServices: 410,
    distanceKm: 5.2,
    arrivalMinutes: 30,
    tags: ['نجارة', 'أثاث'],
    phone: '+966500000004',
    categoryId: 'carpentry',
  ),
];

// ─── Screen ─────────────────────────────────────────────────────────────────

class ServiceProvidersHomeScreen extends StatefulWidget {
  const ServiceProvidersHomeScreen({super.key});

  @override
  State<ServiceProvidersHomeScreen> createState() => _ServiceProvidersHomeScreenState();
}

class _ServiceProvidersHomeScreenState extends State<ServiceProvidersHomeScreen> {
  String _selectedCategoryId = 'all';
  String _selectedZone = 'الرياض';
  int _selectedNavIndex = 0;

  List<ServiceProviderModel> get _filteredProviders => _selectedCategoryId == 'all'
      ? _mockProviders
      : _mockProviders.where((p) => p.categoryId == _selectedCategoryId).toList();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _Palette.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _TopHeader(selectedZone: _selectedZone, onZoneTap: _openZonePicker),
              const SizedBox(height: 4),
              _CategoryChipsBar(
                categories: _mockCategories,
                selectedId: _selectedCategoryId,
                onSelected: (id) => setState(() => _selectedCategoryId = id),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: _filteredProviders.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _SectionHeader(),
                      );
                    }
                    final provider = _filteredProviders[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _ProviderCard(provider: provider),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _BottomNavBar(
          selectedIndex: _selectedNavIndex,
          onSelected: (i) => setState(() => _selectedNavIndex = i),
        ),
      ),
    );
  }

  static const List<String> _zoneOptions = ['الرياض', 'جدة', 'الدمام', 'مكة المكرمة'];

  void _openZonePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: _ZonePickerSheet(
          zones: _zoneOptions,
          selectedZone: _selectedZone,
          onSelected: (zone) {
            setState(() => _selectedZone = zone);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

// ─── Zone picker sheet ───────────────────────────────────────────────────────

class _ZonePickerSheet extends StatelessWidget {
  final List<String> zones;
  final String selectedZone;
  final ValueChanged<String> onSelected;

  const _ZonePickerSheet({required this.zones, required this.selectedZone, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _Palette.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('اختر المنطقة', style: _Type.sectionTitle),
              ),
            ),
            const SizedBox(height: 12),
            for (final zone in zones)
              ListTile(
                onTap: () => onSelected(zone),
                title: Text(
                  zone,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 14.5,
                    fontWeight: zone == selectedZone ? FontWeight.w700 : FontWeight.w500,
                    color: zone == selectedZone ? _Palette.navy : _Palette.textPrimary,
                  ),
                ),
                trailing: zone == selectedZone
                    ? const Icon(Icons.check_circle_rounded, color: _Palette.navy, size: 20)
                    : null,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Header: bell + search ──────────────────────────────────────────────────

class _TopHeader extends StatelessWidget {
  final String selectedZone;
  final VoidCallback onZoneTap;

  const _TopHeader({required this.selectedZone, required this.onZoneTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _Palette.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(child: _SearchField()),
              const SizedBox(width: 12),
              const _NotificationBell(),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: onZoneTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _Palette.border),
                      ),
                      child: const Icon(Icons.location_on_outlined, size: 15, color: _Palette.navyLight),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _Palette.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      selectedZone,
                      style: const TextStyle(
                        fontFamily: _fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _Palette.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _Palette.chipBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 21, color: _Palette.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'ابحث عن خدمة أو مزود...',
              style: TextStyle(fontFamily: _fontFamily, fontSize: 13.5, color: _Palette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _Palette.chipBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.notifications_none_rounded, size: 22, color: _Palette.textPrimary),
        ),
        Positioned(
          top: 8,
          right: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _Palette.discount,
              border: Border.all(color: _Palette.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Category filter chips ──────────────────────────────────────────────────

class _CategoryChipsBar extends StatelessWidget {
  final List<ServiceCategoryModel> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _CategoryChipsBar({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _Palette.surface,
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category.id == selectedId;
            return _CategoryChip(
              category: category,
              isSelected: isSelected,
              onTap: () => onSelected(category.id),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final ServiceCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.category, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(21),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? _Palette.navy : _Palette.surface,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: isSelected ? _Palette.navy : _Palette.border),
          boxShadow: isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 16, color: isSelected ? Colors.white : _Palette.textSecondary),
            const SizedBox(width: 6),
            Text(
              category.label,
              style: _Type.chip.copyWith(color: isSelected ? Colors.white : _Palette.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مزودو خدمات موثوقون', style: _Type.sectionTitle),
              SizedBox(height: 4),
              Text('الخدمات الأقرب والأفضل لك', style: _Type.sectionSubtitle),
            ],
          ),
        ),
        InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontFamily: _fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _Palette.navyLight,
                  ),
                ),
                Icon(Icons.chevron_left_rounded, size: 18, color: _Palette.navyLight),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Provider card ───────────────────────────────────────────────────────────

class _ProviderCard extends StatelessWidget {
  final ServiceProviderModel provider;

  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProviderCover(provider: provider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsRow(provider: provider),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              provider.name,
                              style: _Type.cardTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (provider.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, size: 16, color: _Palette.navyLight),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider.title,
                  style: _Type.cardSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (provider.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.tags.map((t) => _TagChip(label: t)).toList(),
                  ),
                ],
                const SizedBox(height: 14),
                _ActionButtonsRow(provider: provider),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderCover extends StatelessWidget {
  final ServiceProviderModel provider;

  const _ProviderCover({required this.provider});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            provider.coverImageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const _CoverPlaceholder();
            },
            errorBuilder: (context, error, stackTrace) => const _CoverPlaceholder(),
          ),
          // سكريم علوي خفيف لضمان تباين واضح للشارات فوق أي صورة.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.28), Colors.transparent],
                ),
              ),
            ),
          ),
          if (provider.discountPercent != null)
            Positioned(
              top: 12,
              left: 12,
              child: _Badge(
                label: 'خصم ${provider.discountPercent}%',
                background: _Palette.discount,
                textColor: Colors.white,
              ),
            ),
          Positioned(
            top: 12,
            right: 12,
            child: _Badge(
              label: provider.isAvailable ? 'متاح الآن' : 'غير متاح',
              background: Colors.white.withValues(alpha: 0.95),
              textColor: provider.isAvailable ? _Palette.available : _Palette.textSecondary,
              dotColor: provider.isAvailable ? _Palette.available : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  const _CoverPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_Palette.navyLight.withValues(alpha: 0.16), _Palette.navy.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, size: 32, color: _Palette.navyLight),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color background;
  final Color textColor;
  final Color? dotColor;

  const _Badge({required this.label, required this.background, required this.textColor, this.dotColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dotColor != null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
            ),
            const SizedBox(width: 5),
          ],
          Text(label, style: _Type.badge.copyWith(color: textColor)),
        ],
      ),
    );
  }
}

// ─── Stats row: rating / completed / distance / arrival time ───────────────

class _StatsRow extends StatelessWidget {
  final ServiceProviderModel provider;

  const _StatsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        icon: Icons.star_rounded,
        iconColor: _Palette.star,
        value: provider.rating.toStringAsFixed(1),
        label: '(${provider.reviewsCount}) تقييم',
      ),
      _StatItem(
        icon: Icons.work_outline_rounded,
        value: '+${provider.completedServices}',
        label: 'خدمة منجزة',
      ),
      _StatItem(
        icon: Icons.location_on_outlined,
        value: '${provider.distanceKm.toStringAsFixed(1)} كم',
        label: 'المسافة',
      ),
      _StatItem(
        icon: Icons.access_time_rounded,
        value: '${provider.arrivalMinutes} دقيقة',
        label: 'وقت الوصول',
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0)
            Container(width: 1, height: 30, color: _Palette.border, margin: const EdgeInsets.symmetric(horizontal: 4)),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String value;
  final String label;

  const _StatItem({required this.icon, this.iconColor, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor ?? _Palette.textSecondary),
        const SizedBox(height: 4),
        Text(value, style: _Type.statValue),
        const SizedBox(height: 2),
        Text(label, style: _Type.statLabel, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

// ─── Tag chip ────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _Palette.chipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: _Type.tag),
    );
  }
}

// ─── Action buttons: primary "طلب الخدمة" + call + chat ────────────────────

class _ActionButtonsRow extends StatelessWidget {
  final ServiceProviderModel provider;

  const _ActionButtonsRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _Palette.navy,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.work_outline_rounded, size: 18),
              label: const Text('طلب الخدمة', style: _Type.button),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _SquareIconButton(icon: Icons.call_rounded, onTap: () {}),
        const SizedBox(width: 8),
        _SquareIconButton(icon: Icons.chat_bubble_outline_rounded, onTap: () {}),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SquareIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _Palette.border),
        ),
        child: Icon(icon, size: 19, color: _Palette.navyLight),
      ),
    );
  }
}

// ─── Bottom navigation bar ───────────────────────────────────────────────────

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _BottomNavBar({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _Palette.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Row(
                children: [
                  _NavItem(
                    icon: Icons.grid_view_rounded,
                    label: 'الخدمات',
                    isSelected: selectedIndex == 0,
                    onTap: () => onSelected(0),
                  ),
                  _NavItem(
                    icon: Icons.assignment_outlined,
                    selectedIcon: Icons.assignment_rounded,
                    label: 'طلباتي',
                    isSelected: selectedIndex == 1,
                    onTap: () => onSelected(1),
                  ),
                  const Expanded(child: SizedBox()),
                  _NavItem(
                    icon: Icons.favorite_border_rounded,
                    selectedIcon: Icons.favorite_rounded,
                    label: 'المفضلة',
                    isSelected: selectedIndex == 3,
                    onTap: () => onSelected(3),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    label: 'حسابي',
                    isSelected: selectedIndex == 4,
                    onTap: () => onSelected(4),
                  ),
                ],
              ),
              Positioned(top: -22, child: _AddServiceButton(onTap: () => onSelected(2))),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? _Palette.navy : _Palette.textSecondary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? (selectedIcon ?? icon) : icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: _Type.navLabel.copyWith(color: color, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddServiceButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddServiceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_Palette.navyLight, _Palette.navy],
          ),
          border: Border.all(color: _Palette.surface, width: 4),
          boxShadow: [
            BoxShadow(color: _Palette.navy.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}
