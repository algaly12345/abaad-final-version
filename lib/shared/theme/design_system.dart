import 'package:flutter/material.dart';

/// نظام تصميم عالمي (Material 3 + لمسات HIG) — Modern / Minimal / Premium /
/// Clean / Spacious / Accessible / Consistent / Responsive.
///
/// نطاق التطبيق حالياً: تسجيل الدخول، إنشاء حساب، قسم مزود الخدمة بالكامل،
/// وورقة الفلاتر المتقدمة لتصفية الخدمات (FilterBottomSheet) — راجع الشاشات
/// التي تستورد هذا الملف. عمداً لم تُعدَّل [Dimensions]/[styles.dart] العامة
/// حتى لا تتأثر بقية شاشات التطبيق التي لم يُطلب تحديثها.
class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
  static const double huge = 64;

  static const double pagePadding = 16;
  static const double sectionGap = 24;
  static const double itemGap = 16;
}

class AppRadius {
  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double extraLarge = 20;
  static const double bottomSheet = 24;
}

/// IBM Plex Sans Arabic هو خط الهوية العربية للتطبيق — الالتزام به بدل
/// استبداله بخط عالمي عام، مع تطبيق مقاييس/أوزان النظام المطلوبة
/// (Display..Badge) عليه فقط.
class AppTypography {
  static const String _family = 'IBMPlexSansArabic';

  static const TextStyle display = TextStyle(
      fontFamily: _family, fontSize: 40, fontWeight: FontWeight.w700, height: 1.15);
  static const TextStyle h1 = TextStyle(
      fontFamily: _family, fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);
  static const TextStyle h2 = TextStyle(
      fontFamily: _family, fontSize: 28, fontWeight: FontWeight.w700, height: 1.2);
  static const TextStyle h3 = TextStyle(
      fontFamily: _family, fontSize: 24, fontWeight: FontWeight.w600, height: 1.25);
  static const TextStyle title = TextStyle(
      fontFamily: _family, fontSize: 20, fontWeight: FontWeight.w600, height: 1.3);
  static const TextStyle subtitle = TextStyle(
      fontFamily: _family, fontSize: 18, fontWeight: FontWeight.w500, height: 1.3);
  static const TextStyle body = TextStyle(
      fontFamily: _family, fontSize: 16, fontWeight: FontWeight.w400, height: 1.4);
  static const TextStyle bodyMedium = TextStyle(
      fontFamily: _family, fontSize: 16, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle bodyBold = TextStyle(
      fontFamily: _family, fontSize: 16, fontWeight: FontWeight.w700, height: 1.4);
  static const TextStyle small = TextStyle(
      fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w400, height: 1.4);
  static const TextStyle smallMedium = TextStyle(
      fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static const TextStyle smallBold = TextStyle(
      fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w700, height: 1.4);
  static const TextStyle caption = TextStyle(
      fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w400, height: 1.35);
  static const TextStyle captionMedium = TextStyle(
      fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w500, height: 1.35);
  static const TextStyle badge = TextStyle(
      fontFamily: _family, fontSize: 10, fontWeight: FontWeight.w500, height: 1.2);
}

class ButtonSpec {
  static const double primaryHeight = 48;
  static const double largeHeight = 56;
  static const double smallHeight = 36;
  static const double radius = 12;
  static const double hPadding = 24;
  static const double vPadding = 12;
}

class FieldSpec {
  static const double height = 56;
  static const double radius = 12;
  static const double padding = 16;
  static const double iconSize = 24;
}

class CardSpec {
  static const double radius = 16;
  static const double padding = 16;
}

class IconSpec {
  static const double small = 20;
  static const double defaultSize = 24;
  static const double large = 28;
}

class AppBarSpec {
  static const double height = 64;
  static const double hPadding = 16;
}

class SearchSpec {
  static const double height = 56;
  static const double radius = 28;
}

class FabSpec {
  static const double size = 56;
}

class ChipSpec {
  static const double height = 32;
  static const double radius = 16;
}

class DialogSpec {
  static const double radius = 20;
  static const double padding = 24;
}

class BottomSheetSpec {
  static const double radius = 24;
  static const double padding = 24;
}

class AvatarSpec {
  static const double small = 32;
  static const double medium = 40;
  static const double large = 56;
  static const double profile = 80;
}

class AnimSpec {
  static const Duration tap = Duration(milliseconds: 100);
  static const Duration button = Duration(milliseconds: 150);
  static const Duration card = Duration(milliseconds: 200);
  static const Duration dialog = Duration(milliseconds: 250);
  static const Duration bottomSheet = Duration(milliseconds: 300);
}

/// ظل ناعم موحّد (Blur 8–16 / Opacity 6–10%) — بديل موحّد لأي BoxShadow
/// متفرق بقيم عشوائية عبر الشاشات المستهدفة.
class AppShadows {
  static List<BoxShadow> soft({double blur = 12, double opacity = 0.08}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> card(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? [] : soft(blur: 10, opacity: 0.06);
  }
}

/// ألوان دلالية (semantic) تُستمَد من الثيم الحالي بدل قيم ثابتة، حتى تعمل
/// صحيحاً في الوضعين الفاتح والداكن.
class AppColors {
  static Color primary(BuildContext c) => Theme.of(c).primaryColor;
  static Color surface(BuildContext c) => Theme.of(c).cardColor;
  static Color background(BuildContext c) => Theme.of(c).scaffoldBackgroundColor;
  static Color border(BuildContext c) => Theme.of(c).dividerColor;
  static Color divider(BuildContext c) => Theme.of(c).dividerColor;

  static const Color success = Color(0xFF1FAA59);
  static const Color warning = Color(0xFFF5A623);
  static const Color danger = Color(0xFFE53935);
  static const Color info = Color(0xFF2F80ED);

  static Color textPrimary(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? Colors.white : const Color(0xFF1A2340);
  static Color textSecondary(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark
          ? Colors.white.withValues(alpha: 0.65)
          : Colors.grey.shade600;
}

/// حقل نصي موحّد بمقاييس النظام (Height 56 / Radius 12 / Padding 16 / Icon 24)
/// — يوفَّر هنا مرة واحدة ليُستخدم في كل شاشات النطاق المستهدف بدل تكرار نفس
/// الـ decoration يدوياً في كل حقل.
InputDecoration dsInputDecoration(
  BuildContext context, {
  String? label,
  String? hint,
  IconData? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
}) {
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(FieldSpec.radius),
    borderSide: BorderSide(color: AppColors.border(context)),
  );
  return InputDecoration(
    isDense: false,
    labelText: label,
    hintText: hint,
    hintStyle: AppTypography.body.copyWith(color: AppColors.textSecondary(context)),
    labelStyle: AppTypography.body.copyWith(color: AppColors.textSecondary(context)),
    floatingLabelStyle: AppTypography.smallMedium.copyWith(color: AppColors.primary(context)),
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, size: FieldSpec.iconSize, color: AppColors.textSecondary(context))
        : null,
    suffixIcon: suffixIcon,
    errorText: errorText,
    contentPadding: const EdgeInsets.symmetric(
        horizontal: FieldSpec.padding, vertical: FieldSpec.padding),
    filled: true,
    fillColor: AppColors.surface(context),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: AppColors.primary(context), width: 1.6),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.danger, width: 1.4),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
    ),
  );
}

