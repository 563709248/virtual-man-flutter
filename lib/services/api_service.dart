import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import 'session_service.dart';

/// 本机与局域网地址不走系统代理（本机 HTTP_PROXY 会把 127.0.0.1 等请求
/// 送进失效代理导致 502）；其余地址沿用环境代理配置。
bool _isLocalOrLan(String host) {
  if (host == 'localhost' || host == '10.0.2.2' || host.endsWith('.local')) {
    return true;
  }
  final parts = host.split('.');
  if (parts.length != 4) return false;
  final a = int.tryParse(parts[0]);
  final b = int.tryParse(parts[1]);
  if (a == null || b == null) return false;
  return a == 127 ||
      a == 10 ||
      (a == 192 && b == 168) ||
      (a == 172 && b >= 16 && b <= 31);
}

HttpClient _createHttpClient() {
  final client = HttpClient();
  client.findProxy = (uri) => _isLocalOrLan(uri.host)
      ? 'DIRECT'
      : HttpClient.findProxyFromEnvironment(uri);
  return client;
}

/// 接口约定：成功 {"code":200,"data":...}；业务错误 HTTP 200 + 非 200 code；
/// 网关或服务端鉴权失败返回 HTTP 401，统一在这里触发登出。
final Dio dio = _createDio();

Dio _createDio() {
  final d = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      // 请求超时时间
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  if (!kIsWeb) {
    d.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: _createHttpClient,
    );
  }
  d.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = session.token;
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        final body = response.data;
        if (body is Map && body['code'] == 401) {
          session.signOut();
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          session.signOut();
        }
        handler.next(error);
      },
    ),
  );
  return d;
}
