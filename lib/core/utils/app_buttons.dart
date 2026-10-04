import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double widthPercent;
  final double heightPercent;
  final Color? btnColor;
  final bool isLoading;
  final Color? textColor;
  final double fontSize;
  final double borderRadius;
  final bool safeArea;
  final Widget? child;
  final bool expand;
  final double compactHeight;
  final EdgeInsetsGeometry compactPadding;
  // Optional border settings
  final Color? borderColor;
  final double borderWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.widthPercent = 100,
    this.heightPercent = 6,
    this.btnColor,
    this.isLoading = false,
    this.textColor,
    this.fontSize = 12,
    this.borderRadius = 12,
    this.safeArea = false,
    this.child,
    this.expand = true,
    this.compactHeight = 44,
    this.compactPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.borderColor,
    this.borderWidth = 1.5,
  });

  Color get _bg => btnColor ?? AppColors.primary;
  // A plain white label is treated as "automatic" so buttons stay readable on
  // the light gold used in dark mode.
  Color get _fg =>
      (textColor != null && textColor != Colors.white ? textColor : null) ??
      (_bg.computeLuminance() > 0.5 ? const Color(0xFF0E1B33) : Colors.white);

  @override
  Widget build(BuildContext context) {
    final button = DecoratedBox(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      child: _buildButton(context),
    );

    if (!expand) {
      return SizedBox(height: compactHeight, child: button);
    }

    return BoxSizer(
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      safeArea: safeArea,
      child: button,
    );
  }

  Widget _buildButton(BuildContext context) {
    return CupertinoButton(
      onPressed: isLoading ? null : onPressed,
      padding: expand ? EdgeInsets.zero : compactPadding,
      borderRadius: BorderRadius.circular(borderRadius),
      color: Colors.transparent,
      // disabledColor: isLoading ? btnColor : btnColor,
      child: isLoading
          ? SpinKitThreeBounce(
              color: isLoading ? borderColor ?? AppColors.white : borderColor,
              size: 16,
            )
          : child ??
                AppText(
                  text: text,
                  textAlign: TextAlign.center,
                  color: _fg,
                  fontWeight: FontWeight.w600,
                  type: AppTextType.labelMedium,
                ),
    );
  }
}
