import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/companion_character.dart';
import 'api_service.dart';

class CharacterService {
  const CharacterService();

  Future<List<CompanionCharacter>> listEnabled() async {
    final response = await dio.get(ApiConfig.characterApi);
    final items = _data(response) as List<dynamic>? ?? const [];
    return items
        .map(
          (item) => CompanionCharacter.fromJson(item as Map<String, dynamic>),
        )
        .where((character) => character.id > 0)
        .toList();
  }

  Future<CompanionCharacter> detail(int id) async {
    final response = await dio.get('${ApiConfig.characterApi}/$id');
    return CompanionCharacter.fromJson(_data(response) as Map<String, dynamic>);
  }

  /// 创建当前用户自己的角色；后端会从登录态取 userId
  Future<CompanionCharacter> create(CharacterPayload payload) async {
    final response = await dio.post(
      ApiConfig.characterApi,
      data: payload.toJson(),
    );
    return CompanionCharacter.fromJson(_data(response) as Map<String, dynamic>);
  }

  Future<void> update(int id, CharacterPayload payload) async {
    final response = await dio.put(
      '${ApiConfig.characterApi}/$id',
      data: payload.toJson(),
    );
    _data(response);
  }

  /// status: 1 启用，0 停用
  Future<void> updateStatus(int id, int status) async {
    final response = await dio.put(
      '${ApiConfig.characterApi}/$id/status',
      data: status,
    );
    _data(response);
  }

  dynamic _data(Response<dynamic> response) {
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: body['message'],
      );
    }
    return body['data'];
  }
}

class CharacterPayload {
  const CharacterPayload({
    required this.name,
    this.avatar,
    this.personality,
    this.background,
    this.promptTemplate,
    this.voiceId,
    this.modelUrl,
  });

  final String name;
  final String? avatar;
  final String? personality;
  final String? background;
  final String? promptTemplate;
  final String? voiceId;
  final String? modelUrl;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (avatar != null && avatar!.isNotEmpty) 'avatar': avatar,
    if (personality != null && personality!.isNotEmpty)
      'personality': personality,
    if (background != null && background!.isNotEmpty) 'background': background,
    if (promptTemplate != null && promptTemplate!.isNotEmpty)
      'promptTemplate': promptTemplate,
    if (voiceId != null && voiceId!.isNotEmpty) 'voiceId': voiceId,
    if (modelUrl != null && modelUrl!.isNotEmpty) 'modelUrl': modelUrl,
  };
}
