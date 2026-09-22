import 'package:flutter/foundation.dart';

class ApiConfig {
  /// 后端网关地址。安卓模拟器通过 10.0.2.2 访问宿主机，
  /// iOS 模拟器和桌面端使用 127.0.0.1。真机调试请用
  /// `--dart-define=API_BASE_URL=http://<局域网IP>:8080` 指定。
  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8080'
        : 'http://127.0.0.1:8080';
  }

  static const String loginApi = '/auth/login';
  static const String registerApi = '/auth/register';
  static const String chatApi = '/chats';
  static const String chatStreamApi = '/chats/stream';
  static const String chatHistoryApi = '/chats/history';
  static const String relationshipApi = '/memories/relationships';
  static const String memoryApi = '/memories';
  static const String myMemoryApi = '/memories/me';
  static const String notificationApi = '/notifications';
  static const String myNotificationApi = '/notifications/me';
  static const String notificationPreferenceApi = '/notifications/preferences';
  static const String profileApi = '/users/me/profile';
  static const String characterApi = '/characters';
  static const String productApi = '/payments/products';
  static const String orderApi = '/payments/orders';
  static const String activeMembershipApi = '/payments/memberships/active';
}
