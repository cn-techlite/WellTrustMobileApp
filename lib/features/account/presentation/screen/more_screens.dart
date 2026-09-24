import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

/// Shared scaffold for the simple list pages reached from the More tab.
class _MorePage extends StatelessWidget {
  final String title;
  final String lead;
  final List<Widget> children;

  const _MorePage({
    required this.title,
    required this.lead,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          WellTrustAppBar(title: title, showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  lead,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ...children.expand((w) => [w, const SizedBox(height: 12)]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _h = TextStyle(
  fontFamily: 'Playfair Display',
  fontWeight: FontWeight.w700,
  fontSize: 17,
  color: AppColors.ink,
);
final _m = TextStyle(color: AppColors.muted, fontSize: 14);

/// Shifts management has published as open. Carers can only ask for one.
class OpenShiftsScreen extends StatefulWidget {
  const OpenShiftsScreen({super.key});

  @override
  State<OpenShiftsScreen> createState() => _OpenShiftsScreenState();
}

class _OpenShiftsScreenState extends State<OpenShiftsScreen> {
  static const _shifts = [
    (
      'Thursday 24 September',
      '07:30 to 14:30',
      'Kettering North morning run',
      'Four visits, one double-up.',
    ),
    (
      'Saturday 26 September',
      '16:30 to 21:30',
      'Kettering South evening run',
      'Tea and bedtime visits.',
    ),
    (
      'Sunday 27 September',
      '07:30 to 14:30',
      'Kettering North morning run',
      '',
    ),
  ];
  final requested = <int>{};

  @override
  Widget build(BuildContext context) {
    return _MorePage(
      title: 'Open shifts',
      lead:
          'Shifts management has published as open. Ask for one and the office decides. You cannot change your own rota.',
      children: [
        for (var i = 0; i < _shifts.length; i++)
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_shifts[i].$1, style: _h),
                const SizedBox(height: 2),
                Text(
                  _shifts[i].$2,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  '${_shifts[i].$3}${_shifts[i].$4.isEmpty ? '' : '. ${_shifts[i].$4}'}',
                  style: _m,
                ),
                const SizedBox(height: 14),
                if (requested.contains(i)) ...[
                  NoticeBox.ok('Requested. Waiting for the office to decide.'),
                  const SizedBox(height: 10),
                  DesignButton(
                    'Withdraw request',
                    secondary: true,
                    onPressed: () => setState(() => requested.remove(i)),
                  ),
                ] else
                  DesignButton(
                    'Ask for this shift',
                    onPressed: () => setState(() => requested.add(i)),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class MyHoursScreen extends StatefulWidget {
  const MyHoursScreen({super.key});

  @override
  State<MyHoursScreen> createState() => _MyHoursScreenState();
}

class _MyHoursScreenState extends State<MyHoursScreen> {
  String tab = 'this';

  @override
  Widget build(BuildContext context) {
    final rows = tab == 'this'
        ? const [
            ('Harold', 'Mon 08:02 to 08:47', '45 min'),
            ('Margaret', 'Mon 09:01 to 09:44', '43 min'),
            ('Dorothy', 'Tue 12:31 to 13:02', '31 min'),
          ]
        : const [
            ('Suresh', 'Mon 17:32 to 18:16', '44 min'),
            ('Harold', 'Tue 07:31 to 08:15', '44 min'),
          ];
    return _MorePage(
      title: 'My hours',
      lead:
          'Worked out from the times you clocked in and out. Check it against your payslip.',
      children: [
        SegmentTabs(
          options: const [('this', 'This week'), ('last', 'Last week')],
          active: tab,
          onChanged: (v) => setState(() => tab = v),
        ),
        DesignCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(tab == 'this' ? '2 h 0 min' : '1 h 28 min', 'Care time'),
              _Stat(tab == 'this' ? '22 min' : '14 min', 'Planned travel'),
              _Stat('${rows.length}', 'Visits'),
            ],
          ),
        ),
        for (final r in rows)
          DesignCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.$1,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        r.$2,
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Text(
                  r.$3,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat(this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
      ),
      Text(label, style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
    ],
  );
}

class AssessmentsScreen extends StatelessWidget {
  const AssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Home risk review', 'Mr Harold Fisher', 'Due in 6 days'),
      ('Care plan review', 'Mrs Margaret Hensley', 'Due in 12 days'),
    ];
    return _MorePage(
      title: 'Assessments',
      lead: 'Assessments management has asked you to complete.',
      children: [
        for (final a in items)
          DesignCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(a.$1, style: _h)),
                    Pill.neutral('Not started'),
                  ],
                ),
                const SizedBox(height: 4),
                Text(a.$2, style: TextStyle(color: AppColors.ink)),
                Text(a.$3, style: _m),
              ],
            ),
          ),
      ],
    );
  }
}
