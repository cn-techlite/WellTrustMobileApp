import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final VoidCallback? onTap;

  const CustomListTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(height: 25, width: 25, imageUrl),
      title: AppText(
        text: title,
        textAlign: TextAlign.start,
        color: AppColors.black.withAlpha(162),
        fontWeight: FontWeight.w800,
      ),
      subtitle: AppText(
        text: subtitle,
        textAlign: TextAlign.start,
        color: AppColors.black.withValues(alpha: 4),
        fontWeight: FontWeight.w500,
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
      onTap: onTap, // Handle tap event
    );
  }
}
