# IronCensor Phase 2 研究报告：部署鸿沟与自进化闭环修复

> 日期: 2026-03-16 | 方法: 5 阶段并行调研 + 交叉验证 | 状态: [VERIFIED]

---

## 执行摘要

Phase 1 设计了 23 项改进并在项目目录实现了代码，但 **从未重新部署到运行环境 `~/.claude/`**。这意味着全部自我进化增强（4 个新 hook、2 个增强 hook、规则外部化、统一配置）在实际 Claude Code 会话中不生效。本报告称之为 **"部署鸿沟"（Deployment Gap）**——Phase 1 的根本性缺陷。

**核心发现汇总（5/5 阶段一致）：**

| # | 发现 | 严重性 | 根因 |
|---|------|--------|------|
| 1 | 6 个新 hook 脚本未安装到 ~/.claude/hooks/ | 🔴 致命 | install.sh 未重新运行 |
| 2 | safety-guard.sh 已安装版本落后 65 行 | 🔴 高 | 同上 |
| 3 | sensitive-filter.sh 已安装版本落后 72 行 | 🔴 高 | 同上 |
| 4 | hooks.json 缺少 3 个新事件路由 | 🔴 高 | 同上 |
| 5 | rules/ 和 configs/env.sh 未部署 | 🟡 中 | 同上 |
| 6 | agent-insights.jsonl 有配置无写入者 | 🟡 中 | 设计未闭环 |
| 7 | HANDOFF/SELF_REFLECTION 纯提示词约束 | 🟡 中 | 无验证机制 |
| 8 | task-buffer.json 有 5 个 hook 引用但依赖 AI 创建 | 🟡 中 | 写端软约束 |

---

## 一、各阶段研究发现

### Stage 1: Hook 实施质量验证

**方法**: 对比 `~/.claude/hooks/` (运行时) vs `项目/hooks/` (源码)

| 脚本 | 已安装行数 | 项目行数 | 差异 | 状态 |
|------|-----------|---------|------|------|
| safety-guard.sh | 112 | 177 | -65 | ⚠️ 过时 |
| sensitive-filter.sh | 52 | 124 | -72 | ⚠️ 过时 |
| post-edit-audit.sh | ✅ | ✅ | ~0 | ✅ 同步 |
| pre-compact-save.sh | ✅ | ✅ | ~0 | ✅ 同步 |
| post-compact-restore.sh | ✅ | ✅ | ~0 | ✅ 同步 |
| verify-before-stop.sh | ✅ | ✅ | ~0 | ✅ 同步 |
| macos-notify.sh | ✅ | ✅ | ~0 | ✅ 同步 |
| session-banner.sh | ❌ 缺失 | 102 | N/A | 🔴 未部署 |
| learning-trend-injector.sh | ❌ 缺失 | 109 | N/A | 🔴 未部署 |
| reflection-enforcer.sh | ❌ 缺失 | 66 | N/A | 🔴 未部署 |
| bugfix-audit-trigger.sh | ❌ 缺失 | 62 | N/A | 🔴 未部署 |
| correction-detector.sh | ❌ 缺失 | 49 | N/A | 🔴 未部署 |
| session-summary.sh | ❌ 缺失 | 98 | N/A | 🔴 未部署 |

**已安装版本缺失的关键特性**:
- safety-guard: 无规则外部化、无统一配置、无 [IronCensor] 品牌前缀、无 hook-stats.jsonl 统计
- sensitive-filter: 无外部 patterns 文件、无统一配置、无品牌前缀

**结论**: Phase 1 的自我进化层在运行时完全不生效。

### Stage 2: Agent 链路效率分析

**发现**:
1. `agent-insights.jsonl` 在 env.sh (L85) 和 CLAUDE.md 定义了路径和格式，但 **没有任何 hook 或代码实际写入此文件**
2. HANDOFF 信封协议和 SELF_REFLECTION 字段仅存在于 CLAUDE.md 提示词中，无 hook 验证 Agent 输出是否包含
3. Agent 绩效追踪表（recurring-patterns.md L115-130）全部为 0，从未被更新
4. 三级降级协议（CLAUDE.md L162-180）是纯提示词设计，无运行时状态机

