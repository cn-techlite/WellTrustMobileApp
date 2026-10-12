import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/my_documents_screen.dart';
import 'package:well_trust_mobile_app/features/account/presentation/widget/settings_sheet.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/screen/handover_screen.dart';
import 'package:well_trust_mobile_app/features/handover/presentation/widget/handover_widgets.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/providers/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/notification_state.dart';
import 'package:well_trust_mobile_app/features/home_screen.dart';
import 'package:well_trust_mobile_app/features/home/presentation/screen/meetings_screen.dart';
import 'package:well_trust_mobile_app/features/home/presentation/screen/messages_screen.dart';
import 'package:well_trust_mobile_app/shared/state/header_state.dart';
import 'package:well_trust_mobile_app/shared/widgets/welltrust_app_bar.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  String tab = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(notificationControllerProvider.notifier)
          .getAllNotificationExploreData(),
    );
  }

  List<NotificationResponseModel> ordered(
    List<NotificationResponseModel> notifications,
  ) => [...notifications]
    ..sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

  void markAll(List<NotificationResponseModel> notifications) {
    ref
        .read(notificationReadProvider.notifier)
        .markAll(notifications.map(notificationReadKey));
  }

  void openNotification(NotificationResponseModel notification) {
    ref
        .read(notificationReadProvider.notifier)
        .markRead(notificationReadKey(notification));

    final type = (notification.notificationType ?? '').toLowerCase();
    final title = (notification.title ?? '').toLowerCase();
    if (type.contains('message') || title.contains('message')) {
      navigateToRoute(context, const MessagesScreen());
    } else if (type.contains('meeting') || title.contains('meeting')) {
      navigateToRoute(context, const MeetingsScreen());
    } else if (type.contains('document') ||
        type.contains('certificate') ||
        title.contains('document') ||
        title.contains('certificate')) {
      navigateToRoute(context, const DocumentsScreen());
    } else if (type.contains('handover') || title.contains('handover')) {
      navigateToRoute(context, const HandoverScreen());
    } else if (type.contains('rota') ||
        type.contains('visit') ||
        type.contains('reminder') ||
        type.contains('clock')) {
      navigateAndRemoveUntilRoute(context, const HomeScreenPage(imdex: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(notificationControllerProvider);
    final data = asyncState.value ?? const NotificationStateModel();
    final isLoading = asyncState.isLoading && !data.hasFetched;
    final loadError = asyncState.hasError ? asyncState.error.toString() : null;
    final read = ref.watch(notificationReadProvider);
    final all = ordered(
      data.allNotification
          .where((notification) => notification.userId == globals.userId)
          .toList(),
    );
    final unread = all
        .where(
          (notification) => !read.contains(notificationReadKey(notification)),
        )
        .toList();
    final visible = tab == 'unread' ? unread : all;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          const WellTrustAppBar(
            title: 'Notifications',
            notificationsActive: true,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: RefreshIndicator(
                onRefresh: () => ref
                    .read(notificationControllerProvider.notifier)
                    .getAllNotificationExploreData(forceRefresh: true),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                  children: [
                    AppText(
                      text:
                          'Everything that needs your attention. This inbox is always on, so you never miss a rota change or an urgent handover.',
                      type: AppTextType.bodySmall,
                      color: AppColors.muted,
                    ),
                    addVerticalSpacing(1.90),
                    SegmentTabs(
                      active: tab,
                      options: [
                        ('all', 'All (${all.length})'),
                        ('unread', 'Unread (${unread.length})'),
                      ],
                      onChanged: (value) => setState(() => tab = value),
                    ),
                    addVerticalSpacing(1.42),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        DesignButton(
                          'Mark all as read',
                          small: true,
                          secondary: true,
                          onPressed: unread.isEmpty ? null : () => markAll(all),
                        ),
                        DesignButton(
                          'Notification settings',
                          small: true,
                          secondary: true,
                          onPressed: () => displayBottomSheet(
                            context,
                            const SettingsSheet(),
                          ),
                        ),
                      ],
                    ),
                    addVerticalSpacing(2.13),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (loadError != null && visible.isEmpty)
                      _NotificationError(
                        message: loadError,
                        onRetry: () => ref
                            .read(notificationControllerProvider.notifier)
                            .getAllNotificationExploreData(forceRefresh: true),
                      )
                    else if (visible.isEmpty)
                      _NotificationEmpty(unreadOnly: tab == 'unread')
                    else
                      ..._notificationGroups(visible, read),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _notificationGroups(
    List<NotificationResponseModel> notifications,
    Set<String> read,
  ) {
    final widgets = <Widget>[];
    String? previousDay;
    for (final notification in notifications) {
      final day = _dayLabel(notification.createdAt);
      if (day != previousDay) {
        widgets.add(
          Padding(
            padding: EdgeInsets.only(
              top: previousDay == null ? 0 : 18,
              bottom: 10,
            ),
            child: AppText(
              text: day,
              type: AppTextType.titleSmall,
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
        );
        previousDay = day;
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _NotificationCard(
            notification: notification,
            unread: !read.contains(notificationReadKey(notification)),
            onTap: () => openNotification(notification),
          ),
        ),
      );
    }
    return widgets;
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationResponseModel notification;
  final bool unread;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final urgent = _isUrgent(notification);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: unread ? AppColors.gold : AppColors.line),
            boxShadow: unread
                ? [
                    BoxShadow(
                      color: AppColors.gold,
                      offset: const Offset(-4, 0),
                      spreadRadius: -1,
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.goldBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _notificationIcon(notification.notificationType),
                  color: AppColors.goldDeep,
                  size: 21,
                ),
              ),
              addHorizontalSpacing(3.08),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppText(
                            text: notification.title ?? '',
                            type: AppTextType.bodySmall,
                            color: AppColors.ink,
                            fontWeight: unread
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                        ),
                        addHorizontalSpacing(2.05),
                        AppText(
                          text: notification.createdAt == null
                              ? ''
                              : DateFormat(
                                  'HH:mm',
                                ).format(notification.createdAt!.toLocal()),
                          type: AppTextType.labelLarge,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                    addVerticalSpacing(0.36),
                    AppText(
                      text: notification.body ?? '',
                      type: AppTextType.bodySmall,
                      color: AppColors.muted,
                    ),
                    if (urgent && unread) ...[
                      addVerticalSpacing(0.95),
                      Pill.bad('Urgent'),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationEmpty extends StatelessWidget {
  final bool unreadOnly;

  const _NotificationEmpty({required this.unreadOnly});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      child: Column(
        children: [
          AppText(
            text: unreadOnly ? 'You are all caught up' : 'No notifications yet',
            type: AppTextType.bodySmall,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          addVerticalSpacing(0.47),
          AppText(
            text:
                'Rota changes, handover, visit reminders and other alerts appear here.',
            type: AppTextType.bodySmall,
            color: AppColors.muted,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NotificationError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _NotificationError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
      child: Column(
        children: [
          AppText(
            text: 'Could not load notifications',
            type: AppTextType.bodySmall,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          addVerticalSpacing(0.47),
          AppText(
            text: message,
            type: AppTextType.bodySmall,
            color: AppColors.muted,
            textAlign: TextAlign.center,
          ),
          addVerticalSpacing(1.42),
          DesignButton('Try again', small: true, onPressed: onRetry),
        ],
      ),
    );
  }
}

String _dayLabel(DateTime? value) {
  if (value == null) return 'Earlier';
  final date = value.toLocal();
  final now = DateTime.now();
  if (DateUtils.isSameDay(date, now)) return 'Today';
  if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }
  return DateFormat('EEE d MMM').format(date);
}

IconData _notificationIcon(String? rawType) {
  final type = (rawType ?? '').toLowerCase();
  if (type.contains('rota')) return Icons.calendar_today_outlined;
  if (type.contains('reminder') || type.contains('clock')) {
    return Icons.access_time;
  }
  if (type.contains('handover')) return Icons.swap_horiz_rounded;
  if (type.contains('message')) return Icons.chat_bubble_outline;
  if (type.contains('meeting')) return Icons.groups_outlined;
  if (type.contains('document') || type.contains('certificate')) {
    return Icons.folder_open_outlined;
  }
  if (type.contains('assessment')) return Icons.assignment_outlined;
  if (type.contains('shift')) return Icons.add_circle_outline;
  return Icons.warning_amber_rounded;
}

bool _isUrgent(NotificationResponseModel notification) {
  final value = '${notification.notificationType} ${notification.title}'
      .toLowerCase();
  return value.contains('urgent') ||
      value.contains('overdue') ||
      value.contains('expired') ||
      value.contains('missed') ||
      value.contains('not clocked');
}
