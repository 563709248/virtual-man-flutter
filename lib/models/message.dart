class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.createTime,
  });

  final int? id;
  final String role;
  final String content;
  final DateTime? createTime;

  bool get isMine => role.toLowerCase() == 'user';

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: (json['id'] as num?)?.toInt(),
    role: json['role'] as String? ?? 'assistant',
    content: json['content'] as String? ?? '',
    createTime: DateTime.tryParse(json['createTime'] as String? ?? ''),
  );
}

class ChatHistoryPage {
  const ChatHistoryPage({
    required this.messages,
    this.nextBeforeMessageId,
    required this.hasMore,
  });

  final List<ChatMessage> messages;
  final int? nextBeforeMessageId;
  final bool hasMore;

  factory ChatHistoryPage.fromJson(Map<String, dynamic> json) =>
      ChatHistoryPage(
        messages: ((json['messages'] as List<dynamic>?) ?? const [])
            .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
            .toList(),
        nextBeforeMessageId: (json['nextBeforeMessageId'] as num?)?.toInt(),
        hasMore: json['hasMore'] as bool? ?? false,
      );
}
