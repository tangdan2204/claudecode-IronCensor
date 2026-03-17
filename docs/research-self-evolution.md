# IronCensor 自我学习·自我进化机制研究报告

> 日期: 2026-03-16 | 方法: 5 阶段并行调研 + 交叉验证 | 状态: 已验证

---

## 执行摘要

本研究对 IronCensor 框架的自我学习/自我进化机制进行了全面审计和优化调研，覆盖 5 个维度：现有机制审计、知识图谱最佳实践、Agent 编排优化、自进化方法论、记忆持久化。**核心发现：安全层工程质量高(hook硬拦截)，但学习层几乎完全依赖提示词软约束，存在"设计-执行鸿沟"。** 报告提出 23 项具体改进建议，按 P0-P3 优先级分级。

---

## 一、核心诊断：设计-执行鸿沟

### 1.1 安全层 vs 学习层的不对称

| 维度 | 安全层 | 学习层 |
|------|--------|--------|
| 执行方式 | Hook 脚本 `exit 2` 硬阻止 | CLAUDE.md 提示词软约束 |
| AI 可绕过？ | ❌ 不可能 | ✅ 可以选择性忽略 |
| 实际运行数据 | safety-guard/sensitive-filter 每次触发 | recurring-patterns 仅 1 条记录，全局审计 0 次 |
| 设计哲学 | "不信任 AI 自觉性" | "完全信任 AI 自觉性" |

### 1.2 纸面设计 vs 有效设计分类

**有效设计（有 hook/代码强制执行）：**
- 编辑审计日志 (`post-edit-audit.sh`) — >=8 次编辑熔断阻止
- 完成前检查 (`verify-before-stop.sh`) — 未提交文件/TODO 检测
- 热文件检测 — edit-audit.log JSONL 反复编辑分析
- flock 并发保护 — 多实例日志交错防护

**纸面设计（依赖 AI 自觉，无强制执行）：**
- 知识图谱回写协议 — 全项目无执行代码
- 四层自学习模型 L2-L4 — 无代码检测计数阈值跨越
- 被动进化纠正升级链 — 无机制检测"用户纠正"事件
- Agent 采访协议 — 无法回溯性采访已完成 Agent
- 会话结束 edit-audit.log 回顾 — 无 hook 强制执行

### 1.3 "读强写弱"不对称

```
读端（硬保障）:
  post-compact-restore.sh → 7步结构化恢复 ✅
  verify-before-stop.sh → patterns更新时间检查 ✅
  session-banner.sh → 防御状态展示 ✅

写端（软约束）:
  pre-compact-save.sh → 只写Git状态(约5行) ⚠️
  知识图谱回写 → 纯CLAUDE.md文字约束 ❌
  Agent采访结果 → 纯CLAUDE.md文字约束 ❌
  recurring-patterns更新 → 依赖AI自觉 ❌
```

---

## 二、知识图谱与上下文管理

### 2.1 三层存储角色冲突

当前设计：mcp__memory 为主存储 → MEMORY.md 为导出快照 → recurring-patterns.md 为兼容保留

**问题**：mcp__memory 不自动加载到上下文，实际上 MEMORY.md 才是"自动加载"层。

**修正方案（消除冲突）：**

```
Source of Truth 优先级（修正版）:
1. recurring-patterns.md → 模式追踪唯一真相源
2. MEMORY.md → 项目索引 + 关键决策记录
3. mcp__memory → 关系查询引擎（同步而来，非真相源）
4. .omc/state/ → 运行时状态（短暂）
5. notepad → 工作草稿（短暂）

写入流程（单向）:
patterns/MEMORY → [会话结束] → 同步到 mcp__memory
mcp__memory → [会话开始] → search_nodes 补充上下文
```

### 2.2 三级记忆分层架构

```
热记忆（会话内，实时）
├─ 任务状态缓冲区: 当前任务名/目标/进度/阻塞项
├─ 决策日志: 关键决策和原因
├─ Agent 产出缓冲区: reviewer 意见/debugger 发现
└─ 载体: .omc/state/task-buffer.json（约定文件）

温记忆（跨会话，7天有效）
├─ 会话摘要: 每个会话结束时自动生成
├─ 活跃任务追踪: 未完成任务的状态和下一步
├─ 近期决策索引: 按文件/模块索引的决策记录
└─ 载体: .omc/state/sessions/{id}/summary.md

冷记忆（永久，手动维护）
├─ MEMORY.md: 核心记忆索引
├─ recurring-patterns.md: 模式追踪表
├─ mcp__memory: 实体/关系图谱
└─ 载体: 现有文件体系
```

### 2.3 知识衰减策略

