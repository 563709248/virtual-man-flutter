import '../config/api_config.dart';
import 'api_service.dart';
import 'log_service.dart';

class AuthService {
  final log = LogService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await dio.post(
        ApiConfig.loginApi,
        data: {"username": username, "password": password},
      );
      return response.data;
    } catch (e) {
      log.errorLog("登录失败", 800, "登录失败:$e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await dio.post(
        ApiConfig.registerApi,
        data: {
          "username": username,
          "password": password,
          "email": email,
          "phone": phone,
        },
      );

      return response.data;
    } catch (e) {
      log.errorLog("注册失败", 800, "注册失败:$e");
      rethrow;
    }
  }
}
