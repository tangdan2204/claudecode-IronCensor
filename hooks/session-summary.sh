#!/bin/bash
# SessionEnd Hook - 会话结束时自动生成摘要（温记忆层）
# 位置: ~/.claude/hooks/session-summary.sh
# 触发: SessionEnd
# 机制: 从 edit-audit.log + task-buffer.json + git 提取会话摘要，写入温记忆

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
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // .sessionId // "unknown"' 2>/dev/null)
CWD=$(echo "$INPUT" | jq -r '.cwd // .directory // "."' 2>/dev/null)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
DATE_SHORT=$(date '+%Y%m%d')

# 会话摘要目录
SUMMARY_DIR="${CWD}/${SESSION_SUMMARY_DIR:-.omc/state/sessions}"
mkdir -p "$SUMMARY_DIR" 2>/dev/null || true

SUMMARY_FILE="$SUMMARY_DIR/session-${DATE_SHORT}-${SESSION_ID:0:8}.md"

# ============================================================
# 采集会话数据
# ============================================================

# 编辑文件统计
AUDIT_LOG="${EDIT_AUDIT_LOG:-$HOME/.claude/logs/edit-audit.log}"
EDIT_SUMMARY="无编辑记录"
if [ -f "$AUDIT_LOG" ]; then
  EDIT_SUMMARY=$(tail -50 "$AUDIT_LOG" | jq -r '.file // empty' 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -rn | head -10 2>/dev/null || echo "无")
fi

# 任务状态
TASK_BUFFER="${TASK_BUFFER_PATH:-$CWD/.omc/state/task-buffer.json}"
TASK_INFO="无任务记录"
if [ -f "$TASK_BUFFER" ]; then
  TASK_NAME=$(jq -r '.task // "未知"' "$TASK_BUFFER" 2>/dev/null)
  TASK_PROGRESS=$(jq -r '.progress // "未知"' "$TASK_BUFFER" 2>/dev/null)
  TASK_INFO="$TASK_NAME ($TASK_PROGRESS)"
fi

# Git 变更
GIT_SUMMARY="非 git 仓库"
if cd "$CWD" 2>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
  COMMITS_TODAY=$(git log --oneline --since="today" 2>/dev/null | head -5 || echo "无")
  UNCOMMITTED=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  GIT_SUMMARY="分支: $BRANCH | 今日提交: $(echo "$COMMITS_TODAY" | wc -l | tr -d ' ')条 | 未提交: ${UNCOMMITTED}个文件"
fi

# Hook 拦截统计
STATS_LOG="${HOOK_STATS_LOG:-$HOME/.claude/logs/hook-stats.jsonl}"
BLOCK_COUNT=0
if [ -f "$STATS_LOG" ]; then
  BLOCK_COUNT=$(tail -100 "$STATS_LOG" | grep -c '"action":"block"' 2>/dev/null || echo "0")
fi

# 模式变更检测
PATTERNS_FILE="$HOME/.claude/projects/-Users-$(whoami)/memory/recurring-patterns.md"
PATTERN_CHANGES="无变更"
if [ -f "$PATTERNS_FILE" ]; then
  # 检查今天是否有模式更新（最近发现日期包含今天）
  TODAY=$(date '+%Y-%m-%d')
  UPDATED_PATTERNS=$(grep -B1 "最近发现: $TODAY" "$PATTERNS_FILE" 2>/dev/null | grep '###' | sed 's/### //' || echo "")
  if [ -n "$UPDATED_PATTERNS" ]; then
    PATTERN_CHANGES="今日更新: $UPDATED_PATTERNS"
  fi
fi

# 关键决策提取（从 task-buffer.json）
DECISIONS_SUMMARY="无决策记录"
if [ -f "$TASK_BUFFER" ]; then
  DECISIONS_SUMMARY=$(jq -r '(.decisions // [])[] | "- " + .what + "（" + .why + "）"' "$TASK_BUFFER" 2>/dev/null | head -5 || echo "无")
fi

# 教训提取（从 edit-audit.log 中检测反复编辑模式）
LESSONS="无特殊教训"
if [ -f "$AUDIT_LOG" ]; then
  # 被编辑 >=3 次的文件 = 可能的 fix 循环，值得记录
  FIX_LOOPS=$(tail -50 "$AUDIT_LOG" | jq -r '.file // empty' 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -rn | awk '$1 >= 3 {print "- " $2 " (编辑" $1 "次，可能存在反复修改)"}' | head -3)
  if [ -n "$FIX_LOOPS" ]; then
    LESSONS="检测到反复编辑模式:\n$FIX_LOOPS"
  fi
fi

# ============================================================
# 生成会话摘要
# ============================================================
cat > "$SUMMARY_FILE" << EOF
# 会话摘要

> 生成时间: $TIMESTAMP | 会话: $SESSION_ID

## 任务
$TASK_INFO

## 关键决策
$DECISIONS_SUMMARY

## 编辑文件 (按次数排序)
\`\`\`
$EDIT_SUMMARY
\`\`\`

## Git 状态
$GIT_SUMMARY

## 安全事件
拦截次数: $BLOCK_COUNT

## 模式追踪
$PATTERN_CHANGES

## 教训与发现
$(echo -e "$LESSONS")

---
> 有效期: 7天 | 类型: 温记忆
EOF

# 清理超过 7 天的旧摘要
find "$SUMMARY_DIR" -name "session-*.md" -mtime +7 -delete 2>/dev/null || true

exit 0