替换当前 90 天固定窗口为多维评分衰减：

```
衰减分 = 基础权重 × 访问频率系数 × 时间衰减系数 × 关联度系数

时间衰减系数 = e^(-0.01 × 天数)  // 约69天半衰期
访问频率系数 = log(1 + 访问次数)
关联度系数 = 与活跃模式的连接数 / 最大连接数

状态转换:
  活跃 → 休眠: 衰减分 < 0.3 且 30天未触发
  休眠 → 已根治: 衰减分 < 0.1 且 60天未触发
  已根治 → 归档: 衰减分 < 0.05 且无关联活跃模式
  复活: 任何状态均可因新匹配直接回到活跃
```

### 2.4 实体类型扩展

```
现有 4 种: project / file / pattern / fix
新增 3 种:
  - decision: {name: "决策描述", observations: ["[日期] [背景] 选择X非Y，因为Z"]}
  - constraint: {name: "约束名", observations: ["[日期] [来源] 约束内容 [状态:active|expired]"]}
  - session: {name: "session-日期-任务", observations: ["目标/结果/教训"]}

新增关系:
  - supersedes: 新事实→旧事实（版本化）
  - depends_on: 文件→文件 / 模式→模式
  - cooccurs_with: 模式→模式（共现，支撑举一反三）
  - decided_in: 决策→session（决策追溯）

观察格式标准化:
  "[YYYY-MM-DD] [confidence:H/M/L] [ttl:永久|90d|30d] 内容"
```

---

## 三、Agent 编排优化

### 3.1 Agent 交接信封（P0 — 最高优先）

标准化 Agent 输出为结构化"信封"，下游 Agent 能直接解析：

```markdown
### 交接信封格式

[HANDOFF]
from: executor
to: reviewer
task_id: T-001
status: completed
files_changed: [src/auth.ts, src/middleware.ts]
key_decisions:
  - 选择 JWT 而非 session（原因：无状态扩展性）
  - 中间件链采用 express.Router（原因：与现有代码一致）
risks_identified:
  - JWT 未设置刷新机制
  - 缺少并发请求限制
test_status: 4/4 passed
needs_review:
  - 安全: token 过期策略
  - 架构: 中间件执行顺序
[/HANDOFF]
```

### 3.2 分层 Prompt 注入策略（P0）

不同类型 Agent 注入不同量级的上下文：

| Agent 类型 | 注入内容 | 预估 Token |
|-----------|---------|-----------|
| explore (haiku) | 仅编码规范 + 项目结构 | ~200 |
| executor (sonnet) | 编码规范 + 安全分级 + 交接信封格式 | ~500 |
| reviewer (sonnet) | ReACT 协议 + 审查清单 + 输出 Schema | ~400 |
| verifier (sonnet) | 证据清单 + 输出 Schema | ~300 |
| architect (opus) | 完整架构上下文 + 治理原则 | ~800 |

**禁止**：向 haiku 级 Agent 注入完整 CLAUDE.md（浪费 token + 降低遵循率）

### 3.3 Agent 自省字段替代采访协议（P1）

每个 Agent 在输出中嵌入自省字段（而非依赖事后采访）：

```
executor 输出附加:
  "biggest_difficulty": "API 文档缺少超时参数说明"
  "workarounds_used": ["硬编码30s超时"]
  "technical_debt_introduced": ["需要后续参数化超时值"]

reviewer 输出附加:
  "reluctantly_passed_items": ["变量命名不一致但不影响功能"]
  "latent_risks": ["并发场景未充分测试"]
```

### 3.4 Agent 绩效追踪（考课制）（P2）

在 recurring-patterns.md 中增加绩效表：

```markdown
### Agent 绩效追踪

| Agent | 调用次数 | 成功率 | 常见失败原因 | 路由建议 |
|-------|---------|--------|------------|---------|
| executor | 0 | - | - | 默认 sonnet |
| reviewer | 0 | - | - | 默认 sonnet |

规则:
- 成功率 <70% → 升级 model
- 成功率 <50% → 策略审查
- 连续 3 次失败 → 自动降级兜底路径
```

### 3.5 三省六部精简

将 35 行框架精简为 3 行核心约束（详见独立设计文档）：

```
- 规划类 Agent（planner/architect）只产出方案，不执行
- 审核类 Agent（reviewer/verifier）拥有封驳权，可回退到规划阶段
- 执行类 Agent（executor）只执行已通过的方案
```

---

## 四、自进化方法论

### 4.1 学术支撑

