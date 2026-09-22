# 数据模型

客户端不直接连接 MySQL。它通过网关读取后端的 `chat_message`、`relationship_state`、`ai_memory` 和 `notification` 聚合结果。字段定义和本地升级 SQL 由后端仓库维护。
