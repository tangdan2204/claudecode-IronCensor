<div align="center">

# IronCensor

### 铁面御史 · 认知智能体框架 — 将 Claude Code 从被动编辑器锻造为自主智能工程师

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green.svg)]()

[English](./README.en.md) | [日本語](./README.ja.md) | [한국어](./README.ko.md)

**The Iron Censor that never sleeps. 铁面无私，永不休眠。**

**作者: Tangdan / 汤旦**

</div>

---

## 核心革新

> **你不是一个被动的代码编辑器。你是一个拥有完整认知循环的智能工程师。**

IronCensor 通过**纯配置**方式（零代码入侵），为 Claude Code 注入一套完整的自主智能体系统，使其具备：

| 能力 | 描述 | 传统 Claude Code |
|------|------|-----------------|
| **七阶段认知循环** | 感知→思考→规划→执行→验证→反思→进化 | 收到指令→执行→完成 |
| **八层纵深防御** | 硬拦截 + 辅助监控 + 软约束，AI 无法绕过 | 仅靠提示词约束 |
| **自我学习进化** | 错误追踪→全局审计→规则加固→自动化检测 | 无学习机制 |
| **三省六部治理** | 决策/审核/执行分离，封驳制衡 | 无治理框架 |
| **证据驱动验证** | 必须提供测试/构建/lint 实际输出 | "应该没问题" |
| **无人值守执行** | 自动路由+自动监督+自动熔断 | 需要持续人工干预 |

---

## 架构总览

```
┌──────────────────────────────────────────────────────────────┐
│                    IronCensor 智能体系统                      │
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
│  │  Layer 3: pre-compact-save.sh    (压缩前状态保存)      │  │
│  │  Layer 4: post-compact-restore.sh (压缩后上下文恢复)   │  │
│  │  Layer 5: post-edit-audit.sh     (编辑审计+熔断+flock) │  │
│  │  Layer 6: verify-before-stop.sh  (完成前四项检查)      │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 行为指令层 (CLAUDE.md) ──────────────────────────────┐  │
│  │  Layer 7: 智能操作系统 v1                               │  │
│  │  ├─ 七阶段认知循环 (感知→思考→规划→执行→验证→反思→进化)│  │
│  │  ├─ 三省六部治理框架 (决策/审核/执行 + 封驳机制)       │  │
│  │  ├─ 决策树路由 (文件数×依赖×风险 → 三级执行路径)       │  │
│  │  └─ 四层自我学习模型 (修复审计→全局审计→深度反省→举一反三)│ │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ 记忆持久层 ──────────────────────────────────────────┐  │
│  │  MEMORY.md (核心索引) + recurring-patterns.md (模式库) │  │
│  │  compact-state.md (压缩快照) + edit-audit.log (审计)   │  │
│  │  hook-stats.jsonl (拦截统计)                           │  │
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

## 六大革新亮点

### 1. 七阶段认知循环 — 从"执行器"到"工程师"

```
感知 → 思考 → 规划 → 执行 → 验证 → 反思 → 进化
 │       │       │       │       │       │       │
 │       │       │       │       │       │       └─ 纠正升级链:
 │       │       │       │       │       │          1次→记录, 2次→规则, 3次→自动化
 │       │       │       │       │       └─ 模式检测 + 举一反三
 │       │       │       │       └─ 必须提供实际测试/构建输出
 │       │       │       └─ 边做边测 + 每3步汇报 + 失败2次换策略
 │       │       └─ 决策树自动评估 → 路由执行路径
 │       └─ 主动调用 Agent/Skill（不等用户指定）
 └─ 意图识别 + 上下文感知 + 记忆唤醒 + 风险预判
