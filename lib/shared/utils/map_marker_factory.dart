import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// شارة صغيرة دائرية تُرسم فوق شريحة السعر (خدمات / جولة افتراضية / فيديو).
class MarkerBadge {
  final IconData icon;
  final Color color;
  const MarkerBadge(this.icon, this.color);

  String get cacheKey => '${icon.codePoint}-${color.value}';
}

/// مصنع أيقونات الخريطة (بديل مكتبة custom_map_markers).
///
/// المكتبة القديمة كانت ترسم كل ماركر كـ Widget خارج الشاشة ثم تلتقط له
/// صورة (RepaintBoundary.toImage) — لكل ماركر، وفي كل مرة تتغير القائمة.
/// وهذا أثقل شيء في الشاشة.
///
/// هنا نرسم "شريحة السعر" مباشرة على Canvas (أجزاء من الملّي ثانية)،
/// ونحفظ كل أيقونة في كاش بحسب (النص + الألوان). الأسعار تتكرر كثيرًا،
/// فأغلب الماركرات بعد أول تحميل تأتي من الكاش فورًا — نفس فكرة تطبيق عقار.
///
/// يتطلب google_maps_flutter >= 2.6.0 (بسبب BitmapDescriptor.bytes).
class MapMarkerFactory {
  MapMarkerFactory._();

  static final Map<String, BitmapDescriptor> _cache = {};
  static final Map<String, Future<BitmapDescriptor>> _inFlight = {};

  static const String _fontFamily = 'IBMPlexSansArabic';
  static final RegExp _arabic = RegExp(r'[\u0600-\u06FF]');

  static double get _dpr {
    final views = ui.PlatformDispatcher.instance.views;
    return views.isNotEmpty ? views.first.devicePixelRatio : 2.0;
  }

  /// شريحة نص (سعر أو اسم منطقة) مع سهم صغير اختياري في الأسفل.
  static Future<BitmapDescriptor> pill({
    required String text,
    required Color background,
    required Color textColor,
    required Color borderColor,
    List<Color>? gradient,
    Color? dotColor,
    List<MarkerBadge> badges = const [],
    bool withPointer = true,
    double fontSize = 11,
    double borderWidth = 1.2,
    double maxTextWidth = 140,
  }) {
    final key = [
      'pill',
      text,
      background.value,
      textColor.value,
      borderColor.value,
      gradient?.map((c) => c.value).join(','),
      dotColor?.value,
      badges.map((b) => b.cacheKey).join(','),
      withPointer,
      fontSize,
      borderWidth,
      maxTextWidth,
    ].join('|');

    final cached = _cache[key];
    if (cached != null) return Future.value(cached);

    return _inFlight.putIfAbsent(key, () async {
      try {
        final d = await _drawPill(
          text: text,
          background: background,
          textColor: textColor,
          borderColor: borderColor,
          gradient: gradient,
          dotColor: dotColor,
          badges: badges,
          withPointer: withPointer,
          fontSize: fontSize,
          borderWidth: borderWidth,
          maxTextWidth: maxTextWidth,
        );
        _cache[key] = d;
        return d;
      } finally {
        _inFlight.remove(key);
      }
    });
  }

