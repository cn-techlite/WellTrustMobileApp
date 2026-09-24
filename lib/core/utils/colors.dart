import 'package:flutter/material.dart';

/// WellTrust Carer design tokens (navy + gold on cool grey), light and dark.
///
/// Colours are getters that follow [AppColors.dark], which the app root sets
/// from the resolved theme. Legacy names are kept so existing screens follow
/// the design.
class AppColors {
  /// Set by the app root whenever the resolved brightness changes.
  static bool dark = false;

  static Color _t(int light, int darkValue) => Color(dark ? darkValue : light);

  // Fixed
  static const Color white = Color(0xFFFFFFFF);

  // Surfaces
  static Color get outer => _t(0xFFE4E9F2, 0xFF060B16);
  static Color get bg => _t(0xFFF3F5F9, 0xFF0B1322);
  static Color get surface => _t(0xFFFFFFFF, 0xFF141F36);
  static Color get scaffoldBG => bg;
  static Color get darkWhite => bg;
  static Color get baselines => bg;
  static Color get grey3 => bg;
  static Color get grey4 => surface;
  static Color get grey6 => bg;
  static Color get cream => goldBg;

  // Text
  static Color get ink => _t(0xFF12203A, 0xFFE8EDF8);
  static Color get black => ink;
  static Color get ink2 => ink;
  static Color get muted => _t(0xFF55627C, 0xFFA3B0C9);
  static Color get grey1 => muted;
  static Color get grey2 => muted;

  // Lines
  static Color get line => _t(0xFFDBE1EC, 0xFF26344F);
  static Color get grey => line;
  static Color get grey5 => line;
  static Color get stroke => line;
  static Color get disable => line;
  static Color get line2 => _t(0xFF8592AB, 0xFF6A7B9C);

  // Brand (header / masthead) stays navy in both themes
  static Color get navy => _t(0xFF14264A, 0xFF0F1C36);
  static Color get navyDeep => _t(0xFF0F1C36, 0xFF0B1322);
  static const Color navyDeepest = Color(0xFF0B1322);
  static Color get brandMuted => _t(0xFFB9C4DC, 0xFFA9B6D2);
  static Color get darkBlue => navy;
  static Color get primaryDark => navyDeep;

  // Buttons: navy in light, gold in dark. Use onPrimary for the label.
  static Color get primary => _t(0xFF14264A, 0xFFE2BD6B);
  static Color get onPrimary => _t(0xFFFFFFFF, 0xFF0E1B33);

  // Gold
  static Color get gold => _t(0xFFC9A24D, 0xFFE2BD6B);
  static Color get goldBg => _t(0xFFF6EBCF, 0xFF3B2F12);
  static Color get goldDeep => _t(0xFF6F5209, 0xFFEFCF8A);
  static Color get onGold => const Color(0xFF14264A);

  // Status
  static Color get rose => _t(0xFFB42318, 0xFFFF9A8F);
  static Color get red => rose;
  static Color get roseBg => _t(0xFFFDE8E6, 0xFF40191A);
  static Color get sage => _t(0xFF17683A, 0xFF7FDCA6);
  static Color get green => sage;
  static Color get sageBg => _t(0xFFE1F3E8, 0xFF123524);
  static Color get amber => _t(0xFF7F4B00, 0xFFF0C074);
  static Color get warning => amber;
  static Color get amberBg => _t(0xFFFDF0D5, 0xFF3A2A0E);
  static Color get info => _t(0xFF1E4FBF, 0xFF9BBCFF);
  static Color get blue => info;
  static Color get primaryLight => info;
  static Color get infoBg => _t(0xFFE4ECFC, 0xFF172A55);
}
