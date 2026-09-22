# 知心 Flutter 客户端

面向 Android 与 iOS 的 AI 虚拟伴侣客户端，提供登录注册、角色切换、历史聊天、关系成长、长期记忆管理、通知浏览和主动陪伴开关。

## 运行

```powershell
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Android 模拟器使用 `10.0.2.2` 访问本机网关；iOS 模拟器可使用 `http://127.0.0.1:8080`。真机请替换为局域网网关地址。

聊天、记忆、关系和通知请求会自动携带登录后获得的 Bearer Token。登录令牌中的 `userId` 仅用于当前客户端调用仍需该参数的兼容接口，服务端身份以 JWT 为准。

## 文档

- `docs/PROJECT_STRUCTURE.md`：模块和目录职责
- `docs/FEATURES.md`：已接入功能
- `docs/API.md`：客户端调用的后端 API
- `docs/DATABASE.md`：客户端关联的数据模型说明
- `CHANGELOG.md`：变更记录
- `AI_CONTEXT.md`：架构与后续演进上下文
