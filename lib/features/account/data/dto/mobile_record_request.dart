class MobileRecordRequest {
  final Map<String, dynamic> fields;

  const MobileRecordRequest(this.fields);

  Map<String, dynamic> toJson() => fields;
}
