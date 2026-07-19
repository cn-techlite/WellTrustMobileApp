class GeneralResultModel {
  final bool isSuccess;
  final String? message;

  final dynamic rawData;

  /// JSON response map
  final Map<String, dynamic>? data;

  const GeneralResultModel({
    required this.isSuccess,
    this.message,

    this.rawData,
    this.data,
  });

  factory GeneralResultModel.success({
    dynamic rawData,
    String? message,
    Map<String, dynamic>? data,
  }) {
    return GeneralResultModel(
      isSuccess: true,

      rawData: rawData,
      message: message,
      data: data,
    );
  }

  factory GeneralResultModel.failure(String message) {
    return GeneralResultModel(isSuccess: false, message: message);
  }
}

class Competency {
  final String id;
  final String title;
  final String icon;
  String status; // acknowledged | pending | expired
  final String? signedAt;
  final String? dueBy;
  final String? assessor;
  final String standard;
  final String evidence;

  Competency({
    required this.id,
    required this.title,
    required this.icon,
    required this.status,
    this.signedAt,
    this.dueBy,
    this.assessor,
    required this.standard,
    required this.evidence,
  });
}

class Policy {
  final String id;
  final String title;
  final String icon;
  final String version;
  String status; // pending | acknowledged
  String? publishedAt;
  String? acknowledgedAt;
  final String summary;
  final List<String> keyPoints;

  Policy({
    required this.id,
    required this.title,
    required this.icon,
    required this.version,
    required this.status,
    this.publishedAt,
    this.acknowledgedAt,
    required this.summary,
    this.keyPoints = const [],
  });
}

class Declaration {
  final String id;
  final String title;
  final String icon;
  String status; // pending | overdue | completed
  final String? dueBy;
  String? completedAt;
  final String description;
  final List<String> questions;

  Declaration({
    required this.id,
    required this.title,
    required this.icon,
    required this.status,
    this.dueBy,
    this.completedAt,
    required this.description,
    this.questions = const [],
  });
}

class StaffMessage {
  final String from;
  final String initials;
  final bool mine;
  final String text;
  final String time;
  const StaffMessage({
    required this.from,
    required this.initials,
    required this.mine,
    required this.text,
    required this.time,
  });
}

class Meeting {
  final String id;
  final String time;
  final String title;
  final String who;
  final String duration;
  final String status;
  const Meeting({
    required this.id,
    required this.time,
    required this.title,
    required this.who,
    required this.duration,
    required this.status,
  });
}
