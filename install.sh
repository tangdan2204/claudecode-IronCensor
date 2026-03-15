#!/bin/bash
# IronCensor - 自动安装脚本
# 用法: chmod +x install.sh && ./install.sh

set -euo pipefail

echo "=========================================="
echo "  IronCensor - 铁面御史 · 自动安装"
echo "=========================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
USER_NAME=$(whoami)
CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
MEMORY_DIR="$CLAUDE_DIR/projects/-Users-$USER_NAME/memory"

# 检查前置条件
echo "📋 检查前置条件..."

if ! command -v jq &>/dev/null; then
  echo "❌ jq 未安装。请运行: brew install jq"
  exit 1
fi
echo "  ✅ jq 已安装"

if ! command -v claude &>/dev/null; then
  echo "  ⚠️ claude CLI 未找到（可能未在 PATH 中，继续安装）"
else
  echo "  ✅ claude CLI 已安装"
fi

echo ""

# 创建目录
echo "📁 创建目录结构..."
mkdir -p "$HOOKS_DIR"
mkdir -p "$CLAUDE_DIR/logs"
mkdir -p "$MEMORY_DIR"
RULES_DEST="$HOOKS_DIR/../rules"
mkdir -p "$RULES_DEST"
echo "  ✅ 目录已创建"
echo ""

# 备份现有配置
echo "💾 备份现有配置..."
BACKUP_DIR="$CLAUDE_DIR/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f "$CLAUDE_DIR/settings.json" ]; then
  cp "$CLAUDE_DIR/settings.json" "$BACKUP_DIR/"
  echo "  ✅ settings.json 已备份"
fi
if [ -f "$HOOKS_DIR/hooks.json" ]; then
  cp "$HOOKS_DIR/hooks.json" "$BACKUP_DIR/"
  echo "  ✅ hooks.json 已备份"
fi
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/"
  echo "  ✅ CLAUDE.md 已备份"
fi
echo "  📂 备份位置: $BACKUP_DIR"
echo ""

# 部署配置文件
echo "📦 部署配置文件..."

# settings.json - 需要替换用户名
sed "s|/Users/tangdan|/Users/$USER_NAME|g" "$SCRIPT_DIR/configs/settings.json" > "$CLAUDE_DIR/settings.json"
echo "  ✅ settings.json"

# hooks.json - 需要替换用户名
sed "s|/Users/tangdan|/Users/$USER_NAME|g" "$SCRIPT_DIR/configs/hooks.json" > "$HOOKS_DIR/hooks.json"
echo "  ✅ hooks.json"

echo ""

# 部署 Hook 脚本
echo "🔧 部署 Hook 脚本..."
for script in "$SCRIPT_DIR/hooks/"*.sh; do
  if [ -f "$script" ]; then
    BASENAME=$(basename "$script")
    cp "$script" "$HOOKS_DIR/$BASENAME"
    chmod +x "$HOOKS_DIR/$BASENAME"
    echo "  ✅ $BASENAME"
  fi
done
echo ""

# 部署规则文件和统一配置
echo "📐 部署规则文件和配置..."
if [ -d "$SCRIPT_DIR/rules" ]; then
  for rule_file in "$SCRIPT_DIR/rules/"*.txt; do
    if [ -f "$rule_file" ]; then
      BASENAME=$(basename "$rule_file")
      cp "$rule_file" "$RULES_DEST/$BASENAME"
      echo "  ✅ rules/$BASENAME"
    fi
  done
fi
if [ -f "$SCRIPT_DIR/configs/env.sh" ]; then
  # env.sh 放在 hooks 同级的 configs 目录（与项目结构保持一致）
  CONFIGS_DEST="$(dirname "$HOOKS_DIR")/configs"
  mkdir -p "$CONFIGS_DEST"
  cp "$SCRIPT_DIR/configs/env.sh" "$CONFIGS_DEST/env.sh"
  echo "  ✅ configs/env.sh"
fi
echo ""

# 部署记忆文件（不覆盖已有的）
echo "🧠 部署记忆文件..."
for mem_file in "$SCRIPT_DIR/memory/"*.md; do
  if [ -f "$mem_file" ]; then
    BASENAME=$(basename "$mem_file")
    if [ -f "$MEMORY_DIR/$BASENAME" ]; then
      echo "  ⚠️ $BASENAME 已存在，跳过（避免覆盖你的数据）"
    else
      cp "$mem_file" "$MEMORY_DIR/$BASENAME"
      echo "  ✅ $BASENAME"
    fi
  fi
done
echo ""

# CLAUDE.md 提示
echo "📝 CLAUDE.md 处理..."
if [ -f "$CLAUDE_DIR/CLAUDE.md" ]; then
  echo "  ⚠️ CLAUDE.md 已存在。你的自定义内容（OMC 配置等）可能需要保留。"
  echo "  📄 参考模板位置: $SCRIPT_DIR/configs/CLAUDE.md"
  echo "  💡 建议手动将「智能操作系统 v1」等章节合并到现有 CLAUDE.md"
else
  if [ -f "$SCRIPT_DIR/configs/CLAUDE.md" ]; then
    cp "$SCRIPT_DIR/configs/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
    echo "  ✅ CLAUDE.md 已部署"
  else
    echo "  ⚠️ 未找到 CLAUDE.md 模板，请手动创建"
  fi
fi
echo ""

# 验证
echo "🔍 验证安装..."
ERRORS=0

# 验证 JSON 文件
if cat "$CLAUDE_DIR/settings.json" | jq . > /dev/null 2>&1; then
  echo "  ✅ settings.json JSON 有效"
else
  echo "  ❌ settings.json JSON 无效"
  ERRORS=$((ERRORS + 1))
fi

if cat "$HOOKS_DIR/hooks.json" | jq . > /dev/null 2>&1; then
  echo "  ✅ hooks.json JSON 有效"
else
  echo "  ❌ hooks.json JSON 无效"
  ERRORS=$((ERRORS + 1))
fi

# 验证脚本权限
for script in safety-guard.sh sensitive-filter.sh pre-compact-save.sh post-compact-restore.sh post-edit-audit.sh verify-before-stop.sh macos-notify.sh; do
  if [ -x "$HOOKS_DIR/$script" ]; then
    echo "  ✅ $script 有执行权限"
  else
    if [ -f "$HOOKS_DIR/$script" ]; then
      echo "  ❌ $script 缺少执行权限"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

echo ""

if [ "$ERRORS" -eq 0 ]; then
  echo "=========================================="
  echo "  ✅ 安装完成！"
  echo "=========================================="
  echo ""
  echo "下一步："
  echo "  1. 编辑 ~/.claude/settings.json 配置 API 地址"
  echo "  2. 启动 Claude Code: claude"
  echo "  3. 运行 /omc-setup 安装 OMC 多代理编排"
  echo "  4. 测试: 输入一个编程任务，观察七阶段认知循环是否激活"
else
  echo "=========================================="
  echo "  ⚠️ 安装完成，但有 $ERRORS 个问题需要修复"
  echo "=========================================="
fi
