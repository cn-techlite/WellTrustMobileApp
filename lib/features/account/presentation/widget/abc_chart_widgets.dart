import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/account/data/model/abc_chart_entry.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';

class AbcFormLabel extends StatelessWidget {
  final String text;
  final String? help;
  final bool requiredField;

  const AbcFormLabel(
    this.text, {
    super.key,
    this.help,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: requiredField ? '$text *' : text,
          type: AppTextType.bodySmall,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        if (help != null) ...[
          addVerticalSpacing(0.24),
          AppText(
            text: help!,
            type: AppTextType.labelLarge,
            color: AppColors.muted,
          ),
        ],
      ],
    ),
  );
}

class AbcPickerField extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const AbcPickerField({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.line2, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.muted, size: 20),
            addHorizontalSpacing(2.05),
            Expanded(
              child: AppText(
                text: text,
                type: AppTextType.bodySmall,
                color: AppColors.ink,
              ),
            ),
            if (onClear != null)
              IconButton(
                tooltip: 'Clear time',
                visualDensity: VisualDensity.compact,
                onPressed: onClear,
                icon: Icon(Icons.close, color: AppColors.muted, size: 19),
              ),
          ],
        ),
      ),
    ),
  );
}

class AbcFunctionChoices extends StatelessWidget {
  static const options = [
    'Sensory',
    'Escape / Avoidance',
    'Attention',
    'Access to something tangible',
    'Unknown',
  ];

  final String? selected;
  final ValueChanged<String?> onChanged;

  const AbcFunctionChoices({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 6,
    runSpacing: 6,
    children: [
      for (final option in options)
        ChoiceChip(
          label: AppText(
            text: option,
            type: AppTextType.labelLarge,
            color: selected == option ? AppColors.onPrimary : AppColors.ink,
            fontWeight: FontWeight.w600,
          ),
          selected: selected == option,
          showCheckmark: false,
          onSelected: (_) => onChanged(selected == option ? null : option),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: selected == option ? AppColors.primary : AppColors.line2,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
    ],
  );
}

class AbcEntryCard extends StatelessWidget {
  final AbcChartEntry entry;

  const AbcEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final time = _displayTime(entry.episodeTime);
    final summary = [
      DateFormat('d MMM yyyy').format(entry.episodeDate),
      ?time,
      if (entry.location.trim().isNotEmpty) entry.location.trim(),
    ].join(' • ');

    return DesignCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 4),
        shape: const Border(),
        collapsedShape: const Border(),
        title: AppText(
          text: entry.behaviour.trim().isEmpty
              ? 'Behaviour episode'
              : entry.behaviour.trim(),
          type: AppTextType.bodySmall,
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: AppText(
            text: summary,
            type: AppTextType.labelLarge,
            color: AppColors.muted,
          ),
        ),
        children: [
          const Divider(),
          _Detail('Antecedent', entry.antecedent),
          _Detail('Behaviour', entry.behaviour),
          _Detail('Consequence', entry.consequence),
          if (entry.duration.trim().isNotEmpty)
            _Detail('Duration', entry.duration),
          if (entry.possibleFunction != null)
            _Detail('Possible function', entry.possibleFunction!),
          if (entry.staffInvolved.trim().isNotEmpty)
            _Detail('Staff involved', entry.staffInvolved),
          if (entry.recordedBy.trim().isNotEmpty)
            _Detail('Recorded by', entry.recordedBy),
        ],
      ),
    );
  }

  String? _displayTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    return parts.length >= 2 ? '${parts[0]}:${parts[1]}' : value;
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;

  const _Detail(this.label, this.value);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          text: label,
          type: AppTextType.labelLarge,
          color: AppColors.muted,
          fontWeight: FontWeight.w700,
        ),
        addVerticalSpacing(0.24),
        AppText(
          text: value.trim().isEmpty ? 'Not recorded' : value.trim(),
          type: AppTextType.bodySmall,
          color: AppColors.ink,
        ),
      ],
    ),
  );
}

class AbcEmptyState extends StatelessWidget {
  final String title;
  final String body;

  const AbcEmptyState({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) => DesignCard(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(Icons.format_list_bulleted_rounded, color: AppColors.muted),
          addVerticalSpacing(0.71),
          AppText(
            text: title,
            type: AppTextType.bodySmall,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          addVerticalSpacing(0.47),
          AppText(
            text: body,
            type: AppTextType.bodySmall,
            color: AppColors.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
