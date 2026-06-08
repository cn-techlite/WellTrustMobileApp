import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/core/utils/colors.dart';
import 'package:well_trust_mobile_app/core/utils/package_export.dart';
import 'package:well_trust_mobile_app/core/utils/size_config.dart';
import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/provider/home_provider.dart';
import 'package:well_trust_mobile_app/features/home/presentation/state/state_model/notification_state.dart';
import 'package:well_trust_mobile_app/shared/widgets/app_text.dart';
import 'package:well_trust_mobile_app/shared/widgets/back_icon.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key});

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref
          .read(notificationControllerProvider.notifier)
          .getAllNotificationExploreData();
    });
  }

  List<NotificationResponseModel> _getOrdered(
    List<NotificationResponseModel> model,
  ) {
    final notifications = [...model];

    notifications.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

      return bDate.compareTo(aDate);
    });

    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(notificationControllerProvider);

    final data = asyncState.value ?? const NotificationStateModel();

    final isLoading = asyncState.isLoading && !data.hasFetched;

    final notifications = data.allNotification
        .where((element) => element.userId == globals.userId)
        .toList();

    final orderedNotifications = _getOrdered(notifications);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: buildFlexibleAppBar(
        context: context,
        title: const AppText(
          text: "Notifications",
          textAlign: TextAlign.start,
          color: AppColors.black,
          fontWeight: FontWeight.w800,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 18, right: 18),
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(notificationControllerProvider.notifier)
                  .getAllNotificationExploreData(forceRefresh: true);
            },
            child: isLoading
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: SizeConfig.heightAdjusted(35)),
                      const Center(child: CircularProgressIndicator()),
                    ],
                  )
                : orderedNotifications.isNotEmpty
                ? ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: orderedNotifications.length,
                    itemBuilder: (BuildContext context, int index) {
                      final notification = orderedNotifications[index];

                      final createdAt = notification.createdAt;

                      final date = createdAt == null
                          ? ""
                          : DateFormat("E, MMM d").format(createdAt.toLocal());

                      final time = createdAt == null
                          ? ""
                          : DateFormat("hh:mm").format(createdAt.toLocal());

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.grey.withValues(alpha:  0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (notification.id == null) return;

                                    ref
                                        .read(
                                          notificationControllerProvider
                                              .notifier,
                                        )
                                        .getNotificationData(
                                          id: notification.id!,
                                        );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          text: notification.title ?? "",
                                          textAlign: TextAlign.start,
                                          color: AppColors.black,
                                          maxLines: 1,
                                          fontWeight: FontWeight.bold,
                                        ),

                                        AppText(
                                          text: notification.body ?? "",
                                          textAlign: TextAlign.start,
                                          color: AppColors.black,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w400,
                                        ),

                                        addVerticalSpacing(55),

                                        AppText(
                                          text: "$date $time",
                                          textAlign: TextAlign.start,
                                          color: AppColors.green,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const Divider(
                                  thickness: 1.5,
                                  color: AppColors.grey,
                                ),
                              ],
                            ),
                          ),

                          addVerticalSpacing(35),
                        ],
                      );
                    },
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: SizeConfig.heightAdjusted(20)),
                      Image.asset(
                        "assets/images/notification_icon.png",
                        width: 100,
                        height: 100,
                      ),
                      addVerticalSpacing(5),
                      const Center(
                        child: AppText(
                          text: "Nothing to show here",
                          textAlign: TextAlign.start,
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Center(
                        child: AppText(
                          text: "There is no notification yet",
                          textAlign: TextAlign.center,
                          color: AppColors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
