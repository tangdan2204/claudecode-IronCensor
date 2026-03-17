#!/bin/bash
# 记忆保护 Hook - 上下文压缩前自动保存核心状态（自包含恢复文档）
# 位置: ~/.claude/hooks/pre-compact-save.sh
# 触发: PreCompact
# 机制: 从多个数据源提取任务上下文，生成可独立恢复的快照文件
# 数据源: task-buffer.json + edit-audit.log + git + notepad

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

MEMORY_DIR="$HOME/.claude/projects/-Users-$(whoami)/memory"
COMPACT_LOG="$MEMORY_DIR/compact-state.md"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 读取 stdin (PreCompact 事件数据)
INPUT=$(cat 2>/dev/null || echo '{}')
SOURCE=$(echo "$INPUT" | jq -r '.source // .trigger // "auto"' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"' 2>/dev/null)
TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)

mkdir -p "$MEMORY_DIR"

# ============================================================
# 追加模式：多次压缩时保留历史快照（防覆盖）
# 如果已有 compact-state.md，将旧内容归档到 compact-history/
# ============================================================
if [ -f "$COMPACT_LOG" ]; then
  HISTORY_DIR="$MEMORY_DIR/compact-history"
  mkdir -p "$HISTORY_DIR"
  ARCHIVE_NAME="compact-state-$(date '+%Y%m%d-%H%M%S').md"
  mv "$COMPACT_LOG" "$HISTORY_DIR/$ARCHIVE_NAME" 2>/dev/null || true
  # 保留最近 5 个历史快照，清理更早的
  ls -t "$HISTORY_DIR"/compact-state-*.md 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null || true
fi

# ============================================================
# 数据采集函数
# ============================================================

# 采集任务上下文 (从 task-buffer.json)
collect_task_context() {
  local TASK_BUFFER="${TASK_BUFFER_PATH:-$CWD/.omc/state/task-buffer.json}"
  if [ -f "$TASK_BUFFER" ]; then
    local TASK=$(jq -r '.task // "未知"' "$TASK_BUFFER" 2>/dev/null)
    local PROGRESS=$(jq -r '.progress // "未知"' "$TASK_BUFFER" 2>/dev/null)
    local BLOCKED=$(jq -r '.blocked // "无"' "$TASK_BUFFER" 2>/dev/null)
    local NEXT=$(jq -r '.next_step // "未知"' "$TASK_BUFFER" 2>/dev/null)
    local DECISIONS=$(jq -r '(.decisions // [])[] | "  - " + .what + "（原因: " + .why + "）"' "$TASK_BUFFER" 2>/dev/null || echo "  无")

    cat << TASK_EOF
## 任务上下文
- **目标**: $TASK
- **进度**: $PROGRESS
- **阻塞**: $BLOCKED
- **下一步**: $NEXT

### 关键决策
$DECISIONS
TASK_EOF
  else
    echo "## 任务上下文"
    echo "（无 task-buffer.json，任务上下文不可用）"
  fi
}

# 采集本次会话编辑的文件 (从 edit-audit.log)
collect_session_edits() {
  local AUDIT_LOG="${EDIT_AUDIT_LOG:-$HOME/.claude/logs/edit-audit.log}"
  echo "## 本次会话编辑的文件"
  if [ -f "$AUDIT_LOG" ]; then
    # 提取最近 30 条记录中的文件，去重计数
    local FILES=$(tail -30 "$AUDIT_LOG" | jq -r '.file // empty' 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -rn | head -15)
    if [ -n "$FILES" ]; then
      echo '```'
      echo "$FILES"
      echo '```'
    else
      echo "（审计日志中无最近编辑记录）"
    fi
  else
    echo "（无 edit-audit.log）"
  fi
}

# 采集 Git 状态
collect_git_state() {
  echo "## Git 状态"
  if cd "$CWD" 2>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
    local BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
    local UNCOMMITTED=$(git status --short 2>/dev/null | head -15)
    local RECENT_COMMITS=$(git log --oneline -3 2>/dev/null || echo "无提交历史")

    echo "- **分支**: $BRANCH"
    echo "- **未提交变更**:"
    if [ -n "$UNCOMMITTED" ]; then
      echo '```'
      echo "$UNCOMMITTED"
      echo '```'
    else
      echo "  无"
    fi
    echo "- **最近提交**:"
    echo '```'
    echo "$RECENT_COMMITS"
    echo '```'
  else
    echo "非 git 仓库"
  fi
}

