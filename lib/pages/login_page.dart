import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/log_service.dart';
import 'register_page.dart';
import '../services/session_service.dart';

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
  bool _loading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("请输入用户名和密码")));
      return;
    }
    if (_loading) return;
    setState(() => _loading = true);

    try {
      var result = await api.login(username, password);
      if (!mounted) return;

      if (result["code"] == 200) {
        // ListenableBuilder 监听登录态，自动切换到 HomeShell
        await session.signIn(
          token: result['data'] as String,
          username: username,
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result["message"] ?? "登录失败")));
      }
    } catch (e) {
      log.errorLog("网络异常", 800, "$e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("网络异常，请稍后重试")));
    } finally {
      if (mounted) setState(() => _loading = false);
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

              child: ElevatedButton(
                onPressed: _loading ? null : login,
                child: Text(_loading ? "登录中..." : "登录"),
              ),
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
