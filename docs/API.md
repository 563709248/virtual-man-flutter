# API 接入

基础地址由 `API_BASE_URL` 注入。除登录注册外，Dio 自动发送 `Authorization: Bearer <token>`。

- `POST /auth/login`、`POST /auth/register`
- `GET/PUT /users/me/profile`：当前登录用户查看或保存昵称、生日、性别和兴趣。
- `GET /characters`：读取当前认证用户的可用角色列表。
- `POST /chats`：请求体为 `characterId`、`content`；服务端从 JWT 识别用户。
- `POST /chats/stream`：以 SSE `message` 事件逐段返回回复，并以 `complete` 事件结束。
- `GET /chats/history?characterId=&beforeMessageId=&limit=`：按时间正序返回聊天记录和向前翻页游标。
- `GET /memories/relationships/{userId}/{characterId}`：读取关系状态。
- `GET /memories/me?characterId=&memoryType=&limit=`：读取当前用户的长期记忆。
- `PUT /memories/{id}`、`DELETE /memories/{id}`：编辑或删除当前用户的一条记忆。
- `GET /notifications/me?unreadOnly=`、`POST /notifications/{id}/read`：当前用户查询及标记已读。
- `GET/PUT /notifications/preferences`：读取或更新主动陪伴开关，请求体为 `proactiveEnabled`。

网关会验证 JWT；客户端不得自行伪造用户身份头。
