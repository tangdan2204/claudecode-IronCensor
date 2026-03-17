#!/bin/bash
# IronCensor SessionStart Hook - 启动横幅 + 防御状态摘要
# 位置: ~/.claude/hooks/session-banner.sh
# 触发: SessionStart
# 机制: 输出品牌横幅，统计当前规则数，exit 0 不阻止

set -euo pipefail

# 加载统一配置
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/configs/env.sh"
if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

RULES_DIR="${RULES_DIR:-$PROJECT_ROOT/rules}"

# 统计规则数
DENY_COUNT=24  # settings.json 中硬编码的 deny 规则数
CMD_COUNT=0
PATTERN_COUNT=0

CMD_FILE="$RULES_DIR/dangerous-commands.txt"
if [ -f "$CMD_FILE" ]; then
  CMD_COUNT=$(grep -cvE '^\s*#|^\s*$' "$CMD_FILE" 2>/dev/null || echo "0")
fi

PAT_FILE="$RULES_DIR/sensitive-patterns.txt"
if [ -f "$PAT_FILE" ]; then
  PATTERN_COUNT=$(grep -cvE '^\s*#|^\s*$' "$PAT_FILE" 2>/dev/null || echo "0")
fi

echo "⚔️ IronCensor v1.0 · 铁面御史已就位 | 防御: ${DENY_COUNT}条deny规则 ✅ | ${CMD_COUNT}条命令检测 ✅ | ${PATTERN_COUNT}种信息过滤 ✅"

# ============================================================
# 记忆健康度指标
# ============================================================
MEMORY_DIR="$HOME/.claude/projects/-Users-$(whoami)/memory"
MEMORY_FILE="$MEMORY_DIR/MEMORY.md"
PATTERNS_FILE="$MEMORY_DIR/recurring-patterns.md"

HEALTH_PARTS=""

# 覆盖率：MEMORY.md 非空二级标题数 / 总二级标题数
if [ -f "$MEMORY_FILE" ]; then
  TOTAL_SECTIONS=$(grep -c '^## ' "$MEMORY_FILE" 2>/dev/null || echo "0")
  # 空章节 = 标题后紧跟另一个标题或文件结束
  EMPTY_SECTIONS=$(awk '/^## /{if(prev_is_header)empty++; prev_is_header=1; next} /[^ \t]/{prev_is_header=0} END{if(prev_is_header)empty++; print empty+0}' "$MEMORY_FILE" 2>/dev/null || echo "0")
  if [ "$TOTAL_SECTIONS" -gt 0 ]; then
    NON_EMPTY=$((TOTAL_SECTIONS - EMPTY_SECTIONS))
    COVERAGE=$((NON_EMPTY * 100 / TOTAL_SECTIONS))
    if [ "$COVERAGE" -ge 80 ]; then
      HEALTH_PARTS="覆盖率${COVERAGE}%✅"
    else
      HEALTH_PARTS="覆盖率${COVERAGE}%⚠️"
    fi
  fi
fi

# 新鲜度：MEMORY.md 最后修改距今天数
if [ -f "$MEMORY_FILE" ]; then
  if command -v stat &>/dev/null; then
    LAST_MOD=$(stat -f %m "$MEMORY_FILE" 2>/dev/null || stat -c %Y "$MEMORY_FILE" 2>/dev/null || echo "0")
    NOW=$(date +%s)
    DAYS_AGO=$(( (NOW - LAST_MOD) / 86400 ))
    if [ "$DAYS_AGO" -le 7 ]; then
      HEALTH_PARTS="${HEALTH_PARTS:+$HEALTH_PARTS | }新鲜度${DAYS_AGO}天✅"
    else
      HEALTH_PARTS="${HEALTH_PARTS:+$HEALTH_PARTS | }新鲜度${DAYS_AGO}天⚠️"
    fi
  fi
fi

# 一致性：compact-state 中的分支 vs 当前分支
INPUT=$(cat 2>/dev/null || true)
CWD=$(echo "$INPUT" | jq -r '.cwd // "."' 2>/dev/null || echo ".")
COMPACT_FILE="$MEMORY_DIR/compact-state.md"
if [ -f "$COMPACT_FILE" ] && cd "$CWD" 2>/dev/null && git rev-parse --is-inside-work-tree &>/dev/null; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "")
  COMPACT_BRANCH=$(grep -m1 '分支' "$COMPACT_FILE" 2>/dev/null | sed 's/.*: //' | tr -d '[:space:]' || echo "")
  if [ -n "$CURRENT_BRANCH" ] && [ -n "$COMPACT_BRANCH" ]; then
    if [ "$CURRENT_BRANCH" = "$COMPACT_BRANCH" ]; then
      HEALTH_PARTS="${HEALTH_PARTS:+$HEALTH_PARTS | }一致性✅"
    else
      HEALTH_PARTS="${HEALTH_PARTS:+$HEALTH_PARTS | }一致性⚠️(${COMPACT_BRANCH}→${CURRENT_BRANCH})"
    fi
  fi
fi

# 模式活跃度：活跃模式数
if [ -f "$PATTERNS_FILE" ]; then
  ACTIVE_PATTERNS=$(grep -c '^\- 状态: 活跃' "$PATTERNS_FILE" 2>/dev/null || echo "0")
  HEALTH_PARTS="${HEALTH_PARTS:+$HEALTH_PARTS | }模式${ACTIVE_PATTERNS}个✅"
fi

if [ -n "$HEALTH_PARTS" ]; then
  echo "[IronCensor] 记忆健康: $HEALTH_PARTS"
fi

# ============================================================
# 部署同步检查（P002 防复发）
# ============================================================
# 检查关键 hook 是否与项目源码同步
# 项目路径通过 env.sh 中的 RULES_DIR 推断
PROJECT_HOOKS_DIR="$(dirname "$RULES_DIR")/hooks"
if [ -d "$PROJECT_HOOKS_DIR" ]; then
  OUTDATED_COUNT=0
  OUTDATED_FILES=""
  for src in "$PROJECT_HOOKS_DIR"/*.sh; do
    [ -f "$src" ] || continue
    BASENAME=$(basename "$src")
    INSTALLED="$SCRIPT_DIR/$BASENAME"
    if [ ! -f "$INSTALLED" ]; then
      OUTDATED_COUNT=$((OUTDATED_COUNT + 1))
      OUTDATED_FILES="${OUTDATED_FILES} ${BASENAME}"
    else
      SRC_MD5=$(md5 -q "$src" 2>/dev/null || md5sum "$src" 2>/dev/null | awk '{print $1}')
      DST_MD5=$(md5 -q "$INSTALLED" 2>/dev/null || md5sum "$INSTALLED" 2>/dev/null | awk '{print $1}')
      if [ "$SRC_MD5" != "$DST_MD5" ]; then
        OUTDATED_COUNT=$((OUTDATED_COUNT + 1))
        OUTDATED_FILES="${OUTDATED_FILES} ${BASENAME}"
      fi
    fi
  done
  if [ "$OUTDATED_COUNT" -gt 0 ]; then
    echo "[IronCensor] ⚠️ 部署过时: ${OUTDATED_COUNT}个hook与项目源码不同步(${OUTDATED_FILES})。请运行 install.sh 更新。"
  fi
fi

exit 0
