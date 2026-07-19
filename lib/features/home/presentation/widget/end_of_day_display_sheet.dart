import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

class EndOfDaySummarySheet extends StatelessWidget {
  const EndOfDaySummarySheet({super.key});

  @override
  Widget build(BuildContext context) {
    final outstandingVisits = [
      "12:00–13:00 · Maeve O'Connor · Lunch call",
      "12:30–12:45 · Anita Patel · Lunch call",
      "13:30–14:00 · Tadeusz Kowalski · Lunch call",
      "14:30–15:00 · Edna Henderson · Welfare check",
      "16:00–16:15 · George Davies · Tea call",
      "17:00–17:15 · Oluwaseun Akinola · Tea call",
      "18:00–18:45 · Maeve O'Connor · Tea call",
      "19:30–20:00 · Anita Patel · Bedtime call",
      "20:30–21:00 · Edna Henderson · Bedtime call",
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          addVerticalSpacing(2),
          Container(
            width: 72,
            height: 6,
            decoration: BoxDecoration(
              color: const Color(0xffd7d0bf),
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        text: "🌙 End of day summary",
                        color: Colors.black,
                        type: AppTextType.headlineSmall,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 8),
                      AppText(
                        text: "Review and confirm your shift",
                        color: Color(0xff8a877f),
                        type: AppTextType.bodyMedium,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xfffaf8f3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18),
                  ),
                ),
              ],
            ),
          ),

          Container(height: 1, color: const Color(0xffded6c7)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 28, 14, 20),
              child: Column(
                children: [
                  const AppText(
                    text: "🌙",
                    color: AppColors.black,
                    type: AppTextType.displaySmall,
                  ),

                  addVerticalSpacing(2),

                  const AppText(
                    text: "Round complete",
                    color: AppColors.blue,
                    type: AppTextType.titleLarge,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.center,
                  ),

                  addVerticalSpacing(2),

                  const AppText(
                    text: "4 visits delivered · 2.2 contact hours",
                    color: AppColors.gold,
                    type: AppTextType.bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  addVerticalSpacing(2),

                  Row(
                    children: const [
                      Expanded(
                        child: _SummaryBox(
                          value: "4",
                          title: "VISITS DONE",
                          valueColor: Color(0xff5a7d5d),
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: _SummaryBox(
                          value: "0",
                          title: "MISSED",
                          valueColor: Color(0xff203f7a),
                        ),
                      ),
                    ],
                  ),

                  addVerticalSpacing(2),

                  Row(
                    children: const [
                      Expanded(
                        child: _SummaryBox(
                          value: "130",
                          title: "MIN DELIVERED",
                          valueColor: Color(0xff203f7a),
                        ),
                      ),
                      SizedBox(width: 18),
                      Expanded(
                        child: _SummaryBox(
                          value: "2",
                          title: "GAPS RECONCILED",
                          valueColor: Color(0xff203f7a),
                        ),
                      ),
                    ],
                  ),

                  addVerticalSpacing(2),

                  _CardBox(
                    title: "📋 Activity today",
                    children: const [
                      _DashedText("0 care notes written by you"),
                      _DashedText("0 concerns raised"),
                      _DashedText("0 safety check-ins escalated"),
                      _DashedText(
                        "0 daily MAR closures completed",
                        showLine: false,
                      ),
                    ],
                  ),

                  addVerticalSpacing(2),

                  _CardBox(
                    title: "⏱ Reconciliations to be aware of",
                    children: const [
                      _RichDashedText(
                        bold: "George Davies",
                        normal: " · 7 min short",
                        note:
                            "\"Mary had breakfast under control — left early with agreement.\"",
                      ),
                      _RichDashedText(
                        bold: "Edna Henderson",
                        normal: " · 4 min over",
                        note:
                            "\"Bath took longer — she was very anxious. Worth recording for the care plan review.\"",
                        showLine: false,
                      ),
                    ],
                  ),

                  addVerticalSpacing(2),

                  _CardBox(
                    title: "⚠ Still outstanding",
                    titleColor: Color(0xff9a711f),
                    children: [
                      ...outstandingVisits.map((e) => _DashedText(e)),
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: AppText(
                          text:
                              "You can't end your day with visits still scheduled.\nEither deliver them or mark missed with a reason.",
                          color: Color(0xff8a877f),
                          type: AppTextType.bodyMedium,
                        ),
                      ),
                    ],
                  ),

                  addVerticalSpacing(2),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f9fb),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xffd5dbe6)),
                    ),
                    child: const AppText(
                      text:
                          "📌 What happens next: Confirming creates the shift record sent to your manager and forms part of the monthly commissioner report.",
                      color: Color(0xff8a877f),
                      type: AppTextType.bodyMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  addVerticalSpacing(2),

                  Row(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 64,
                        child: AppButton(
                          text: "Cancel",
                          onPressed: () => Navigator.pop(context),
                          btnColor: Colors.white,
                          textColor: Colors.black,
                          borderColor: const Color(0xffded6c7),
                          borderRadius: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 64,
                          child: AppButton(
                            text: "9 visits still scheduled",
                            onPressed: null,
                            btnColor: Colors.white,
                            textColor: const Color(0xff8a877f),
                            borderColor: const Color(0xffeee8df),
                            borderRadius: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final String value;
  final String title;
  final Color valueColor;

  const _SummaryBox({
    required this.value,
    required this.title,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12.heightAdjusted,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffded6c7)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            text: value,
            color: valueColor,
            type: AppTextType.labelLarge,
            fontWeight: FontWeight.w800,
          ),
          addVerticalSpacing(2),
          AppText(
            text: title,
            color: AppColors.amber,
            type: AppTextType.bodyMedium,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CardBox extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<Widget> children;

  const _CardBox({
    required this.title,
    required this.children,
    this.titleColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffded6c7)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: title,
            color: titleColor,
            type: AppTextType.bodyLarge,
            fontWeight: FontWeight.w800,
          ),
          addVerticalSpacing(2),
          ...children,
        ],
      ),
    );
  }
}

class _DashedText extends StatelessWidget {
  final String text;
  final bool showLine;

  const _DashedText(this.text, {this.showLine = true});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: text,
          color: Colors.black,
          type: AppTextType.bodyLarge,
          fontWeight: FontWeight.w500,
        ),
        if (showLine) const _DashedDivider(),
      ],
    );
  }
}

class _RichDashedText extends StatelessWidget {
  final String bold;
  final String normal;
  final String note;
  final bool showLine;

  const _RichDashedText({
    required this.bold,
    required this.normal,
    required this.note,
    this.showLine = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: AppTextType.bodySmall.style(
              context,
              color: Colors.black,
              fontSize: 18,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: bold,
                style: AppTextType.bodySmall.style(
                  context,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(text: normal),
            ],
          ),
        ),
        addVerticalSpacing(2),
        AppText(
          text: note,
          color: const Color(0xff8a877f),
          type: AppTextType.bodyMedium,
        ),
        if (showLine) const _DashedDivider(),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
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
