import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static final TextTheme _textTheme = TextTheme(
    // LABELS (smallest)
    labelSmall: TextStyle(
      fontSize: 10.textSize,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    labelMedium: TextStyle(
      fontSize: 12.textSize,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontSize: 14.textSize,
      fontWeight: FontWeight.w600,
      height: 1.3,
    ),

    // BODY
    bodySmall: TextStyle(
      fontSize: 15.textSize,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontSize: 18.textSize,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyLarge: TextStyle(
      fontSize: 21.textSize,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),

    // TITLE
    titleSmall: TextStyle(
      fontSize: 18.textSize,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    titleMedium: TextStyle(
      fontSize: 21.textSize,
      fontWeight: FontWeight.w700,
      height: 1.4,
    ),
    titleLarge: TextStyle(
      fontSize: 24.textSize,
      fontWeight: FontWeight.bold,
      height: 1.3,
    ),

    // HEADLINE
    headlineSmall: TextStyle(
      fontSize: 21.textSize,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    headlineMedium: TextStyle(
      fontSize: 25.textSize,
      fontWeight: FontWeight.w800,
      height: 1.3,
    ),
    headlineLarge: TextStyle(
      fontSize: 30.textSize,
      fontWeight: FontWeight.w900,
      height: 1.2,
    ),

    // DISPLAY (largest)
    displaySmall: TextStyle(
      fontSize: 25.textSize,
      fontWeight: FontWeight.w700,
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 30.textSize,
      fontWeight: FontWeight.w800,
      height: 1.1,
    ),
    displayLarge: TextStyle(
      fontSize: 35.textSize,
      fontWeight: FontWeight.w900,
      height: 1.1,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: "Mulish",
    textTheme: _textTheme,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: "Mulish",
    textTheme: _textTheme,
  );
}

// ENUM APP TEXT TYPE
enum AppTextType {
  displayLarge,
  displayMedium,
  displaySmall,

  headlineLarge,
  headlineMedium,
  headlineSmall,

  titleLarge,
  titleMedium,
  titleSmall,

  bodyLarge,
  bodyMedium,
  bodySmall,

  labelLarge,
  labelMedium,
  labelSmall,
}

extension AppTextTypeExtension on AppTextType {
  TextStyle resolve(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    switch (this) {
      case AppTextType.displayLarge:
        return textTheme.displayLarge!;
      case AppTextType.displayMedium:
        return textTheme.displayMedium!;
      case AppTextType.displaySmall:
        return textTheme.displaySmall!;

      case AppTextType.headlineLarge:
        return textTheme.headlineLarge!;
      case AppTextType.headlineMedium:
        return textTheme.headlineMedium!;
      case AppTextType.headlineSmall:
        return textTheme.headlineSmall!;

      case AppTextType.titleLarge:
        return textTheme.titleLarge!;
      case AppTextType.titleMedium:
        return textTheme.titleMedium!;
      case AppTextType.titleSmall:
        return textTheme.titleSmall!;

      case AppTextType.bodyLarge:
        return textTheme.bodyLarge!;
      case AppTextType.bodyMedium:
        return textTheme.bodyMedium!;
      case AppTextType.bodySmall:
        return textTheme.bodySmall!;

      case AppTextType.labelLarge:
        return textTheme.labelLarge!;
      case AppTextType.labelMedium:
        return textTheme.labelMedium!;
      case AppTextType.labelSmall:
        return textTheme.labelSmall!;
    }
  }

  /// 🔥 Custom style builder
  TextStyle style(
    BuildContext context, {
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    double? height,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return resolve(context).copyWith(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      height: height,
      decoration: decoration,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }
}

class AppText extends StatelessWidget {
  final String text;
  final AppTextType type;

  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final double? letterSpacing;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;

  const AppText({
    super.key,
    required this.text,
    this.type = AppTextType.bodyMedium,
    this.color,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.letterSpacing,
    this.fontWeight,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = type.resolve(context);

    return Text(
      text,
      style: baseStyle.copyWith(
        color: color ?? baseStyle.color,
        letterSpacing: letterSpacing,
        fontWeight: fontWeight ?? baseStyle.fontWeight,
        decoration: decoration,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}
