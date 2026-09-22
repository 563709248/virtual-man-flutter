class RelationshipState {
  const RelationshipState({
    required this.intimacy,
    required this.trust,
    required this.emotion,
    required this.level,
  });

  final int intimacy;
  final int trust;
  final String emotion;
  final int level;

  factory RelationshipState.fromJson(Map<String, dynamic> json) =>
      RelationshipState(
        intimacy: json['intimacy'] as int? ?? 0,
        trust: json['trust'] as int? ?? 0,
        emotion: json['emotion'] as String? ?? '平静',
        level: json['level'] as int? ?? 0,
      );
}

class MemoryItem {
  const MemoryItem({
    required this.id,
    required this.type,
    required this.content,
    required this.importance,
  });
  final int id;
  final String type;
  final String content;
  final int importance;

  factory MemoryItem.fromJson(Map<String, dynamic> json) => MemoryItem(
    id: (json['id'] as num?)?.toInt() ?? 0,
    type: json['memoryType'] as String? ?? 'MEMORY',
    content: json['content'] as String? ?? '',
    importance: json['importance'] as int? ?? 0,
  );
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.read,
  });
  final int id;
  final String title;
  final String content;
  final bool read;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        read: (json['status'] as int? ?? 0) == 1,
      );
}

class NotificationPreference {
  const NotificationPreference({required this.proactiveEnabled});

  final bool proactiveEnabled;

  factory NotificationPreference.fromJson(Map<String, dynamic> json) =>
      NotificationPreference(
        proactiveEnabled: (json['proactiveEnabled'] as num?)?.toInt() != 0,
      );
}
