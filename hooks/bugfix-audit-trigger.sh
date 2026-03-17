#!/bin/bash
# PostToolUse:Edit Hook - Bug 修复审计触发器
# 位置: ~/.claude/hooks/bugfix-audit-trigger.sh
# 触发: PostToolUse (matcher: Write|Edit)
# 机制: 检测编辑内容是否为 bug 修复，如果是则注入 L1 审计提醒
# 目的: 将"修复即审计"从软约束升级为 hook 自动提醒

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

# 空文件路径或非源代码文件则跳过
if [ -z "$FILE" ]; then
  exit 0
fi

# 只检查源代码文件（排除配置/文档/记忆文件）
if [[ ! "$FILE" =~ \.(ts|tsx|js|jsx|py|go|rs|java|vue|svelte|c|cpp|rb)$ ]]; then
  exit 0
fi

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

# ============================================================
# Bug 修复检测: 通过编辑内容的上下文关键词判断
# ============================================================
BUGFIX_PATTERN="${BUGFIX_KEYWORDS:-fix|bug|repair|patch|hotfix|resolve|修复|修正|修bug}"

# 检查 tool_input 中是否包含 bug 修复相关内容
# Edit 工具的 old_string/new_string 中检测关键词
# 注意: Edit 工具无 description 字段，仅从 old_string/new_string 和文件名推断
EDIT_CONTEXT=$(echo "$INPUT" | jq -r '
  (.tool_input.old_string // "") + " " +
  (.tool_input.new_string // "") + " " +
  (.tool_input.content // "")
' 2>/dev/null || echo "")

# 同时检查文件名是否暗示修复（如 fix-xxx.ts, bugfix-xxx.py）
FILENAME=$(basename "$FILE")
FULL_CONTEXT="${EDIT_CONTEXT} ${FILENAME}"

# 用 grep 检测是否匹配 bug 修复关键词（不区分大小写）
if echo "$FULL_CONTEXT" | grep -qiE "$BUGFIX_PATTERN"; then
  # 检测到 bug 修复模式 — 注入 L1 审计提醒
  FILENAME=$(basename "$FILE")
  DIRNAME=$(dirname "$FILE")

  echo "[IronCensor] 🔍 检测到 bug 修复（$FILENAME）。L1 修复即审计协议激活:" >&2
  echo "  1) 分类归因: 用一句话总结根因" >&2
  echo "  2) 模式匹配: 对照 recurring-patterns.md 已知模式" >&2
  echo "  3) 同文件审查: 在 $FILENAME 中搜索同类问题" >&2
  echo "  4) 同模块审查: 在 $DIRNAME/ 中搜索同类问题" >&2
  echo "  5) 记录: 更新 recurring-patterns.md" >&2
fi

exit 0
