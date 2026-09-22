class UserProfile {
  const UserProfile({
    required this.nickname,
    this.avatar,
    this.birthday,
    this.gender,
    this.interest,
  });

  final String nickname;
  final String? avatar;
  final DateTime? birthday;
  final int? gender;
  final String? interest;

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    nickname: json['nickname'] as String? ?? '',
    avatar: json['avatar'] as String?,
    birthday: DateTime.tryParse(json['birthday'] as String? ?? ''),
    gender: (json['gender'] as num?)?.toInt(),
    interest: json['interest'] as String?,
  );
}