/// زر أساسي موحّد (Height 48 / Radius 12) بعرض كامل افتراضياً.
class DSPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool large;
  final IconData? icon;

  const DSPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.large = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return SizedBox(
      width: double.infinity,
      height: large ? ButtonSpec.largeHeight : ButtonSpec.primaryHeight,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary.withValues(alpha: 0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: ButtonSpec.hPadding),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ButtonSpec.radius)),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: IconSpec.defaultSize),
                    const SizedBox(width: Spacing.sm),
                  ],
                  Text(label, style: AppTypography.bodyBold.copyWith(color: Colors.white)),
                ],
              ),
      ),
    );
  }
}

/// زر ثانوي (outline) بنفس ارتفاع الزر الأساسي.
class DSSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool large;

  const DSSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return SizedBox(
      width: double.infinity,
      height: large ? ButtonSpec.largeHeight : ButtonSpec.primaryHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: ButtonSpec.hPadding),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ButtonSpec.radius)),
        ),
        child: Text(label, style: AppTypography.bodyBold.copyWith(color: primary)),
      ),
    );
  }
}

/// بطاقة موحّدة (Radius 16 / Padding 16 / ظل ناعم / بلا حدود ثقيلة).
class DSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const DSCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface(context),
      borderRadius: BorderRadius.circular(CardSpec.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CardSpec.radius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(CardSpec.padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CardSpec.radius),
            boxShadow: AppShadows.card(context),
          ),
          child: child,
        ),
      ),
    );
  }
}
