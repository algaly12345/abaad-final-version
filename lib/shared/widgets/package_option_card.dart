import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:flutter/material.dart';

/// عنصر ميزة واحد داخل بطاقة الباقة (مثال: "1 إعلانات"، "2 مناطق").
class PackageFeatureItem {
  final String label;
  final IconData icon;
  const PackageFeatureItem(this.label, this.icon);
}

/// بطاقة اختيار باقة موحّدة — نُسخت من التصميم المضمّن سابقًا في
/// add_property_service_offer_screen.dart (خطوة اختيار الباقة) واستُخرجت هنا
/// لتُستخدم في أي شاشة أخرى تحتاج نفس نمط "اختيار باقة" (حدّ ولون primary
/// عند التحديد، شارة صح، صفّ ميزات قابل للف). نفس نصف قطر الحواف وظل البطاقة
/// المستخدَمين في بطاقة صفحة قائمة الخدمات (_ServiceCard في
/// services_catalog_screen.dart: AppRadius.extraLarge + AppShadows.soft(blur:
/// 16, opacity: داكن؟0.28:0.06)) بدل قيم مختلفة محليًا لكل بطاقة.
class PackageOptionCard extends StatelessWidget {
  final String title;
  final String priceLabel;
  final bool selected;
  final VoidCallback onTap;
  final List<PackageFeatureItem> features;

  const PackageOptionCard({
    super.key,
    required this.title,
    required this.priceLabel,
    required this.selected,
    required this.onTap,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AnimSpec.card,
        padding: const EdgeInsets.all(CardSpec.padding),
        decoration: BoxDecoration(
          // تعبئة أساسية شفافة جدًا (0.05) عند التحديد + حدّ primary، بدل حدّ
          // ملوّن فقط بلا خلفية — الحالة غير المحدَّدة تبقى محايدة تمامًا.
          color: selected ? primary.withValues(alpha: 0.05) : AppColors.surface(context),
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
          border: Border.all(
            color: selected ? primary : AppColors.border(context),
            width: selected ? 1.5 : 1,
          ),
          // ظل ثابت مطابق لبطاقة صفحة قائمة الخدمات — لا يتغيّر بين حالتَي
          // التحديد وعدمه (خلافًا للتصميم السابق الذي كان يُكثّف الظل عند
          // التحديد)، فالحدّ الملوّن وحده كافٍ للتمييز البصري.
          boxShadow: AppShadows.soft(blur: 16, opacity: dark ? 0.28 : 0.06),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? primary : AppColors.background(context),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.workspace_premium_rounded,
                      color: selected ? Colors.white : AppColors.textSecondary(context),
                      size: IconSpec.defaultSize),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppTypography.bodyBold
                              .copyWith(color: AppColors.textPrimary(context))),
                      const SizedBox(height: 4),
                      // تسلسل هرمي واضح: السعر أكبر وأثقل وزنًا من اسم الباقة
                      // أعلاه، وبلون primary دومًا (محدَّدة كانت أم لا) كي يبقى
                      // أبرز عنصر نصّي في البطاقة في كل الحالات.
                      Text(priceLabel,
                          style: AppTypography.title
                              .copyWith(color: primary, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                if (selected)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                  ),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Divider(height: 1, color: AppColors.border(context)),
            const SizedBox(height: Spacing.md),
            // Wrap بدل Row: يمنع فيض العناصر أفقيًا عند تعدّد الميزات أو طول
            // تسمياتها على الشاشات الصغيرة، وينتقل تلقائيًا لسطر جديد.
            Wrap(
              spacing: Spacing.sm,
              runSpacing: Spacing.sm,
              children: features
                  .map((f) => _PackageFeatureChip(
                      label: f.label, icon: f.icon, selected: selected))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageFeatureChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;

  const _PackageFeatureChip({
    required this.label,
    required this.icon,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: selected ? primary.withValues(alpha: 0.1) : AppColors.background(context),
        borderRadius: BorderRadius.circular(ChipSpec.radius),
        border: Border.all(
          color: selected ? primary.withValues(alpha: 0.3) : AppColors.border(context),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: selected ? primary : AppColors.textSecondary(context)),
          const SizedBox(width: 5),
          Text(label,
              style: AppTypography.badge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? primary : AppColors.textSecondary(context))),
        ],
      ),
    );
  }
}
