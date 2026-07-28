import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ChatService {
  final Dio dio = Dio();

  Future<String> sendMessage(String message) async {
    try {
      final response = await dio.post(
        ApiConfig.baseUrl + ApiConfig.chatApi,

        data: {"userId": 1, "characterId": 1, "content": message},
      );

      final json = response.data;
      // 判断接口是否成功
      if (json["code"] == 200) {
        return json["data"]["reply"];
      } else {
        return "服务器错误:${json["message"]}";
      }
    } catch (e) {
      return "服务器连接失败: $e";
    }
  }
}
