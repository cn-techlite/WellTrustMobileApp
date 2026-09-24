import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/provider/home_provider.dart';

/// Unread messages from the office. Sample count until there is a messages API.
class UnreadMessagesNotifier extends Notifier<int> {
  @override
  int build() => 3;

  void clear() => state = 0;
}

final unreadMessagesProvider = NotifierProvider<UnreadMessagesNotifier, int>(
  UnreadMessagesNotifier.new,
);

/// When the carer last opened Notifications on this device.
class NotificationsSeenNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void markSeen() => state = DateTime.now();
}

final notificationsSeenProvider =
    NotifierProvider<NotificationsSeenNotifier, DateTime?>(
      NotificationsSeenNotifier.new,
    );

/// Notifications for this carer that arrived since they last opened the list.
final unreadNotificationsProvider = Provider<int>((ref) {
  final seenAt = ref.watch(notificationsSeenProvider);
  final all =
      ref.watch(notificationControllerProvider).value?.allNotification ??
      const [];
  return all.where((n) {
    if (n.userId != globals.userId) return false;
    final at = n.createdAt;
    return seenAt == null || at == null || at.isAfter(seenAt);
  }).length;
});
