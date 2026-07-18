import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:flutter/material.dart';

/// بطاقة اختيار نوع/منطقة موحّدة — استُخرجت من _TypeOptionCard في
/// filter_bottom_sheet.dart (قسمَي "المنطقة" و"نوع العقار" في فلاتر قائمة
/// الخدمات) لتُستخدم في أي شاشة أخرى تحتاج نفس نمط بطاقة الاختيار: تصميم
/// مسطّح، حدّ رمادي فاتح وأيقونة/نص رماديان في الحالة غير المحددة، وتعبئة
/// خضراء فاتحة + حدّ وأيقونة ونص بلون primary عند التحديد.
class TypeOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color primary;
  final double width;
  final VoidCallback onTap;
  /// بديل اختياري عن الأيقونة المسطّحة الافتراضية (icon) — يُستخدم في بطاقات
  /// المناطق لعرض خارطة مصغّرة ([ZoneMapIcon]) بدل دبّوس عام.
  final Widget Function(bool isSelected)? leadingBuilder;
  /// أبعاد اختيارية لنسخة مصغّرة من البطاقة (مثال: شبكة كثيفة بدلاً من صفّ
  /// أفقي) — القيم الافتراضية تطابق البطاقة الأصلية في filter_bottom_sheet.dart.
  final double height;
  final double iconBoxSize;
  final double iconSize;
  final double fontSize;
  final double verticalPadding;
  final double iconLabelGap;

  const TypeOptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.width,
    required this.onTap,
    this.leadingBuilder,
    this.height = 118,
    this.iconBoxSize = 36,
    this.iconSize = 18,
    this.fontSize = 11,
    this.verticalPadding = 12,
    this.iconLabelGap = 6,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final unselectedInk = AppColors.textSecondary(context);

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.large),
          child: AnimatedContainer(
            duration: AnimSpec.card,
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: verticalPadding),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: dark ? 0.2 : 0.08)
                  : AppColors.background(context),
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(
                color: isSelected ? primary : AppColors.border(context),
                width: isSelected ? 1.4 : 1,
              ),
              boxShadow: !isSelected && !dark ? AppShadows.soft(blur: 8, opacity: 0.06) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leadingBuilder != null
                    ? leadingBuilder!(isSelected)
                    : Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primary.withValues(alpha: dark ? 0.28 : 0.14)
                              : (dark
                                  ? Colors.white.withValues(alpha: 0.06)
                                  : Colors.grey.shade100),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon,
                            size: iconSize, color: isSelected ? primary : unselectedInk),
                      ),
                SizedBox(height: iconLabelGap),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: (isSelected ? AppTypography.smallBold : AppTypography.smallMedium)
                      .copyWith(
                    fontSize: fontSize,
                    height: 1.2,
                    color: isSelected ? primary : unselectedInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// أيقونة "خارطة مصغّرة" لبطاقة المنطقة — استُخرجت من _ZoneMapIcon في
/// filter_bottom_sheet.dart: مربّع مقرّب الحواف برسم تخطيطي بسيط (طرق منحنية
/// + كتلتا مبانٍ + دبّوس موقع) بدل دبّوس مسطّح عام، تمنح الانطباع البصري
/// بخارطة فعلية لكل منطقة دون الحاجة لجلب صور خرائط حقيقية عبر الإنترنت.
class ZoneMapIcon extends StatelessWidget {
  final bool isSelected;
  final Color primary;
  final double width;
  final double height;

  const ZoneMapIcon({
    super.key,
    required this.isSelected,
    required this.primary,
    this.width = 42,
    this.height = 32,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = isSelected
        ? primary.withValues(alpha: dark ? 0.24 : 0.13)
        : (dark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100);
    final road = isSelected ? primary.withValues(alpha: 0.6) : Colors.grey.shade400;
    final block = isSelected ? primary.withValues(alpha: 0.3) : Colors.grey.shade300;
    final pin = isSelected ? primary : Colors.grey.shade600;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _MiniMapPainter(roadColor: road, blockColor: block, pinColor: pin),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final Color roadColor;
  final Color blockColor;
  final Color pinColor;

  _MiniMapPainter({
    required this.roadColor,
    required this.blockColor,
    required this.pinColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = roadColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.32)
        ..quadraticBezierTo(
            size.width * 0.5, size.height * 0.05, size.width, size.height * 0.38),
      roadPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.18, 0)
        ..quadraticBezierTo(
            size.width * 0.42, size.height * 0.55, size.width * 0.3, size.height),
      roadPaint,
    );

    final blockPaint = Paint()..color = blockColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.06, size.height * 0.58, size.width * 0.22, size.height * 0.24),
        const Radius.circular(1.5),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.64, size.height * 0.12, size.width * 0.26, size.height * 0.22),
        const Radius.circular(1.5),
      ),
      blockPaint,
    );

    final center = Offset(size.width * 0.56, size.height * 0.52);
    canvas.drawCircle(center, size.width * 0.15, Paint()..color = pinColor.withValues(alpha: 0.22));
    canvas.drawCircle(center, size.width * 0.08, Paint()..color = pinColor);
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) =>
      oldDelegate.roadColor != roadColor ||
      oldDelegate.blockColor != blockColor ||
      oldDelegate.pinColor != pinColor;
}