```

每个任务不再是简单的"收到→执行→完成"，而是经历完整的认知闭环。AI 会主动感知风险、调用专业工具分析、制定科学计划、边做边验证，并在完成后反思和进化。

### 2. 八层纵深防御 — 硬安全保障

| 层级 | 组件 | 类型 | 功能 |
|------|------|------|------|
| Layer 0 | settings.json deny | 硬拦截 | 24 条规则：rm -rf、mkfs、dd、chmod 777、SSH 密钥、hooks 目录保护、sudo、eval、force push、curl\|bash |
| Layer 1 | safety-guard.sh | 硬拦截 | 五层检测：元命令包装器 → Base64/heredoc/xargs 绕过 → L4 绝对禁止 → L3 高风险 → 凭证泄露；规则外部化到 `rules/dangerous-commands.txt` |
| Layer 2 | sensitive-filter.sh | 硬拦截 | 24 种敏感信息模式：API Key/Token/密码/私钥/JWT/云凭证/数据库连接；规则外部化到 `rules/sensitive-patterns.txt` |
| Layer 3 | pre-compact-save.sh | 辅助 | 压缩前自动保存 Git 状态 + 工作目录快照 |
| Layer 4 | post-compact-restore.sh | 辅助 | 压缩后注入上下文 + 强制 7 步恢复检查列表 |
| Layer 5 | post-edit-audit.sh | 辅助 | 编辑审计日志 + 熔断计数检测（5 次预警/8 次硬阻止）+ flock 并发保护 |
| Layer 6 | verify-before-stop.sh | 辅助 | 完成前 4 项检查：未提交/TODO/反复编辑/反思证据 |
| Layer 7 | CLAUDE.md | 软约束 | L1-L4 安全分级 + 认知循环 + 三省六部治理 |

**设计理念**: 前三层为硬拦截（exit 2），构成安全核心，AI **无法绕过**；后四层与前三层有意功能重叠，形成**纵深冗余**。

### 3. 三省六部治理框架 — 权力制衡

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

### 4. 四层自我学习模型 — 从错误中进化

```
Layer 1: 修复即审计     → 每修一个 bug，在同文件/同模块搜索同类问题
Layer 2: 全局审计       → 同一模式 ≥2次 → Grep 全项目扫描 + 防御规则
Layer 3: 深度反省       → 同一模式 ≥3次 → 根因链分析 + 规则加固 + 提议自动化
Layer 4: 举一反三       → 类比推断 + 跨项目迁移 + 预防性建议
```

**纠正升级链**: 被用户纠正 1 次→记录到 `recurring-patterns.md`；2 次→升级为 CLAUDE.md 禁止事项；3 次→必须提议创建自动化检测（hook/lint/test）。

### 5. 智能决策树路由 — 科学任务分配

```
IF 文件数 ≤ 2 AND 无外部依赖 AND 非安全/架构变更:
  → 简单路径 (直接执行 + 自检)
ELIF 文件数 ≤ 10 AND 无架构变更:
  → 中等路径 (plan → executor → reviewer → verifier)
ELSE:
  → 复杂路径 (ralplan → team → 全套审核 → verifier)
```

### 6. 上下文压缩恢复 — 永不丢失进度

当 Claude Code 的上下文窗口被压缩时：
- **压缩前**: `pre-compact-save.sh` 自动保存 Git 状态 + 工作目录到 `compact-state.md`
- **压缩后**: `post-compact-restore.sh` 注入上下文 + 强制执行 7 步恢复检查列表
- **记忆层**: `MEMORY.md` 核心索引 + `recurring-patterns.md` 模式库持久保存

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
│   ├── hooks.json                      # Hook 路由表（7 个生命周期事件）
│   ├── CLAUDE.md                       # 核心行为指令（智能操作系统 v1）
│   └── env.sh                          # 统一路径/阈值配置（所有 Hook 共用）
├── rules/
│   ├── dangerous-commands.txt          # 危险命令正则规则集（26 条，动态加载）
│   └── sensitive-patterns.txt          # 敏感信息检测规则集（24 种，动态加载）
├── hooks/
│   ├── safety-guard.sh                 # Bash 命令安全防护 (exit 2 拦截)
│   ├── sensitive-filter.sh             # 敏感信息过滤 (exit 2 拦截)
│   ├── pre-compact-save.sh             # 压缩前状态保存
│   ├── post-compact-restore.sh         # 压缩后上下文恢复
│   ├── post-edit-audit.sh              # 编辑审计 + 熔断检测 + flock 并发保护
│   ├── verify-before-stop.sh           # 完成前四项检查
│   └── macos-notify.sh                 # macOS 桌面通知
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
git clone https://github.com/tangdan2204/ironcensor.git
cd ironcensor
chmod +x install.sh
./install.sh
```

### 手动安装

```bash
# 1. 创建目录
mkdir -p ~/.claude/hooks ~/.claude/logs ~/.claude/rules ~/.claude/configs

# 2. 部署配置
cp configs/settings.json ~/.claude/settings.json
cp configs/hooks.json ~/.claude/hooks/hooks.json
cp configs/CLAUDE.md ~/.claude/CLAUDE.md
cp configs/env.sh ~/.claude/configs/env.sh

# 3. 部署 Hook 脚本
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# 4. 部署规则文件（安全规则外部化）
cp rules/*.txt ~/.claude/rules/

# 5. 部署记忆文件
mkdir -p ~/.claude/projects/-Users-$(whoami)/memory
cp memory/*.md ~/.claude/projects/-Users-$(whoami)/memory/

# 6. 验证
claude  # 启动 Claude Code，观察认知循环是否激活
```

