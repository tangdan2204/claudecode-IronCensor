#!/bin/bash
# 写入安全 Hook - 检测记忆文件中的敏感信息
# 位置: ~/.claude/hooks/sensitive-filter.sh
# 触发: PreToolUse (matcher: Write|Edit)
# 机制: 当写入记忆文件时，检查内容是否含密钥/密码
# 规则来源: rules/sensitive-patterns.txt (外部化) + 内置兜底

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
CONTENT=""

# 检查写入敏感目录的操作（记忆目录 + 项目目录 + 配置文件）
if [[ ! "$FILE_PATH" =~ \.claude/.*memory|\.claude/.*CLAUDE|\.omc/|\.env$ ]]; then
  exit 0
fi

# 提取内容 (Write 有 content, Edit 有 new_string)
if [ "$TOOL_NAME" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty' 2>/dev/null)
elif [ "$TOOL_NAME" = "Edit" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty' 2>/dev/null)
fi

if [ -z "$CONTENT" ]; then
  exit 0
fi

# ============================================================
# 配置: 加载统一环境变量
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/configs/env.sh"
if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

PATTERNS_FILE="${RULES_DIR:-$PROJECT_ROOT/rules}/sensitive-patterns.txt"
STATS_LOG="${HOOK_STATS_LOG:-${HOME}/.claude/logs/hook-stats.jsonl}"

# ============================================================
# 拦截统计
# ============================================================
log_block() {
  local pattern_hint="$1"
  local stats_dir
  stats_dir="$(dirname "$STATS_LOG")"
  mkdir -p "$stats_dir"
  local ts
  ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  echo "{\"ts\":\"$ts\",\"hook\":\"sensitive-filter\",\"file\":\"$FILE_PATH\",\"pattern\":\"$pattern_hint\",\"tool\":\"$TOOL_NAME\"}" >> "$STATS_LOG" 2>/dev/null || true
}

# ============================================================
# 外部规则检测
# ============================================================
check_external_patterns() {
  if [ ! -f "$PATTERNS_FILE" ]; then
    return 1  # 返回非零让调用方降级到内置规则
  fi

  while IFS= read -r pattern; do
    # 跳过注释和空行
    [[ "$pattern" =~ ^#.*$ || -z "$pattern" || "$pattern" =~ ^[[:space:]]*$ ]] && continue

    if echo "$CONTENT" | grep -qEi "$pattern" 2>/dev/null; then
      echo "[IronCensor] ⛔ 安全阻止: 检测到敏感信息（API Key/Token/密码）即将写入记忆文件" >&2
      echo "文件: $FILE_PATH" >&2
      echo "请将敏感信息替换为 [REDACTED] 后重试" >&2
      log_block "$pattern"
      exit 2
    fi
  done < "$PATTERNS_FILE"
}

# ============================================================
# 内置兜底规则（patterns 文件不存在时的最小保护集）
# ============================================================
check_builtin_patterns() {
  local SENSITIVE_PATTERNS=(
    'sk-[a-zA-Z0-9]{20,}'
    'ghp_[a-zA-Z0-9]{36}'
    'gho_[a-zA-Z0-9]{36}'
    'ghs_[a-zA-Z0-9]{36}'
    'glpat-[a-zA-Z0-9\-]{20,}'
    'xox[bpsa]-[a-zA-Z0-9\-]+'
    'AKIA[0-9A-Z]{16}'
    'AIza[0-9A-Za-z_-]{35}'
    'ya29\.[0-9A-Za-z_-]+'
    'npm_[a-zA-Z0-9]{36}'
    'pypi-[a-zA-Z0-9]{60,}'
    'Bearer\s+[a-zA-Z0-9\-._~+/]+=*'
    'password\s*[:=]\s*["\x27][^"\x27]{4,}'
    'secret\s*[:=]\s*["\x27][^"\x27]{4,}'
    'api[_-]?key\s*[:=]\s*["\x27][^"\x27]{8,}'
    '-----BEGIN.*PRIVATE KEY-----'
    'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.'
    'DefaultEndpointsProtocol='
    'AccountKey=[a-zA-Z0-9+/=]{40,}'
  )

  for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if echo "$CONTENT" | grep -qEi "$pattern"; then
      echo "[IronCensor] ⛔ 安全阻止: 检测到敏感信息（API Key/Token/密码）即将写入记忆文件" >&2
      echo "文件: $FILE_PATH" >&2
      echo "请将敏感信息替换为 [REDACTED] 后重试" >&2
      log_block "$pattern"
      exit 2
    fi
  done
}

# ============================================================
# 执行检测: 优先外部规则，降级到内置规则
# ============================================================
if ! check_external_patterns; then
  check_builtin_patterns
fi

exit 0
