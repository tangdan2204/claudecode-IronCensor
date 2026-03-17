#!/bin/bash
# Stop Hook - 反思阶段强制执行器
# 位置: ~/.claude/hooks/reflection-enforcer.sh
# 触发: Stop
# 机制: 检查本次会话是否有代码编辑，如果有但 recurring-patterns.md 未更新则提醒
# 目的: 将"每次任务完成后必须反思"从软约束升级为 hook 检测

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
CWD=$(echo "$INPUT" | jq -r '.cwd // "."' 2>/dev/null)

# ============================================================
# 加载统一配置
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/configs/env.sh"
if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

EDIT_THRESHOLD="${REFLECTION_EDIT_THRESHOLD:-3}"
LOG_FILE="${EDIT_AUDIT_LOG:-$HOME/.claude/logs/edit-audit.log}"
PATTERNS_FILE="$HOME/.claude/projects/-Users-$(whoami)/memory/recurring-patterns.md"
PATTERNS_CHECKSUM_FILE="$HOME/.claude/logs/.patterns-checksum"

# ============================================================
# 检查条件: 本次会话有足够的代码编辑
# ============================================================
if [ ! -f "$LOG_FILE" ]; then
  exit 0
fi

# 统计本次会话的编辑次数（近 50 条记录）
SESSION_EDITS=$(tail -50 "$LOG_FILE" | jq -r '.file // empty' 2>/dev/null | grep -v '^$' | wc -l | tr -d ' ')

if [ "$SESSION_EDITS" -lt "$EDIT_THRESHOLD" ]; then
  # 编辑次数太少，不需要强制反思
  exit 0
fi

# ============================================================
# 检查 recurring-patterns.md 是否在本次会话中被更新
# ============================================================
if [ ! -f "$PATTERNS_FILE" ]; then
  echo "[IronCensor] 💡 反思提醒: 本次会话编辑了 ${SESSION_EDITS} 个文件，但 recurring-patterns.md 不存在。请创建模式追踪表并执行反思阶段。" >&2
  exit 0
fi

# 使用 checksum 检测内容是否变化
CURRENT_CHECKSUM=$(md5 -q "$PATTERNS_FILE" 2>/dev/null || md5sum "$PATTERNS_FILE" 2>/dev/null | awk '{print $1}')

if [ -f "$PATTERNS_CHECKSUM_FILE" ]; then
  SAVED_CHECKSUM=$(cat "$PATTERNS_CHECKSUM_FILE" 2>/dev/null)
  if [ "$CURRENT_CHECKSUM" = "$SAVED_CHECKSUM" ]; then
    # 内容未变 — 反思可能未执行
    echo "[IronCensor] 💡 反思提醒: 本次会话编辑了 ${SESSION_EDITS} 个文件，但 recurring-patterns.md 内容未变化。请确认是否已执行反思阶段（模式检测+举一反三）。如果本次任务确实无新模式，可忽略此提醒。" >&2
  fi
fi

# 更新 checksum 供下次对比
echo "$CURRENT_CHECKSUM" > "$PATTERNS_CHECKSUM_FILE" 2>/dev/null || true

# ============================================================
# Agent 自省检查: 如果有 Agent 调用但 agent-insights.jsonl 未更新
# ============================================================
INSIGHTS_LOG="${AGENT_INSIGHTS_LOG:-$HOME/.claude/logs/agent-insights.jsonl}"
INSIGHTS_CHECKSUM_FILE="$HOME/.claude/logs/.insights-checksum"
if [ -f "$INSIGHTS_LOG" ]; then
  INS_CHECKSUM=$(md5 -q "$INSIGHTS_LOG" 2>/dev/null || md5sum "$INSIGHTS_LOG" 2>/dev/null | awk '{print $1}')
  if [ -f "$INSIGHTS_CHECKSUM_FILE" ]; then
    SAVED_INS=$(cat "$INSIGHTS_CHECKSUM_FILE" 2>/dev/null)
    if [ "$INS_CHECKSUM" = "$SAVED_INS" ] && [ "$SESSION_EDITS" -ge 5 ]; then
      echo "[IronCensor] 💡 Agent 自省提醒: 本次会话编辑较多但 agent-insights.jsonl 未更新。如果调用了 Agent，请在反思阶段提取自省字段（biggest_difficulty/workarounds_used/technical_debt_introduced）写入 ${INSIGHTS_LOG}。" >&2
    fi
  fi
  echo "$INS_CHECKSUM" > "$INSIGHTS_CHECKSUM_FILE" 2>/dev/null || true
fi

exit 0