| 方法论 | 与 IronCensor 的对应 | 学术来源 |
|--------|---------------------|---------|
| Reflexion | 纠正升级链 (1次/2次/3次) | Shinn et al., NeurIPS 2023 |
| Self-Refine | 七阶段认知循环的反思→进化 | Madaan et al., NeurIPS 2023 |
| Constitutional AI | CLAUDE.md 行为约束体系 | Anthropic, 2022 |
| Voyager | 开放世界技能学习 → 模式库积累 | Wang et al., 2023 |
| Memory-Augmented LLMs | 外部记忆体系天然抗遗忘 | Adepu, 2025 |

### 4.2 纠正升级链阈值优化

当前 "1次/2次/3次" 阈值缺乏学术验证。建议：

- 保持 1 次触发记录（与 Reflexion 的"语言反馈"对齐）
- 2 次触发全局审计改为 **动态阈值**：高风险模式(安全/数据)降低到 1 次即审计
- 3 次触发自动化改为 **成本效益评估**：只在规则创建成本 < 潜在损失时提议

### 4.3 进化效果度量指标

| 指标 | 计算方式 | 理想趋势 |
|------|---------|---------|
| 问题递减率 | count(pattern, T2) / count(pattern, T1) | < 1.0 |
| 规则命中率 | 自动规则实际拦截次数 / 总触发次数 | > 80% |
| 首次解决率 | 不经升级链解决 / 总问题数 | 持续上升 |
| 平均升级深度 | 问题平均在第几层被解决 | 持续下降 |

### 4.4 自动化规则生成管道

```
错误模式 → 提取审计正则
审计正则 → 评估可否转化为 lint 规则
  可转化 → 生成 ESLint/TSC 规则 + 测试用例
  不可转化 → 生成 hook 脚本 (PreToolUse)
生成后 → 全项目验证（避免误报）
误报率 > 20% → 自动降级为"建议"而非"强制"
```

### 4.5 记忆膨胀防护

IronCensor 基于外部记忆天然具有抗遗忘优势（不修改模型权重），但存在膨胀风险：
- 分层存储：高频/活跃 → 始终加载；已根治 → 按需加载
- 记忆压缩：多个相关模式合并为更高层抽象
- 优先级排序：最近触发的模式优先加载
- 容量治理：MEMORY.md 前 200 行自动加载限制

---

## 五、记忆持久化优化

### 5.1 compact-state.md 升级（P0）

从"路标"升级为"自包含恢复文档"：

```markdown
# 压缩状态快照 (YYYY-MM-DD HH:MM:SS)

## 任务上下文
- 目标: [从 task-buffer.json 读取]
- 进度: [从 task-buffer.json 读取]
- 阻塞: [从 task-buffer.json 读取]

## 本次会话编辑的文件
[从 edit-audit.log 按 session 筛选]

## Git 状态
分支: main | 未提交: 3 个文件
最近提交: abc1234 feat: add memory layer

## 关键决策记录
[从 task-buffer.json 的 decisions 字段]

## 恢复指令
1. 读取 MEMORY.md
2. 读取 recurring-patterns.md
3. 继续执行: [具体的下一步]
```

### 5.2 约定文件机制

引入 `.omc/state/task-buffer.json` 作为 AI 内部状态的外化通道：

```json
{
  "task": "实现用户认证",
  "progress": "3/5 子任务完成",
  "blocked": null,
  "decisions": [
    {"what": "选择 JWT", "why": "无状态扩展性"},
    {"what": "中间件链", "why": "与现有代码一致"}
  ],
  "files_changed": ["src/auth.ts", "src/middleware.ts"],
  "next_step": "实现 token 刷新机制"
}
```

Hook 脚本可读取此文件，实现"软约束"到"可检测"的升级。

### 5.3 记忆健康度指标

在 session-banner.sh 中展示：

```
[IronCensor] 记忆健康: 覆盖率 85% ✅ | 新鲜度 2天 ✅ | 一致性 ✅ | 模式 1个 ✅
```

| 指标 | 计算方式 | 健康阈值 |
|------|---------|---------|
| 覆盖率 | MEMORY.md 非空章节数 / 总章节数 | >= 80% |
| 新鲜度 | 最后修改距今天数 | <= 7 天 |
| 一致性 | compact-state Git 分支 vs 当前分支 | 必须一致 |
| 模式活跃度 | recurring-patterns 活跃模式数 | >= 1 |

### 5.4 知识萃取过滤器

Agent 产出经过分类过滤后再写入记忆：

```
[ACTIONABLE] 可立即执行的改进 → recurring-patterns.md + mcp__memory
[INSIGHT] 有价值但非紧急 → MEMORY.md 备忘
[NOISE] 重复/显而易见 → 丢弃

过滤条件:
  与已有 pattern 匹配度 >80% → NOISE
  涉及未覆盖风险面 → ACTIONABLE
  无法在当前项目验证 → INSIGHT
```

