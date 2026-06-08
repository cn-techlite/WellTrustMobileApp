import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';

class BizoraCheckBoxWidget extends StatelessWidget {
  const BizoraCheckBoxWidget({
    super.key,
    required this.onChanged,
    this.isChecked = false,
  });

  final Function(bool) onChanged;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isChecked ? Colors.transparent : Colors.transparent,
          border: Border.all(
            color: isChecked ? AppColors.black : AppColors.grey,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: isChecked
            ? Icon(Icons.check, size: 18, color: AppColors.primaryDark)
            : null,
      ),
    );
  }
}
