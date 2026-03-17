#!/bin/bash
# SessionStart:compact Hook - 压缩后自动注入恢复上下文（增强版）
# 位置: ~/.claude/hooks/post-compact-restore.sh
# 触发: SessionStart (matcher: compact)
# 机制: 多源采集恢复信息 + 结构化 JSON 注入 + 温记忆桥接
# 数据源: compact-state.md + session summaries + task-buffer.json + git

set -euo pipefail

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

# 读取事件数据
INPUT=$(cat 2>/dev/null || echo '{}')
CWD=$(echo "$INPUT" | jq -r '.cwd // "."' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)

MEMORY_DIR="$HOME/.claude/projects/-Users-$(whoami)/memory"
COMPACT_STATE="$MEMORY_DIR/compact-state.md"
PATTERNS_FILE="$MEMORY_DIR/recurring-patterns.md"

# ============================================================
# 采集恢复信息
# ============================================================
CONTEXT_PARTS=""

# 1. Git 状态
BRANCH="unknown"
DIRTY=0
LAST_COMMIT=""
if cd "$CWD" 2>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  LAST_COMMIT=$(git log --oneline -1 2>/dev/null || echo "无提交")
  DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  CONTEXT_PARTS="分支=$BRANCH, 最近提交=$LAST_COMMIT, 未提交=$DIRTY个文件"
fi

# 2. task-buffer.json 任务状态
TASK_NAME=""
TASK_PROGRESS=""
NEXT_STEP=""
TASK_BUFFER="${TASK_BUFFER_PATH:-$CWD/.omc/state/task-buffer.json}"
if [ -f "$TASK_BUFFER" ]; then
  TASK_NAME=$(jq -r '.task // empty' "$TASK_BUFFER" 2>/dev/null)
  TASK_PROGRESS=$(jq -r '.progress // empty' "$TASK_BUFFER" 2>/dev/null)
  NEXT_STEP=$(jq -r '.next_step // empty' "$TASK_BUFFER" 2>/dev/null)
  if [ -n "$TASK_NAME" ]; then
    CONTEXT_PARTS="${CONTEXT_PARTS:+$CONTEXT_PARTS. }任务=$TASK_NAME($TASK_PROGRESS)"
    if [ -n "$NEXT_STEP" ]; then
      CONTEXT_PARTS="${CONTEXT_PARTS}, 下一步=$NEXT_STEP"
    fi
  fi
fi

# 3. 最近的 session summary（温记忆桥接）
SESSION_DIR="${CWD}/${SESSION_SUMMARY_DIR:-.omc/state/sessions}"
RECENT_SESSION_INFO=""
if [ -d "$SESSION_DIR" ]; then
  # 找到最近的 session summary 文件
  LATEST_SUMMARY=$(ls -t "$SESSION_DIR"/session-*.md 2>/dev/null | head -1)
  if [ -n "$LATEST_SUMMARY" ] && [ -f "$LATEST_SUMMARY" ]; then
    # 提取任务信息和编辑文件
    RECENT_SESSION_INFO=$(head -20 "$LATEST_SUMMARY" 2>/dev/null | grep -E '^\S' | head -5 || true)
    if [ -n "$RECENT_SESSION_INFO" ]; then
      CONTEXT_PARTS="${CONTEXT_PARTS:+$CONTEXT_PARTS. }前次会话摘要可用($(basename "$LATEST_SUMMARY"))"
    fi
  fi
fi

# 4. 活跃模式警告
ACTIVE_PATTERNS=0
if [ -f "$PATTERNS_FILE" ]; then
  ACTIVE_PATTERNS=$(grep -c '^\- 状态: 活跃' "$PATTERNS_FILE" 2>/dev/null || echo "0")
  if [ "$ACTIVE_PATTERNS" -gt 0 ]; then
    CONTEXT_PARTS="${CONTEXT_PARTS:+$CONTEXT_PARTS. }活跃风险模式=${ACTIVE_PATTERNS}个"
  fi
fi

# 5. compact-state.md 可用性
COMPACT_AVAILABLE="false"
if [ -f "$COMPACT_STATE" ]; then
  COMPACT_AVAILABLE="true"
  CONTEXT_PARTS="${CONTEXT_PARTS:+$CONTEXT_PARTS. }compact-state.md可用(含详细恢复信息)"
fi

# ============================================================
# 结构化 JSON 输出（additionalContext 格式）
# ============================================================
RESTORE_MSG="[IronCensor] 🔄 压缩恢复: ${CONTEXT_PARTS}。"
RESTORE_MSG="${RESTORE_MSG} [MUST] 强制恢复步骤(按顺序,禁止跳过):"
RESTORE_MSG="${RESTORE_MSG} 1)读取 MEMORY.md → 核心记忆索引"
RESTORE_MSG="${RESTORE_MSG} 2)读取 recurring-patterns.md → 已知风险模式"

if [ "$COMPACT_AVAILABLE" = "true" ]; then
  RESTORE_MSG="${RESTORE_MSG} 3)读取 compact-state.md → 压缩前完整工作进度和决策"
fi

if [ -n "$TASK_NAME" ]; then
  RESTORE_MSG="${RESTORE_MSG} 4)读取 task-buffer.json → 当前任务详细状态"
fi

RESTORE_MSG="${RESTORE_MSG} 5)git status → 确认分支和变更"

if [ -n "$RECENT_SESSION_INFO" ]; then
  RESTORE_MSG="${RESTORE_MSG} 6)读取最近 session summary → 前次会话教训"
fi

RESTORE_MSG="${RESTORE_MSG}。禁止忽略此恢复流程，禁止从零开始。"

echo "$RESTORE_MSG"
exit 0
