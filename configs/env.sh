#!/bin/bash
# IronCensor - 统一环境变量
# 所有 hook 脚本通过 source 加载此文件
# 修改此处即可全局生效，无需逐个修改脚本

# ============================================================
# 路径配置
# ============================================================

# 日志目录
export LOG_DIR="${HOME}/.claude/logs"

# 规则文件目录（相对于项目根，安装后为绝对路径）
export RULES_DIR="${RULES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/rules}"

# Hook 拦截统计日志
export HOOK_STATS_LOG="${LOG_DIR}/hook-stats.jsonl"

# 编辑审计日志
export EDIT_AUDIT_LOG="${LOG_DIR}/edit-audit.log"

# 记忆文件基础路径
export MEMORY_BASE="${HOME}/.claude/projects"

# compact 状态保存路径
export COMPACT_STATE_DIR="${HOME}/.claude/compact-state"

# ============================================================
# 熔断阈值配置
# ============================================================

# 同文件编辑次数 - 预警阈值
export CIRCUIT_BREAKER_WARN=5

# 同文件编辑次数 - 硬阻止阈值
export CIRCUIT_BREAKER_BLOCK=8

# 熔断检测的回溯记录数
export CIRCUIT_BREAKER_LOOKBACK=30

# ============================================================
# 日志轮转配置
# ============================================================

# 审计日志最大行数（超过则触发轮转）
export AUDIT_LOG_MAX_LINES=500

# 轮转后保留行数
export AUDIT_LOG_RETAIN_LINES=200

# Hook 统计日志最大行数
export STATS_LOG_MAX_LINES=1000

# Hook 统计日志轮转后保留行数
export STATS_LOG_RETAIN_LINES=500

# ============================================================
# verify-before-stop 配置
# ============================================================

# 热点文件检测阈值（最近 N 条记录中同文件编辑 >= 此值视为热点）
export HOT_FILE_THRESHOLD=5

# 热点文件检测回溯条数
export HOT_FILE_LOOKBACK=20

# recurring-patterns.md 更新超时（分钟）
export PATTERNS_UPDATE_TIMEOUT=60

# ============================================================
# 敏感信息检测配置
# ============================================================

# 监控的敏感目录模式（正则，用于 sensitive-filter.sh）
export SENSITIVE_DIR_PATTERN='\.claude/.*memory|\.claude/.*CLAUDE|\.omc/|\.env$'

# ============================================================
# 自我进化数据路径
# ============================================================

# 任务缓冲区（AI 内部状态外化通道，hook 可读取验证）
export TASK_BUFFER_PATH=".omc/state/task-buffer.json"

# Agent 自省日志（记录 Agent 输出中的自省字段）
export AGENT_INSIGHTS_LOG="${LOG_DIR}/agent-insights.jsonl"

# 会话摘要目录（跨会话温记忆）
export SESSION_SUMMARY_DIR=".omc/state/sessions"

# ============================================================
# 自我进化硬化配置
# ============================================================

# transcript 提取：从 .jsonl 提取的最大文件路径数
export TRANSCRIPT_MAX_FILES=20

# transcript 提取：从 .jsonl 提取的最大命令数
export TRANSCRIPT_MAX_COMMANDS=10

# task-buffer 新鲜度检查间隔（每 N 次编辑检查一次）
export TASK_BUFFER_CHECK_INTERVAL=10

# task-buffer 过期阈值（分钟）
export TASK_BUFFER_STALE_MINUTES=5

# 反思强制：编辑计数阈值（超过此值且 patterns 未更新则提醒）
export REFLECTION_EDIT_THRESHOLD=3

# bug 修复检测关键词（用于 bugfix-audit-trigger）
export BUGFIX_KEYWORDS="fix|bug|repair|patch|hotfix|resolve|修复|修正|修bug"

# 用户纠正检测关键词（用于 correction-detector）
export CORRECTION_KEYWORDS="不对|不是|错了|别|不要|换一个|重新|wrong|no not|instead|don't|shouldn't|stop"

# 学习趋势警告：高频模式阈值
export LEARNING_TREND_HIGH_FREQ=3

# 学习趋势警告：最近会话检查数
export LEARNING_TREND_SESSION_COUNT=5
