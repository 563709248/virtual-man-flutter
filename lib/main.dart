import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/home_shell.dart';
import 'services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await session.restore();
  runApp(const AiFriendApp());
}

class AiFriendApp extends StatelessWidget {
  const AiFriendApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp 是整个APP的根组件
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '知心',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B87),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
      // 登录态变化（登录/登出/401 失效）时自动切换首页
      home: ListenableBuilder(
        listenable: session,
        builder: (context, _) =>
            session.isAuthenticated ? const HomeShell() : const LoginPage(),
      ),
    );
  }
}