  /// أيقونة من صورة Assets بحجم منطقي محدد (مع كاش).
  static Future<BitmapDescriptor> asset(String path, double logicalSize) {
    final key = 'asset|$path|$logicalSize';
    final cached = _cache[key];
    if (cached != null) return Future.value(cached);

    return _inFlight.putIfAbsent(key, () async {
      try {
        final dpr = _dpr;
        final data = await rootBundle.load(path);
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(),
          targetWidth: (logicalSize * dpr).round(),
        );
        final frame = await codec.getNextFrame();
        final png =
        await frame.image.toByteData(format: ui.ImageByteFormat.png);
        frame.image.dispose();
        final d = BitmapDescriptor.bytes(
          png!.buffer.asUint8List(),
          imagePixelRatio: dpr,
        );
        _cache[key] = d;
        return d;
      } finally {
        _inFlight.remove(key);
      }
    });
  }

  /// ماركر العقار بتصميم جديد (قريب من تطبيق عقار):
  /// كبسولة مستديرة بالسعر بخط واضح، وبجانبه أيقونات ملوّنة واضحة داخل
  /// نفس الكبسولة لكل ميزة: خدمات مزودين / جولة افتراضية / فيديو.
  static Future<BitmapDescriptor> estate({
    required String price,
    required Color primary,
    bool selected = false,
    bool hasOffer = false,
    bool hasTour = false,
    bool hasVideo = false,
  }) {
    final key = [
      'estate', price, primary.value, selected, hasOffer, hasTour, hasVideo,
    ].join('|');

    final cached = _cache[key];
    if (cached != null) return Future.value(cached);

    return _inFlight.putIfAbsent(key, () async {
      try {
        final d = await _drawEstate(
          price: price,
          primary: primary,
          selected: selected,
          features: [
            if (hasOffer) offerFeature,
            if (hasTour) tourFeature,
            if (hasVideo) videoFeature,
          ],
          hasOffer: hasOffer,
        );
        _cache[key] = d;
        return d;
      } finally {
        _inFlight.remove(key);
      }
    });
  }

  static const MarkerBadge offerFeature =
  MarkerBadge(Icons.local_offer_rounded, Color(0xFFF97316));
  static const MarkerBadge tourFeature =
  MarkerBadge(Icons.threesixty_rounded, Color(0xFF7C3AED));
  static const MarkerBadge videoFeature =
  MarkerBadge(Icons.play_arrow_rounded, Color(0xFFE11D48));

  static Future<BitmapDescriptor> _drawEstate({
    required String price,
    required Color primary,
    required bool selected,
    required List<MarkerBadge> features,
    required bool hasOffer,
  }) async {
    final dpr = _dpr;

    final double fontSize = selected ? 13.5 : 12.5;
    const double hPad = 10;
    const double vPad = 5;
    const double iconD = 18; // قطر دائرة الميزة
    const double iconGap = 3;
    const double dividerGap = 7;
    const double pointerH = 7;
    const double pointerW = 12;
    const double pad = 5; // مساحة للظل

    final Color bg = selected ? primary : Colors.white;
    final Color fg = selected ? Colors.white : const Color(0xFF111827);
    final Color border = selected
        ? Colors.white
        : (hasOffer ? const Color(0xFFF97316) : const Color(0xFFD1D5DB));
    final double borderW = selected ? 2 : (hasOffer ? 1.8 : 1);

    final tp = TextPainter(
      text: TextSpan(
        text: price,
        style: TextStyle(
          color: fg,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          fontFamily: _fontFamily,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.rtl,
      maxLines: 1,
    )..layout();

    final int n = features.length;
    final double iconsW = n == 0 ? 0 : n * iconD + (n - 1) * iconGap;
    final double innerH = tp.height > iconD ? tp.height : iconD;
    final double bodyH = innerH + vPad * 2;
    final double bodyW =
        hPad * 2 + tp.width + (n == 0 ? 0 : dividerGap * 2 + 1 + iconsW);
    final double totalW = bodyW + pad * 2;
    // طرف السهم عند أسفل الصورة تمامًا = نقطة الربط الافتراضية (0.5, 1)
    // فيقع السهم على موقع العقار بالضبط.
    final double totalH = pad + bodyH + pointerH + 1;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(dpr);

    final body = Rect.fromLTWH(pad, pad, bodyW, bodyH);
    final cx = body.center.dx;
    final shape = Path.combine(
      PathOperation.union,
      Path()..addRRect(RRect.fromRectAndRadius(body, Radius.circular(bodyH / 2))),
      Path()
        ..moveTo(cx - pointerW / 2, body.bottom - 1)
        ..lineTo(cx, body.bottom + pointerH)
        ..lineTo(cx + pointerW / 2, body.bottom - 1)
        ..close(),
    );

    canvas.drawShadow(shape, Colors.black.withOpacity(0.45), 3, false);
    canvas.drawPath(shape, Paint()..color = bg..isAntiAlias = true);
    canvas.drawPath(
      shape,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderW
        ..color = border,
    );

    // الترتيب من اليمين لليسار (مناسب للعربي): السعر يمين، الميزات يسار.
    double x = body.left + hPad;
    if (n > 0) {
      for (final f in features) {
        final c = Offset(x + iconD / 2, body.center.dy);
        canvas.drawCircle(
          c,
          iconD / 2,
          Paint()..color = selected ? Colors.white : f.color,
        );
        final ip = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(f.icon.codePoint),
            style: TextStyle(
              fontFamily: f.icon.fontFamily,
              package: f.icon.fontPackage,
              fontSize: 13,
              height: 1.0,
              color: selected ? f.color : Colors.white,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        ip.paint(canvas, Offset(c.dx - ip.width / 2, c.dy - ip.height / 2));
        x += iconD + iconGap;
      }
      x += dividerGap - iconGap;
      canvas.drawLine(
        Offset(x, body.center.dy - 7),
        Offset(x, body.center.dy + 7),
        Paint()
          ..strokeWidth = 1
          ..color = selected
              ? Colors.white.withOpacity(0.6)
              : const Color(0xFFE5E7EB),
      );
      x += 1 + dividerGap;
    }
    tp.paint(canvas, Offset(x, body.center.dy - tp.height / 2));

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (totalW * dpr).ceil(),
      (totalH * dpr).ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
  }

  static void clearCache() => _cache.clear();

  static Future<BitmapDescriptor> _drawPill({
    required String text,
    required Color background,
    required Color textColor,
    required Color borderColor,
    List<Color>? gradient,
    Color? dotColor,
    required List<MarkerBadge> badges,
    required bool withPointer,
    required double fontSize,
    required double borderWidth,
    required double maxTextWidth,
  }) async {
    final dpr = _dpr;

    const double hPad = 8;
    const double vPad = 4;
    const double radius = 8;
    const double pointerH = 6;
    const double pointerW = 10;
    const double shadowPad = 3;
    const double dotSize = 6;
    const double dotGap = 4;

    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: _fontFamily,
          height: 1.2,
        ),
      ),
      textDirection:
      _arabic.hasMatch(text) ? TextDirection.rtl : TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxTextWidth);

    // الشارات: صف دوائر صغيرة فوق الشريحة، متداخلة قليلًا مع حافتها العلوية.
    const double badgeD = 16;
    const double badgeGap = 2;
    const double badgeOverlap = 4;
    final int nBadges = badges.length;
    final double badgesW =
    nBadges == 0 ? 0 : nBadges * badgeD + (nBadges - 1) * badgeGap;
    final double badgesExtraH = nBadges == 0 ? 0 : badgeD - badgeOverlap;

    final double dotSpace = dotColor != null ? dotSize + dotGap : 0;
    final double bodyW = tp.width + hPad * 2 + dotSpace;
    final double bodyH = tp.height + vPad * 2;
    final double contentW = bodyW > badgesW ? bodyW : badgesW;
    final double totalW = contentW + shadowPad * 2;
    final double totalH = badgesExtraH +
        bodyH +
        (withPointer ? pointerH : 0) +
        shadowPad * 2;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(dpr);

    // الشريحة في منتصف العرض حتى يبقى السهم في منتصف الأيقونة (نقطة الربط).
    final bodyRect = Rect.fromLTWH(
      shadowPad + (contentW - bodyW) / 2,
      shadowPad + badgesExtraH,
      bodyW,
      bodyH,
    );
    Path shape = Path()
      ..addRRect(RRect.fromRectAndRadius(bodyRect, const Radius.circular(radius)));

    if (withPointer) {
      final cx = bodyRect.center.dx;
      final pointer = Path()
        ..moveTo(cx - pointerW / 2, bodyRect.bottom - 1)
        ..lineTo(cx, bodyRect.bottom + pointerH)
        ..lineTo(cx + pointerW / 2, bodyRect.bottom - 1)
        ..close();
      shape = Path.combine(PathOperation.union, shape, pointer);
    }

    canvas.drawShadow(shape, Colors.black.withOpacity(0.35), 2, false);

    final fill = Paint()..isAntiAlias = true;
    if (gradient != null && gradient.length >= 2) {
      fill.shader = ui.Gradient.linear(
        bodyRect.topLeft,
        bodyRect.bottomRight,
        gradient,
      );
    } else {
      fill.color = background;
    }
    canvas.drawPath(shape, fill);

    canvas.drawPath(
      shape,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..color = borderColor,
    );

    double textX = bodyRect.left + hPad;
    if (dotColor != null) {
      canvas.drawCircle(
        Offset(bodyRect.left + hPad + dotSize / 2, bodyRect.center.dy),
        dotSize / 2,
        Paint()..color = dotColor,
      );
      textX += dotSpace;
    }
    tp.paint(canvas, Offset(textX, bodyRect.top + vPad));

    if (nBadges > 0) {
      double x = shadowPad + (contentW - badgesW) / 2;
      const double r = badgeD / 2;
      final double cy = shadowPad + r;
      for (final b in badges) {
        final center = Offset(x + r, cy);
        canvas.drawCircle(
          center.translate(0, 0.8),
          r,
          Paint()..color = Colors.black.withOpacity(0.25),
        );
        canvas.drawCircle(center, r, Paint()..color = Colors.white);
        canvas.drawCircle(center, r - 1.6, Paint()..color = b.color);

        final ip = TextPainter(
          text: TextSpan(
            text: String.fromCharCode(b.icon.codePoint),
            style: TextStyle(
              fontFamily: b.icon.fontFamily,
              package: b.icon.fontPackage,
              fontSize: 10,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        ip.paint(
          canvas,
          Offset(center.dx - ip.width / 2, center.dy - ip.height / 2),
        );
        x += badgeD + badgeGap;
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      (totalW * dpr).ceil(),
      (totalH * dpr).ceil(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
  }
}