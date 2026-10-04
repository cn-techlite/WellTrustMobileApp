import 'package:well_trust_mobile_app/core/utils/app_buttons.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/notification_page.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:well_trust_mobile_app/features/meetings/presentation/screen/meetings_screen.dart';
import 'package:well_trust_mobile_app/features/messages/presentation/screen/messages_screen.dart';
import 'package:well_trust_mobile_app/shared/state/header_state.dart';
import 'package:well_trust_mobile_app/features/meetings/presentation/state/providers/meeting_provider.dart';
import 'package:well_trust_mobile_app/shared/widgets/brand_logo.dart';

/// The navy bar at the top of every screen (design `.bar`): the WellTrust mark,
/// then the page title, then Messages, Team meetings, Lock and Notifications.
///
/// With no [title] it shows the app name (the Today tab). With [showBack] it
/// starts with a Back button instead of the mark, for pages opened from a tab.
class WellTrustAppBar extends ConsumerWidget {
  final String? title;
  final bool showBack;
  final bool messagesActive;
  final bool meetingsActive;
  final bool notificationsActive;

  const WellTrustAppBar({
    super.key,
    this.title,
    this.showBack = false,
    this.messagesActive = false,
    this.meetingsActive = false,
    this.notificationsActive = false,
  });

  Future<void> _lock(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: AppText(
          text: 'Lock the app?',
          type: AppTextType.bodySmall,
          color: AppColors.ink,
        ),
        content: AppText(
          text:
              'You will go back to the sign in screen and need your username and PIN to continue.',
          type: AppTextType.bodySmall,
          color: AppColors.muted,
        ),
        actions: [
          AppButton(
            text: 'Cancel',
            expand: false,
            btnColor: Colors.transparent,
            textColor: AppColors.muted,
            onPressed: () => Navigator.pop(dialogContext, false),
          ),
          AppButton(
            text: 'Lock',
            expand: false,
            onPressed: () => Navigator.pop(dialogContext, true),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      navigateAndRemoveUntilRoute(context, const LoginScreens());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final unreadMessages = ref.watch(unreadMessagesProvider);
    final unreadNotifications = ref.watch(unreadNotificationsProvider);
    final meetingLive =
        ref
            .watch(meetingsProvider)
            .value
            ?.meetings
            .any((meeting) => meeting.isLive) ??
        false;
    final slot = width <= 380 ? 40.0 : 44.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        width: double.infinity,
        color: AppColors.navy,
        padding: EdgeInsets.fromLTRB(
          showBack ? 4 : 12,
          MediaQuery.paddingOf(context).top + 8,
          6,
          8,
        ),
        child: Row(
          children: [
            if (showBack)
              _BackButton(
                showLabel: width > 400,
                onTap: () => Navigator.maybePop(context),
              )
            else ...[
              const WellTrustMark(size: 32),
              addHorizontalSpacing(2.56),
            ],
            Expanded(
              child: AppText(
                text: title ?? (width <= 400 ? 'WellTrust' : 'WellTrust Carer'),
                type: AppTextType.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                fontFamily: 'Playfair Display',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: title == null ? 17 : 19,
              ),
            ),
            _BarIcon(
              icon: Icons.chat_bubble_outline,
              label: unreadMessages > 0
                  ? 'Messages, $unreadMessages unread'
                  : 'Messages',
              badge: unreadMessages,
              slot: slot,
              active: messagesActive,
              onTap: messagesActive
                  ? () {}
                  : () => navigateToRoute(context, const MessagesScreen()),
            ),
            _BarIcon(
              icon: Icons.groups_outlined,
              label: meetingLive ? 'Team meetings, on now' : 'Team meetings',
              slot: slot,
              active: meetingsActive,
              liveDot: meetingLive,
              onTap: meetingsActive
                  ? () {}
                  : () => navigateToRoute(context, const MeetingsScreen()),
            ),
            _BarIcon(
              icon: Icons.lock_outline,
              label: 'Lock the app',
              slot: slot,
              onTap: () => _lock(context),
            ),
            _BarIcon(
              icon: Icons.notifications_none,
              label: unreadNotifications > 0
                  ? 'Notifications, $unreadNotifications unread'
                  : 'Notifications',
              badge: unreadNotifications,
              slot: slot,
              active: notificationsActive,
              onTap: notificationsActive
                  ? () {}
                  : () => navigateToRoute(context, const NotificationPage()),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool showLabel;

  const _BackButton({required this.onTap, required this.showLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Go back',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: showLabel ? 8 : 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  if (showLabel) ...[
                    addHorizontalSpacing(1.54),
                    const AppText(
                      text: 'Back',
                      type: AppTextType.bodySmall,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    addHorizontalSpacing(1.54),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badge;
  final double slot;
  final VoidCallback onTap;
  final bool active;
  final bool liveDot;

  const _BarIcon({
    required this.icon,
    required this.label,
    required this.slot,
    required this.onTap,
    this.badge = 0,
    this.active = false,
    this.liveDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: ExcludeSemantics(
        child: SizedBox(
          width: slot,
          height: 44,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkResponse(
                    onTap: onTap,
                    radius: 24,
                    child: Center(
                      child: Icon(icon, color: Colors.white, size: 22),
                    ),
                  ),
                ),
              ),
              if (badge > 0)
                Positioned(
                  top: 3,
                  right: 1,
                  child: IgnorePointer(
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.rose,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: AppText(
                        text: badge > 9 ? '9+' : '$badge',
                        type: AppTextType.bodySmall,
                        color: AppColors.dark
                            ? const Color(0xFF40191A)
                            : Colors.white,
                        fontSize: 11.2,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              if (liveDot && badge == 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: IgnorePointer(
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.sage,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.navy, width: 1.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
