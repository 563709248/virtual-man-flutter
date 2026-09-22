import 'dart:convert';

import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/message.dart';
import 'api_service.dart';

class ChatService {
  Future<String> sendMessage({
    required int characterId,
    required String message,
  }) async {
    try {
      final response = await dio.post(
        ApiConfig.chatApi,
        data: {'characterId': characterId, 'content': message},
      );

      final json = response.data;
      // 判断接口是否成功
      if (json["code"] == 200) {
        return json['data']['reply'] as String;
      } else {
        return "服务器错误:${json["message"]}";
      }
    } catch (e) {
      return "服务器连接失败: $e";
    }
  }

  Future<ChatHistoryPage> history({
    required int characterId,
    int? beforeMessageId,
  }) async {
    final response = await dio.get(
      ApiConfig.chatHistoryApi,
      queryParameters: {
        'characterId': characterId,
        'beforeMessageId': ?beforeMessageId,
        'limit': 30,
      },
    );
    final body = response.data as Map<String, dynamic>;
    if (body['code'] != 200) {
      throw DioException(
        requestOptions: response.requestOptions,
        error: body['message'],
      );
    }
    return ChatHistoryPage.fromJson(body['data'] as Map<String, dynamic>);
  }

  Stream<String> streamMessage({
    required int characterId,
    required String message,
  }) async* {
    final response = await dio.post<ResponseBody>(
      ApiConfig.chatStreamApi,
      data: {'characterId': characterId, 'content': message},
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
        // 大模型生成间隔可能超过全局 10s 的 receiveTimeout，流式请求单独放宽
        receiveTimeout: const Duration(minutes: 3),
      ),
    );
    final stream = response.data?.stream;
    if (stream == null) throw StateError('服务端未返回流式响应');

    var eventName = 'message';
    final data = <String>[];
    await for (final line
        in utf8.decoder.bind(stream).transform(const LineSplitter())) {
      if (line.isEmpty) {
        if (eventName == 'message' && data.isNotEmpty) {
          yield data.join('\n');
        }
        eventName = 'message';
        data.clear();
      } else if (line.startsWith('event:')) {
        eventName = line.substring('event:'.length).trim();
      } else if (line.startsWith('data:')) {
        data.add(line.substring('data:'.length).trimLeft());
      }
    }
  }
}
