import 'package:intl/intl.dart';
import 'package:well_trust_mobile_app/features/account/data/model/abc_chart_entry.dart';

class CreateAbcChartRequest {
  final AbcChartDraft draft;

  const CreateAbcChartRequest(this.draft);

  Map<String, dynamic> toJson() => {
    'residentId': draft.residentId,
    'episodeDate': DateFormat('yyyy-MM-dd').format(draft.episodeDate),
    'episodeTime': _optional(draft.episodeTime),
    'location': _optional(draft.location),
    'antecedent': draft.antecedent.trim(),
    'behaviour': draft.behaviour.trim(),
    'duration': _optional(draft.duration),
    'consequence': draft.consequence.trim(),
    'possibleFunction': _optional(draft.possibleFunction),
    'staffInvolved': _optional(draft.staffInvolved),
  };

  String? _optional(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
