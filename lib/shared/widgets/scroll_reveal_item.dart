import 'package:flutter/material.dart';

/// يمنح أي عنصر داخل قائمة/شبكة قابلة للتمرير حركة ظهور مرتبطة فعليًا بموضعه
/// من الشاشة (تلاشي + تكبير خفيف + انزلاق بسيط) بدل ظهور القائمة دفعة واحدة
/// وبشكل ثابت كلاسيكي — الحركة تتجدد تلقائيًا مع كل تمرير صعودًا أو نزولًا،
/// وليس مرة واحدة فقط عند أول تحميل.
///
/// يتطلب [scrollController] نفسه المستخدم في الـ ScrollView الأب حتى يحسب كل
/// عنصر موضعه الحقيقي من الشاشة عند كل حدث تمرير.
class ScrollRevealItem extends StatefulWidget {
  final Widget child;
  final ScrollController scrollController;

  const ScrollRevealItem({
    super.key,
    required this.child,
    required this.scrollController,
  });

  @override
  State<ScrollRevealItem> createState() => _ScrollRevealItemState();
}

class _ScrollRevealItemState extends State<ScrollRevealItem> {
  final GlobalKey _key = GlobalKey();
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_update);
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(covariant ScrollRevealItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_update);
      widget.scrollController.addListener(_update);
      WidgetsBinding.instance.addPostFrameCallback((_) => _update());
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;

    final screenHeight = MediaQuery.sizeOf(context).height;
    final top = box.localToGlobal(Offset.zero).dy;
    final center = top + box.size.height / 2;

    const edgeZone = 130.0;
    double progress = 1.0;
    if (center < edgeZone) {
      progress = (center / edgeZone).clamp(0.0, 1.0);
    } else if (center > screenHeight - edgeZone) {
      progress = ((screenHeight - center) / edgeZone).clamp(0.0, 1.0);
    }

    if ((progress - _progress).abs() > 0.015) {
      setState(() => _progress = progress);
    }
  }

  @override
  Widget build(BuildContext context) {
    final opacity = 0.25 + 0.75 * _progress;
    final scale = 0.92 + 0.08 * _progress;
    final dy = (1 - _progress) * 18;

    return KeyedSubtree(
      key: _key,
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.center,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
