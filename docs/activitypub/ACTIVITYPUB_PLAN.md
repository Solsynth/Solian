🛠️ ActivityPub 接入 Solar Network 的分步清单

⸻

🧱 1. 准备 & 设计阶段

1.1 理解 ActivityPub 的核心概念
• Actor / Object / Activity / Collection
• Outbox / Inbox / Followers 列表
ActivityPub 是使用 JSON-LD + ActivityStreams 2.0 来描述社交行为的规范。 ￼

1.2 映射你现有的 Solar Domain 结构

把你现在 Solar Network 的用户、帖子、关注、点赞等：
• 映射为 ActivityPub 的 Actor / Note / Follow / Like 等
• 明确本地模型与 ActivityStreams 对应关系

比如：
• Solar User → ActivityPub Actor
• Post → ActivityPub Note/Object
• Like → ActivityPub Like Activity
这一步是关键的领域建模设计。

⸻

🚪 2. Actor 发现与必要入口

2.1 实现 WebFinger

为每个用户提供 WebFinger endpoint：

GET /.well-known/webfinger?resource=acct:<username>@<domain>

用来让远端服务器查出 actor 细节（包括 inbox/outbox URL）。

2.2 Actor 资源 URL

确保每个用户有一个全局可访问的 URL，例如：

https://solar.io/users/alice

并在其 JSON-LD 中包含：
• inbox
• outbox
• followers
• following
这些是 ActivityPub 基础通信的入口。 ￼

⸻

📮 3. 核心协议实现

3.1 Inbox / Outbox 接口

Inbox（接收来自其他实例的 Activity）
Outbox（本地用户发布 Activity 的出口）

Outbox 需要：
• 生成 activity JSON（Create、Follow、Like 等）
• 存储至本地数据库
• 推送到各 follower 的 Inbox

Inbox 需要：
• 接收并 parse Activity
• 验证签名
• 处理活动（如接受 Follow，记录远程 Post 等）

注意：
• 请求需要验证 HTTP Signatures（远端服务器签名）。 ￼
• 必须满足 ActivityPub 规范对字段的要求。

⸻

🔐 4. 安全与签名

4.1 Actor Keys

每个 Actor 对应一对 RSA / Ed25519 密钥：
• 私钥用于签名发送到其它服务器的请求
• 公钥发布在 Actor JSON 中供对方验证

远端服务器发送到你的 Inbox 时，需要：
• 使用对方的公钥验证签名

HTTP Signatures 是服务器间通信安全的一部分，防止伪造请求。 ￼

⸻

🌐 5. 实现联邦逻辑

5.1 关注逻辑

处理:
• Follow Activity
• Accept / Reject Activity
• 更新本地 followers / following 数据

实现流程参考：1. 本地用户发起 Follow 2. 推送 Follow 到远端 Inbox 3. 等待远端发送 Accept 或 Reject

5.2 推送 content（联邦同步）

当本地用户发布内容时：
• 从 Outbox 取出 Create Activity
• 发送到所有远端 followers 的 Inbox
注意：你可以缓存远端 followers 数据表来减少重复请求。

⸻

📡 6. 消息处理与存储

6.1 本地对象缓存

对于接收到的远端内容（Post / Note / Like 等）：
• 需要保存到 Solar 的数据库
• 供 UI / API 生成用户时间线
这使得 Solar 能把远端联邦内容与本地内容统一展示。

6.2 处理 Collections

ActivityPub 定义了 Collection 类型用于：
• followers 列表
• liked 列表
• outbox、inbox

你需要实现这些集合的获取与分页逻辑。

⸻

🔁 7. 与现有 Solar Network API 协调

你可能已经有本地的帖子、用户 API。那么：
• 把这套 API 与 ActivityPub 同步层绑定
• 决定哪些内容对外发布
• 决定哪些 Activity 类型需要响应

比如：

Solar Post Create -> 生成 ActivityPub Create Note -> 发往联邦

⸻

📦 8. 测试与兼容性

8.1 与现存联邦测试

用已存在的 ActivityPub 实例测试兼容性：
• Mastodon
• Pleroma
• Lemmy 等

检查：
• 对方是否能关注 Solar 用户
• Solar 是否能接收远端内容

ActivityPub 规范（W3C Recommendation）有详细规范流包括：
• Server to Server API
你最重要的目标是与现存实例互操作。 ￼

⸻

🧪 9. UX & 监控支持

9.1 用户显示远端内容

从 Inbox 收到内容后：
• 如何展示在 Solar UI
• 链接远端用户的展示名 / 头像

9.2 监控 & 审计
• 失败的推送
• 无法验证签名的请求
• 阻止 spam / 恶意 Activity

⸻

🏁 10. 逐步推进

建议按阶段 rollout：

阶段 目标
Stage 1 实现 Actor / WebFinger / Outbox / Inbox 基本框架
Stage 2 支持 Follow / Accept / Reject Activity
Stage 3 支持 Create / Like / Announce
Stage 4 与远端实例互联测试
Stage 5 UI & Feed 统一显示本地 + 联邦内容

⸻

📌 小结

核心步骤总结：1. 映射 Solar Network 数据模型到 ActivityPub 2. 实现 WebFinger + Actor JSON-LD 3. 实现 Inbox 和 Outbox endpoints 4. 管理 Actor Keys 与 HTTP Signatures 5. 处理关注/发帖/点赞等 Activity 6. 推送到远端 / 接收远端同步 7. 将远端内容存入 Solar 并展示 8. 测试与现有 Fediverse 实例互通

这套步骤覆盖了 ActivityPub 协议必须实现的点和实际联邦要处理的逻辑。 ￼

⸻

如果你想，我可以进一步展开 Solar Network 对应的具体 API 设计模板（包括 Inbox / Outbox 的 REST 定义与 JSON 输出示例），甚至帮你写 可运行的 Go / .NET 样例代码。你希望从哪一部分开始深入？
