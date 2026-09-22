class CompanionCharacter {
  const CompanionCharacter({
    required this.id,
    required this.name,
    this.avatar,
    this.personality,
    this.background,
    this.promptTemplate,
    this.voiceId,
    this.modelUrl,
    this.status = 1,
  });

  final int id;
  final String name;
  final String? avatar;
  final String? personality;
  final String? background;
  final String? promptTemplate;
  final String? voiceId;

  /// 3D 模型资源地址（预留）
  final String? modelUrl;
  final int status;

  bool get enabled => status == 1;

  factory CompanionCharacter.fromJson(Map<String, dynamic> json) =>
      CompanionCharacter(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '未命名角色',
        avatar: json['avatar'] as String?,
        personality: json['personality'] as String?,
        background: json['background'] as String?,
        promptTemplate: json['promptTemplate'] as String?,
        voiceId: json['voiceId'] as String?,
        modelUrl: json['modelUrl'] as String?,
        status: (json['status'] as num?)?.toInt() ?? 1,
      );
}
