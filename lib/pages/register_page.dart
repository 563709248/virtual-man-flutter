import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/log_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final api = AuthService();
  final log = LogService();
  bool _loading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void register() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("用户名和密码不能为空")));
      return;
    }
    if (_loading) return;
    setState(() => _loading = true);
    log.log("注册$username");

    try {
      var result = await api.register(
        username: username,
        password: password,
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );
      if (!mounted) return;

      if (result["code"] == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("注册成功")));
        Navigator.pop(context);
      } else {
        throw Exception(result["message"]);
      }
    } catch (e) {
      log.errorLog("注册失败", 800, "$e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("注册失败:$e")));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("注册")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "用户名"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "密码"),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "邮箱"),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: "手机"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _loading ? null : register,
              child: Text(_loading ? "注册中..." : "注册"),
            ),
          ],
        ),
      ),
    );
  }
}
