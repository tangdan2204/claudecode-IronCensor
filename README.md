<div align="center">

# IronCensor

### 铁面御史 · 认知智能体框架

#### 将 Claude Code 从被动编辑器锻造为自主智能工程师

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green.svg)]()
[![Zero Code](https://img.shields.io/badge/Zero%20Code-Pure%20Config-orange.svg)]()
[![Hooks](https://img.shields.io/badge/Hooks-13%20Scripts%20·%2010%20Events-purple.svg)]()
[![Version](https://img.shields.io/badge/Version-2.0-brightgreen.svg)]()

[English](./README.en.md) | [日本語](./README.ja.md) | [한국어](./README.ko.md)

**The Iron Censor that never sleeps. 铁面无私，永不休眠。**

**作者: [Tangdan / 汤旦](https://github.com/tangdan2204)**

</div>

---

## 为什么选择 IronCensor？

> **一行安装，零代码入侵，让你的 Claude Code 拥有完整的认知循环、安全治理和自我进化能力。**

```bash
git clone https://github.com/tangdan2204/claudecode-IronCensor.git && cd ironcensor && ./install.sh
```

### 三大核心差异化

**🧠 认知循环** — 不只是执行命令，而是像工程师一样思考

每个任务经历完整的 **感知→思考→规划→执行→验证→反思→进化** 七阶段闭环。AI 会主动感知风险、调用专业工具分析、制定科学计划、边做边验证，并在完成后反思和进化。

**🛡️ 纵深防御** — 十三道防线，三层硬拦截不可绕过

`settings.json deny`（24条） → `safety-guard.sh`（26条检测） → `sensitive-filter.sh`（24种过滤）三层 exit 2 硬拦截构成安全核心，AI 无法绕过。另有 10 道辅助防线形成纵深冗余，覆盖 10 个生命周期事件。

**📈 自我进化** — 五大专用 Hook + 知识图谱，越用越强

四层递进学习：修复即审计 → 重复触发全局审计 → 深度反省 → 举一反三。五大自我学习专用 Hook（bugfix-audit-trigger、reflection-enforcer、correction-detector、learning-trend-injector、session-summary）+ 三级记忆系统 + 知识图谱回写，实现真正的自我进化。

---

## 与同类工具对比

| 维度 | IronCensor v2.0 | [everything-claude-code](https://github.com/affaan-m/everything-claude-code) | [oh-my-claudecode](https://github.com/anthropics/claude-code) | [Trail of Bits Config](https://github.com/trailofbits/claude-code-config) | [IronCurtain](https://github.com/provos/ironcurtain) |
|------|------------|------|------|------|------|
| **认知循环** | ✅ 七阶段完整闭环 | ❌ 无 | ❌ 无 | ❌ 无 | ❌ 无 |
| **安全防御层数** | ✅ 13脚本/10事件（3层硬拦截） | ⚠️ 安全指南（无 Hook） | ⚠️ 基础 Hook | ✅ 生产级安全 | ✅ 宪法策略引擎 |
| **自我学习/进化** | ✅ 四层递进 + 5专用Hook | ❌ 无 | ❌ 无 | ❌ 无 | ❌ 无 |
| **Agent 容错降级** | ✅ L1→L2→L3 三级 | ❌ 无 | ⚠️ 基础重试 | ❌ 无 | ❌ 无 |
| **记忆分层** | ✅ 热/温/冷三级 | ❌ 无 | ⚠️ 基础 | ❌ 无 | ❌ 无 |
| **治理框架** | ✅ 三省六部制衡 | ❌ 无 | ⚠️ Agent 编排 | ❌ 无 | ⚠️ 策略约束 |
| **Agent 交接协议** | ✅ HANDOFF + pipeline-state | ❌ 无 | ⚠️ 基础传递 | ❌ 无 | ❌ 无 |
| **安装方式** | 纯配置（零依赖） | 纯配置 | npm 安装 | 纯配置 | npm 安装 |

> **IronCensor 是唯一同时覆盖「认知循环 + 安全治理 + 自我进化 + 容错降级 + Agent 协作」的纯配置框架。**

---

## 核心能力一览

| 能力 | 描述 | 传统 Claude Code |
|------|------|-----------------|
| **七阶段认知循环** | 感知→思考→规划→执行→验证→反思→进化 | 收到指令→执行→完成 |
| **13 脚本纵深防御** | 硬拦截 + 辅助监控 + 自学习 + 软约束 | 仅靠提示词约束 |
| **自我学习进化** | 错误追踪→全局审计→规则加固→自动化检测 | 无学习机制 |
| **三级容错降级** | L1正常→L2降级重试→L3规则兜底 | 失败即停止 |
| **三级记忆系统** | 热(task-buffer)→温(session-summary)→冷(MEMORY) | 压缩后遗忘 |
| **Agent 交接协议** | HANDOFF信封 + pipeline-state.json | 无结构化传递 |
| **三省六部治理** | 决策/审核/执行分离，封驳制衡 | 无治理框架 |
| **证据驱动验证** | 必须提供测试/构建/lint 实际输出 | "应该没问题" |
| **品牌化可观测性** | [IronCensor] 前缀 + 启动横幅 + macOS 通知 | 无品牌存在感 |
| **并行维度调度** | executor ∥ test ∥ writer ∥ security | 串行逐步 |
| **知识图谱回写** | 实体+关系+语义搜索自动积累 | 每次从零 |

---

## 架构总览

```
┌──────────────────────────────────────────────────────────────┐
│                    IronCensor v2.0 智能体系统                  │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─ 硬安全层 (Hooks + settings.json) ───────────────────┐   │
│  │  Layer 0: settings.json deny (24条绝对禁止规则)        │   │
│  │  Layer 1: safety-guard.sh  (元命令+危险操作+绕过检测)  │   │
│  │  Layer 2: sensitive-filter.sh (24种敏感信息检测)       │   │
│  │  [exit 2 硬阻止 — AI 无法绕过]                         │   │
│  │  规则外部化: rules/dangerous-commands.txt              │   │
│  │              rules/sensitive-patterns.txt              │   │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 辅助监控层 (Hooks) ──────────────────────────────────┐  │
│  │  Layer 3: pre-compact-save.sh    (压缩前状态保存+归档) │  │
│  │  Layer 4: post-compact-restore.sh (压缩后上下文恢复)   │  │
│  │  Layer 5: post-edit-audit.sh (审计+熔断+task-buffer)   │  │
│  │  Layer 6: verify-before-stop.sh  (完成前四项检查)      │  │
│  │  Layer 7: session-banner.sh (启动横幅+防御状态摘要)    │  │
│  │  Layer 8: macos-notify.sh (桌面通知+品牌化标题)        │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 自我学习层 (Hooks) ──────────────────────────────────┐  │
│  │  Layer 9:  bugfix-audit-trigger.sh (修复时自动审计)    │  │
│  │  Layer 10: reflection-enforcer.sh  (反思阶段强制执行)  │  │
│  │  Layer 11: correction-detector.sh  (纠正信号捕获)      │  │
│  │  Layer 12: learning-trend-injector.sh (趋势注入)       │  │
│  │  Layer 13: session-summary.sh (温记忆会话摘要)         │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 行为指令层 (CLAUDE.md) ──────────────────────────────┐  │
│  │  智能操作系统 v1                                       │  │
│  │  ├─ 七阶段认知循环                                     │  │
│  │  ├─ 三省六部治理框架                                    │  │
│  │  ├─ 决策树路由 + 统一 Agent 降级决策表                  │  │
│  │  ├─ Agent 交接信封协议 + pipeline-state.json           │  │
│  │  ├─ 分层 Prompt 注入策略                               │  │
│  │  ├─ ReACT 审查协议 (5轮推理-行动循环)                  │  │
│  │  ├─ Agent 自省字段协议                                 │  │
│  │  ├─ 知识图谱回写协议 + 知识萃取过滤器                   │  │
│  │  └─ 四层自我学习模型                                    │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 容错降级层 ──────────────────────────────────────────┐  │
│  │  L1: 正常调用 (最优 model + 完整 prompt)               │  │
│  │  L2: 降级重试 (opus→sonnet→haiku + 简化 prompt)       │  │
│  │  L3: 规则兜底 (无 LLM，使用 fallback-templates/)      │  │
│  │  5 项失败判定标准 (空输出/幻觉/超时/语法错/重复错误)    │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 记忆持久层 (三级记忆) ────────────────────────────────┐ │
│  │  🔥 热记忆: task-buffer.json (实时任务状态)             │ │
│  │  🌡️ 温记忆: session-summary (7天TTL，自动清理)         │ │
│  │  ❄️ 冷记忆: MEMORY.md + recurring-patterns.md          │ │
│  │  📊 审计: edit-audit.log + hook-stats.jsonl            │ │
│  │  📦 归档: compact-history/ (最近5份，追加模式)          │ │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 配置中枢层 ────────────────────────────────────────┐   │
│  │  configs/env.sh (统一路径/阈值，一处修改全局生效)       │   │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 多代理编排层 (OMC 可选) ─────────────────────────────┐  │
│  │  17+ Agent + 20+ Skills + 智能路由                     │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

---

## 七大革新亮点

### 1. 七阶段认知循环 — 从"执行器"到"工程师"

```
感知 → 思考 → 规划 → 执行 → 验证 → 反思 → 进化
 │       │       │       │       │       │       │
 │       │       │       │       │       │       └─ 纠正升级链:
 │       │       │       │       │       │          1次→记录, 2次→规则, 3次→自动化
 │       │       │       │       │       └─ 模式检测 + 举一反三 + Agent自省字段
 │       │       │       │       └─ 必须提供实际测试/构建输出
 │       │       │       └─ 边做边测 + 每3步汇报 + 失败2次换策略
 │       │       └─ 决策树自动评估 → 路由执行路径 → 预演验证
 │       └─ 主动调用 Agent/Skill（不等用户指定）
 └─ 意图识别 + 上下文感知 + 记忆唤醒 + 风险预判
```

每个任务不再是简单的"收到→执行→完成"，而是经历完整的认知闭环。AI 会主动感知风险、调用专业工具分析、制定科学计划、边做边验证，并在完成后反思和进化。

### 2. 十三道纵深防御 — 硬安全保障

| 层级 | 组件 | 类型 | 功能 |
|------|------|------|------|
| Layer 0 | settings.json deny | 硬拦截 | 24 条规则：rm -rf、mkfs、dd、chmod 777、SSH 密钥、hooks 目录保护、sudo、eval、force push、curl\|bash |
| Layer 1 | safety-guard.sh | 硬拦截 | 五层检测：元命令包装器 → Base64/heredoc/xargs 绕过 → L4 绝对禁止 → L3 高风险 → 凭证泄露 |
| Layer 2 | sensitive-filter.sh | 硬拦截 | 24 种敏感信息模式：API Key/Token/密码/私钥/JWT/云凭证/数据库连接 |
| Layer 3 | pre-compact-save.sh | 辅助 | 压缩前状态保存 + 归档模式（保留最近 5 份快照） |
| Layer 4 | post-compact-restore.sh | 辅助 | 压缩后注入上下文 + 强制 7 步恢复检查列表 |
| Layer 5 | post-edit-audit.sh | 辅助 | 编辑审计 + 熔断计数（5次预警/8次硬阻止）+ flock 并发 + task-buffer 自动初始化 |
| Layer 6 | verify-before-stop.sh | 辅助 | 完成前 4 项检查：未提交/TODO/反复编辑/反思证据 |
| Layer 7 | session-banner.sh | 辅助 | 启动横幅 + 防御状态实时统计 |
| Layer 8 | macos-notify.sh | 辅助 | macOS 桌面通知 + [IronCensor] 品牌化标题 |
| Layer 9 | bugfix-audit-trigger.sh | 自学习 | 检测修复类编辑 → 自动触发同文件/同模块审计 |
| Layer 10 | reflection-enforcer.sh | 自学习 | Stop 时强制检查反思阶段是否执行 |
| Layer 11 | correction-detector.sh | 自学习 | 捕获用户纠正信号 → 自动写入模式追踪 |
| Layer 12 | learning-trend-injector.sh | 自学习 | 会话启动时注入高频模式趋势预警 |
| Layer 13 | session-summary.sh | 自学习 | 会话结束时生成温记忆摘要（7天TTL） |

**设计理念**: Layer 0-2 为硬拦截（exit 2），构成安全核心，AI **无法绕过**；Layer 3-8 辅助监控形成纵深冗余；Layer 9-13 为自我学习专用 Hook，驱动持续进化。所有拦截消息统一 `[IronCensor]` 品牌前缀。

### 3. 三级容错降级 — Agent 永不停摆

```
Level 1: 正常调用（最优 model + 完整 prompt）
  ↓ 失败（5项判定标准之一触发）
Level 2: 降级重试（opus→sonnet→haiku + 简化 prompt + 增加示例）
  ↓ 失败
Level 3: 规则兜底（无 LLM，使用 fallback-templates/ 预定义策略）
```

**5 项失败判定标准**:
1. Agent 返回空输出或格式不可解析
2. Agent 输出与任务要求明显不相关（hallucination）
3. Agent 执行超时（单步 >5 分钟）
4. Agent 产出代码无法通过语法检查
5. 连续 2 次相同 Agent 产出相同错误

**L3 规则兜底模板**:
- `fallback-templates/executor-checklist.md` — 执行降级清单
- `fallback-templates/review-checklist.md` — 审查降级清单
- `fallback-templates/architecture-checklist.md` — 架构降级决策树

### 4. 三省六部治理框架 — 权力制衡

借鉴中国古代三省六部制的治理智慧，确保任务从决策到执行全链路有审核：

```
┌─────────────────────────────────────────────┐
│              三省制衡体系                      │
├─────────────────────────────────────────────┤
│                                             │
│  中书省 (决策)          门下省 (审核)          │
│  ├ planner             ├ critic             │
│  ├ architect           ├ verifier           │
│  ├ analyst             ├ reviewers          │
│  └ explore             └ hooks (exit 2)     │
│           ↓                 ↕               │
│           尚书省 (执行)                       │
│           ├ executor                        │
│           ├ deep-executor                   │
│           └ OMC 编排                        │
│                                             │
│  封驳机制:                                    │
│  ├ 硬封驳: Hook exit 2 → 危险操作直接阻止     │
│  ├ 软封驳: Reviewer 阻塞性意见 → 回退规划      │
│  └ 条件封驳: 熔断触发 → 失败3次/编辑5次暂停    │
│                                             │
│  御史台 (独立监察):                            │
│  ├ 台院: safety-guard + sensitive-filter     │
│  ├ 殿院: post-edit-audit + edit-audit.log   │
│  └ 察院: verify-before-stop + patterns.md   │
└─────────────────────────────────────────────┘
```

### 5. Agent 交接协议 — 结构化协作

每个 Agent 输出包含标准化交接信封，确保信息无损传递：

```
[HANDOFF]
from: executor          ← OMC agent 名
to: reviewer
task_id: T-001
status: completed | partial | blocked
files_changed: [文件列表]
key_decisions:
  - 决策1（原因：xxx）
risks_identified:
  - 风险1
test_status: N/M passed
needs_review:
  - 审查维度: 具体关注点
[/HANDOFF]
```

长链路（≥3 个 Agent）时，还会将交接状态写入 `.omc/state/pipeline-state.json`，支持跨会话恢复。

### 6. 四层自我学习模型 — 从错误中进化

```
Layer 1: 修复即审计     → 每修一个 bug，在同文件/同模块搜索同类问题
Layer 2: 全局审计       → 同一模式 ≥2次 → Grep 全项目扫描 + 防御规则
Layer 3: 深度反省       → 同一模式 ≥3次 → 根因链分析 + 规则加固 + 提议自动化
Layer 4: 举一反三       → 类比推断 + 跨项目迁移 + 预防性建议
```

**纠正升级链**: 被用户纠正 1 次→记录到 `recurring-patterns.md`；2 次→升级为 CLAUDE.md 禁止事项；3 次→必须提议创建自动化检测（hook/lint/test）。

**5 大自我学习专用 Hook**:
| Hook | 触发时机 | 作用 |
|------|----------|------|
| `bugfix-audit-trigger.sh` | 编辑后 | 检测修复类编辑 → 提醒"同文件/同模块可能有同类问题" |
| `reflection-enforcer.sh` | 完成前 | 检查 recurring-patterns.md 是否被更新 → 强制反思 |
| `correction-detector.sh` | 用户纠正时 | 捕获"不对/错了/不要"等信号 → 自动写入模式追踪 |
| `learning-trend-injector.sh` | 会话启动 | 分析高频模式 → 注入"最近高频问题"预警到上下文 |
| `session-summary.sh` | 会话结束 | 生成温记忆摘要 → 关键决策/教训/模式变更（7天TTL） |

### 7. 三级记忆系统 — 永不丢失知识

```
🔥 热记忆 (实时)
   └─ task-buffer.json — 当前任务状态，Hook 可读取验证
      └─ post-edit-audit.sh 自动初始化（解决"4 hooks 读 0 hooks 写"问题）

🌡️ 温记忆 (7天)
   └─ session-summary — 会话级摘要
      ├─ 任务 + 关键决策 + 编辑文件统计
      ├─ Git 状态 + 安全拦截次数
      ├─ 模式追踪变更 + 教训与发现
      └─ 7天自动过期清理

❄️ 冷记忆 (永久)
   ├─ MEMORY.md — 核心索引 + 恢复检查列表
   ├─ recurring-patterns.md — 模式追踪 + 全局审计触发
   ├─ mcp__memory 知识图谱 — 实体+关系+语义搜索
   └─ compact-history/ — 压缩快照归档（最近5份，追加不覆盖）
```

---

## 文件结构

```
IronCensor/
├── README.md                           # 本文件（中文）
├── README.en.md                        # English README
├── README.ja.md                        # 日本語 README
├── README.ko.md                        # 한국어 README
├── AUDIT-REPORT.md                     # 三维架构审查报告
├── PRD.md                              # 产品需求文档
├── RESEARCH-REPORT.md                  # 六维科学研究报告
├── QUICK-START.md                      # 快速搭建指南
├── ONE-LINER.md                        # 一句话快速搭建提示词
├── install.sh                          # 自动安装脚本
├── LICENSE                             # MIT 许可证
├── configs/
│   ├── settings.json                   # 权限配置 + 24 条 deny 规则
│   ├── hooks.json                      # Hook 路由表（10 个生命周期事件）
│   ├── CLAUDE.md                       # 核心行为指令（智能操作系统 v1）
│   ├── env.sh                          # 统一路径/阈值配置（所有 Hook 共用）
│   └── fallback-templates/             # L3 容错降级规则兜底模板
│       ├── executor-checklist.md       # 执行降级清单
│       ├── review-checklist.md         # 审查降级清单
│       └── architecture-checklist.md   # 架构降级决策树
├── rules/
│   ├── dangerous-commands.txt          # 危险命令正则规则集（26 条，动态加载）
│   └── sensitive-patterns.txt          # 敏感信息检测规则集（24 种，动态加载）
├── hooks/                              # 13 个 Hook 脚本
│   ├── safety-guard.sh                 # [硬拦截] Bash 命令安全防护
│   ├── sensitive-filter.sh             # [硬拦截] 敏感信息过滤
│   ├── pre-compact-save.sh             # [辅助] 压缩前状态保存 + 归档
│   ├── post-compact-restore.sh         # [辅助] 压缩后上下文恢复
│   ├── post-edit-audit.sh              # [辅助] 编辑审计 + 熔断 + task-buffer
│   ├── verify-before-stop.sh           # [辅助] 完成前四项检查
│   ├── session-banner.sh               # [辅助] 启动横幅 + 防御状态
│   ├── macos-notify.sh                 # [辅助] macOS 桌面通知
│   ├── bugfix-audit-trigger.sh         # [自学习] 修复时审计触发
│   ├── reflection-enforcer.sh          # [自学习] 反思阶段强制执行
│   ├── correction-detector.sh          # [自学习] 纠正信号捕获
│   ├── learning-trend-injector.sh      # [自学习] 趋势预警注入
│   └── session-summary.sh              # [自学习] 温记忆会话摘要
├── docs/
│   ├── governance-framework.md         # 三省六部治理框架详细文档
│   ├── research-self-evolution.md      # 自我进化研究报告
│   └── research-phase2-deployment-gap.md # Phase 2 部署差距研究
└── memory/
    ├── MEMORY.md                       # 核心记忆索引模板
    └── recurring-patterns.md           # 反复问题追踪表模板
```

---

## 快速开始

### 前置条件

- macOS 或 Linux 系统
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) 已安装
- `jq` 命令行工具（`brew install jq`）
- [oh-my-claudecode (OMC)](https://github.com/anthropics/claude-code) 插件（可选，用于多代理编排）

### 一键安装

```bash
git clone https://github.com/tangdan2204/claudecode-IronCensor.git
cd ironcensor
chmod +x install.sh
./install.sh
```

### 手动安装

```bash
# 1. 创建目录
mkdir -p ~/.claude/hooks ~/.claude/logs ~/.claude/rules ~/.claude/configs/fallback-templates

# 2. 部署配置
cp configs/settings.json ~/.claude/settings.json
cp configs/hooks.json ~/.claude/hooks/hooks.json
cp configs/CLAUDE.md ~/.claude/CLAUDE.md
cp configs/env.sh ~/.claude/configs/env.sh

# 3. 部署容错降级模板
cp configs/fallback-templates/*.md ~/.claude/configs/fallback-templates/

# 4. 部署 Hook 脚本
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# 5. 部署规则文件（安全规则外部化）
cp rules/*.txt ~/.claude/rules/

# 6. 部署记忆文件
mkdir -p ~/.claude/projects/-Users-$(whoami)/memory
cp memory/*.md ~/.claude/projects/-Users-$(whoami)/memory/

# 7. 验证
claude  # 启动 Claude Code，应看到 ⚔️ IronCensor 启动横幅
```

### 安装后验证

```bash
# 验证 JSON 配置
cat ~/.claude/settings.json | jq . > /dev/null && echo "✅ settings.json"
cat ~/.claude/hooks/hooks.json | jq . > /dev/null && echo "✅ hooks.json"

# 验证脚本权限
ls -la ~/.claude/hooks/*.sh

# 验证容错模板
ls ~/.claude/configs/fallback-templates/

# 测试安全防护（应被拦截）
# 在 Claude Code 中输入: 帮我执行 sudo rm -rf /
```

详细步骤请参考 [QUICK-START.md](./QUICK-START.md)。

---

## 真实场景对比：Before vs After

### 场景一：修复一个 API 接口 bug

**普通 Claude Code：**
```
用户: "修复 /api/users 接口的 500 错误"
Claude: 直接打开文件 → 看到报错 → 改一行代码 → "好了，应该没问题了"
结果: 没跑测试，引入了新 bug；同类问题在 /api/orders 中也存在，但没人发现
```

**装了 IronCensor 的 Claude Code：**
```
用户: "修复 /api/users 接口的 500 错误"
Claude:
  [感知] 读取 recurring-patterns.md → 发现 API 层过去出现过 P003 模式
  [思考] 调用 explore agent 定位所有相关文件 + debugger 分析根因
  [规划] "涉及 3 个文件，走中等路径" → 向用户展示计划
  [执行] executor 修复 + 边改边跑测试 → quality-reviewer 审查
         → bugfix-audit-trigger.sh 自动提醒检查同类问题
  [验证] ✅ npm test 通过 ✅ tsc 无报错 ✅ reviewer 无阻塞意见
  [反思] Grep 全项目扫描 → 发现 /api/orders 有同类问题 → 一并修复
         → reflection-enforcer.sh 确认反思已执行
  [进化] 写入 recurring-patterns.md + 知识图谱，下次自动预警
```

### 场景二：上下文窗口被压缩

**普通 Claude Code：**
```
[压缩发生] → 之前的工作全部遗忘 → 用户: "继续刚才的任务"
Claude: "抱歉，我不记得之前在做什么了，请重新说明"
```

**装了 IronCensor 的 Claude Code：**
```
[压缩前] pre-compact-save.sh 保存状态 → 归档到 compact-history/
[压缩后] post-compact-restore.sh 注入恢复上下文
Claude: "检测到压缩恢复，执行 7 步恢复检查列表..."
  → 读取 task-buffer.json → 读取 MEMORY.md → 读取 recurring-patterns.md
  → 恢复 Git 分支状态 → 确认任务进度
  → "已恢复上下文。上次完成到第 3 步（共 5 步），继续执行第 4 步..."
```

### 场景三：Agent 调用失败

**普通 Claude Code：**
```
executor agent 返回空输出 → 放弃 → "抱歉，无法完成此任务"
```

**装了 IronCensor 的 Claude Code：**
```
executor (sonnet) 返回空输出 → 判定为失败（标准1：空输出）
  → L2 降级: executor (haiku) + 简化 prompt + 增加示例
  → L2 仍然失败
  → L3 规则兜底: 加载 fallback-templates/executor-checklist.md
  → 按预定义的保守策略继续执行，不依赖 LLM
```

---

## 效果对比

| 指标 | v1.0 | v2.0 | 改善 |
|------|------|------|------|
| Hook 脚本数量 | 8 | 13 | +62% |
| 生命周期事件覆盖 | 7 | 10 | +43% |
| 自我学习专用 Hook | 0 | 5 | 全新 |
| 记忆层级 | 1（冷） | 3（热/温/冷） | 全新 |
| Agent 容错降级 | 无 | 3级 + L3模板 | 全新 |
| Agent 交接协议 | 无 | HANDOFF + pipeline-state | 全新 |
| 品牌可观测性 | 无 | 启动横幅 + 消息前缀 + 通知 | 全新 |
| 压缩快照模式 | 覆盖 | 归档（保留5份） | 数据安全 |
| task-buffer | 仅读不写 | Hook 自动初始化 | 闭环 |
| stdin 安全性 | 部分 | 全部（13/13） | 100% |

---

## 设计哲学

### 纯配置驱动

本项目**不修改任何 Claude Code 源代码**，完全通过官方支持的配置机制实现：

- `settings.json` — 权限控制
- `hooks/` — 生命周期钩子
- `CLAUDE.md` — 行为指令
- `memory/` — 持久记忆
- `fallback-templates/` — 容错降级

这意味着：
- 与 Claude Code 版本更新**完全兼容**
- 可以在任何机器上**5 分钟内部署**
- 可以**渐进式采用**（按需启用各层）
- **零侵入**，随时可以完全移除

### SSOT 原则

所有规则**只定义一次**（Single Source of Truth）：
- 安全规则外部化到 `rules/` 目录（脚本动态加载，扩展无需改代码）
- 路径和阈值统一在 `configs/env.sh`（一处修改全局生效）
- 行为指令定义在 CLAUDE.md 中
- 记忆文件通过指针引用（非复制）
- 避免跨文件的规则重复和不一致

### 纵深冗余

安全层有意设计了功能重叠：
- `settings.json deny` 和 `safety-guard.sh` 都拦截 `rm -rf`
- 硬拦截（exit 2）确保即使提示词被绕过，危险操作仍被阻止
- 软约束（CLAUDE.md）提供预防层，减少硬拦截的触发频率

---

## 版本更新日志

### v2.0 — 自我进化架构升级 (2026-03-17)

> **从"安全框架"进化为"认知智能体"** — 新增 5 个自学习 Hook、三级记忆系统、Agent 容错降级协议，实现真正的自主进化能力。

**🆕 新增功能:**
- **5 个自我学习专用 Hook**: bugfix-audit-trigger（修复即审计）、reflection-enforcer（反思强制）、correction-detector（纠正捕获）、learning-trend-injector（趋势注入）、session-summary（温记忆）
- **三级容错降级**: L1 正常→L2 模型降级→L3 规则兜底，5 项失败判定标准
- **L3 兜底模板**: `fallback-templates/` 目录下 3 个预定义保守策略文件
- **三级记忆系统**: 热记忆(task-buffer)→温记忆(session-summary, 7天TTL)→冷记忆(MEMORY+patterns+知识图谱)
- **Agent 交接协议**: `[HANDOFF]...[/HANDOFF]` 结构化信封 + `pipeline-state.json` 持久化状态
- **分层 Prompt 注入策略**: 按 Agent 类型差异化注入（haiku ~200 token, opus ~800 token）
- **Agent 自省字段协议**: 每个 Agent 输出末尾嵌入 `[SELF_REFLECTION]` 字段
- **知识图谱回写协议**: 自动提取实体/关系，统一真相源优先级
- **知识萃取过滤器**: ACTIONABLE/INSIGHT/NOISE 三级分类，防止记忆膨胀
- **品牌化可观测性**: 启动横幅 + `[IronCensor]` 消息前缀 + macOS 通知品牌化
- **并行维度调度表**: executor ∥ test-engineer ∥ writer ∥ security-reviewer 同时工作
- **预演验证**: 复杂路径执行前由 executor+debugger+test-engineer 干跑模拟

**🔧 改进:**
- **压缩快照归档模式**: compact-state.md 从覆盖改为追加归档（保留最近 5 份）
- **task-buffer 自动初始化**: post-edit-audit.sh 在首次编辑时自动创建 task-buffer.json
- **stdin 安全加固**: 全部 13 个 Hook 统一使用 `cat 2>/dev/null || echo '{}'`
- **session-summary 增强**: 新增关键决策提取、模式变更检测、反复编辑教训发现
- **checksum 竞态修复**: verify-before-stop 和 reflection-enforcer 使用独立校验文件
- **CLAUDE.md 统一降级决策表**: 7 个决策点 × 3 级降级路径的完整矩阵
- **bugfix-audit-trigger 检测优化**: 修复 `.tool_input.description` 不存在的字段引用
- **macos-notify stdin 安全**: 防止无 stdin 时阻塞

**📊 数据对比:**
| 指标 | v1.0 | v2.0 |
|------|------|------|
| Hook 脚本 | 8 | 13 (+62%) |
| 生命周期事件 | 7 | 10 (+43%) |
| 自学习 Hook | 0 | 5 |
| 记忆层级 | 1 | 3 |
| 容错降级 | 0 | 3级 |
| Agent 交接 | 无 | 结构化 |

### v1.0 — 初始发布 (2026-03-15)

- 八层纵深防御架构（3 层硬拦截 + 5 层辅助）
- 七阶段认知循环（感知→思考→规划→执行→验证→反思→进化）
- 三省六部治理框架（决策/审核/执行分离 + 封驳机制）
- 四层自我学习模型（修复审计→全局审计→深度反省→举一反三）
- 安全规则外部化（`rules/` 目录，OCP 原则）
- 统一配置中枢（`configs/env.sh`）
- 智能决策树路由（文件数×依赖×风险 → 三级执行路径）
- 上下文压缩恢复（pre-compact-save + post-compact-restore）
- macOS 桌面通知（idle/permission 事件）
- ReACT 审查协议（5 轮推理-行动循环）
- 熔断机制（计数+时间+硬阻止）
- flock 并发保护（编辑审计日志）

---

## 贡献

欢迎提交 Issue 和 Pull Request！

- 新的 Hook 脚本
- 安全规则增强
- 多平台适配（Windows/WSL）
- 更多语言的 README 翻译

---

## 许可证

本项目采用 [MIT 许可证](./LICENSE)。

---

<div align="center">

**由 [Tangdan / 汤旦](https://github.com/tangdan2204) 设计和维护**

*The Iron Censor that never sleeps. 铁面无私，永不休眠。*

</div>
