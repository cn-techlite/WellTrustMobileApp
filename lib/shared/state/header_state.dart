import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/providers/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/providers/message_provider.dart';

/// Unread message threads shown by the badge in the global app bar.
final unreadMessagesProvider = Provider<int>(
  (ref) => ref.watch(unreadMessageCountProvider),
);

String notificationReadKey(NotificationResponseModel notification) {
  final id = notification.id;
  if (id != null && id.isNotEmpty) return id;
  return '${notification.title}|${notification.createdAt?.toIso8601String()}';
}

/// Notifications the carer has opened on this device.
class NotificationReadNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void markRead(String id) => state = {...state, id};

  void markAll(Iterable<String> ids) => state = {...state, ...ids};
}

final notificationReadProvider =
    NotifierProvider<NotificationReadNotifier, Set<String>>(
      NotificationReadNotifier.new,
    );

/// Notifications for this carer that arrived since they last opened the list.
final unreadNotificationsProvider = Provider<int>((ref) {
  final read = ref.watch(notificationReadProvider);
  final all =
      ref.watch(notificationControllerProvider).value?.allNotification ??
      const [];
  return all.where((n) {
    if (n.userId != globals.userId) return false;
    return !read.contains(notificationReadKey(n));
  }).length;
});
