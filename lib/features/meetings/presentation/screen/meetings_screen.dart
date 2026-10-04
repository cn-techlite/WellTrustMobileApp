import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/meetings/data/model/meeting_model.dart';
import 'package:well_trust_mobile_app/features/meetings/presentation/state/providers/meeting_provider.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

/// Team meetings run by the office (design "Team meetings" page).
class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final meetings =
        ref.watch(meetingsProvider).value?.meetings ?? const <TeamMeeting>[];
    final upcoming =
        meetings
            .where((m) => (m.isLive || m.end.isAfter(now)) && !m.cancelled)
            .toList()
          ..sort((a, b) => a.start.compareTo(b.start));
    final earlier = meetings.where((m) => !upcoming.contains(m)).toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'Team meetings', meetingsActive: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                AppText(
                  text:
                      'Team meetings run by the office. You can listen while a meeting is on, and read it here once the office has saved it.',
                  type: AppTextType.bodySmall,
                  color: AppColors.muted,
                  height: 1.4,
                ),
                addVerticalSpacing(1.66),
                _heading('Coming up'),
                if (upcoming.isEmpty)
                  const _Empty('No meetings planned')
                else
                  for (final m in upcoming) _MeetingCard(meeting: m),
                addVerticalSpacing(1.66),
                _heading('Saved meetings'),
                if (earlier.isEmpty)
                  const _Empty(
                    'Nothing saved yet',
                    subtitle:
                        'Recordings, notes and minutes appear here after the office saves a meeting.',
                  )
                else
                  for (final m in earlier) _MeetingCard(meeting: m),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: AppText(
      text: text,
      type: AppTextType.bodySmall,
      fontFamily: 'Playfair Display',
      fontWeight: FontWeight.w700,
      fontSize: 18,
      color: AppColors.ink,
    ),
  );
}

class _MeetingCard extends StatelessWidget {
  final TeamMeeting meeting;

  const _MeetingCard({required this.meeting});

  @override
  Widget build(BuildContext context) {
    final m = meeting;
    final sameDay = DateUtils.isSameDay(m.start, DateTime.now());
    final when = sameDay
        ? 'Today, ${hhmm(m.start)} to ${hhmm(m.end)}'
        : '${DateFormat('EEE d MMM').format(m.start)}, ${hhmm(m.start)} to ${hhmm(m.end)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DesignCard(
        onTap: () =>
            navigateToRoute(context, MeetingDetailsScreen(meeting: meeting)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppText(
                    text: m.title,
                    type: AppTextType.bodySmall,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
                if (m.isLive) ...[
                  addHorizontalSpacing(2.05),
                  Pill.ok('Live now'),
                ] else if (m.isSaved) ...[
                  addHorizontalSpacing(2.05),
                  Pill.ok('Minutes'),
                ] else if (sameDay) ...[
                  addHorizontalSpacing(2.05),
                  Pill.gold('Today'),
                ],
              ],
            ),
            addVerticalSpacing(0.47),
            AppText(
              text: when,
              type: AppTextType.bodySmall,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
            AppText(
              text: 'Hosted by ${m.host}. ${m.location}',
              type: AppTextType.bodySmall,
              color: AppColors.muted,
              fontSize: 14,
            ),
          ],
        ),
      ),
    );
  }
}

/// The meeting-specific destination used by Today notices and meeting rows.
class MeetingDetailsScreen extends StatefulWidget {
  final TeamMeeting meeting;

