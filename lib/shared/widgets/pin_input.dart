import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';

/// Row of PIN boxes in the design's input style.
class AppPinInput extends StatelessWidget {
  final int length;
  final TextEditingController? controller;
  final bool obscure;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const AppPinInput({
    super.key,
    this.length = 5,
    this.controller,
    this.obscure = false,
    this.enabled = true,
    this.onChanged,
    this.onCompleted,
  });

  PinTheme _theme(Color border, double width) => PinTheme(
    width: 56,
    height: 56,
    textStyle: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.ink,
    ),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: border, width: width),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: length,
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      obscuringCharacter: '●',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      defaultPinTheme: _theme(AppColors.line2, 1.5),
      focusedPinTheme: _theme(AppColors.primary, 2),
      submittedPinTheme: _theme(AppColors.line2, 1.5),
      onChanged: onChanged,
      onCompleted: onCompleted,
    );
  }
}
