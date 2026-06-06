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
