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
