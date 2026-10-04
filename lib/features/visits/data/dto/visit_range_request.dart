import 'package:intl/intl.dart';

/// Query values used to request a carer's rota for a date range.
class VisitRangeRequest {
  final DateTime from;
  final DateTime to;

  const VisitRangeRequest({required this.from, required this.to});

  Map<String, String?> toQuery() => {
    'from': DateFormat('yyyy-MM-dd').format(from),
    'to': DateFormat('yyyy-MM-dd').format(to),
  };
}
