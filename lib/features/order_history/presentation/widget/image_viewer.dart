import 'package:ginilog_customer_app/core/utils/colors.dart';
import 'package:ginilog_customer_app/core/utils/package_export.dart';
import 'package:ginilog_customer_app/core/utils/size_config.dart';
import 'package:ginilog_customer_app/shared/widgets/app_text.dart';
import 'package:ginilog_customer_app/shared/widgets/back_icon.dart';

class ZoomableImageViewer extends StatelessWidget {
  final String imageUrl;

  const ZoomableImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildFlexibleAppBar(
        context: context,
        title: const AppText(
          text: "",
          textAlign: TextAlign.start,
          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: SizedBox(
        height: SizeConfig.heightAdjusted(100),
        width: SizeConfig.widthAdjusted(100),
        child: InteractiveViewer(
          panEnabled: true, // Allows panning
          minScale: 0.5, // Minimum zoom scale
          maxScale: 5.0, // Maximum zoom scale
          child: Image.network(imageUrl, fit: BoxFit.fill),
        ),
      ),
    );
  }
}
