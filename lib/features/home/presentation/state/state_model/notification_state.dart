// Notification

import 'package:well_trust_mobile_app/features/home/data/model/notification_model.dart';

class NotificationStateModel {
  final bool hasFetched;
  final int visitCount;
  final List<NotificationResponseModel> allNotification;
  final NotificationResponseModel? singleData;

  const NotificationStateModel({
    this.hasFetched = false,
    this.visitCount = 0,
    this.allNotification = const [],
    this.singleData,
  });

  NotificationStateModel copyWith({
    bool? hasFetched,
    int? visitCount,
    List<NotificationResponseModel>? allNotification,
    NotificationResponseModel? singleData,
  }) {
    return NotificationStateModel(
      hasFetched: hasFetched ?? this.hasFetched,
      visitCount: visitCount ?? this.visitCount,
      allNotification: allNotification ?? this.allNotification,
      singleData: singleData ?? this.singleData,
    );
  }
}
