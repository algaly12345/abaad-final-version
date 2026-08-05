import 'package:flutter/material.dart';

class BottomNavItem extends StatelessWidget {
  final String? iconData;
  final Function? onTap;
  final bool? isSelected;
  final String? name;

  const BottomNavItem({
    super.key,
    this.iconData,
    this.name,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = isSelected ?? false;
    final Color primaryColor = Theme.of(context).primaryColor;
    const Color inactiveColor = Color(0xFF9CA3AF);

    return Expanded(
      child: GestureDetector(
        onTap: onTap as GestureTapCallback?,
        behavior: HitTestBehavior.opaque,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 مؤشر رفيع أعلى العنصر المختار — يعطي إحساس "تبويب نشط"
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                height: 2,
                width: selected ? 16 : 0,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // 🔹 الأيقونة مع تكبير وخلفية ناعمة عند التحديد
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? primaryColor.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  scale: selected ? 1.08 : 1.0,
                  child: Image.asset(
                    iconData ?? "",
                    color: selected ? primaryColor : inactiveColor,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),

              const SizedBox(height: 2),

              // 🔹 النص مع انتقال سلس بين الحالتين بدل التغيير المفاجئ
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: selected ? 10.5 : 10,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? primaryColor : inactiveColor,
                  height: 1.1,
                ),
                child: Text(
                  name ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}