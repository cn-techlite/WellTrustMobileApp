import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/features/account/data/model/user_response_model.dart';

class RegionListTileWidget extends StatelessWidget {
  final DeliveryAddress country;
  final bool isNative;
  final bool isSelected;
  final ValueChanged<DeliveryAddress> onSelectedCountry;

  const RegionListTileWidget({
    super.key,
    required this.country,
    required this.isNative,
    required this.isSelected,
    required this.onSelectedCountry,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor;

    return ListTile(
      onTap: () => onSelectedCountry(country),
      // leading: FlagWidget(code: country.code),
      title: AppText(
        text:
            isNative
                ? "${country.state},${country.city}"
                : "${country.state},${country.city}",
        textAlign: TextAlign.start,

        color: AppColors.black,

        fontWeight: FontWeight.bold,
      ),
      subtitle: AppText(
        text:
            isNative ? country.address.toString() : country.address.toString(),
        textAlign: TextAlign.start,

        color: AppColors.black,

        fontWeight: FontWeight.bold,
      ),
      trailing:
          isSelected == false
              ? Icon(Icons.check, color: selectedColor, size: 26)
              : const SizedBox.shrink(),
    );
  }
}
