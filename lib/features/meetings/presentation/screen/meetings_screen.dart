import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/meetings/data/model/meeting_model.dart';
import 'package:well_trust_mobile_app/features/visits/data/model/today_visit.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

/// Team meetings run by the office (design "Team meetings" page).
class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final upcoming = teamMeetings.where((m) => m.end.isAfter(now)).toList();
    final earlier = teamMeetings.where((m) => !m.end.isAfter(now)).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(title: 'Team meetings', showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                Text(
                  'Team meetings run by the office. You can listen while a meeting is on, and read it here once the office has saved it.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 14),
                _heading('Coming up'),
                if (upcoming.isEmpty)
                  const _Empty('No meetings planned')
                else
                  for (final m in upcoming) _MeetingCard(meeting: m),
                const SizedBox(height: 14),
                _heading('Earlier'),
                if (earlier.isEmpty)
                  const _Empty('Nothing saved yet')
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
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Playfair Display',
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: AppColors.ink,
      ),
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
                  child: Text(
                    m.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                if (m.isLive) ...[const SizedBox(width: 8), Pill.ok('On now')],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              when,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            Text(
              'Hosted by ${m.host}. ${m.location}',
              style: TextStyle(color: AppColors.muted, fontSize: 14),
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
          WellTrustAppBar(title: m.title, showBack: true),
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
                            Text(
                              m.title,
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontWeight: FontWeight.w700,
                                fontSize: 19,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$date, ${hhmm(m.start)} to ${hhmm(m.end)}',
                              style: TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${m.location}, Hosted by ${m.host}',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      if (live) ...[
                        const SizedBox(width: 8),
                        Pill.ok('Live now'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (live)
                  _LiveMeetingCard(
                    listening: _listening,
                    onToggle: () => setState(() => _listening = !_listening),
                  )
                else
                  NoticeBox.info(
                    ended
                        ? 'The office has not saved this meeting yet. It will appear here when they do.'
                        : 'You can listen here once the office starts the meeting. This page updates by itself.',
                  ),
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
          Text(
            listening ? 'Listening' : 'The meeting is on now',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w700,
              fontSize: 19,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            listening
                ? 'You are listening only. This app never uses your microphone.'
                : 'Listen in from here. You cannot speak, record or add notes.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
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

  const _Empty(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line2, width: 1.5),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.muted),
      ),
    );
  }
}
