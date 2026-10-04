/// Body for POST /api/mobile/visits/{id}/issues.
class VisitIssueRequest {
  final String issueType;
  final String details;

  const VisitIssueRequest({required this.issueType, required this.details});

  Map<String, dynamic> toJson() => {'issueType': issueType, 'details': details};
}