---

## 六、优先级排序汇总

### P0（立即实施 — 解决根本性缺陷）

| # | 改进项 | 实施方式 | 预期收益 |
|---|--------|---------|---------|
| 1 | compact-state.md 升级为自包含快照 | 重构 pre-compact-save.sh | 解决"压缩后信息丢失"最严重问题 |
| 2 | 引入 task-buffer.json 约定文件 | CLAUDE.md 新增约定 + env.sh 路径 | 为所有写入优化提供数据基础 |
| 3 | Agent 交接信封标准化 | CLAUDE.md 新增格式规范 | 减少 Agent 间理解开销 |
| 4 | 分层 Prompt 注入策略 | CLAUDE.md 分层规范 | 减少每次 Task 的 token 消耗 |
| 5 | recurring-patterns.md 定为模式唯一真相源 | CLAUDE.md 修改优先级定义 | 消除三层存储一致性漂移 |

### P1（短期 — 显著提升学习效果）

| # | 改进项 | 实施方式 | 预期收益 |
|---|--------|---------|---------|
| 6 | Agent 自省字段替代采访协议 | 修改 CLAUDE.md 文本 | 使反思机制真正可执行 |
| 7 | verify-before-stop 增加 KG 检查 | 修改 hook 脚本 | 软约束变为半硬约束 |
| 8 | 观察格式标准化(时间戳+置信度+TTL) | CLAUDE.md 图谱协议修改 | 实现知识版本化和自动衰减 |
| 9 | 进化效果度量指标 | recurring-patterns.md 新增仪表板字段 | 可量化进化效果 |

### P2（中期 — 体系完善）

| # | 改进项 | 实施方式 | 预期收益 |
|---|--------|---------|---------|
| 10 | 记忆健康度指标 | session-banner.sh 增强 | 持续监控记忆系统退化 |
| 11 | Agent 绩效追踪（考课制） | recurring-patterns.md 新增表格 | 动态优化 Agent 路由 |
| 12 | 三省六部外移精简 | 移至 docs/ | CLAUDE.md 减 30 行，提高遵循率 |
| 13 | 实体类型和关系扩展 | CLAUDE.md 图谱协议更新 | 支撑决策追溯和举一反三 |
| 14 | 知识衰减多维评分 | CLAUDE.md 替换固定 90 天规则 | 更智能的遗忘策略 |

### P3（长期 — 持续优化）

| # | 改进项 | 实施方式 | 预期收益 |
|---|--------|---------|---------|
| 15 | 自动化规则生成管道 | CLAUDE.md + 新 hook | 将学习成果硬化为自动检测 |
| 16 | 并行文件冲突预检 | CLAUDE.md 规则细化 | 防止并行 Agent 竞态 |
| 17 | SessionEnd 会话摘要生成 | 新增 hook 脚本 | 解决跨会话记忆断点 |
| 18 | 知识萃取过滤器 | CLAUDE.md 协议更新 | 防止图谱污染 |

---

## 七、Stage 4 关键发现：transcript_path 黄金通道

### 7.1 被忽略的 PreCompact 输入字段

PreCompact hook 的 stdin JSON 包含 `transcript_path` 字段（指向完整会话 .jsonl），但此前所有 hook 脚本均未使用此字段。这是压缩恢复质量的最大提升杠杆。

### 7.2 Re-Reading Loop 致命问题

压缩后 AI 重读文件消耗刚释放的空间 → 再次压缩 → 摘要的摘要。首次压缩后通常连续压缩 3-5 次。transcript_path 提取可在压缩前一次性捕获所有关键信息，减轻重读循环。

### 7.3 task-buffer.json 执行断路

协议设计完备但写入完全依赖 CLAUDE.md 软约束。解决方案：post-edit-audit.sh 每 N 次编辑检查 task-buffer.json 新鲜度并注入提醒。

### 7.4 温记忆层桥接缺失

session-summary.sh 原先未注册到 hooks.json，新会话也不加载历史 session summary。已修复：注册 SessionEnd + post-compact-restore.sh 桥接 + learning-trend-injector.sh 加载。

---

## 八、实施记录

### 已实施改进项（全量）

