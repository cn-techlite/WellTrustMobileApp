import 'package:flutter/material.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';

class ResidentProfileScreen extends StatelessWidget {
  const ResidentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: buildFlexibleAppBar(
        context: context,

        backgroundColor: AppColors.darkBlue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _ResidentHeader(),
              _StatisticsCard(),
              _ActionCards(),
              _CareSummaryCard(),
              _InformationCard(),
              _TodayVisitsSection(),
              _NotesSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResidentHeader extends StatelessWidget {
  const _ResidentHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 18),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white24,
                child: AppText(
                  text: "AP",
                  color: Colors.white,
                  type: AppTextType.titleLarge,
                  fontWeight: FontWeight.w800,
                ),
              ),
              addHorizontalSpacing(2),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: "Anita Patel",
                      color: Colors.white,
                      type: AppTextType.titleLarge,
                      fontWeight: FontWeight.w800,
                    ),
                    SizedBox(height: 6),
                    AppText(
                      text: "84 years · 14h/week · 4 calls/day",
                      color: Colors.white70,
                      type: AppTextType.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          addVerticalSpacing(2),
          const AppText(
            text: "📍 14 Linden Avenue, Kettering NN15 6JL",
            color: Colors.white70,
            type: AppTextType.bodySmall,
          ),
          addVerticalSpacing(2),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(text: "FALLS RISK", color: Color(0xff34476d)),
              _Tag(text: "ALLERGY: PENICILLIN", color: Color(0xff34476d)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  const _StatisticsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 8, 6, 6),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xffded6c7)),
      ),
      child: const Row(
        children: [
          _StatItem("3", "VISITS TODAY"),
          _StatDivider(),
          _StatItem("1", "DONE"),
          _StatDivider(),
          _StatItem("2", "TO GO"),
          _StatDivider(),
          _StatItem("14h/week", "WEEKLY", smallValue: true),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool smallValue;

  const _StatItem(this.value, this.label, {this.smallValue = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          AppText(
            text: value,
            color: const Color(0xff24447f),
            type: smallValue
                ? AppTextType.titleMedium
                : AppTextType.headlineSmall,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          AppText(
            text: label,
            color: const Color(0xff8B867B),
            type: AppTextType.labelSmall,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: const Color(0xffeee6d9));
  }
}

class _ActionCards extends StatelessWidget {
  const _ActionCards();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              icon: "👤",
              title: "About me",
              subtitle: "Written by my daughter Priya",
              background: const Color(0xff24447f),
              textColor: Colors.white,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionCard(
              icon: "📝",
              title: "Add note",
              subtitle: "",
              background: Colors.white,
              textColor: AppColors.black,
              onTap: () {},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ActionCard(
              icon: "🚩",
              title: "Raise concern",
              subtitle: "",
              background: const Color(0xfffff4f2),
              textColor: const Color(0xffbf4b45),
              borderColor: const Color(0xffefc3bf),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color textColor;
  final VoidCallback onTap;
  final Color? borderColor;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 132,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor ?? const Color(0xffded6c7)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(text: icon, type: AppTextType.titleLarge),
            const SizedBox(height: 10),
            AppText(
              text: title,
              color: textColor,
              type: AppTextType.bodySmall,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              AppText(
                text: subtitle,
                color: textColor.withValues(alpha: .85),
                type: AppTextType.labelSmall,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CareSummaryCard extends StatelessWidget {
  const _CareSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xfff6f8fb),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffdce4ee)),
      ),
      child: const AppText(
        text:
            "Care summary: Vascular dementia, lives alone. Daughter visits weekends. Independent with prompting; needs help with personal care morning and bedtime.",
        color: AppColors.black,
        type: AppTextType.bodySmall,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _InformationCard extends StatefulWidget {
  const _InformationCard();

  @override
  State<_InformationCard> createState() => _InformationCardState();
}

class _InformationCardState extends State<_InformationCard> {
  bool showKeySafe = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffded6c7)),
      ),
      child: Column(
        children: [
          const _InfoRow(
            icon: "📞",
            title: "NOK: Priya Patel (daughter) · 07700 900201",
          ),
          const Divider(color: Color(0xffded6c7)),
          const _InfoRow(
            icon: "🧑‍⚕️",
            title: "GP: Dr Reeves, Kettering Medical Centre",
          ),
          const Divider(color: Color(0xffded6c7)),
          _KeySafeRow(
            value: showKeySafe ? "4821" : "Tap to reveal",
            onTap: () {
              setState(() => showKeySafe = !showKeySafe);
            },
          ),
        ],
      ),
    );
  }
}

class _TodayVisitsSection extends StatelessWidget {
  const _TodayVisitsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: "Today's visits to Anita"),
        _VisitTile(
          completed: true,
          time: "07:30–08:00",
          duration: "30 min",
          title: "🌅 Morning call",
          onTap: () {},
        ),
        _VisitTile(
          completed: false,
          time: "12:30–12:45",
          duration: "15 min",
          title: "🍽 Lunch call",
          onTap: () {},
        ),
        _VisitTile(
          completed: false,
          time: "19:30–20:00",
          duration: "30 min",
          title: "🛏 Bedtime call",
          onTap: () {},
        ),
      ],
    );
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionTitle(
          title: "Notes diary",
          trailing: GestureDetector(
            onTap: () {},
            child: const AppText(
              text: "+ Add note",
              color: Color(0xff24447f),
              type: AppTextType.bodyMedium,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xffded6c7)),
          ),
          child: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: const Color(0xfff8f4eb),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 52,
                  color: Color(0xffd2c8b1),
                ),
              ),
              addVerticalSpacing(2),
              const AppText(
                text: "No notes yet",
                color: AppColors.black,
                type: AppTextType.titleMedium,
                fontWeight: FontWeight.w800,
              ),
              addVerticalSpacing(1),
              const AppText(
                text: "Tap + Add note above to write the first one.",
                color: Color(0xff8a877f),
                type: AppTextType.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: title,
              color: AppColors.black,
              type: AppTextType.titleMedium,
              fontWeight: FontWeight.w800,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _VisitTile extends StatelessWidget {
  final bool completed;
  final String time;
  final String duration;
  final String title;
  final VoidCallback? onTap;

  const _VisitTile({
    required this.completed,
    required this.time,
    required this.duration,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffded6c7)),
        ),
        child: Row(
          children: [
            Icon(
              completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: completed ? const Color(0xff5d825c) : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                text: "$time · $duration · $title",
                color: AppColors.black,
                type: AppTextType.bodySmall,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xff24447f)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback? onTap;

  const _InfoRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(text: icon, type: AppTextType.bodyLarge),
            const SizedBox(width: 10),
            Expanded(
              child: AppText(
                text: title,
                color: AppColors.black,
                type: AppTextType.bodySmall,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeySafeRow extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const _KeySafeRow({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppText(text: "🔑", type: AppTextType.bodyLarge),
        const SizedBox(width: 10),
        const AppText(
          text: "Key safe:",
          color: AppColors.black,
          type: AppTextType.bodyMedium,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xfff8f4eb),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xffd6c6a5)),
            ),
            child: AppText(
              text: value,
              color: const Color(0xff9c7422),
              type: AppTextType.bodySmall,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final Color? textColor;

  const _Tag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AppText(
        text: text,
        color: textColor ?? Colors.white,
        type: AppTextType.labelSmall,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
