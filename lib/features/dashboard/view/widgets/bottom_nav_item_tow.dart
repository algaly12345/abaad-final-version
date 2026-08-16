import 'package:flutter/material.dart';

/// ملاحظة: نفس اسم الكلاس وباقي الخصائص (name, onTap, isSelected,
/// badgeCount). نفس التصميم البسيط (أيقونة داخل كبسولة صغيرة + نص تحتها)
/// لكن بمقاسات أصغر شوية عشان تدخل في المساحة الفعلية المتاحة في الشريط،
/// ومُغلَّف بالكامل بـ FittedBox كصمّام أمان نهائي — يعني حتى لو المساحة
/// المتاحة قلّت شوية تاني لأي سبب، المحتوى هيتصغّر تلقائيًا بدل ما يعمل
/// overflow زي اللي حصل، بدون أي تأثير ملحوظ على الشكل في الحالة العادية.
class BottomNavItem extends StatelessWidget {
  final IconData? iconData;
  final Function? onTap;
  final bool? isSelected;
  final String? name;
  final int? badgeCount;

  const BottomNavItem({
    super.key,
    this.iconData,
    this.name,
    this.onTap,
    this.isSelected = false,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = isSelected ?? false;
    final Color primaryColor = Theme.of(context).primaryColor;
    const Color inactiveColor = Color(0xFF9CA3AF);
    final bool hasBadge = (badgeCount ?? 0) > 0;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap as GestureTapCallback?,
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withOpacity(0.12),
          highlightColor: Colors.transparent,
          child: FittedBox(
            // صمّام أمان: لن يصغّر شيئًا طالما المساحة كافية، ويمنع أي
            // overflow نهائيًا لو قلّت المساحة المتاحة لأي سبب مستقبلًا.
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 38,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          iconData ?? Icons.circle_outlined,
                          color: selected ? Colors.white : inactiveColor,
                          size: 20,
                        ),
                      ),
                      if (hasBadge)
                        Positioned(
                          right: -2,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            constraints:
                            const BoxConstraints(minWidth: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white, width: 1.5),
                            ),
                            child: Text(
                              (badgeCount! > 9) ? '9+' : '$badgeCount',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 10,
                      fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? primaryColor : inactiveColor,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}