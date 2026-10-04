import 'package:well_trust_mobile_app/features/handover/data/model/handover_model.dart';

class CreateHandoverRequest {
  final HandoverEntry entry;

  const CreateHandoverRequest(this.entry);

  Map<String, dynamic> toJson() => {
    'clientId': entry.clientId,
    'kind': entry.kind == HandoverKind.todo
        ? 'Todo'
        : entry.kind.label.replaceAll(' ', ''),
    'priority': entry.priority.label,
    'text': entry.text,
    'details': entry.details,
    'needsFollowUp': entry.needsFollowUp,
    'followUpFor': entry.followUpFor,
    'followUpDue': entry.followUpDue?.toIso8601String(),
  };
}

class ResolveHandoverRequest {
  final String resolutionNote;

  const ResolveHandoverRequest(this.resolutionNote);

  Map<String, dynamic> toJson() => {'resolutionNote': resolutionNote};
}
