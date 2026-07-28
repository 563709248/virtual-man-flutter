import 'package:dio/dio.dart';
import '../config/api_config.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    // 请求超时时间
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {"Content-Type": "application/json"},
  ),
);