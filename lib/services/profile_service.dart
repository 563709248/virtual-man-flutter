import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/user_profile.dart';
import 'api_service.dart';

class ProfileService {
  const ProfileService();

  Future<UserProfile> getProfile() async {
    final response = await dio.get(ApiConfig.profileApi);
    return UserProfile.fromJson(_data(response) as Map<String, dynamic>);
  }

  /// 后端会整体覆盖资料字段，avatar 必须带上原值，否则会被清空
  Future<UserProfile> saveProfile({
    required String nickname,
    String? avatar,
    DateTime? birthday,
    int? gender,
    String? interest,
  }) async {
    final response = await dio.put(
      ApiConfig.profileApi,
      data: {
        'nickname': nickname,
        'avatar': avatar,
        'birthday': birthday == null
            ? null
            : '${birthday.year.toString().padLeft(4, '0')}-${birthday.month.toString().padLeft(2, '0')}-${birthday.day.toString().padLeft(2, '0')}',
        'gender': gender,
        'interest': interest,
      },
    );
    return UserProfile.fromJson(_data(response) as Map<String, dynamic>);
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
