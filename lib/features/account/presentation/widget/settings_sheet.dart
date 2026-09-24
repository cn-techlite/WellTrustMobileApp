import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/state/theme_state.dart';

/// Text size and appearance, as in the design's Settings page.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeNotifierProvider);
    final size = ref.watch(textSizeProvider);

    Widget title(String t) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        t,
        style: TextStyle(
          fontFamily: 'Playfair Display',
          fontWeight: FontWeight.w700,
          fontSize: 19,
          color: AppColors.ink,
        ),
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.w700,
                fontSize: 24,
                color: AppColors.ink,
              ),
            ),
            title('Text size'),
            SegmentTabs(
              active: size.name,
              onChanged: (v) => ref
                  .read(textSizeProvider.notifier)
                  .set(TextSizeOption.values.firstWhere((o) => o.name == v)),
              options: [
                for (final o in TextSizeOption.values) (o.name, o.label),
              ],
            ),
            title('Appearance'),
            SegmentTabs(
              active: mode.name,
              onChanged: (v) => ref
                  .read(themeNotifierProvider.notifier)
                  .setMode(ThemeMode.values.firstWhere((m) => m.name == v)),
              options: const [
                ('system', 'Match phone'),
                ('light', 'Light'),
                ('dark', 'Dark'),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
