import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/add_note_bottom_sheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/body_map_bottomsheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/med_visit_bottomsheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/raise_cocerns_bottomshet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/report_incident_bottomsheet.dart';
import 'package:well_trust_mobile_app/features/visits/presentation/widget/safe_guard_bottomsheet.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';

class VisitStartDetailsPage extends StatefulWidget {
  const VisitStartDetailsPage({super.key});

  @override
  State<VisitStartDetailsPage> createState() => _VisitStartDetailsPageState();
}

class _VisitStartDetailsPageState extends State<VisitStartDetailsPage> {
  bool showKeySafe = false;
  final Set<int> checkedTasks = {};

  final tasks = ["Lunch prompt", "Lunch meds", "Fluids"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: buildFlexibleAppBar(
        context: context,

        backgroundColor: AppColors.bg,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 14, right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _PatientHeader(),

              addVerticalSpacing(2),

              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _RiskBadge(text: "FALLS RISK"),
                  _RiskBadge(
                    text: "ALLERGY: PENICILLIN",
                    bgColor: Color(0xfff6efe3),
                    textColor: Color(0xff96701f),
                  ),
                ],
              ),

              addVerticalSpacing(2),

              const _ScheduleCard(),

              addVerticalSpacing(2),

              _VisitInfoCard(
                showKeySafe: showKeySafe,
                onReveal: () {
                  setState(() => showKeySafe = !showKeySafe);
                },
              ),

              addVerticalSpacing(2),

              _VisitTasksCard(
                tasks: tasks,
                checkedTasks: checkedTasks,
                onChanged: (index) {
                  setState(() {
                    checkedTasks.contains(index)
                        ? checkedTasks.remove(index)
                        : checkedTasks.add(index);
                  });
                },
              ),

              addVerticalSpacing(2),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _VisitActionButton(
                    icon: "📝",
                    title: "Add care note",
                    subtitle: "3-step wizard + voice",
                    onTap: () {
                      displayBottomSheet(context, AddCareNoteBottomSheet());
                    },
                  ),
                  _VisitActionButton(
                    icon: "💊",
                    title: "Meds this visit",
                    subtitle: "2 due · 2 total",
                    onTap: () {
                      displayBottomSheet(context, MedsForVisitBottomSheet());
                    },
                  ),
                  _VisitActionButton(
                    icon: "🩹",
                    title: "Body map",
                    subtitle: "Mark observations",
                    onTap: () {
                      displayBottomSheet(context, BodyMapBottomSheet());
                    },
                  ),
                  _VisitActionButton(
                    icon: "🚩",
                    title: "Raise concern",
                    subtitle: "Early warning to manager",
                    isDanger: true,
                    onTap: () {
                      displayBottomSheet(context, RaiseConcernBottomSheet());
                    },
                  ),
                  _VisitActionButton(
                    icon: "⚠️",
                    title: "Report incident",
                    subtitle: "Fall, error, near-miss",
                    dangerTextOnly: true,
                    onTap: () {
                      displayBottomSheet(context, ReportIncidentBottomSheet());
                    },
                  ),
                  _VisitActionButton(
                    icon: "🚨",
                    title: "Safeguarding",
                    subtitle: "Abuse / serious harm",
                    onTap: () {
                      displayBottomSheet(context, SafeguardingBottomSheet());
                    },
                  ),
                ],
              ),

              AppButton(
                text: "▶ Start visit",
                onPressed: () {},
                btnColor: const Color(0xffbd9650),
                textColor: Colors.white,
                borderRadius: 12,
              ),

              addVerticalSpacing(2),
            ],
          ),
        ),
      ),
    );
  }
}

