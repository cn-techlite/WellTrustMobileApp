import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/helper_functions.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/account/presentation/screen/notification_page.dart';
import 'package:well_trust_mobile_app/features/auth/presentation/screen/logins.dart';
import 'package:well_trust_mobile_app/features/home/presentation/widget/chat_message_widget.dart';
import 'package:well_trust_mobile_app/features/meetings/presentation/screen/meetings_screen.dart';
import 'package:well_trust_mobile_app/shared/state/header_state.dart';
import 'package:well_trust_mobile_app/shared/widgets/brand_logo.dart';

/// The navy bar at the top of every screen (design `.bar`): the WellTrust mark,
/// then the page title, then Messages, Team meetings, Lock and Notifications.
///
/// With no [title] it shows the app name (the Today tab). With [showBack] it
/// starts with a Back button instead of the mark, for pages opened from a tab.
class WellTrustAppBar extends ConsumerWidget {
  final String? title;
  final bool showBack;

  const WellTrustAppBar({super.key, this.title, this.showBack = false});

  Future<void> _lock(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Lock the app?', style: TextStyle(color: AppColors.ink)),
        content: Text(
          'You will go back to the sign in screen and need your username and PIN to continue.',
          style: TextStyle(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Lock', style: TextStyle(color: AppColors.ink)),
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
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title ?? (width <= 400 ? 'WellTrust' : 'WellTrust Carer'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: title == null ? 17 : 19,
                ),
              ),
            ),
            _BarIcon(
              icon: Icons.chat_bubble_outline,
              label: unreadMessages > 0
                  ? 'Messages, $unreadMessages unread'
                  : 'Messages',
              badge: unreadMessages,
              slot: slot,
              onTap: () {
                ref.read(unreadMessagesProvider.notifier).clear();
                displayBottomSheet(context, const MessagesBottomSheet());
              },
            ),
            _BarIcon(
              icon: Icons.groups_outlined,
              label: 'Team meetings',
              slot: slot,
              onTap: () => navigateToRoute(context, const MeetingsScreen()),
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
              onTap: () {
                ref.read(notificationsSeenProvider.notifier).markSeen();
                navigateToRoute(context, const NotificationPage());
              },
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
                    const SizedBox(width: 6),
                    const Text(
                      'Back',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 6),
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

  const _BarIcon({
    required this.icon,
    required this.label,
    required this.slot,
    required this.onTap,
    this.badge = 0,
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
                child: InkResponse(
                  onTap: onTap,
                  radius: 24,
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: 22),
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
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: TextStyle(
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
