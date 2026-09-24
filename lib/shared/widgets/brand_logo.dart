import 'package:flutter/material.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';

/// The full WellTrust Healthstaff logo. The wordmark is dark teal, so in dark
/// mode it sits on a white card to stay readable.
class WellTrustLogo extends StatelessWidget {
  final double height;

  const WellTrustLogo({super.key, this.height = 160});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/welltrust_logo.png',
      height: height,
      semanticLabel: 'WellTrust Healthstaff Ltd',
    );
    if (!AppColors.dark) return image;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: image,
    );
  }
}

/// The stethoscope mark on a white tile, for the navy headers.
class WellTrustMark extends StatelessWidget {
  final double size;

  const WellTrustMark({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Image.asset(
        'assets/images/welltrust_mark.png',
        semanticLabel: 'WellTrust',
      ),
    );
  }
}