# 采集 OMC 状态
collect_omc_state() {
  local OMC_STATE_DIR="$CWD/.omc/state"
  if [ -d "$OMC_STATE_DIR" ]; then
    echo "## OMC 运行状态"
    # 检查各模式状态文件
    for STATE_FILE in "$OMC_STATE_DIR"/*-state.json; do
      if [ -f "$STATE_FILE" ]; then
        local MODE=$(basename "$STATE_FILE" | sed 's/-state\.json//')
        local STATUS=$(jq -r '.status // .current_phase // "unknown"' "$STATE_FILE" 2>/dev/null)
        echo "- **${MODE}**: ${STATUS}"
      fi
    done
  fi
}

# 采集 Hook 拦截统计
collect_hook_stats() {
  local STATS_LOG="${HOOK_STATS_LOG:-$HOME/.claude/logs/hook-stats.jsonl}"
  if [ -f "$STATS_LOG" ]; then
    local BLOCK_COUNT=$(tail -50 "$STATS_LOG" | grep -c '"action":"block"' 2>/dev/null || echo "0")
    if [ "$BLOCK_COUNT" -gt 0 ]; then
      echo "## 本次会话安全事件"
      echo "- 拦截次数: $BLOCK_COUNT"
      tail -50 "$STATS_LOG" | grep '"action":"block"' | tail -3 | jq -r '"  - " + .hook + ": " + (.reason // "unknown")' 2>/dev/null || true
    fi
  fi
}

# ============================================================
# 从 transcript_path 提取会话关键信息（黄金通道）
# ============================================================
collect_transcript_context() {
  if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
    return
  fi

  local MAX_FILES="${TRANSCRIPT_MAX_FILES:-20}"
  local MAX_CMDS="${TRANSCRIPT_MAX_COMMANDS:-10}"

  echo "## 会话详细上下文（来自 transcript）"
  echo ""

  # 提取工具调用中涉及的文件路径（Read/Edit/Write）
  local TOOL_FILES
  TOOL_FILES=$(jq -r '
    select(.type == "tool_use" or .tool_name != null) |
    .tool_input.file_path // .tool_input.path // .input.file_path // empty
  ' "$TRANSCRIPT_PATH" 2>/dev/null | grep -v '^$' | sort -u | tail -"$MAX_FILES" || true)

  if [ -n "$TOOL_FILES" ]; then
    echo "### 涉及的文件"
    echo '```'
    echo "$TOOL_FILES"
    echo '```'
    echo ""
  fi

  # 提取最近执行的 Bash 命令
  local RECENT_CMDS
  RECENT_CMDS=$(jq -r '
    select(.tool_name == "Bash" or (.type == "tool_use" and .name == "Bash")) |
    .tool_input.command // .input.command // empty
  ' "$TRANSCRIPT_PATH" 2>/dev/null | grep -v '^$' | tail -"$MAX_CMDS" || true)

  if [ -n "$RECENT_CMDS" ]; then
    echo "### 最近执行的命令"
    echo '```bash'
    echo "$RECENT_CMDS"
    echo '```'
    echo ""
  fi

  # 提取 AI 最近的推理摘要（最后 3 条 assistant 消息的前 200 字符）
  local LAST_THOUGHTS
  LAST_THOUGHTS=$(jq -r '
    select(.role == "assistant" and .type == "text") |
    .content[:200] // .text[:200] // empty
  ' "$TRANSCRIPT_PATH" 2>/dev/null | grep -v '^$' | tail -3 || true)

  if [ -n "$LAST_THOUGHTS" ]; then
    echo "### AI 最近推理摘要"
    echo "$LAST_THOUGHTS"
    echo ""
  fi

  # 提取 Agent/Task 调用记录
  local AGENT_CALLS
  AGENT_CALLS=$(jq -r '
    select(.tool_name == "Agent" or (.type == "tool_use" and .name == "Agent")) |
    "- " + (.tool_input.description // .input.description // "unknown agent")
  ' "$TRANSCRIPT_PATH" 2>/dev/null | grep -v '^$' | tail -10 || true)

  if [ -n "$AGENT_CALLS" ]; then
    echo "### Agent 调用记录"
    echo "$AGENT_CALLS"
    echo ""
  fi
}

# ============================================================
# 生成自包含恢复文档
# ============================================================
{
  echo "# 压缩状态快照（自包含恢复文档）"
  echo ""
  echo "> 自动保存于 $TIMESTAMP | 触发: $SOURCE | 会话: $SESSION_ID"
  echo ""
  echo "## 工作目录"
  echo "$CWD"
  echo ""

  collect_task_context
  echo ""

  collect_session_edits
  echo ""

  collect_git_state
  echo ""

  collect_omc_state

  collect_hook_stats
  echo ""

  collect_transcript_context

  echo "## 恢复指令"
  echo ""
  echo "压缩已发生。按以下顺序恢复上下文:"
  echo "1. 读取 MEMORY.md（核心记忆索引）"
  echo "2. 读取 recurring-patterns.md（已知风险模式）"
  echo "3. 读取本文件中「任务上下文」和「关键决策」"
  echo "4. 检查 Git 状态，确认分支和未提交变更"
  echo "5. 继续执行「下一步」中指定的操作"
} > "$COMPACT_LOG"

# 注入上下文到 Claude（stdout 输出会被 Claude 读取）
echo "[IronCensor] ⚠️ 上下文压缩已触发。自包含恢复快照已保存到 compact-state.md。压缩后请先读取 MEMORY.md + compact-state.md 恢复上下文。禁止清空任务状态、用户意图、执行历史。"

exit 0
