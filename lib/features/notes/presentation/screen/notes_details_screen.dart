import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/add_note_bottom_sheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/raise_cocerns_bottomshet.dart';

/// Client profile, in the design's card layout.
class ResidentProfileScreen extends StatefulWidget {
  const ResidentProfileScreen({super.key});

  @override
  State<ResidentProfileScreen> createState() => _ResidentProfileScreenState();
}

class _ResidentProfileScreenState extends State<ResidentProfileScreen> {
  bool showCode = false;

  TextStyle _serif(double size) => TextStyle(
    fontFamily: 'Playfair Display',
    fontWeight: FontWeight.w700,
    fontSize: size,
    color: AppColors.ink,
  );

  Widget _section(String t, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 10),
    child: Row(
      children: [
        Expanded(child: Text(t, style: _serif(19))),
        ?trailing,
      ],
    ),
  );

  Widget _stat(String v, String l) => Expanded(
    child: Column(
      children: [
        Text(v, style: _serif(20)),
        const SizedBox(height: 2),
        Text(
          l,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.muted,
          ),
        ),
      ],
    ),
  );

  Widget _visit(String time, String dur, String title, bool done) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: DesignCard(
      child: Row(
        children: [
          SizedBox(
            width: 58,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  dur,
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
          ),
          done ? Pill.ok('Done') : Pill.neutral('Upcoming'),
        ],
      ),
    ),
  );

  Widget _infoRow(IconData icon, String text, {VoidCallback? onTap}) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.goldDeep),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: AppColors.ink)),
          ),
          if (onTap != null) Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(
          'Anita',
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            fontSize: 19,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anita Patel', style: _serif(22)),
                const SizedBox(height: 2),
                Text(
                  '84 years · 14h/week · 4 calls/day',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.place_outlined, size: 20, color: AppColors.ink),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '14 Linden Avenue, Kettering NN15 6JL',
                        style: TextStyle(color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Pill.warn('Falls risk'),
                    Pill.bad('Allergy: penicillin'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          DesignCard(
            child: Row(
              children: [
                _stat('3', 'VISITS TODAY'),
                _stat('1', 'DONE'),
                _stat('2', 'TO GO'),
                _stat('14h', 'WEEKLY'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DesignButton(
                  'Add note',
                  small: true,
                  icon: Icons.edit_outlined,
                  onPressed: () =>
                      displayBottomSheet(context, AddCareNoteBottomSheet()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DesignButton(
                  'Raise concern',
                  small: true,
                  secondary: true,
                  icon: Icons.flag_outlined,
                  onPressed: () =>
                      displayBottomSheet(context, RaiseConcernBottomSheet()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          NoticeBox.info('About me: written by my daughter Priya.'),
          const SizedBox(height: 14),
          DesignCard(
            child: Column(
              children: [
                _infoRow(
                  Icons.phone_outlined,
                  'NOK: Priya Patel (daughter), 07700 900201',
                  onTap: () =>
                      launchUrl(Uri(scheme: 'tel', path: '07700900201')),
                ),
                Divider(color: AppColors.line, height: 1),
                _infoRow(
                  Icons.medical_services_outlined,
                  'GP: Dr Reeves, Kettering Medical Centre',
                ),
                Divider(color: AppColors.line, height: 1),
                _infoRow(
                  Icons.key_outlined,
                  showCode ? 'Key safe: 4821' : 'Key safe: tap to show code',
                  onTap: () => setState(() => showCode = !showCode),
                ),
              ],
            ),
          ),
          _section("Today's visits to Anita"),
          _visit('07:30', '30 min', 'Morning call', true),
          _visit('12:30', '15 min', 'Lunch call', false),
          _visit('19:30', '30 min', 'Bedtime call', false),
          _section(
            'Notes diary',
            trailing: TextButton(
              onPressed: () =>
                  displayBottomSheet(context, AddCareNoteBottomSheet()),
              child: Text(
                '+ Add note',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line2),
            ),
            child: Column(
              children: [
                Text(
                  'No notes yet',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap + Add note above to write the first one.',
                  style: TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
