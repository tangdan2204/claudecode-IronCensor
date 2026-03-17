#!/bin/bash
# 安全防护 Hook - 硬拦截危险 Bash 命令
# 位置: ~/.claude/hooks/safety-guard.sh
# 触发: PreToolUse (matcher: Bash)
# 机制: exit 2 = 阻止执行, exit 0 = 放行
# 规则来源: rules/dangerous-commands.txt (外部化) + 内置兜底

set -euo pipefail

# 读取 stdin JSON
INPUT=$(cat 2>/dev/null || echo '{}')
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# 如果提取不到命令，放行（其他工具可能不是 Bash）
if [ -z "$COMMAND" ]; then
  exit 0
fi

# ============================================================
# 配置: 加载统一环境变量（路径/阈值）
# ============================================================
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_ROOT/configs/env.sh"
if [ -f "$ENV_FILE" ]; then
  # shellcheck source=/dev/null
  source "$ENV_FILE"
fi

# 默认值（env.sh 未加载时的兜底）
RULES_FILE="${RULES_DIR:-$PROJECT_ROOT/rules}/dangerous-commands.txt"
STATS_LOG="${HOOK_STATS_LOG:-${HOME}/.claude/logs/hook-stats.jsonl}"

# ============================================================
# 拦截统计: 记录每次阻止事件
# ============================================================
log_block() {
  local level="$1" label="$2" message="$3"
  local stats_dir
  stats_dir="$(dirname "$STATS_LOG")"
  mkdir -p "$stats_dir"
  local ts
  ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
  echo "{\"ts\":\"$ts\",\"hook\":\"safety-guard\",\"level\":\"$level\",\"label\":\"$label\",\"command\":$(echo "$COMMAND" | jq -Rs .),\"message\":\"$message\"}" >> "$STATS_LOG" 2>/dev/null || true
}

# ============================================================
# 规则引擎: 从外部文件加载规则并逐条匹配
# ============================================================
check_external_rules() {
  if [ ! -f "$RULES_FILE" ]; then
    return 0  # 规则文件不存在，降级到内置规则
  fi

  while IFS='|' read -r level label regex message; do
    # 跳过注释和空行
    [[ "$level" =~ ^#.*$ || -z "$level" ]] && continue

    # 去除首尾空白
    level=$(echo "$level" | tr -d '[:space:]')
    label=$(echo "$label" | tr -d '[:space:]' || true)

    # 反引号规则用 grep -F（固定字符串）
    if [ "$regex" = '`' ]; then
      if echo "$COMMAND" | grep -qF '`'; then
        local icon="⛔"
        [ "$level" = "L3" ] && icon="🔴"
        [ "$level" = "META" ] && icon="⛔"
        echo "[IronCensor] $icon $level 阻止 [$label]: $message" >&2
        echo "命令: $COMMAND" >&2
        log_block "$level" "$label" "$message"
        exit 2
      fi
      continue
    fi

    # 正则匹配
    if echo "$COMMAND" | grep -qEi "$regex" 2>/dev/null; then
      local icon="⛔"
      [ "$level" = "L3" ] && icon="🔴"
      [ "$level" = "META" ] && icon="⛔"
      echo "[IronCensor] $icon $level 阻止 [$label]: $message" >&2
      echo "命令: $COMMAND" >&2
      log_block "$level" "$label" "$message"
      exit 2
    fi
  done < "$RULES_FILE"
}

# ============================================================
# 内置兜底规则（rules 文件不存在时的最小保护集）
# ============================================================
check_builtin_rules() {
  # 元命令包装器
  if echo "$COMMAND" | grep -qEi '(^|\s|;|&&|\|\|)(eval\s|bash\s+-c|sh\s+-c|zsh\s+-c)'; then
    echo "[IronCensor] ⛔ 元命令阻止: 检测到命令包装器(eval/bash -c/sh -c)，需要审查内部命令" >&2
    log_block "META" "元命令包装器" "命令包装器检测"
    exit 2
  fi

  # 脚本语言间接执行
  if echo "$COMMAND" | grep -qEi '(python[23]?\s+-c|ruby\s+-e|perl\s+-e|node\s+-e)\s'; then
    echo "[IronCensor] ⛔ 元命令阻止: 检测到通过脚本语言间接执行命令" >&2
    log_block "META" "脚本语言间接执行" "间接执行检测"
    exit 2
  fi

  # 反引号
  if echo "$COMMAND" | grep -qF '`'; then
    echo "[IronCensor] 🔴 L3 阻止: 检测到反引号命令替换，请使用明确的命令" >&2
    log_block "META" "反引号" "反引号命令替换"
    exit 2
  fi

  # Base64 解码执行
  if echo "$COMMAND" | grep -qEi 'base64\s+(-d|--decode).*\|\s*(ba)?sh'; then
    echo "[IronCensor] ⛔ 元命令阻止: 检测到 Base64 解码后执行" >&2
    log_block "META" "Base64解码执行" "编码绕过检测"
    exit 2
  fi

  # rm -rf / 或家目录
  if echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]*f[a-zA-Z]*\s+|--force\s+)*(\/|~\/|\/Users\/|\$HOME)'; then
    echo "[IronCensor] ⛔ L4 阻止: 检测到对家目录或根目录的删除操作" >&2
    log_block "L4" "删除家/根目录" "危险删除操作"
    exit 2
  fi

  # sudo
  if echo "$COMMAND" | grep -qE '(^|\s|;|&&|\|\|)(sudo|doas)\s'; then
    echo "[IronCensor] 🔴 L3 阻止: sudo/doas 提权操作需用户明确授权" >&2
    log_block "L3" "sudo提权" "提权操作"
    exit 2
  fi

  # git push
  if echo "$COMMAND" | grep -qE 'git\s+push(\s|$)'; then
    echo "[IronCensor] 🔴 L3 阻止: git push 需用户确认后执行" >&2
    log_block "L3" "git push" "代码推送"
    exit 2
  fi

  # git reset --hard
  if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
    echo "[IronCensor] 🔴 L3 阻止: git reset --hard 会丢失未提交更改，需用户确认" >&2
    log_block "L3" "git reset hard" "硬重置"
    exit 2
  fi

  # curl|bash
  if echo "$COMMAND" | grep -qE '(curl|wget)\s+.*\|\s*(ba)?sh'; then
    echo "[IronCensor] ⛔ L4 阻止: 检测到从远程 URL 下载并执行脚本" >&2
    log_block "L4" "远程脚本执行" "curl pipe bash"
    exit 2
  fi

  # mkfs/dd
  if echo "$COMMAND" | grep -qE 'mkfs|fdisk|dd\s+if=.*of=/dev/'; then
    echo "[IronCensor] ⛔ L4 阻止: 检测到磁盘格式化/写入操作" >&2
    log_block "L4" "磁盘格式化" "磁盘操作"
    exit 2
  fi
}

# ============================================================
# 执行规则检查: 优先外部规则，降级到内置规则
# ============================================================
if [ -f "$RULES_FILE" ]; then
  check_external_rules
else
  check_builtin_rules
fi

# ============================================================
# 通过所有检查，放行
# ============================================================
exit 0