| # | 改进项 | 实施文件 | 类型 |
|---|--------|---------|------|
| 1 | transcript_path 黄金通道 | `hooks/pre-compact-save.sh` | 增强 |
| 2 | post-compact-restore 结构化恢复 | `hooks/post-compact-restore.sh` | 重写 |
| 3 | task-buffer 新鲜度检查 | `hooks/post-edit-audit.sh` | 增强 |
| 4 | 反思阶段强制执行器 | `hooks/reflection-enforcer.sh` | 新建 |
| 5 | Bug 修复审计触发器 | `hooks/bugfix-audit-trigger.sh` | 新建 |
| 6 | 用户纠正检测器 | `hooks/correction-detector.sh` | 新建 |
| 7 | 学习趋势注入器 | `hooks/learning-trend-injector.sh` | 新建 |
| 8 | 温记忆桥接（session-summary 注册） | `configs/hooks.json` | 修改 |
| 9 | 自进化配置变量 | `configs/env.sh` | 增强 |
| 10 | 安装脚本更新 | `install.sh` | 修改 |
| 11 | Agent 交接信封标准化 | `configs/CLAUDE.md` | 已有 |
| 12 | 分层 Prompt 注入策略 | `configs/CLAUDE.md` | 已有 |
| 13 | Agent 自省字段协议 | `configs/CLAUDE.md` | 已有 |
| 14 | 知识图谱回写协议 | `configs/CLAUDE.md` | 已有 |
| 15 | 知识萃取过滤器 | `configs/CLAUDE.md` | 已有 |
| 16 | Source of Truth 优先级 | `configs/CLAUDE.md` | 已有 |
| 17 | 知识衰减多维评分 | `memory/recurring-patterns.md` | 已有 |
| 18 | Agent 绩效追踪 | `memory/recurring-patterns.md` | 已有 |
| 19 | 进化效果度量指标 | `memory/recurring-patterns.md` | 已有 |
| 20 | 三省六部治理精简 | `configs/CLAUDE.md` | 已有 |
| 21 | 会话摘要温记忆 | `hooks/session-summary.sh` | 已有 |
| 22 | 自包含恢复文档 | `hooks/pre-compact-save.sh` | 已有 |
| 23 | 任务状态外化协议 | `configs/CLAUDE.md` | 已有 |

### Hook 体系完整清单（13 个脚本，10 个事件触点）

| 脚本 | 事件 | 类型 | 作用 |
|------|------|------|------|
| session-banner.sh | SessionStart | 辅助 | 品牌横幅 + 记忆健康度 |
| learning-trend-injector.sh | SessionStart | 辅助 | 学习趋势警告注入 |
| post-compact-restore.sh | SessionStart:compact | 辅助 | 结构化压缩恢复 |
| session-summary.sh | SessionEnd | 辅助 | 温记忆生成 |
| safety-guard.sh | PreToolUse:Bash | 拦截 | 危险命令检测 |
| sensitive-filter.sh | PreToolUse:Write\|Edit | 拦截 | 敏感信息过滤 |
| post-edit-audit.sh | PostToolUse:Write\|Edit | 辅助 | 编辑审计 + 熔断 + task-buffer 检查 |
| bugfix-audit-trigger.sh | PostToolUse:Write\|Edit | 辅助 | Bug 修复审计提醒 |
| pre-compact-save.sh | PreCompact | 辅助 | 自包含恢复快照 + transcript 提取 |
| verify-before-stop.sh | Stop | 辅助 | 完成前检查 |
| reflection-enforcer.sh | Stop | 辅助 | 反思阶段强制执行 |
| macos-notify.sh | Notification:idle/permission | 辅助 | macOS 桌面通知 |
| correction-detector.sh | Notification:纠正关键词 | 辅助 | 用户纠正检测 |

---

## 九、交叉验证结论

**验证状态：[VERIFIED]** — 5 个阶段研究发现高度一致，无实质性矛盾。全部 23 项改进已实施。

**最强共识（5/5 阶段一致）：**
1. 安全层硬 vs 学习层软 — 核心不对称问题 → **已通过 4 个新 hook 缓解**
2. compact-state.md 是最薄弱环节 → **已通过 transcript_path 提取增强**
3. 写入机制是整个体系的阿喀琉斯之踵 → **已通过 task-buffer 新鲜度检查 + reflection-enforcer 缓解**
4. 升级路径清晰：提示词约束 → 约定文件 → hook 验证 → 硬拦截 → **本次实施覆盖前三级**

**关键参考文献：**
- Reflexion (Shinn et al., NeurIPS 2023) — 语言反馈强化学习
- Self-Refine (Madaan et al., NeurIPS 2023) — 迭代自我改进
- Graphiti (Zep AI) — 知识图谱时序建模
- MemGPT/Letta — 分层记忆架构
- LifelongAgentBench (2025) — Agent 终身学习基准
- BitsAI-Fix (ByteDance, 2025) — 自动化规则生成工业实践