class _PatientHeader extends StatelessWidget {
  const _PatientHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 34,
          backgroundColor: Color(0xff24447f),
          child: AppText(
            text: "AP",
            color: Colors.white,
            type: AppTextType.labelLarge,
            fontWeight: FontWeight.w800,
          ),
        ),

        addHorizontalSpacing(2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                text: "Anita Patel",
                color: Colors.black,
                type: AppTextType.headlineSmall,
                fontWeight: FontWeight.w800,
              ),
              addVerticalSpacing(.2),
              const AppText(
                text: "84 years · 🍽️ Lunch call",
                color: Color(0xff8a877f),
                type: AppTextType.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _RiskBadge({
    required this.text,
    this.bgColor = const Color(0xffffefe1),
    this.textColor = const Color(0xffc87536),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AppText(
        text: text,
        color: textColor,
        type: AppTextType.labelSmall,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard();

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 28),
      child: Column(
        children: const [
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: "SCHEDULED",
                  color: Color(0xff8a877f),
                  type: AppTextType.bodyMedium,
                  fontWeight: FontWeight.w800,
                ),
              ),
              AppText(
                text: "12:30 – 12:45 (15 min)",
                color: Colors.black,
                type: AppTextType.bodySmall,
                fontWeight: FontWeight.w800,
              ),
            ],
          ),
          SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: AppText(
                  text: "TYPE",
                  color: Color(0xff8a877f),
                  type: AppTextType.bodyMedium,
                  fontWeight: FontWeight.w800,
                ),
              ),
              AppText(
                text: "🍽️ Lunch call",
                color: Colors.black,
                type: AppTextType.labelLarge,
                fontWeight: FontWeight.w800,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisitInfoCard extends StatelessWidget {
  final bool showKeySafe;
  final VoidCallback onReveal;

  const _VisitInfoCard({required this.showKeySafe, required this.onReveal});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: "📍 Address: 11 Rosedale Walk, Burton Latimer NN15 5XB",
            color: Colors.black,
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w500,
          ),
          addVerticalSpacing(1),
          Row(
            children: [
              const AppText(
                text: "🔑 Key safe:",
                color: Colors.black,
                type: AppTextType.bodyMedium,
                fontWeight: FontWeight.w800,
              ),
              addHorizontalSpacing(1),
              GestureDetector(
                onTap: onReveal,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfffff7e9),
                    border: Border.all(color: const Color(0xffdfc99f)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppText(
                    text: showKeySafe ? "4821" : "Tap to reveal",
                    color: AppColors.amber,
                    type: AppTextType.labelSmall,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          addVerticalSpacing(1),
          const AppText(
            text: "📞 NOK: Sean O'Connor (son) · 07700 900112",
            color: Colors.black,
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}

class _VisitTasksCard extends StatelessWidget {
  final List<String> tasks;
  final Set<int> checkedTasks;
  final ValueChanged<int> onChanged;

  const _VisitTasksCard({
    required this.tasks,
    required this.checkedTasks,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: "📋 Tasks for this visit",
            color: Colors.black,
            type: AppTextType.titleMedium,
            fontWeight: FontWeight.w800,
          ),
          addVerticalSpacing(2),

          ...List.generate(tasks.length, (index) {
            final checked = checkedTasks.contains(index);

            return Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => onChanged(index),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xffd0c8b4),
                            width: 3,
                          ),
                          color: checked
                              ? const Color(0xff5d825c)
                              : Colors.white,
                        ),
                        child: checked
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 10,
                              )
                            : null,
                      ),
                    ),
                    addHorizontalSpacing(2),
                    AppText(
                      text: tasks[index],
                      color: Colors.black,
                      type: AppTextType.bodySmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
                if (index != tasks.length - 1) const _DashedDivider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _BaseCard({
    required this.child,
    this.padding = const EdgeInsets.all(22),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffded6c7)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 18),
      height: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Flex(
            direction: Axis.horizontal,
            children: List.generate(
              (constraints.maxWidth / 8).floor(),
              (_) => const SizedBox(
                width: 4,
                height: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xffded6c7)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VisitActionButton extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;
  final bool dangerTextOnly;

  const _VisitActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
    this.dangerTextOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final dangerColor = const Color(0xffbf4b45);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDanger ? const Color(0xfffff1ee) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDanger ? const Color(0xffe8b7b3) : const Color(0xffded6c7),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              text: icon,
              color: AppColors.black,
              type: AppTextType.titleLarge,
              textAlign: TextAlign.center,
            ),
            addVerticalSpacing(.8),
            AppText(
              text: title,
              color: isDanger || dangerTextOnly ? dangerColor : AppColors.black,
              type: AppTextType.bodySmall,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
            addVerticalSpacing(.4),
            AppText(
              text: subtitle,
              color: const Color(0xff8a877f),
              type: AppTextType.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
