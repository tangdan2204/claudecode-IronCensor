#!/bin/bash
# SessionStart Hook - 学习趋势注入器
# 位置: ~/.claude/hooks/learning-trend-injector.sh
# 触发: SessionStart
# 机制: 分析 recurring-patterns.md 和最近 session summaries，注入学习趋势警告
# 目的: 让 AI 在会话开始时就感知到哪些模式是高频的、哪些区域需要特别注意

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

PATTERNS_FILE="$HOME/.claude/projects/-Users-$(whoami)/memory/recurring-patterns.md"
HIGH_FREQ="${LEARNING_TREND_HIGH_FREQ:-3}"
SESSION_CHECK_COUNT="${LEARNING_TREND_SESSION_COUNT:-5}"

WARNINGS=""

# ============================================================
# 1. 高频模式警告
# ============================================================
if [ -f "$PATTERNS_FILE" ]; then
  # 提取出现次数 >= 高频阈值的活跃模式
  # 格式: "- 出现次数: N" 在 "### [PXXX]" 之后
  HIGH_FREQ_PATTERNS=$(awk -v threshold="$HIGH_FREQ" '
    /^### \[P[0-9]+\]/ { pattern_name = $0; sub(/^### /, "", pattern_name) }
    /^\- 出现次数:/ {
      count = $NF + 0
      if (count >= threshold) {
        gsub(/^### /, "", pattern_name)
        print pattern_name "(" count "次)"
      }
    }
    /^\- 状态: 已根治|^\- 状态: 已归档/ { pattern_name = "" }
  ' "$PATTERNS_FILE" 2>/dev/null || true)

  if [ -n "$HIGH_FREQ_PATTERNS" ]; then
    WARNINGS="${WARNINGS}⚠️ 高频模式警告: ${HIGH_FREQ_PATTERNS}. "
  fi

  # 统计总活跃模式数
  TOTAL_ACTIVE=$(grep -c '^\- 状态: 活跃' "$PATTERNS_FILE" 2>/dev/null || echo "0")
  if [ "$TOTAL_ACTIVE" -gt 0 ]; then
    WARNINGS="${WARNINGS}活跃模式${TOTAL_ACTIVE}个. "
  fi
fi

# ============================================================
# 2. 最近会话的安全拦截趋势
# ============================================================
STATS_LOG="${HOOK_STATS_LOG:-$HOME/.claude/logs/hook-stats.jsonl}"
if [ -f "$STATS_LOG" ]; then
  RECENT_BLOCKS=$(tail -100 "$STATS_LOG" | grep -c '"action":"block"' 2>/dev/null || echo "0")
  if [ "$RECENT_BLOCKS" -gt 5 ]; then
    WARNINGS="${WARNINGS}🛡️ 近期安全拦截${RECENT_BLOCKS}次(偏高). "
  fi
fi

# ============================================================
# 3. 最近 session summary 中的热点文件
# ============================================================
SESSION_DIR="${CWD}/${SESSION_SUMMARY_DIR:-.omc/state/sessions}"
if [ -d "$SESSION_DIR" ]; then
  # 检查最近 N 个 session summary 中反复出现的文件
  RECENT_SUMMARIES=$(ls -t "$SESSION_DIR"/session-*.md 2>/dev/null | head -"$SESSION_CHECK_COUNT")
  if [ -n "$RECENT_SUMMARIES" ]; then
    # 提取各 session 中编辑过的文件，找出跨会话反复编辑的
    CROSS_SESSION_HOT=$(echo "$RECENT_SUMMARIES" | xargs grep -h '^\s*[0-9]' 2>/dev/null |
      awk '{print $NF}' | sort | uniq -c | sort -rn |
      awk '$1 >= 2 {print $2 "(" $1 "次会话)"}' | head -3 || true)
    if [ -n "$CROSS_SESSION_HOT" ]; then
      WARNINGS="${WARNINGS}🔥 跨会话热点文件: ${CROSS_SESSION_HOT}. "
    fi
  fi
fi

# ============================================================
# 4. edit-audit.log 中的反复修改趋势
# ============================================================
AUDIT_LOG="${EDIT_AUDIT_LOG:-$HOME/.claude/logs/edit-audit.log}"
if [ -f "$AUDIT_LOG" ]; then
  # 检查最近 100 条记录中编辑次数最多的文件
  TOP_EDITED=$(tail -100 "$AUDIT_LOG" | jq -r '.file // empty' 2>/dev/null |
    grep -v '^$' | sort | uniq -c | sort -rn | head -1 |
    awk '$1 >= 5 {print $2 "(" $1 "次)"}' || true)
  if [ -n "$TOP_EDITED" ]; then
    WARNINGS="${WARNINGS}📊 高频编辑文件: ${TOP_EDITED}. "
  fi
fi

# ============================================================
# 输出学习趋势（仅在有警告时输出）
# ============================================================
if [ -n "$WARNINGS" ]; then
  echo "[IronCensor] 📈 学习趋势: ${WARNINGS}请在规划阶段特别关注这些区域。"
fi

exit 0
