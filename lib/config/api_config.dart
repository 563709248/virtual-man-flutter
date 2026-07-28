class ApiConfig {
  // Android模拟器访问电脑本机
  static const String baseUrl = "http://10.0.2.2:8080";

  static const String authTitle = "/auth";

  static const String chatApi = "/chats/chats";

  static const String loginApi = '$authTitle/auth/login';
  static const String registerApi = '$authTitle/auth/register';
}
