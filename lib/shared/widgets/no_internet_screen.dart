import 'dart:math' as math;

import 'package:abaad_flutter/shared/widgets/custom_button.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// شاشة "لا يوجد اتصال بالإنترنت" — أُعيد تصميمها لتتبع نفس لغة نظام التصميم
/// المستخدمة في [UpdateScreen]: خلفية الثيم، رسمة هوية مرسومة برمجيًا مع نبض
/// خفيف (بلا صورة نقطية)، عنوان + وصف مساعد، وزر إعادة محاولة موحّد بحالة
/// تحميل. كل الألوان مشتقّة من [ThemeData] لتعمل صحيحًا في الوضعين الفاتح
/// والداكن.
class NoInternetScreen extends StatefulWidget {
  /// الشاشة التي يُعاد فتحها عند نجاح إعادة المحاولة (السبلاش عادةً).
  final Widget? child;

  const NoInternetScreen({super.key, this.child});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _checking = false;

  Future<void> _retry() async {
    if (_checking) return;
    setState(() => _checking = true);

    // connectivity_plus 6.x يُرجع قائمة. لو لا توجد أي واجهة شبكة نُبقي
    // المستخدم هنا ونُظهر تنبيهًا بدل إعادة تحميل تفشل فورًا.
    final List<ConnectivityResult> status =
        await Connectivity().checkConnectivity();
    final bool hasNetwork =
        status.any((ConnectivityResult r) => r != ConnectivityResult.none);

    if (!mounted) return;

    final Widget? next = widget.child;
    if (!hasNetwork || next == null) {
      setState(() => _checking = false);
      if (!hasNetwork) showCustomSnackBar('no_internet_connection'.tr);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (_) => next),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textPrimary = theme.textTheme.bodyLarge?.color ??
        theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: _OfflineIllustration(),
                    ),
                  ),
                  const SizedBox(height: 36),
                  Text(
                    'no_internet_connection'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'no_internet_desc'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14,
                      height: 1.7,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    buttonText: 'retry'.tr,
                    icon: _checking ? null : Icons.refresh_rounded,
                    margin: EdgeInsets.zero,
                    isLoading: _checking,
                    onPressed: _retry,
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

/// رسمة الهوية للشاشة: قرص متدرّج داخل حلقات نابضة، وبلاطة العلامة في المنتصف
/// تحمل أيقونة "بلا واي فاي" مع نقاط مدارية. مشتقّة بالكامل من [ThemeData]
/// (نفس أسلوب `UpdateIllustration`).
class _OfflineIllustration extends StatefulWidget {
  const _OfflineIllustration();

  @override
  State<_OfflineIllustration> createState() => _OfflineIllustrationState();
}

class _OfflineIllustrationState extends State<_OfflineIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.primaryColor;
    final Color mid = theme.secondaryHeaderColor;
    final Color accent = theme.colorScheme.secondary;

    return RepaintBoundary(
      child: AspectRatio(
        aspectRatio: 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double size = math.min(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final double t = _controller.value; // 0 .. 1
                final double pulse = math.sin(t * math.pi);
                final double bob = math.sin(t * 2 * math.pi);
                final double spin = t * 2 * math.pi;

                return SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // نبضة "رادار" تتمدّد وتتلاشى.
                      Transform.scale(
                        scale: 0.68 + t * 0.36,
                        child: _ring(
                          size * 0.90,
                          primary.withValues(alpha: 0.28 * (1 - t)),
                          2,
                        ),
                      ),

                      // حلقات ثابتة.
                      _ring(size * 0.90, primary.withValues(alpha: 0.10), 1.5),
                      _ring(size * 0.64, primary.withValues(alpha: 0.14), 1.5),

                      // قرص متدرّج ناعم.
                      Container(
                        width: size * 0.64,
                        height: size * 0.64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primary.withValues(alpha: 0.12),
                              mid.withValues(alpha: 0.04),
                            ],
                          ),
                        ),
                      ),

                      // نقاط مدارية.
                      ..._orbitDots(size, spin, accent, primary),

                      // بلاطة العلامة، تطفو برفق.
                      Transform.translate(
                        offset: Offset(0, -bob * size * 0.02),
                        child: _tile(size, primary, mid, accent, pulse),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _ring(double diameter, Color color, double stroke) => Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: stroke),
        ),
      );

  List<Widget> _orbitDots(double size, double spin, Color a, Color b) {
    const int count = 3;
    final double radius = size * 0.33;

    return List<Widget>.generate(count, (i) {
      final double angle = spin + i * (2 * math.pi / count);
      final double dot = i.isEven ? 9 : 6;
      final Color color = i.isEven ? a : b;

      return Transform.translate(
        offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
        child: Container(
          width: dot,
          height: dot,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 8),
            ],
          ),
        ),
      );
    });
  }

  Widget _tile(
    double size,
    Color primary,
    Color mid,
    Color accent,
    double pulse,
  ) {
    final double s = size * 0.42;
    final double badge = s * 0.56;

    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s * 0.30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primary, mid],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.35),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: badge,
          height: badge,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.30 + 0.30 * pulse),
                blurRadius: 12 + 10 * pulse,
              ),
            ],
          ),
          child: Icon(
            Icons.wifi_off_rounded,
            color: accent,
            size: badge * 0.56,
          ),
        ),
      ),
    );
  }
}