**根因**: Agent 编排完全依赖 OMC 插件 (`${CLAUDE_PLUGIN_ROOT}`)，IronCensor 层无独立 Agent 调度能力。

### Stage 3: 知识图谱实践分析

**发现**:
1. mcp__memory 是服务端存储，不存在本地文件——无法被 hook 脚本直接读写
2. MEMORY.md 索引仍引用旧版信息（"3个拦截型hook"，实际应为完整13个）
3. 知识图谱回写协议（CLAUDE.md L314-341）定义了 7 种实体类型和 10 种关系，但：
   - 无 hook 强制执行回写
   - 无 hook 验证回写完成度
   - 完全依赖 AI 自觉性
4. 知识萃取过滤器（ACTIONABLE/INSIGHT/NOISE）同样无代码实现

**结论**: 知识图谱层是"写入靠自觉"，与安全层"写入靠 hook"形成鲜明对比。

### Stage 4: 跨会话学习持久化链

**发现**:
1. hooks.json 已注册 SessionEnd → session-summary.sh，但该脚本未部署到 ~/.claude/hooks/
2. post-compact-restore.sh 正确注册在 SessionStart:compact，且已部署
3. learning-trend-injector.sh 注册在 SessionStart，但未部署
4. 温记忆层（.omc/state/sessions/）的目录从未被创建，因为 session-summary.sh 从未运行
5. task-buffer.json 被 5 个 hook 引用（pre-compact-save、post-compact-restore、post-edit-audit、verify-before-stop、session-summary），但创建完全依赖 AI

**跨会话学习链断裂图**:
```
SessionStart: banner(❌) → trend-injector(❌) → compact-restore(✅)
                ↓ 会话中 ↓
PostToolUse:  edit-audit(✅) → bugfix-trigger(❌) → task-buffer-check(部分)
                ↓ 会话中 ↓
Stop:         verify(✅) → reflection-enforcer(❌)
                ↓ 会话结束 ↓
SessionEnd:   session-summary(❌)
                ↓ 下次会话 ↓
SessionStart: → 断链 → 无温记忆可加载
```

### Stage 5: 容错降级分析

**发现**:
1. 三级降级协议定义了 5 个决策点的降级路径，但：
   - 无状态追踪（不知道当前在哪一级）
   - 无自动降级触发器（需 AI 自觉判断）
   - 无降级日志（无法事后分析降级效果）
2. 多级容错是 Phase 1 中唯一完全停留在提示词层的复杂设计
3. 预演验证（dry-run）同样无执行机制

---

## 二、交叉验证

**5/5 阶段共识**: 所有阶段独立发现同一根因——**Phase 1 增强从未部署**。

**无矛盾发现**: 各阶段视角互补：
- Stage 1（文件级）确认了哪些文件缺失
- Stage 2（协议级）确认了哪些协议无写入者
- Stage 3（存储级）确认了知识图谱写入依赖 AI
- Stage 4（链路级）确认了跨会话链完全断裂
- Stage 5（容错级）确认了降级机制无运行时支撑

**新增模式**: P002 — "项目目录增强未同步到运行环境"（与 P001 "Hook存在但未注册" 同源但更严重）

---

## 三、根因分析

```
install.sh 设计为一次性安装脚本
    ↓
Phase 1 在项目目录完成了大量增强
    ↓
但没有重新运行 install.sh（或 install.sh 自身无增量更新能力）
    ↓
导致 ~/.claude/ 运行环境停留在增强前的状态
    ↓
所有自我进化机制（4 新 hook + 2 增强 hook + rules + env.sh）= 纸面设计
```

**深层根因**: install.sh 缺乏版本检测和增量更新能力，用户无法知道"运行环境是否与项目源码同步"。

---

## 四、实施方案（按优先级）

### P0: 立即部署（修复部署鸿沟）

1. **重新运行 install.sh** — 将全部 13 个 hook + rules + configs 部署到 ~/.claude/
2. **验证部署结果** — 对比安装后的文件行数/MD5

### P1: 增强安装脚本（防止复发）

3. **install.sh 增加版本比对** — 安装后自动对比 installed vs project 的 MD5
4. **install.sh 增加 `--check` 模式** — 仅比对不安装，输出过时文件清单

