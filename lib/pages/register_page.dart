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

  void register() async {
    log.log("注册${usernameController.text}");

    try {
      var result = await api.register(
        username: usernameController.text,
        password: passwordController.text,
        email: emailController.text,
        phone: phoneController.text,
      );

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("注册失败:$e")));
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

            ElevatedButton(onPressed: register, child: const Text("注册")),
          ],
        ),
      ),
    );
  }
}
