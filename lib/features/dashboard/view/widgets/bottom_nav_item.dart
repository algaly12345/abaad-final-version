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
    const Color inactiveColor = Color(0xFF9DA3AF);

    return Expanded(
      child: GestureDetector(
        onTap: onTap as GestureTapCallback?,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? primaryColor.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.asset(
                iconData ?? "",
                color: selected ? primaryColor : inactiveColor,
                width: 20,
                height: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              name ?? "",
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? primaryColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
