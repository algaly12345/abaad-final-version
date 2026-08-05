import 'package:flutter/material.dart';

import '../../../../shared/utils/images.dart';

/// خلفية شاشة البداية (Splash) — الصورة الجاهزة مع أنيميشن:
/// 1) تلاشي دخول ناعم للصورة كاملة عند فتح الشاشة (fade-in).
/// 2) نبض ضوئي مستمر خلف الدائرة المركزية (نفس موقع أيقونة المنزل بالصورة).
/// 3) شعاع ضوء (shimmer) يمر قطريًا فوق الصورة بشكل متكرر لإحساس بالحيوية.
class SplashBackground extends StatefulWidget {
  const SplashBackground({super.key});

  @override
  State<SplashBackground> createState() => _SplashBackgroundState();
}

class _SplashBackgroundState extends State<SplashBackground>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fade;

  late final AnimationController _glowController;
  late final Animation<double> _glow;

  late final AnimationController _shimmerController;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    // 1) تلاشي دخول الصورة — مرة واحدة عند فتح الشاشة
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    // 2) نبض ضوئي مستمر خلف الدائرة المركزية (المنزل)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 3) شعاع ضوء يمر قطريًا فوق الصورة، يتكرر كل 3 ثواني
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _shimmer = CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // الصورة الأساسية
          Image.asset(
            Images.background, // عدّل المسار حسب مكانه الفعلي بمشروعك
            fit: BoxFit.cover,
          ),

          // نبض ضوئي خلف الدائرة المركزية (تقريبًا عند 50% أفقيًا و30% رأسيًا من الصورة)
          Align(
            alignment: const Alignment(0, -0.42),
            child: AnimatedBuilder(
              animation: _glow,
              builder: (context, child) {
                return Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(_glow.value),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // شعاع ضوء يمر قطريًا فوق كامل الصورة
          AnimatedBuilder(
            animation: _shimmer,
            builder: (context, child) {
              return IgnorePointer(
                child: ShaderMask(
                  blendMode: BlendMode.plus,
                  shaderCallback: (Rect bounds) {
                    final double t = _shimmer.value;
                    return LinearGradient(
                      begin: Alignment(-1.5 + t * 3, -1),
                      end: Alignment(-0.5 + t * 3, 1),
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.10),
                        Colors.transparent,
                      ],
                      stops: const [0.35, 0.5, 0.65],
                    ).createShader(bounds);
                  },
                  child: Container(color: Colors.transparent),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}