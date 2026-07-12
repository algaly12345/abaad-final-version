import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isBold;

  const CustomButton({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin,
    this.width,
    this.height,
    this.fontSize,
    this.radius = 12,
    this.icon,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.isBold = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = onPressed == null
        ? Theme.of(context).disabledColor
        : transparent
            ? Colors.transparent
            : color ?? Theme.of(context).primaryColor;

    final Color fgColor = textColor ??
        (transparent ? Theme.of(context).primaryColor : Colors.white);

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: width ?? double.infinity,
        height: height ?? 52,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading ? null : onPressed as void Function()?,
            borderRadius: BorderRadius.circular(radius),
            child: Ink(
              decoration: BoxDecoration(
                color: transparent ? Colors.transparent : bgColor,
                borderRadius: BorderRadius.circular(radius),
                border: transparent
                    ? Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      )
                    : null,
                boxShadow: transparent || onPressed == null
                    ? null
                    : [
                        BoxShadow(
                          color: bgColor.withValues(alpha: 0.30),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(fgColor),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: fgColor, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            buttonText,
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: fontSize ?? 15,
                              fontWeight: isBold
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: fgColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
