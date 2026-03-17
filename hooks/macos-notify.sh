#!/bin/bash
# Notification Hook - macOS 桌面通知
# 位置: ~/.claude/hooks/macos-notify.sh
# 触发: Notification (matcher: idle_prompt|permission_prompt)

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
TYPE=$(echo "$INPUT" | jq -r '.type // "unknown"' 2>/dev/null)

case "$TYPE" in
  idle_prompt)
    osascript -e 'display notification "任务已完成，等待你的指示" with title "IronCensor · Claude Code" sound name "Glass"' 2>/dev/null
    ;;
  permission_prompt)
    osascript -e 'display notification "需要你的权限确认" with title "IronCensor · Claude Code" sound name "Ping"' 2>/dev/null
    ;;
  *)
    osascript -e 'display notification "有新的通知" with title "IronCensor · Claude Code"' 2>/dev/null
    ;;
esac

exit 0
