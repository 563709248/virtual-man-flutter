# AI Context

客户端使用 Flutter Material 3 和 Dio。`SessionService` 在内存中持有登录令牌并解析 JWT 中的 `userId` 供兼容接口使用，`api_service.dart` 统一注入 Bearer 头。资料页使用 `/users/me/profile`，不再将用户 ID 交给客户端路径。`HomeShell` 从 `/characters` 加载当前用户的启用角色，并将选择结果传给聊天、关系和记忆页面。聊天页使用 `/chats/history` 游标分页；长期记忆使用当前用户范围的 `/memories/me`、`PUT /memories/{id}` 和 `DELETE /memories/{id}`。新接口优先添加类型模型和服务方法，再由页面消费。

后续优先级：持久化安全会话、文件预签名上传、资料编辑和离线缓存。
