import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/companion_models.dart';
import 'api_service.dart';

class CompanionService {
  const CompanionService();

  Future<RelationshipState> relationship({
    required int userId,
    required int characterId,
  }) async {
    final response = await dio.get(
      '${ApiConfig.relationshipApi}/$userId/$characterId',
    );
    return RelationshipState.fromJson(_data(response));
  }

  Future<List<MemoryItem>> myMemories({
    required int characterId,
    String? memoryType,
  }) async {
    final response = await dio.get(
      ApiConfig.myMemoryApi,
      queryParameters: {
        'characterId': characterId,
        'memoryType': ?memoryType,
        'limit': 20,
      },
    );
    final items = _data(response) as List<dynamic>? ?? <dynamic>[];
    return items
        .map((item) => MemoryItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MemoryItem> updateMemory({
    required int id,
    required String content,
    required int importance,
  }) async {
    final response = await dio.put(
      '${ApiConfig.memoryApi}/$id',
      data: {'content': content, 'importance': importance},
    );
    return MemoryItem.fromJson(_data(response) as Map<String, dynamic>);
  }

  Future<void> deleteMemory({required int id}) async {
    final response = await dio.delete('${ApiConfig.memoryApi}/$id');
    _data(response);
  }

  Future<List<AppNotification>> notifications({bool unreadOnly = false}) async {
    final response = await dio.get(
      ApiConfig.myNotificationApi,
      queryParameters: {'unreadOnly': unreadOnly},
    );
    final items = _data(response) as List<dynamic>? ?? <dynamic>[];
    return items
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationRead({required int id}) async {
    final response = await dio.post('${ApiConfig.notificationApi}/$id/read');
    _data(response);
  }

  Future<NotificationPreference> notificationPreference() async {
    final response = await dio.get(ApiConfig.notificationPreferenceApi);
    return NotificationPreference.fromJson(
      _data(response) as Map<String, dynamic>,
    );
  }

  Future<NotificationPreference> updateNotificationPreference({
    required bool proactiveEnabled,
  }) async {
    final response = await dio.put(
      ApiConfig.notificationPreferenceApi,
      data: {'proactiveEnabled': proactiveEnabled},
    );
    return NotificationPreference.fromJson(
      _data(response) as Map<String, dynamic>,
    );
  }

  dynamic _data(Response<dynamic> response) {
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200)
      throw DioException(
        requestOptions: response.requestOptions,
        error: body['message'],
      );
    return body['data'];
  }
}
