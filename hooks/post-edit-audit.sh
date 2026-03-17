#!/bin/bash
# PostToolUse Hook - 编辑后审计日志（JSONL 结构化格式）+ 熔断计数检测
# 位置: ~/.claude/hooks/post-edit-audit.sh
# 触发: PostToolUse (matcher: Write|Edit)
# 机制: 以 JSONL 格式记录所有源代码编辑，按 session 分组检测熔断
# 输出格式: {"ts":"...","tool":"...","file":"...","session":"...","cumulative_edits":N}
# 配置来源: configs/env.sh (统一阈值)
# 并发保护: flock 防止多实例同时写入

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
SESSION=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

# 空文件路径则跳过
if [ -z "$FILE" ]; then
  exit 0
fi

# 只记录源代码和配置文件的编辑
if [[ "$FILE" =~ \.(ts|tsx|js|jsx|py|go|rs|java|vue|svelte|json|yaml|yml|toml|sh|md)$ ]]; then

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

  # 使用统一配置或默认值
  LOG_DIR="${LOG_DIR:-$HOME/.claude/logs}"
  mkdir -p "$LOG_DIR"
  LOG_FILE="${EDIT_AUDIT_LOG:-$LOG_DIR/edit-audit.log}"
  WARN_THRESHOLD="${CIRCUIT_BREAKER_WARN:-5}"
  BLOCK_THRESHOLD="${CIRCUIT_BREAKER_BLOCK:-8}"
  LOOKBACK="${CIRCUIT_BREAKER_LOOKBACK:-30}"
  MAX_LINES="${AUDIT_LOG_MAX_LINES:-500}"
  RETAIN_LINES="${AUDIT_LOG_RETAIN_LINES:-200}"

  # ============================================================
  # flock 并发保护: 使用文件锁防止多实例同时写入
  # ============================================================
  LOCK_FILE="${LOG_FILE}.lock"

  (
    # 获取排他锁（等待最多 5 秒）
    if command -v flock &>/dev/null; then
      flock -w 5 200 2>/dev/null || true
    fi

    # ============================================================
    # 熔断计数: 先统计，再写入（确保当前编辑也被计入）
    # ============================================================
    RECENT_EDITS=1
    if [ -f "$LOG_FILE" ]; then
      # 统计最近 N 条记录中同一文件的编辑次数
      RECENT_EDITS=$(( $(tail -"$LOOKBACK" "$LOG_FILE" | grep -c "\"file\":\"$FILE\"" || true) + 1 ))
    fi

    # 追加 JSONL 格式审计日志
    echo "{\"ts\":\"$TIMESTAMP\",\"tool\":\"$TOOL\",\"file\":\"$FILE\",\"session\":\"$SESSION\",\"cumulative_edits\":$RECENT_EDITS}" >> "$LOG_FILE"

    # ============================================================
    # 熔断检测
    # ============================================================
    if [ "$RECENT_EDITS" -ge "$BLOCK_THRESHOLD" ]; then
      echo "[IronCensor] 🔴 熔断硬阻止: $FILE 已被编辑 ${RECENT_EDITS} 次（近${LOOKBACK}条记录内），强制暂停" >&2
      echo "必须: 1)检查是否陷入 fix 循环 2)启动降级协议 Level 3 3)请求用户介入" >&2
      exit 2
    elif [ "$RECENT_EDITS" -ge "$WARN_THRESHOLD" ]; then
      echo "[IronCensor] ⚠️ 熔断预警: $FILE 已被编辑 ${RECENT_EDITS} 次（近${LOOKBACK}条记录内），注意是否在反复修改" >&2
    fi

    # 日志轮转: 超过最大行数时截断
    if [ -f "$LOG_FILE" ]; then
      LINE_COUNT=$(wc -l < "$LOG_FILE" | tr -d ' ')
      if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
        tail -"$RETAIN_LINES" "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
      fi
    fi

    # ============================================================
    # task-buffer.json 新鲜度检查: 每 N 次编辑提醒外化状态
    # ============================================================
    CHECK_INTERVAL="${TASK_BUFFER_CHECK_INTERVAL:-10}"
    STALE_MINUTES="${TASK_BUFFER_STALE_MINUTES:-5}"
    CWD_DIR=$(echo "$INPUT" | jq -r '.cwd // "."' 2>/dev/null)
    TOTAL_EDITS=$(wc -l < "$LOG_FILE" 2>/dev/null | tr -d ' ')

    if [ $((TOTAL_EDITS % CHECK_INTERVAL)) -eq 0 ] && [ "$TOTAL_EDITS" -gt 0 ]; then
      TASK_BUFFER_FILE="${CWD_DIR}/${TASK_BUFFER_PATH:-.omc/state/task-buffer.json}"
      if [ ! -f "$TASK_BUFFER_FILE" ]; then
        # 自动初始化 task-buffer.json（解决"4个hook读取但0个hook写入"的问题）
        TASK_BUFFER_DIR=$(dirname "$TASK_BUFFER_FILE")
        if mkdir -p "$TASK_BUFFER_DIR" 2>/dev/null; then
          cat > "$TASK_BUFFER_FILE" << TEOF
{
  "task": "（待AI更新）",
  "progress": "进行中",
  "blocked": null,
  "decisions": [],
  "files_changed": ["$FILE"],
  "next_step": "（待AI更新）",
  "created_by": "post-edit-audit.sh",
  "created_at": "$TIMESTAMP"
}
TEOF
          echo "[IronCensor] 💡 已自动创建 task-buffer.json。请在执行阶段更新任务目标、进度和决策，以确保压缩恢复质量。" >&2
        fi
      elif [ "$(find "$TASK_BUFFER_FILE" -mmin +"$STALE_MINUTES" 2>/dev/null)" ]; then
        echo "[IronCensor] 💡 task-buffer.json 已超过${STALE_MINUTES}分钟未更新。请刷新任务状态以确保压缩恢复质量。" >&2
      fi
    fi

  ) 200>"$LOCK_FILE"
fi

exit 0