### 安装后验证

```bash
# 验证 JSON 配置
cat ~/.claude/settings.json | jq . > /dev/null && echo "✅ settings.json"
cat ~/.claude/hooks/hooks.json | jq . > /dev/null && echo "✅ hooks.json"

# 验证脚本权限
ls -la ~/.claude/hooks/*.sh

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

**装了本配置的 Claude Code：**
```
用户: "修复 /api/users 接口的 500 错误"
Claude:
  [感知] 读取 recurring-patterns.md → 发现 API 层过去出现过 P003 模式
  [思考] 调用 explore agent 定位所有相关文件 + debugger 分析根因
  [规划] "涉及 3 个文件，走中等路径" → 向用户展示计划
  [执行] executor 修复 + 边改边跑测试 → quality-reviewer 审查
  [验证] ✅ npm test 通过 ✅ tsc 无报错 ✅ reviewer 无阻塞意见
  [反思] Grep 全项目扫描 → 发现 /api/orders 有同类问题 → 一并修复
  [进化] 写入 recurring-patterns.md + 知识图谱，下次自动预警
```

### 场景二：重构认证模块

**普通 Claude Code：**
```
用户: "重构认证模块"
Claude: 直接开始大改 → 改了 15 个文件 → 构建失败 → 反复修补 → 越改越乱
     → 用户发现 SSH 密钥被意外暴露在日志中 → 安全事故
```

**装了本配置的 Claude Code：**
```
用户: "重构认证模块"
Claude:
  [规划] >10 文件 → 复杂路径 → ralplan 共识规划
         → planner + architect + critic 三方审核计划
         → 预演验证: executor 干跑 + debugger 预判风险
  [执行] 并行调度: executor(核心逻辑) ∥ test-engineer(测试) ∥ security-reviewer(安全)
         → 每 3 步汇报进度 → 第 5 步发现潜在密钥泄露
         → sensitive-filter.sh 硬拦截 (exit 2) → 阻止写入
         → security-reviewer 建议增加密钥脱敏层
  [验证] 全量测试 + 构建 + ReACT 深度审查（5 轮自主检查）
  [反思] Agent 采访 → executor/debugger/test-engineer 各自反馈
         → 发现测试覆盖盲区 → 补充边界测试
```

### 场景三：上下文窗口被压缩

**普通 Claude Code：**
```
[压缩发生] → 之前的工作全部遗忘 → 用户: "继续刚才的任务"
Claude: "抱歉，我不记得之前在做什么了，请重新说明"
```

**装了本配置的 Claude Code：**
```
[压缩前] pre-compact-save.sh 自动保存 Git 状态 + 任务进度到 compact-state.md
[压缩后] post-compact-restore.sh 注入恢复上下文
Claude: "检测到压缩恢复，执行 7 步恢复检查列表..."
  → 读取 notepad → 读取 project_memory → 读取 MEMORY.md
  → 恢复 Git 分支状态 → 确认任务进度
  → "已恢复上下文。上次完成到第 3 步（共 5 步），继续执行第 4 步..."
```

---

## 效果对比

| 指标 | 改善前 | 改善后 |
|------|--------|--------|
| 同类 bug 重复出现 | 无追踪机制 | 四层学习模型，递减至消除 |
| 完成声明可信度 | "应该没问题" | 必须附带测试/构建实际输出 |
| 危险操作防护 | 仅靠提示词 | 八层纵深防御（3 层硬拦截） |
| 上下文压缩后恢复 | 从零开始 | 自动恢复 Git 状态 + 任务进度 |
| 任务规划质量 | 随机 | 决策树自动评估 + 路由 |
| 错误自我修正 | 被动等待纠正 | 主动检测 + 升级 + 自动化 |
| 治理结构 | 无 | 三省六部制衡 + 封驳机制 |
| 编辑异常检测 | 无 | 熔断计数（5 次预警/8 次警告） |
| Agent 调用失败 | 直接放弃 | 三级容错降级（正常→重试→规则兜底） |
| 代码审查深度 | 固定清单 | ReACT 自主审查（最多 5 轮推理-行动循环） |
| 并行执行效率 | 串行逐步 | 并行维度调度（executor ∥ test ∥ writer ∥ security） |
| 任务经验积累 | 每次从零 | 知识图谱自动回写（实体+关系+语义搜索） |

---

## 设计哲学

### 纯配置驱动

本项目**不修改任何 Claude Code 源代码**，完全通过官方支持的配置机制实现：

- `settings.json` — 权限控制
- `hooks/` — 生命周期钩子
- `CLAUDE.md` — 行为指令
- `memory/` — 持久记忆

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
