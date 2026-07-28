import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/log_service.dart';
import 'chat_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 用户名输入框
  final usernameController = TextEditingController();

  // 密码输入框
  final passwordController = TextEditingController();
  final api = AuthService();
  final log = LogService();

  void login() async {
    String username = usernameController.text;
    String password = passwordController.text;

    try {
      var result = await api.login(username, password);

      if (result["code"] == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ChatPage()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result["message"] ?? "登录失败")));
      }
    } catch (e) {
      print("网络异常:$e");
      log.errorLog("网络异常", 800, "$e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("网络异常:$e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Friend 登录")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            TextField(
              controller: usernameController,

              decoration: const InputDecoration(
                labelText: "用户名",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,

              obscureText: true,

              decoration: const InputDecoration(
                labelText: "密码",

                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(onPressed: login, child: const Text("登录")),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,

                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },

              child: const Text("没有账号？注册"),
            ),
          ],
        ),
      ),
    );
  }
}
