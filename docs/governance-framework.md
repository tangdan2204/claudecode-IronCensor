# 三省六部治理框架（完整版）

> 借鉴中国古代三省六部制的权力制衡与专业分工，确保任务从决策到执行全链路有审核。
> 本文档为完整参考，CLAUDE.md 中仅保留 3 行核心约束。

## 三省制衡

| 机构 | Claude Code 等价 | 核心 Agent | 权力边界 |
|------|-----------------|------------|----------|
| 中书省(决策) | 认知规划层 | planner, architect, analyst, explore | 只起草方案，不执行；必须经门下省审核 |
| 门下省(审核) | 审核制衡层 | critic, verifier, reviewers, hooks(exit 2) | 拥有封驳权；可回退到规划阶段 |
| 尚书省(执行) | 执行编排层 | executor, deep-executor, OMC编排 | 只执行已通过方案；结果必须回送门下省验证 |

## 六部专业分工（隶属尚书省）

| 部门 | 职责域 | 对应组件 |
|------|--------|----------|
| 吏部(Agent调度) | Agent选择、Model路由 | 决策树 + model routing |
| 户部(资源管控) | Token预算、上下文管理 | 记忆压缩策略 + notepad |
| 礼部(规范标准) | 编码规范、Git约定 | CLAUDE.md编码规范 + lint/tsc |
| 兵部(安全防御) | 命令拦截、权限控制 | safety-guard.sh + settings.json deny |
| 刑部(审计追踪) | 错误追踪、模式检测 | post-edit-audit.sh + recurring-patterns.md |
| 工部(工程构建) | 构建、测试、部署 | build-fixer + test-engineer + qa-tester |

## 封驳机制（三种形态）

- **硬封驳**: Hook exit 2 → 危险命令/敏感信息泄露时直接阻止
- **软封驳**: Reviewer 阻塞性意见 → 质量/安全/架构问题时回退
- **条件封驳**: 熔断机制触发 → 失败3次/编辑5次时自动暂停

## 御史台（独立监察 — 跨三省的审计体系）

- **台院**: safety-guard.sh + sensitive-filter.sh（实时监察）
- **殿院**: post-edit-audit.sh + edit-audit.log（事后审计）
- **察院**: verify-before-stop.sh + recurring-patterns.md（完成前检查+模式追踪）
