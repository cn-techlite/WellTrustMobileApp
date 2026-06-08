// Explorer

import 'package:well_trust_mobile_app/features/home/data/model/advert_response_model.dart';

class AdvertStateModel {
  final bool hasFetched;
  final int visitCount;
  final List<AdvertResponseModel> explore;

  const AdvertStateModel({
    this.hasFetched = false,
    this.visitCount = 0,
    this.explore = const [],
  });

  AdvertStateModel copyWith({
    bool? hasFetched,
    int? visitCount,
    List<AdvertResponseModel>? explore,
  }) {
    return AdvertStateModel(
      hasFetched: hasFetched ?? this.hasFetched,
      visitCount: visitCount ?? this.visitCount,
      explore: explore ?? this.explore,
    );
  }
}
