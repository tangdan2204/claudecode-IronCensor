#!/bin/bash
# UserPromptSubmit Hook - 用户纠正检测器
# 位置: ~/.claude/hooks/correction-detector.sh
# 触发: PreToolUse (通过 Notification 或 UserPromptSubmit 间接触发)
# 实际部署: Notification hook (matcher 匹配纠正关键词)
# 机制: 检测用户输入是否包含纠正/否定语义，注入进化协议提醒
# 目的: 将"被纠正时立即学习"从软约束升级为 hook 自动提醒

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')

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
# 提取用户消息内容
# ============================================================
# Notification hook 的 message 字段
USER_MSG=$(echo "$INPUT" | jq -r '.message // .content // .text // empty' 2>/dev/null)

if [ -z "$USER_MSG" ]; then
  exit 0
fi

# ============================================================
# 纠正模式检测
# ============================================================
CORRECTION_PATTERN="${CORRECTION_KEYWORDS:-不对|不是|错了|别|不要|换一个|重新|wrong|no not|instead|don't|shouldn't|stop}"

if echo "$USER_MSG" | grep -qiE "$CORRECTION_PATTERN"; then
  # 检测到用户纠正 — 注入被动进化协议
  echo "[IronCensor] 📝 检测到用户纠正信号。被动进化协议激活:" >&2
  echo "  1) 分析纠正根因: 为什么我的输出不符合预期？" >&2
  echo "  2) 检查 recurring-patterns.md: 是否已有匹配模式？有则+1计数" >&2
  echo "  3) 无匹配则新建模式记录（状态=活跃，次数=1）" >&2
  echo "  4) 计数≥2 → 触发全局审计 | 计数≥3 → 触发深度反省+提议自动化" >&2
  echo "  5) 将教训写入 MEMORY.md 或 CLAUDE.md（如为通用教训）" >&2
fi

exit 0