### P2: 修复断路（使设计生效）

5. **agent-insights.jsonl 写入者** — 在 post-edit-audit.sh 中增加基于 Agent 上下文的自省提取
6. **P002 模式记录** — 写入 recurring-patterns.md
7. **MEMORY.md 更新** — 修正过时的 hook 数量描述

### P3: 闭环强化（长期）

8. **SessionStart hook 增加版本检查** — 每次会话启动对比关键 hook MD5，不一致则警告
9. **知识图谱回写** — verify-before-stop.sh 增加图谱更新检查

---

## 五、关键发现复述（供实施使用）

| 文件 | 当前问题 | 修复方式 |
|------|----------|----------|
| ~/.claude/hooks/safety-guard.sh | 112行,缺失规则外部化/品牌/统计 | 用项目版本(177行)覆盖 |
| ~/.claude/hooks/sensitive-filter.sh | 52行,缺失外部patterns/品牌 | 用项目版本(124行)覆盖 |
| ~/.claude/hooks/session-banner.sh | 不存在 | 从项目复制 |
| ~/.claude/hooks/learning-trend-injector.sh | 不存在 | 从项目复制 |
| ~/.claude/hooks/reflection-enforcer.sh | 不存在 | 从项目复制 |
| ~/.claude/hooks/bugfix-audit-trigger.sh | 不存在 | 从项目复制 |
| ~/.claude/hooks/correction-detector.sh | 不存在 | 从项目复制 |
| ~/.claude/hooks/session-summary.sh | 不存在 | 从项目复制 |
| ~/.claude/hooks/hooks.json | 缺少3个事件路由 | 用项目版本覆盖 |
| ~/.claude/rules/*.txt | 不存在 | 从项目复制 |
| ~/.claude/configs/env.sh | 不存在 | 从项目复制 |
| recurring-patterns.md | 缺少P002模式 | 新增 |
| env.sh L85 AGENT_INSIGHTS_LOG | 有路径无写入者 | 增加写入逻辑 |

---

## 六、与 Phase 1 关系

Phase 2 不推翻 Phase 1 的任何设计。Phase 1 的 23 项改进在设计层面正确，问题在于 **"最后一英里"未完成**：
- 项目目录 → 运行环境 的同步断裂
- 这本身是自我进化的典型反面案例：做了改进但没有验证改进是否生效

**元学习**: IronCensor 框架需要一个 **自检机制** 来验证自身是否正确部署——这是 Phase 2 最重要的输出。

---

## 七、实施记录

### 已实施改进项（Phase 2）

| # | 改进项 | 实施文件 | 类型 | 状态 |
|---|--------|---------|------|------|
| 1 | 重新部署全部 13 个 hook + rules + configs | install.sh 执行 | 部署 | ✅ 完成 |
| 2 | install.sh `--check` 模式 | install.sh | 增强 | ✅ 完成 |
| 3 | install.sh 安装后 MD5 同步验证 | install.sh | 增强 | ✅ 完成 |
| 4 | session-banner.sh 部署同步检查 | hooks/session-banner.sh | 增强 | ✅ 完成 |
| 5 | reflection-enforcer.sh Agent 自省提醒 | hooks/reflection-enforcer.sh | 增强 | ✅ 完成 |
| 6 | P002 模式记录 | memory/recurring-patterns.md | 新增 | ✅ 完成 |
| 7 | Phase 2 研究报告 | docs/research-phase2-deployment-gap.md | 新建 | ✅ 完成 |
| 8 | macos-notify.sh stdin 安全处理 | hooks/macos-notify.sh | 修复 | ✅ 完成 |
| 9 | verify-before-stop.sh checksum 竞争修复 | hooks/verify-before-stop.sh | 修复 | ✅ 完成 |
| 10 | bugfix-audit-trigger.sh 检测率提升 | hooks/bugfix-audit-trigger.sh | 修复 | ✅ 完成 |
| 11 | CLAUDE.md 降级协议 temperature 修正 | configs/CLAUDE.md | 修复 | ✅ 完成 |

### P002 防复发机制

```
部署时防线:
  install.sh → 安装后自动 MD5 校验 ✅
  install.sh --check → 只对比不安装，输出过时清单 ✅

运行时防线:
  session-banner.sh → 每次会话启动自动对比已安装/项目源码 MD5 ✅
  如不一致 → 输出 "[IronCensor] ⚠️ 部署过时: N个hook与项目源码不同步" ✅

知识层防线:
  P002 模式写入 recurring-patterns.md → 未来任何部署类任务自动关联 ✅
```

### 代码级修复记录（5 阶段研究交叉验证后实施）

#### 修复 1: macos-notify.sh stdin 安全（Stage 1 发现）
- **问题**: `INPUT=$(cat)` 在无 stdin 时会阻塞
- **修复**: 改为 `INPUT=$(cat 2>/dev/null || echo '{}')`
- **影响**: 防止 Notification hook 超时

#### 修复 2: checksum 竞争条件（Stage 4 发现）
- **问题**: `verify-before-stop.sh` 和 `reflection-enforcer.sh` 共用 `.patterns-checksum` 文件，verify-before-stop 先执行并更新 checksum，导致 reflection-enforcer 的变更检测永远通过
- **修复**: verify-before-stop 使用独立的 `.patterns-checksum-stop`，reflection-enforcer 保留 `.patterns-checksum`
- **影响**: 两个 Stop hook 的 recurring-patterns.md 变更检测互不干扰

#### 修复 3: bugfix-audit-trigger.sh 检测率（Stage 4 发现）
- **问题**: Edit 工具的 `tool_input` 无 `description` 字段，`.tool_input.description` 始终为空，导致 bug 修复关键词检测率极低
- **修复**: 移除 `description` 字段引用，改用 `.tool_input.content`（Write 工具）+ 文件名模式匹配（`fix-xxx.ts` 等）
- **影响**: 提升 bug 修复自动检测率

#### 修复 4: CLAUDE.md 降级协议（Stage 5 发现）
- **问题**: 降级协议引用 `temperature` 参数，但 Claude Code 的 Agent 工具不支持 temperature 调节
- **修复**: 将 `temperature` 引用替换为 model 降级路径（opus→sonnet→haiku），这是 Claude Code 实际支持的降级维度
- **影响**: 降级协议可操作化

---

## 八、5 阶段研究深度发现汇总

### 设计层面正确但需长期迭代的发现

以下发现经 5 阶段交叉验证确认，属于设计合理但当前框架能力边界外的增强方向：

| # | 发现 | 来源 | 建议时间线 | 状态 |
|---|------|------|-----------|------|
| D1 | pipeline-state.json 替代 HANDOFF/SELF_REFLECTION 文本标签 | Stage 2 | Phase 3 | 📋 记录 |
| D2 | Agent prompt 模板化（configs/agent-prompts/）| Stage 2 | Phase 3 | 📋 记录 |
| D3 | mcp__memory 知识图谱降级为可选增强 | Stage 3 | 当前 | ✅ 确认 |
| D4 | task-buffer.json 写入端闭环 | Stage 4 | Phase 3 | 📋 记录 |
| D5 | compact-state.md 追加模式（防多次压缩覆盖）| Stage 4 | Phase 3 | 📋 记录 |
| D6 | session-summary.sh 内容丰富化（含教训/意图）| Stage 4 | Phase 3 | 📋 记录 |
| D7 | 降级与性能路由统一（消除双系统）| Stage 5 | Phase 3 | 📋 记录 |
| D8 | L3 规则兜底资产文件（模板/脚本）| Stage 5 | Phase 3 | 📋 记录 |
| D9 | "失败"操作定义（5 项判定标准）| Stage 5 | Phase 3 | 📋 记录 |

### 关键架构约束（Phase 2 确认）

1. **Hook 脚本无法调用 MCP 工具**: mcp__memory 等工具仅在 Claude Code 会话内可用，hook 脚本（bash）无法直接调用。知识图谱写入必须依赖 AI 自觉性。
2. **Sub-agent 继承完整 CLAUDE.md**: Claude Code 的 Agent 工具会让子 agent 看到完整提示词，分层 prompt injection 防御需要基于此事实重新设计。
3. **correction-detector.sh 在 Notification hook 上无法可靠检测用户纠正**: Notification 事件的 payload 不包含用户输入内容，纠正检测需要其他机制。
