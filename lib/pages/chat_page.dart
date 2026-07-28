import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';

import '../services/chat_service.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final controller = InMemoryChatController();

  final chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI朋友")),

      body: Chat(
        chatController: controller,
        currentUserId: "user001",
        resolveUser: (userId) async {
          return User(id: userId, name: userId == "ai" ? "AI朋友" : "我");
        },
        onMessageSend: (text) async {
          // 用户消息
          controller.insertMessage(
            TextMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              authorId: "user001",
              createdAt: DateTime.now(),
              text: text,
            ),
          );
          final reply = await chatService.sendMessage(text);
          controller.insertMessage(
            TextMessage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              authorId: "ai",
              createdAt: DateTime.now(),
              text: reply,
            ),
          );
        },
      ),
    );
  }
}
