import 'package:flutter/material.dart';

import 'pages/login_page.dart';

void main() {
  // 程序入口
  debugPrint("======== APP START ========");

  runApp(const AiFriendApp());
}

class AiFriendApp extends StatelessWidget {
  const AiFriendApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp 是整个APP的根组件
    return MaterialApp(
      // 去掉右上角debug标识
      debugShowCheckedModeBanner: false,

      // APP名字
      title: "AI Friend",

      // 全局主题
      theme: ThemeData(primarySwatch: Colors.blue),

      // 首页
      home: const LoginPage(),
    );
  }
}
