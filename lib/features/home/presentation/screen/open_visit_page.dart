import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';

class OpenVisitDetailsPage extends StatefulWidget {
  const OpenVisitDetailsPage({super.key});

  @override
  State<OpenVisitDetailsPage> createState() => _OpenVisitDetailsPageState();
}

class _OpenVisitDetailsPageState extends State<OpenVisitDetailsPage> {
  bool showKeySafe = false;

  final tasks = [
    "Lunch prep",
    "Eating support",
    "Lunch meds",
    "Toilet",
    "Bin out",
  ];

  final Set<int> completedTasks = {};

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
              _ClientHeader(),

              addVerticalSpacing(2),

              const _RiskBadge(text: "FALLS RISK"),

              addVerticalSpacing(2),

              const _TimerBox(),
              addVerticalSpacing(2),

              _InfoCard(
                showKeySafe: showKeySafe,
                onRevealKeySafe: () {
                  setState(() => showKeySafe = !showKeySafe);
                },
              ),

              addVerticalSpacing(2),

              _TasksCard(
                tasks: tasks,
                completedTasks: completedTasks,
                onChanged: (index) {
                  setState(() {
                    if (completedTasks.contains(index)) {
                      completedTasks.remove(index);
                    } else {
                      completedTasks.add(index);
                    }
                  });
                },
              ),

              addVerticalSpacing(2),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.65,
                children: const [
                  _ActionCard(
                    icon: "📝",
                    title: "Add care note",
                    subtitle: "3-step wizard + voice",
                  ),
                  _ActionCard(
                    icon: "💊",
                    title: "Meds this visit",
                    subtitle: "2 due · 2 total",
                  ),
                  _ActionCard(
                    icon: "🩹",
                    title: "Body map",
                    subtitle: "Mark observations",
                  ),
                  _ActionCard(
                    icon: "🚩",
                    title: "Raise concern",
                    subtitle: "Early warning to manager",
                    danger: true,
                  ),
                  _ActionCard(
                    icon: "⚠️",
                    title: "Report incident",
                    subtitle: "Fall, error, near-miss",
                    dangerText: true,
                  ),
                  _ActionCard(
                    icon: "🚨",
                    title: "Safeguarding",
                    subtitle: "Abuse / serious harm",
                  ),
                ],
              ),

              addVerticalSpacing(2),

              AppButton(
                text: "✓ End visit",
                onPressed: () {},
                btnColor: const Color(0xff5d825c),
                textColor: Colors.white,
                borderRadius: 12,
              ),

              addVerticalSpacing(10),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientHeader extends StatelessWidget {
  const _ClientHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.blue,
          child: AppText(
            text: "MO",
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
                text: "Maeve O'Connor",
                color: Colors.black,
                type: AppTextType.headlineSmall,
                fontWeight: FontWeight.w800,
              ),
              addVerticalSpacing(.2),
              const AppText(
                text: "86 years · 🍽️ Lunch call",
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

  const _RiskBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffffefe1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: AppText(
        text: text,
        color: AppColors.amber,
        type: AppTextType.labelSmall,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _TimerBox extends StatelessWidget {
  const _TimerBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 17.heightAdjusted,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xfff8fbf8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xff5d825c), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const AppText(
            text: "0:00",
            color: Color(0xff5d825c),
            type: AppTextType.displaySmall,
            fontWeight: FontWeight.w800,
          ),
          addVerticalSpacing(1),
          const AppText(
            text: "Started 12:04 · scheduled 60 min",
            color: Color(0xff8a877f),
            type: AppTextType.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool showKeySafe;
  final VoidCallback onRevealKeySafe;

  const _InfoCard({required this.showKeySafe, required this.onRevealKeySafe});

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
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
                onTap: onRevealKeySafe,
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

class _TasksCard extends StatelessWidget {
  final List<String> tasks;
  final Set<int> completedTasks;
  final ValueChanged<int> onChanged;

  const _TasksCard({
    required this.tasks,
    required this.completedTasks,
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
            final checked = completedTasks.contains(index);

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

class _ActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool danger;
  final bool dangerText;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.danger = false,
    this.dangerText = false,
  });

  @override
  Widget build(BuildContext context) {
    final dangerColor = const Color(0xffbf4b45);

    return Container(
      decoration: BoxDecoration(
        color: danger ? const Color(0xfffff1ee) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: danger ? const Color(0xffe8b7b3) : const Color(0xffded6c7),
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: icon,
            color: Colors.black,
            type: AppTextType.headlineMedium,
            textAlign: TextAlign.center,
          ),
          addVerticalSpacing(2),
          AppText(
            text: title,
            color: danger || dangerText ? dangerColor : Colors.black,
            type: AppTextType.bodySmall,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          AppText(
            text: subtitle,
            color: const Color(0xff8a877f),
            type: AppTextType.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BaseCard extends StatelessWidget {
  final Widget child;

  const _BaseCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
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