  const MeetingDetailsScreen({super.key, required this.meeting});

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  bool _listening = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.meeting;
    final now = DateTime.now();
    final live = !now.isBefore(m.start) && now.isBefore(m.end);
    final ended = !now.isBefore(m.end);
    final sameDay = DateUtils.isSameDay(m.start, now);
    final date = sameDay ? 'Today' : DateFormat('EEE d MMM').format(m.start);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          WellTrustAppBar(title: m.title, showBack: true, meetingsActive: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                DesignCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              text: m.title,
                              type: AppTextType.bodySmall,
                              fontFamily: 'Playfair Display',
                              fontWeight: FontWeight.w700,
                              fontSize: 19,
                              color: AppColors.ink,
                            ),
                            addVerticalSpacing(0.47),
                            AppText(
                              text: '$date, ${hhmm(m.start)} to ${hhmm(m.end)}',
                              type: AppTextType.bodySmall,
                              color: AppColors.ink,
                              fontWeight: FontWeight.w700,
                            ),
                            AppText(
                              text: '${m.location}, Hosted by ${m.host}',
                              type: AppTextType.bodySmall,
                              color: AppColors.muted,
                            ),
                          ],
                        ),
                      ),
                      if (live) ...[
                        addHorizontalSpacing(2.05),
                        Pill.ok('Live now'),
                      ] else if (m.isSaved) ...[
                        addHorizontalSpacing(2.05),
                        Pill.info('Saved'),
                      ],
                    ],
                  ),
                ),
                addVerticalSpacing(1.66),
                if (m.agenda.isNotEmpty) ...[
                  DesignCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: 'Agenda',
                          type: AppTextType.bodySmall,
                          color: AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                        addVerticalSpacing(0.71),
                        for (var i = 0; i < m.agenda.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: AppText(
                              text: '${i + 1}. ${m.agenda[i]}',
                              type: AppTextType.bodySmall,
                              color: AppColors.ink,
                            ),
                          ),
                      ],
                    ),
                  ),
                  addVerticalSpacing(1.66),
                ],
                if (live)
                  _LiveMeetingCard(
                    listening: _listening,
                    onToggle: () => setState(() => _listening = !_listening),
                  )
                else if (!m.isSaved)
                  NoticeBox.info(
                    ended
                        ? 'The office has not saved this meeting yet. It will appear here when they do.'
                        : 'You can listen here once the office starts the meeting. This page updates by itself.',
                  ),
                if (m.savedMinutes != null) ...[
                  _sectionHeading('Minutes'),
                  _MeetingMinutesCard(minutes: m.savedMinutes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveMeetingCard extends StatelessWidget {
  final bool listening;
  final VoidCallback onToggle;

  const _LiveMeetingCard({required this.listening, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      borderColor: AppColors.sage,
      borderWidth: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: listening ? 'Listening' : 'The meeting is on now',
            type: AppTextType.bodySmall,
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.w700,
            fontSize: 19,
            color: AppColors.ink,
          ),
          addVerticalSpacing(0.47),
          AppText(
            text: listening
                ? 'You are listening only. This app never uses your microphone.'
                : 'Listen in from here. You cannot speak, record or add notes.',
            type: AppTextType.bodySmall,
            color: AppColors.muted,
          ),
          addVerticalSpacing(1.42),
          DesignButton(
            listening ? 'Leave meeting' : 'Listen to the meeting',
            secondary: listening,
            icon: listening ? Icons.call_end_outlined : Icons.headphones,
            onPressed: onToggle,
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  final String? subtitle;

  const _Empty(this.text, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line2, width: 1.5),
      ),
      child: Column(
        children: [
          AppText(
            text: text,
            type: AppTextType.bodySmall,
            textAlign: TextAlign.center,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
          if (subtitle != null) ...[
            addVerticalSpacing(0.47),
            AppText(
              text: subtitle!,
              type: AppTextType.bodySmall,
              textAlign: TextAlign.center,
              color: AppColors.muted,
            ),
          ],
        ],
      ),
    );
  }
}

Widget _sectionHeading(String text) => Padding(
  padding: const EdgeInsets.only(top: 22, bottom: 10),
  child: AppText(
    text: text,
    type: AppTextType.titleSmall,
    fontFamily: 'Playfair Display',
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  ),
);

class _MeetingMinutesCard extends StatelessWidget {
  final MeetingMinutes minutes;

  const _MeetingMinutesCard({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return DesignCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: minutes.summary,
            type: AppTextType.bodySmall,
            color: AppColors.ink,
          ),
          if (minutes.decisions.isNotEmpty) ...[
            addVerticalSpacing(1.42),
            AppText(
              text: 'Decisions',
              type: AppTextType.bodySmall,
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
            addVerticalSpacing(0.47),
            for (final decision in minutes.decisions)
              AppText(
                text: '• $decision',
                type: AppTextType.bodySmall,
                color: AppColors.ink,
              ),
          ],
          if (minutes.actions.isNotEmpty) ...[
            addVerticalSpacing(1.42),
            AppText(
              text: 'Actions',
              type: AppTextType.bodySmall,
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
            addVerticalSpacing(0.47),
            for (final action in minutes.actions)
              AppText(
                text:
                    '• ${action.action} (${action.owner}${action.due == null ? '' : ', by ${DateFormat('d MMM yyyy').format(action.due!)}'})',
                type: AppTextType.bodySmall,
                color: AppColors.ink,
              ),
          ],
        ],
      ),
    );
  }
}
