/// Body for POST /api/mobile/visits/{id}/clock-out.
class VisitClockOutRequest {
  final DateTime at;
  final List<String> completedTasks;
  final List<String> outstandingTasks;
  final bool requiresFollowUp;
  final bool requiresEscalation;

  const VisitClockOutRequest({
    required this.at,
    required this.completedTasks,
    required this.outstandingTasks,
    this.requiresFollowUp = false,
    this.requiresEscalation = false,
  });

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'tasksCompleted': completedTasks.join('; '),
    'outstandingTasks': outstandingTasks.isEmpty
        ? null
        : outstandingTasks.join('; '),
    'requiresFollowUp': requiresFollowUp,
    'requiresEscalation': requiresEscalation,
  };
}
