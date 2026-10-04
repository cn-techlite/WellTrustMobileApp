/// Body for PUT /api/mobile/visits/{id}/tasks.
class VisitTaskRequest {
  final String taskId;
  final bool completed;

  const VisitTaskRequest({required this.taskId, required this.completed});

  Map<String, dynamic> toJson() => {'taskId': taskId, 'completed': completed};
}
