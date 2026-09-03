import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Branded, self-drawn hero graphic for the update / maintenance screen.
///
/// No raster asset: a gradient "device" with a glowing badge, sitting inside
/// pulsing brand rings with a few orbiting accent dots. Everything is derived
/// from the active [ThemeData] so it works in light and dark mode.
class UpdateIllustration extends StatefulWidget {
  final bool isUpdate;

  const UpdateIllustration({super.key, required this.isUpdate});

  @override
  State<UpdateIllustration> createState() => _UpdateIllustrationState();
}

class _UpdateIllustrationState extends State<UpdateIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
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
                // Smooth at the loop seam: 0 at both ends, peak in the middle.
                final double pulse = math.sin(t * math.pi);
                final double bob = math.sin(t * 2 * math.pi);
                final double spin = t * 2 * math.pi;

                return SizedBox(
                  width: size,
                  height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Expanding "radar" pulse.
                      Transform.scale(
                        scale: 0.70 + t * 0.34,
                        child: _ring(
                          size * 0.92,
                          primary.withValues(alpha: 0.30 * (1 - t)),
                          2,
                        ),
                      ),

                      // Static concentric rings.
                      _ring(size * 0.92, primary.withValues(alpha: 0.10), 1.5),
                      _ring(size * 0.68, primary.withValues(alpha: 0.14), 1.5),

                      // Soft gradient disc.
                      Container(
                        width: size * 0.68,
                        height: size * 0.68,
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

                      // Orbiting accent dots.
                      ..._orbitDots(size, spin, accent, primary),

                      // The device, gently bobbing.
                      Transform.translate(
                        offset: Offset(0, -bob * size * 0.02),
                        child: _device(size, primary, mid, accent, pulse),
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
    final double radius = size * 0.34;

    return List<Widget>.generate(count, (i) {
      final double angle = spin + i * (2 * math.pi / count);
      final double dot = i.isEven ? 10 : 6;
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

  Widget _device(
    double size,
    Color primary,
    Color mid,
    Color accent,
    double pulse,
  ) {
    final double w = size * 0.34;
    final double h = size * 0.46;
    final double badge = w * 0.54;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(w * 0.30),
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
                color: accent.withValues(alpha: 0.35 + 0.35 * pulse),
                blurRadius: 12 + 10 * pulse,
              ),
            ],
          ),
          child: Icon(
            widget.isUpdate ? Icons.arrow_upward_rounded : Icons.build_rounded,
            color: accent,
            size: badge * 0.58,
          ),
        ),
      ),
    );
  }
}
