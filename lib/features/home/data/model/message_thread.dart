class MessageEntry {
  final String id;
  final String body;
  final DateTime at;
  final bool mine;

  const MessageEntry({
    this.id = '',
    required this.body,
    required this.at,
    required this.mine,
  });

  factory MessageEntry.fromJson(Map<String, dynamic> json) => MessageEntry(
    id: (json['id'] ?? '').toString(),
    body: (json['message'] ?? '').toString(),
    at:
        DateTime.tryParse((json['createdAtUtc'] ?? '').toString())?.toLocal() ??
        DateTime.now(),
    mine: json['mine'] == true,
  );
}

class MessageThread {
  final String id;
  final String party;
  final String subject;
  final bool unread;
  final List<MessageEntry> entries;
  final String? actionLabel;
  final String? actionRoute;

  const MessageThread({
    required this.id,
    required this.party,
    required this.subject,
    required this.unread,
    required this.entries,
    this.actionLabel,
    this.actionRoute,
  });

  factory MessageThread.fromMessages(
    String threadId,
    Map<String, dynamic> json,
    List<MessageEntry> entries,
  ) => MessageThread(
    id: threadId,
    party: (json['party'] ?? json['recipientGroup'] ?? 'Office').toString(),
    subject: (json['subject'] ?? '').toString(),
    unread: entries.any((entry) => !entry.mine) && json['isRead'] != true,
    entries: entries,
    actionLabel: json['actionLabel']?.toString(),
    actionRoute: json['actionRoute']?.toString(),
  );

  DateTime get lastAt => entries.last.at;
  MessageEntry get lastEntry => entries.last;

  MessageThread copyWith({bool? unread, List<MessageEntry>? entries}) =>
      MessageThread(
        id: id,
        party: party,
        subject: subject,
        unread: unread ?? this.unread,
        entries: entries ?? this.entries,
        actionLabel: actionLabel,
        actionRoute: actionRoute,
      );
}
